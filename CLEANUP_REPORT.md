# Cleanup Report

## What Was Removed

| File | Reason |
|---|---|
| None | No source files were removed. No orphaned, duplicate, or obsolete source files were found. |

The `frontend/test/widget_test.dart` (default Flutter scaffold test) does not exist in this repository, so no removal was needed.

---

## What Was Added

| File | Purpose |
|---|---|
| `.gitignore` (root) | Root-level gitignore was missing entirely. Now excludes build outputs, venvs, IDE files, OS files, and runtime-generated data. |

---

## What Was Improved

### Backend

| File | Change |
|---|---|
| `backend/app/ml/predictor.py` | Added module-level `_cached_model` — the model is now loaded from disk once and kept in memory. Every subsequent prediction call uses the in-memory instance, eliminating per-call disk I/O. |
| `backend/app/ml/predictor.py` | Added `from __future__ import annotations` for forward-compatible type hints. |
| `backend/app/analytics.py` | Fixed `_latest_n_logs()` bug — the function received a `logs` list argument but silently ignored it and called `get_all_sleep_logs()` from the database again. It now uses the already-fetched list, removing a hidden double DB call on every insights and weekly-report request. |
| `backend/app/routes/logs.py` | Replaced `train_model()` with `retrain_model()` when `actual_energy_level` is provided at log creation. This makes the behavior consistent with the feedback endpoint (PATCH /logs/{id}/feedback) which also calls `retrain_model()`. |
| `backend/app/repository.py` | Fixed missing blank line between `update_log_prediction` and `update_sleep_log_feedback` functions (PEP 8). |
| `backend/.gitignore` | Added `build/`, `dist/`, `.venv_exe/`, and `data/*.invalid_*.joblib` to the backend gitignore so PyInstaller outputs and quarantined model backups are not accidentally committed. |

### Frontend

| File | Change |
|---|---|
| `frontend/lib/src/core/api/api_client.dart` | Increased `connectTimeout` from 10s to 15s and `receiveTimeout` from 10s to 30s. The backend can take several seconds to cold-start and train the initial model on first launch, especially inside the Windows EXE. A 10s timeout caused false connection errors during normal startup. |

---

## What Was Intentionally Kept

- All `docs/*_AR.md` — Arabic user-facing documentation
- All root-level `*_AR.md` fix notes — historical Arabic release notes
- `CHANGELOG.md`, `RELEASE_CANDIDATE_NOTES.md`, `FINAL_RC_TEST_REPORT.md` — release history records
- `backend/data/initial_sleep_dataset.csv` — 27-row seed training dataset, required for first launch
- `release/Reset_Backend_Model_Cache.bat` — user utility for clearing corrupt model files
- `backend/sleep_quality_backend.spec` — PyInstaller build spec, required for Windows EXE
- `scripts/build_release_windows.ps1` — Windows release builder script
- `release/Start_Sleep_Quality_App.bat` — end-user launcher script
- `backend/.venv_exe/` directory on disk (not committed to git, needed for local EXE builds)
- `backend/build/` and `backend/dist/` directories on disk (not committed, PyInstaller outputs)
