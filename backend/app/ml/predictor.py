from __future__ import annotations

import csv
import math
from collections import Counter
from datetime import datetime
from typing import Any

from app.config import DATA_DIR, SEED_DATA_PATH, KAGGLE_DATA_PATH, ensure_runtime_files
from app.repository import get_logs_for_training, count_user_training_rows

FEATURE_COLUMNS = ["sleep_hours", "bedtime_hour", "wake_hour", "mood", "activity_level"]
TARGET_COLUMN = "energy_level"
ENERGY_TO_SCORE = {"Low": 1.0, "Medium": 2.0, "High": 3.0}

# Min-max bounds for feature normalization
_BOUNDS = {
    "sleep_hours":    (0.0, 24.0),
    "bedtime_hour":   (0.0, 23.99),
    "wake_hour":      (0.0, 23.99),
    "mood":           (1.0, 5.0),
    "activity_level": (1.0, 5.0),
}

K_NEIGHBORS = 7

# In-memory training data cache — avoids reloading CSV on every prediction
_training_cache: list[dict[str, Any]] | None = None


def _normalize(features: dict[str, Any]) -> list[float]:
    result = []
    for col in FEATURE_COLUMNS:
        lo, hi = _BOUNDS[col]
        val = float(features[col])
        result.append((val - lo) / (hi - lo) if hi > lo else 0.0)
    return result


def _distance(a: list[float], b: list[float]) -> float:
    return math.sqrt(sum((x - y) ** 2 for x, y in zip(a, b)))


def _knn_predict(features: dict[str, Any], training: list[dict[str, Any]]) -> tuple[str, float]:
    if not training:
        return _heuristic_energy_label(features), 0.5

    query = _normalize(features)
    ranked = sorted(
        [(_distance(query, _normalize(row)), row[TARGET_COLUMN]) for row in training],
        key=lambda x: x[0],
    )
    k = min(K_NEIGHBORS, len(ranked))
    top_labels = [label for _, label in ranked[:k]]
    counts = Counter(top_labels)
    best_label, best_count = counts.most_common(1)[0]
    return best_label, round(best_count / k, 3)


def _heuristic_energy_label(features: dict[str, Any]) -> str:
    sleep_hours = float(features.get("sleep_hours", 7.0))
    mood = float(features.get("mood", 3.0))
    activity = float(features.get("activity_level", 3.0))
    bedtime = float(features.get("bedtime_hour", 22.5))
    bedtime_penalty = 1.0 if 1.0 <= bedtime <= 4.0 else 0.0
    score = (sleep_hours * 0.45) + (mood * 0.7) + (activity * 0.35) - bedtime_penalty
    if score < 5.2:
        return "Low"
    if score < 7.2:
        return "Medium"
    return "High"


def _read_csv_rows(path: Any) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    col_map = {
        "Sleep Duration": "sleep_hours", "sleep_hours": "sleep_hours",
        "Bedtime Hour": "bedtime_hour", "bedtime_hour": "bedtime_hour",
        "Wake Hour": "wake_hour", "wake_hour": "wake_hour",
        "Mood": "mood", "mood": "mood",
        "Activity Level": "activity_level",
        "Physical Activity Level": "activity_level",
        "activity_level": "activity_level",
        "Energy Level": "energy_level", "energy_level": "energy_level",
    }
    try:
        with open(path, newline="", encoding="utf-8") as f:
            for raw in csv.DictReader(f):
                mapped: dict[str, Any] = {}
                for src, tgt in col_map.items():
                    if src in raw and tgt not in mapped:
                        mapped[tgt] = raw[src]

                if not all(col in mapped for col in FEATURE_COLUMNS):
                    continue

                if "energy_level" not in mapped:
                    if "Quality of Sleep" in raw:
                        quality = float(raw["Quality of Sleep"]) if raw["Quality of Sleep"] else 5.0
                        mapped["energy_level"] = "Low" if quality <= 4 else ("High" if quality >= 8 else "Medium")
                    else:
                        mapped["energy_level"] = _heuristic_energy_label(mapped)

                if mapped.get("energy_level") not in ("Low", "Medium", "High"):
                    continue

                try:
                    row = {col: float(mapped[col]) for col in FEATURE_COLUMNS}
                    row[TARGET_COLUMN] = mapped[TARGET_COLUMN]
                    rows.append(row)
                except (ValueError, KeyError):
                    continue
    except OSError:
        pass
    return rows


