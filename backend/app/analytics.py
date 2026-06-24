from __future__ import annotations

from collections import Counter
from datetime import date, datetime, timedelta
from math import atan2, cos, log, pi, sin, sqrt
from statistics import mean
from typing import Any

from app.ml.predictor import energy_score, generate_explanation, generate_tip, model_status
from app.repository import get_all_sleep_logs, get_latest_sleep_log, count_user_training_rows

TARGET_SLEEP_HOURS = 8.0


def _parse_date(value: str) -> date:
    return datetime.strptime(value, "%Y-%m-%d").date()


def _sorted_logs_ascending(logs: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return sorted(logs, key=lambda item: (item["log_date"], item["id"]))


def _latest_n_logs(logs: list[dict[str, Any]], limit: int) -> list[dict[str, Any]]:
    # logs arrive newest-first from the DB; reverse to ascending, then take the most recent N.
    return list(reversed(logs))[-limit:] if logs else []


def _preferred_energy(log: dict[str, Any]) -> str | None:
    return log.get("actual_energy_level") or log.get("predicted_energy_level")


def _circular_std_hours(values: list[float]) -> float:
    if len(values) < 2:
        return 0.0

    angles = [(value % 24.0) / 24.0 * 2.0 * pi for value in values]
    sin_mean = mean([sin(angle) for angle in angles])
    cos_mean = mean([cos(angle) for angle in angles])
    resultant = max(1e-9, min(1.0, sqrt((sin_mean * sin_mean) + (cos_mean * cos_mean))))
    circular_std_radians = sqrt(max(0.0, -2.0 * log(resultant)))
    return circular_std_radians * 24.0 / (2.0 * pi)


def sleep_consistency_score(logs: list[dict[str, Any]]) -> int:
    recent = _latest_n_logs(logs, 7)
    if len(recent) < 2:
        return 100 if recent else 0

    bedtime_std = _circular_std_hours([float(item["bedtime_hour"]) for item in recent])
    wake_std = _circular_std_hours([float(item["wake_hour"]) for item in recent])
    score = 100.0 - ((bedtime_std * 22.0) + (wake_std * 18.0))
    return round(max(0.0, min(100.0, score)))


def sleep_debt_this_week(logs: list[dict[str, Any]]) -> float:
    recent = _latest_n_logs(logs, 7)
    debt = sum(max(0.0, TARGET_SLEEP_HOURS - float(item["sleep_hours"])) for item in recent)
    return round(debt, 2)


def current_streak_days(logs: list[dict[str, Any]]) -> int:
    if not logs:
        return 0

    dates = sorted({_parse_date(item["log_date"]) for item in logs}, reverse=True)
    streak = 1
    cursor = dates[0]
    for item_date in dates[1:]:
        if item_date == cursor - timedelta(days=1):
            streak += 1
            cursor = item_date
        else:
            break
    return streak


def _weekly_logs(logs: list[dict[str, Any]]) -> list[dict[str, Any]]:
    if not logs:
        return []

    sorted_logs = _sorted_logs_ascending(logs)
    latest_date = _parse_date(sorted_logs[-1]["log_date"])
    cutoff = latest_date - timedelta(days=6)
    return [item for item in sorted_logs if _parse_date(item["log_date"]) >= cutoff]


def _best_and_worst_days(logs: list[dict[str, Any]]) -> tuple[str | None, str | None]:
    if not logs:
        return None, None

    def score(log: dict[str, Any]) -> tuple[float, float]:
        energy = energy_score(_preferred_energy(log))
        sleep_closeness = -abs(float(log["sleep_hours"]) - TARGET_SLEEP_HOURS)
        return energy, sleep_closeness

    best = max(logs, key=score)
    worst = min(logs, key=score)
    return best["log_date"], worst["log_date"]


def _most_common_energy(logs: list[dict[str, Any]]) -> str | None:
    values = [_preferred_energy(item) for item in logs if _preferred_energy(item)]
    if not values:
        return None
    return Counter(values).most_common(1)[0][0]


def data_quality_warnings(logs: list[dict[str, Any]]) -> list[str]:
    latest = get_latest_sleep_log()
    if not latest:
        return ["Add sleep logs to activate data quality checks."]

    warnings: list[str] = []
    sleep_hours = float(latest["sleep_hours"])
    bedtime = float(latest["bedtime_hour"])
    wake = float(latest["wake_hour"])

    if sleep_hours < 4.5:
        warnings.append("Latest sleep duration is very low; confirm that the value is correct.")
    if sleep_hours > 10.5:
        warnings.append("Latest sleep duration is unusually high; confirm that the value is correct.")
    if 1 <= bedtime <= 5:
        warnings.append("Latest bedtime is very late; the app treats wake time as the next-day wake-up.")
    if bedtime < wake and sleep_hours > 12:
        warnings.append("Bedtime/wake-time pattern looks unusual compared with the sleep duration.")
    if not warnings:
        warnings.append("No critical data quality warnings detected.")

    return warnings


def personalization_level() -> str:
    rows = count_user_training_rows()
    if rows >= 20:
        return "High"
    if rows >= 7:
        return "Medium"
    if rows >= 1:
        return "Low"
    return "Seed only"


def recommendation_for(logs: list[dict[str, Any]]) -> str:
    if not logs:
        return "Add at least one sleep log to receive a recommendation."

    latest = get_latest_sleep_log()
    consistency = sleep_consistency_score(logs)
    debt = sleep_debt_this_week(logs)

    if debt >= 5:
        return "Your weekly sleep debt is high. Try adding 45–60 minutes of sleep for the next few nights."
    if consistency < 65:
        return "Your sleep timing is inconsistent. Keep bedtime and wake time within a stable 45-minute window."
    if latest and float(latest["sleep_hours"]) < 6.5:
        return "Your latest sleep duration is below the target range. Prioritize a slightly earlier bedtime tonight."
    if latest:
        return generate_tip(latest, _preferred_energy(latest) or "Medium")
    return "Keep collecting data so the model can personalize future recommendations."


def weekly_report_payload() -> dict[str, Any]:
    logs = get_all_sleep_logs()
    week = _weekly_logs(logs)
    if not week:
        return {
            "days_count": 0,
            "average_sleep": 0.0,
            "average_mood": 0.0,
            "average_activity": 0.0,
            "most_common_energy": None,
            "best_sleep_day": None,
            "worst_sleep_day": None,
            "sleep_debt": 0.0,
            "streak_days": 0,
        }

    best_day, worst_day = _best_and_worst_days(week)
    return {
        "days_count": len(week),
        "average_sleep": round(mean([float(item["sleep_hours"]) for item in week]), 2),
        "average_mood": round(mean([float(item["mood"]) for item in week]), 2),
        "average_activity": round(mean([float(item["activity_level"]) for item in week]), 2),
        "most_common_energy": _most_common_energy(week),
        "best_sleep_day": best_day,
        "worst_sleep_day": worst_day,
        "sleep_debt": sleep_debt_this_week(logs),
        "streak_days": current_streak_days(logs),
    }


def insights_payload() -> dict[str, Any]:
    logs = get_all_sleep_logs()
    latest = get_latest_sleep_log()
    weekly = weekly_report_payload()

    explanation: list[str] = []
    if latest:
        explanation = generate_explanation(latest, _preferred_energy(latest) or "Medium")

    return {
        "sleep_consistency_score": sleep_consistency_score(logs),
        "sleep_debt_this_week": sleep_debt_this_week(logs),
        "average_sleep": weekly["average_sleep"],
        "average_mood": weekly["average_mood"],
        "average_activity": weekly["average_activity"],
        "most_common_energy": weekly["most_common_energy"],
        "best_sleep_day": weekly["best_sleep_day"],
        "worst_sleep_day": weekly["worst_sleep_day"],
        "streak_days": weekly["streak_days"],
        "personalization_level": personalization_level(),
        "model_status": model_status(),
        "recommendation": recommendation_for(logs),
        "data_quality_warnings": data_quality_warnings(logs),
        "latest_explanation": explanation,
    }
