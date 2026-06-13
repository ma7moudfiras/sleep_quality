# Changelog

## Final Release Candidate Patch — 2026-06-11

### Frontend
- Removed all `withOpacity` deprecated calls and replaced them with `withValues(alpha: ...)`.
- Updated default local API URL to `http://127.0.0.1:8010`.
- Added `System Status` screen.
- Added `About Project` screen.
- Added data quality warning panel in the daily log form.
- Added API/data models for `/system-status`.
- Refreshed read providers after feedback/retrain/log submission.

### Backend
- Added `app/config.py` for EXE-safe runtime paths.
- Added `/system-status` endpoint.
- Updated `/health` payload with runtime/data paths.
- Updated static file mounting to work in local and PyInstaller contexts.
- Updated SQLite/model path handling for writable runtime data.
- Added `run_backend.py` entrypoint for PyInstaller.
- Added `sleep_quality_backend.spec`.
- Added `requirements-dev.txt`.

### Release tooling
- Added `scripts/build_release_windows.ps1`.
- Added `release/Start_Sleep_Quality_App.bat` launcher template.
- Added `RELEASE_CANDIDATE_NOTES.md`.

### Validation
- Backend Python compile check passed.
- Backend TestClient smoke test passed for `/`, `/health`, `/system-status`, `/app`, `/log`, `/predict`, and `/what-if`.
- Flutter SDK is not available in this environment, so Flutter analyzer must be run locally.


## Documentation Pack — Arabic Operation Guide + Features List

- Added `docs/USER_OPERATION_GUIDE_AR.md` with a full Arabic system operation guide.
- Added `docs/PROGRAM_FEATURES_AR.md` with a structured Arabic feature list.
- Added `PROJECT_DOCUMENTATION_AR.md` as an Arabic documentation index.
- Updated root `README.md` with links to the Arabic documentation files.


## EXE Package Builder Patch

- تحسين سكربت بناء Windows release.
- إضافة فحص Flutter/Python 3.12 قبل البناء.
- إضافة مشغل BAT ينتظر جاهزية Backend قبل فتح Flutter.
- إضافة دليل عربي لبناء EXE.
- تجهيز إخراج `release_package` و `SleepQuality_Windows_Release.zip` محليًا على Windows.
