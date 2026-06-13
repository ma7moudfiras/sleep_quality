from __future__ import annotations

from fastapi import APIRouter

from app.config import DATA_DIR, DB_PATH, runtime_base_dir
from app.ml.predictor import model_status, load_or_train_model
from app.repository import count_all_sleep_logs, count_user_training_rows, get_latest_sleep_log

router = APIRouter(tags=["status"])


@router.get("/system-status")
def system_status() -> dict[str, object]:
    latest = get_latest_sleep_log()
    training = load_or_train_model()
    return {
        "api_running": True,
        "runtime_base_dir": str(runtime_base_dir()),
        "data_dir": str(DATA_DIR),
        "database_path": str(DB_PATH),
        "database_exists": DB_PATH.exists(),
        "training_examples": len(training),
        "logs_count": count_all_sleep_logs(),
        "user_training_rows": count_user_training_rows(),
        "latest_log_id": latest["id"] if latest else None,
        "latest_log_date": latest["log_date"] if latest else None,
        "latest_prediction": latest.get("predicted_energy_level") if latest else None,
        "latest_actual_energy": latest.get("actual_energy_level") if latest else None,
        "model_status": model_status(),
        "ready_for_prediction": bool(latest),
    }
