from __future__ import annotations

import os
import shutil
import sys
from pathlib import Path

APP_DIR = Path(__file__).resolve().parent
BACKEND_DIR = APP_DIR.parent


def is_frozen_app() -> bool:
    return bool(getattr(sys, "frozen", False))


def runtime_base_dir() -> Path:
    """Directory that should remain writable after PyInstaller packaging."""
    if is_frozen_app():
        return Path(sys.executable).resolve().parent
    return BACKEND_DIR


def bundled_base_dir() -> Path:
    """Read-only bundle directory when frozen; project backend dir in development."""
    if is_frozen_app() and hasattr(sys, "_MEIPASS"):
        return Path(sys._MEIPASS).resolve()
    return BACKEND_DIR


def get_data_dir() -> Path:
    configured = os.getenv("SLEEP_QUALITY_DATA_DIR")
    if configured:
        return Path(configured).expanduser().resolve()
    return runtime_base_dir() / "data"


DATA_DIR = get_data_dir()
DB_PATH = DATA_DIR / "sleep_energy.db"
MODEL_PATH = DATA_DIR / "sleep_energy_model.joblib"
SEED_DATA_PATH = DATA_DIR / "initial_sleep_dataset.csv"
KAGGLE_DATA_PATH = DATA_DIR / "kaggle_sleep_health.csv"


def get_static_dir() -> Path:
    bundled_static = bundled_base_dir() / "app" / "static"
    if bundled_static.exists():
        return bundled_static
    return APP_DIR / "static"


def _copy_if_missing(filename: str) -> None:
    target = DATA_DIR / filename
    if target.exists():
        return

    candidates = [
        bundled_base_dir() / "data" / filename,
        BACKEND_DIR / "data" / filename,
    ]
    for source in candidates:
        try:
            if source.exists() and source.resolve() != target.resolve():
                shutil.copy2(source, target)
                return
        except OSError:
            continue


def ensure_runtime_files() -> None:
    """Create writable runtime directories and seed files for local and EXE runs."""
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    _copy_if_missing("initial_sleep_dataset.csv")
    # Do not copy a bundled model into runtime by default. A model serialized
    # with a different NumPy/scikit-learn environment may be incompatible inside
    # the Windows EXE. The app can train a fresh model safely from seed data
    # and user feedback when MODEL_PATH is missing.
    _copy_if_missing("sleep_energy.db")
