from app.config import DATA_DIR, DB_PATH, runtime_base_dir
from app.ml.predictor import model_status


def health_payload() -> dict[str, object]:
    return {
        "status": "running",
        "runtime_base_dir": str(runtime_base_dir()),
        "data_dir": str(DATA_DIR),
        "database_path": str(DB_PATH),
        "database_exists": DB_PATH.exists(),
        "model_status": model_status(),
    }
