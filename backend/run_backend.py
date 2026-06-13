"""Windows EXE entrypoint for Sleep Quality Backend.

Important for PyInstaller:
- Import the FastAPI app directly, not through the string "app.main:app".
- Set runtime data folders before importing app.main.
- Keep the process single and non-reloading.
"""

from __future__ import annotations

import os
import sys
from pathlib import Path


def _runtime_dir() -> Path:
    if getattr(sys, "frozen", False):
        return Path(sys.executable).resolve().parent
    return Path(__file__).resolve().parent


def _prepare_runtime() -> None:
    base_dir = _runtime_dir()
    os.environ.setdefault("SLEEP_QUALITY_RUNTIME_DIR", str(base_dir))
    os.environ.setdefault("SLEEP_QUALITY_DATA_DIR", str(base_dir / "data"))
    os.environ.setdefault("OMP_NUM_THREADS", "1")
    os.environ.setdefault("OPENBLAS_NUM_THREADS", "1")
    os.environ.setdefault("MKL_NUM_THREADS", "1")
    os.environ.setdefault("NUMEXPR_NUM_THREADS", "1")

    if str(base_dir) not in sys.path:
        sys.path.insert(0, str(base_dir))


def main() -> None:
    _prepare_runtime()

    # Import directly so PyInstaller can bundle app.main and avoid dynamic ASGI import issues.
    from app.main import app
    import uvicorn

    port = int(os.getenv("SLEEP_QUALITY_PORT", "8010"))
    uvicorn.run(
        app,
        host="127.0.0.1",
        port=port,
        reload=False,
        workers=1,
        log_level="info",
    )


if __name__ == "__main__":
    main()
