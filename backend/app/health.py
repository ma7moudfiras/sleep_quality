from pathlib import Path

from app.config import DATA_DIR, DB_PATH, MODEL_PATH, runtime_base_dir


def health_payload() -> dict[str, object]:
    return {
        "status": "running",
        "runtime_base_dir": str(runtime_base_dir()),
        "data_dir": str(DATA_DIR),
        "database_path": str(DB_PATH),
        "database_exists": Path(DB_PATH).exists(),
        "model_path": str(MODEL_PATH),
        "model_exists": Path(MODEL_PATH).exists(),
    }
