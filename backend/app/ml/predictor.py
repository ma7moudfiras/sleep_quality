from __future__ import annotations

from typing import Any
from datetime import datetime
import joblib
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

from app.config import DATA_DIR, MODEL_PATH, SEED_DATA_PATH, KAGGLE_DATA_PATH, ensure_runtime_files
from app.repository import get_logs_for_training, count_user_training_rows

_cached_model: Pipeline | None = None

FEATURE_COLUMNS = [
    "sleep_hours",
    "bedtime_hour",
    "wake_hour",
    "mood",
    "activity_level",
]
TARGET_COLUMN = "energy_level"
ENERGY_TO_SCORE = {"Low": 1.0, "Medium": 2.0, "High": 3.0}


def _normalize_initial_dataset(df: pd.DataFrame) -> pd.DataFrame:
    """
    Accepts either the included simple CSV or a Kaggle-like sleep dataset.
    If a Kaggle file is supplied, this function tries to map common column names.
    """
    cleaned = pd.DataFrame()

    column_map = {
        "Sleep Duration": "sleep_hours",
        "sleep_duration": "sleep_hours",
        "sleep_hours": "sleep_hours",
        "Bedtime Hour": "bedtime_hour",
        "bedtime_hour": "bedtime_hour",
        "Wake Hour": "wake_hour",
        "wake_hour": "wake_hour",
        "Mood": "mood",
        "mood": "mood",
        "Activity Level": "activity_level",
        "Physical Activity Level": "activity_level",
        "activity_level": "activity_level",
        "Energy Level": "energy_level",
        "energy_level": "energy_level",
    }

    for source, target in column_map.items():
        if source in df.columns and target not in cleaned.columns:
            cleaned[target] = df[source]

    if "energy_level" not in cleaned.columns:
        if "Quality of Sleep" in df.columns:
            quality = pd.to_numeric(df["Quality of Sleep"], errors="coerce")
            cleaned["energy_level"] = pd.cut(
                quality,
                bins=[0, 4, 7, 10],
                labels=["Low", "Medium", "High"],
                include_lowest=True,
            ).astype(str)
        else:
            cleaned["energy_level"] = cleaned.apply(_heuristic_energy_label, axis=1)

    missing_features = [col for col in FEATURE_COLUMNS if col not in cleaned.columns]
    if missing_features:
        # Safe defaults allow the app to start even if the Kaggle CSV shape differs.
        defaults = {
            "sleep_hours": 7.0,
            "bedtime_hour": 22.5,
            "wake_hour": 6.5,
            "mood": 3,
            "activity_level": 3,
        }
        for col in missing_features:
            cleaned[col] = defaults[col]

    for col in FEATURE_COLUMNS:
        cleaned[col] = pd.to_numeric(cleaned[col], errors="coerce")

    cleaned = cleaned.dropna(subset=FEATURE_COLUMNS + [TARGET_COLUMN])
    cleaned = cleaned[cleaned[TARGET_COLUMN].isin(["Low", "Medium", "High"])]
    return cleaned[FEATURE_COLUMNS + [TARGET_COLUMN]]


def _heuristic_energy_label(row: Any) -> str:
    sleep_hours = float(row.get("sleep_hours", 7.0))
    mood = float(row.get("mood", 3.0))
    activity = float(row.get("activity_level", 3.0))
    bedtime = float(row.get("bedtime_hour", 22.5))

    bedtime_penalty = 1.0 if bedtime >= 1.0 and bedtime <= 4.0 else 0.0
    score = (sleep_hours * 0.45) + (mood * 0.7) + (activity * 0.35) - bedtime_penalty

    if score < 5.2:
        return "Low"
    if score < 7.2:
        return "Medium"
    return "High"


def _load_initial_training_data() -> pd.DataFrame:
    ensure_runtime_files()
    csv_path = KAGGLE_DATA_PATH if KAGGLE_DATA_PATH.exists() else SEED_DATA_PATH
    df = pd.read_csv(csv_path)
    return _normalize_initial_dataset(df)