def _build_training_data() -> list[dict[str, Any]]:
    ensure_runtime_files()
    csv_path = KAGGLE_DATA_PATH if KAGGLE_DATA_PATH.exists() else SEED_DATA_PATH
    seed = _read_csv_rows(csv_path)

    user: list[dict[str, Any]] = []
    for r in get_logs_for_training():
        try:
            row = {col: float(r[col]) for col in FEATURE_COLUMNS}
            row[TARGET_COLUMN] = r["actual_energy_level"]
            user.append(row)
        except (ValueError, KeyError):
            continue

    return seed + user


def load_or_train_model() -> list[dict[str, Any]]:
    """Load training data into the in-memory cache (replaces joblib model loading)."""
    global _training_cache
    if _training_cache is None:
        _training_cache = _build_training_data()
    return _training_cache


def train_model() -> list[dict[str, Any]]:
    global _training_cache
    _training_cache = _build_training_data()
    return _training_cache


def retrain_model() -> dict[str, Any]:
    global _training_cache
    seed_count_before = len(_read_csv_rows(
        KAGGLE_DATA_PATH if KAGGLE_DATA_PATH.exists() else SEED_DATA_PATH
    ))
    _training_cache = _build_training_data()
    user_rows = count_user_training_rows()
    return {
        "status": "retrained",
        "message": "Model retrained successfully.",
        "seed_rows": seed_count_before,
        "user_training_rows": user_rows,
        "total_training_rows": len(_training_cache),
        "model_status": model_status(),
    }


def predict_energy(features: dict[str, Any]) -> dict[str, Any]:
    training = load_or_train_model()
    prediction, confidence = _knn_predict(features, training)
    return {
        "prediction": prediction,
        "confidence": confidence,
        "model_status": model_status(),
    }


def model_status() -> str:
    user_rows = count_user_training_rows()
    if user_rows == 0:
        return "initial_seed_model"
    return f"seed_plus_user_data_{user_rows}_labeled_rows"


def energy_score(level: str | None) -> float:
    if not level:
        return 0.0
    return ENERGY_TO_SCORE.get(level, 0.0)


def generate_tip(features: dict[str, Any], prediction: str) -> str:
    sleep_hours = float(features["sleep_hours"])
    bedtime_hour = float(features["bedtime_hour"])
    mood = int(features["mood"])
    activity_level = int(features["activity_level"])

    if sleep_hours < 6:
        return "حاول رفع مدة النوم تدريجيًا إلى 7 ساعات على الأقل خلال الأيام القادمة."
    if bedtime_hour >= 1 and bedtime_hour <= 4:
        return "وقت النوم متأخر جدًا؛ جرّب تقديم موعد النوم 30 دقيقة الليلة."
    if mood <= 2:
        return "المزاج منخفض؛ خفف النشاط قبل النوم واستخدم روتين تهدئة قصير."
    if activity_level <= 2 and prediction != "High":
        return "نشاط خفيف نهارًا قد يساعد على نوم أعمق وطاقة أعلى في اليوم التالي."
    if prediction == "High":
        return "نمطك الحالي جيد؛ حافظ على وقت نوم واستيقاظ ثابتين."
    return "حافظ على روتين نوم ثابت وقلل الشاشات قبل النوم بساعة."


def generate_explanation(features: dict[str, Any], prediction: str) -> list[str]:
    sleep_hours = float(features["sleep_hours"])
    bedtime_hour = float(features["bedtime_hour"])
    mood = int(features["mood"])
    activity_level = int(features["activity_level"])
    reasons: list[str] = []

    if sleep_hours >= 7.5:
        reasons.append("Sleep duration is in a strong range for next-day energy.")
    elif sleep_hours >= 6.5:
        reasons.append("Sleep duration is acceptable but slightly below the ideal target.")
    else:
        reasons.append("Sleep duration is below the recommended target and may reduce energy.")

    if 1 <= bedtime_hour <= 4:
        reasons.append("Bedtime is very late, which can reduce sleep regularity.")
    elif bedtime_hour >= 22 or bedtime_hour < 1:
        reasons.append("Bedtime is within a normal night-sleep window.")
    else:
        reasons.append("Bedtime is earlier than usual; check whether it matches your real routine.")

    if mood >= 4:
        reasons.append("Mood score is positive and supports a higher energy prediction.")
    elif mood <= 2:
        reasons.append("Mood score is low and may pull the prediction downward.")
    else:
        reasons.append("Mood score is neutral and has moderate impact on the prediction.")

    if activity_level >= 4:
        reasons.append("Activity level is high, which may support better sleep pressure and energy.")
    elif activity_level <= 2:
        reasons.append("Activity level is low; light movement may improve future energy.")
    else:
        reasons.append("Activity level is moderate and does not create a strong negative signal.")

    training = load_or_train_model()
    reasons.append(
        f"The k-NN model (trained on {len(training)} examples) classified this scenario as {prediction} energy."
    )
    return reasons
