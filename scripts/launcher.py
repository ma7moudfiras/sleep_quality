"""
Sleep Quality App – Launcher

This is the single entry point for the end user.
Compiled to a windowed EXE (no console), it:
  1. Starts the backend silently in the background
  2. Waits until the backend is ready (health check loop)
  3. Launches the Flutter desktop app
  4. Falls back to the backend web UI in the browser if the desktop app is missing

Build with:
  pyinstaller --clean --noconfirm scripts/launcher.spec
"""

from __future__ import annotations

import os
import subprocess
import sys
import time
import urllib.request
import webbrowser
from pathlib import Path


PORT = 8010
HEALTH_URL = f"http://127.0.0.1:{PORT}/health"
WEB_UI_URL = f"http://127.0.0.1:{PORT}/app"
HEALTH_POLL_TRIES = 40
HEALTH_POLL_INTERVAL = 1.0


def _base_dir() -> Path:
    """Root of the release package — same folder as this EXE when frozen."""
    if getattr(sys, "frozen", False):
        return Path(sys.executable).resolve().parent
    # Dev mode: assume repo root
    return Path(__file__).resolve().parent.parent / "release_package"


def _show_error(title: str, message: str) -> None:
    """Show a native Windows message box (no console required)."""
    try:
        import ctypes
        ctypes.windll.user32.MessageBoxW(0, message, title, 0x10)  # MB_ICONERROR
    except Exception:
        pass  # Non-Windows or ctypes unavailable — silent fail


def _show_warning(title: str, message: str) -> None:
    try:
        import ctypes
        ctypes.windll.user32.MessageBoxW(0, message, title, 0x30)  # MB_ICONWARNING
    except Exception:
        pass


def _backend_ready() -> bool:
    for _ in range(HEALTH_POLL_TRIES):
        try:
            with urllib.request.urlopen(HEALTH_URL, timeout=1) as resp:
                if resp.status == 200:
                    return True
        except Exception:
            pass
        time.sleep(HEALTH_POLL_INTERVAL)
    return False


def main() -> None:
    base = _base_dir()
    backend_exe = base / "backend" / "sleep_quality_backend.exe"
    frontend_dir = base / "frontend"

    # --- Start backend silently ---
    if not backend_exe.exists():
        _show_error(
            "Sleep Quality App",
            f"Backend executable not found:\n{backend_exe}\n\n"
            "Please make sure the release package is complete.",
        )
        return

    # CREATE_NO_WINDOW prevents the backend console from appearing
    CREATE_NO_WINDOW = 0x08000000
    backend_proc = subprocess.Popen(
        [str(backend_exe)],
        cwd=str(backend_exe.parent),
        creationflags=CREATE_NO_WINDOW,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

    # --- Wait for backend to be healthy ---
    if not _backend_ready():
        backend_proc.terminate()
        _show_warning(
            "Sleep Quality App",
            "The backend did not respond in time.\n\n"
            "Try running Start_Sleep_Quality_App.bat for diagnostic output.",
        )
        return

    # --- Launch Flutter desktop app (or fall back to web UI) ---
    frontend_exe: Path | None = None
    for f in sorted(frontend_dir.glob("*.exe")):
        frontend_exe = f
        break

    if frontend_exe and frontend_exe.exists():
        subprocess.Popen([str(frontend_exe)], cwd=str(frontend_dir))
    else:
        webbrowser.open(WEB_UI_URL)

    # Keep the launcher process alive so the backend process stays attached.
    # When the user closes the Flutter app the backend keeps running until they
    # close the launcher from the system tray / task manager.
    # For simplicity in this demo we just wait for the backend to exit.
    try:
        backend_proc.wait()
    except KeyboardInterrupt:
        backend_proc.terminate()


if __name__ == "__main__":
    main()