def _load_user_training_data() -> pd.DataFrame:
    rows = get_logs_for_training()
    if not rows:
        return pd.DataFrame(columns=FEATURE_COLUMNS + [TARGET_COLUMN])

    df = pd.DataFrame(rows)
    df = df.rename(columns={"actual_energy_level": TARGET_COLUMN})
    return df[FEATURE_COLUMNS + [TARGET_COLUMN]]


def _build_training_frame() -> tuple[pd.DataFrame, int, int]:
    initial_df = _load_initial_training_data()
    user_df = _load_user_training_data()
    train_df = (
        pd.concat([initial_df, user_df], ignore_index=True)
        if not user_df.empty
        else initial_df.copy()
    )
    return train_df, len(initial_df), len(user_df)


def _fit_and_save_model(train_df: pd.DataFrame) -> Pipeline:
    global _cached_model
    ensure_runtime_files()

    model = Pipeline(
        steps=[
            ("scaler", StandardScaler()),
            (
                "classifier",
                RandomForestClassifier(
                    n_estimators=120,
                    random_state=42,
                    class_weight="balanced",
                ),
            ),
        ]
    )

    model.fit(train_df[FEATURE_COLUMNS], train_df[TARGET_COLUMN])
    joblib.dump(model, MODEL_PATH)
    _cached_model = model
    return model


def train_model() -> Pipeline:
    train_df, _, _ = _build_training_frame()
    return _fit_and_save_model(train_df)


def retrain_model() -> dict[str, Any]:
    train_df, seed_rows, user_training_rows = _build_training_frame()
    _fit_and_save_model(train_df)

    return {
        "status": "retrained",
        "message": "Model retrained successfully.",
        "seed_rows": seed_rows,
        "user_training_rows": user_training_rows,
        "total_training_rows": len(train_df),
        "model_status": model_status(),
    }


def _quarantine_invalid_model(error: Exception) -> None:
    """Move an incompatible/corrupted model file aside so the app can retrain safely.

    This is especially important for PyInstaller/EXE releases where an old
    joblib model may have been serialized with a different NumPy version.
    """
    if not MODEL_PATH.exists():
        return

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = MODEL_PATH.with_name(
        f"{MODEL_PATH.stem}.invalid_{timestamp}{MODEL_PATH.suffix}"
    )
    try:
        MODEL_PATH.replace(backup_path)
    except OSError:
        try:
            MODEL_PATH.unlink()
        except OSError:
            pass


def load_or_train_model() -> Pipeline:
    global _cached_model
    if _cached_model is not None:
        return _cached_model
    ensure_runtime_files()
    if MODEL_PATH.exists():
        try:
            _cached_model = joblib.load(MODEL_PATH)
            return _cached_model
        except Exception as error:
            # Old model files can fail after EXE packaging or NumPy version changes.
            # Do not crash the server; quarantine the invalid model and retrain.
            _quarantine_invalid_model(error)
    return train_model()


def predict_energy(features: dict[str, Any]) -> dict[str, Any]:
    model = load_or_train_model()
    frame = pd.DataFrame([{key: features[key] for key in FEATURE_COLUMNS}])
    prediction = str(model.predict(frame)[0])

    confidence = 0.0
    if hasattr(model, "predict_proba"):
        classes = list(model.classes_)
        probabilities = model.predict_proba(frame)[0]
        confidence = float(probabilities[classes.index(prediction)])

    return {
        "prediction": prediction,
        "confidence": round(confidence, 3),
        "model_status": model_status(),
    }


def model_status() -> str:
    user_rows = count_user_training_rows()
    if user_rows == 0:
        return "initial_seed_model"
    return f"seed_plus_user_data_{user_rows}_labeled_rows"


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
        reasons.append("Sleep duration is acceptable but still slightly below the ideal target.")
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

    reasons.append(f"The trained model classified this scenario as {prediction} energy.")
    return reasons


def energy_score(level: str | None) -> float:
    if not level:
        return 0.0
    return ENERGY_TO_SCORE.get(level, 0.0)
