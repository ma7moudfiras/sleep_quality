# Sleep Quality Analyzer — Final Release Candidate Patch

## Release decision
This patch prepares the project for local packaging as a Windows executable bundle.

## Included improvements
- Removed Flutter `withOpacity` deprecation warnings by using `withValues(alpha: ...)`.
- Changed default local API URL to `http://127.0.0.1:8010`.
- Added `/system-status` backend endpoint.
- Added Flutter `System Status` screen.
- Added Flutter `About Project` screen.
- Added data quality warnings in the Flutter log form.
- Added EXE-safe runtime data path handling for SQLite and ML model files.
- Added `run_backend.py` for PyInstaller.
- Added `sleep_quality_backend.spec` for backend EXE generation.
- Added `scripts/build_release_windows.ps1` release packaging script.
- Added `release/Start_Sleep_Quality_App.bat` launcher template.

## Recommended final packaging flow
1. Confirm backend works: `http://127.0.0.1:8010/docs`.
2. Confirm Flutter analyze has no errors.
3. Run the release build script from project root:
   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts/build_release_windows.ps1
   ```
4. Open `release_package/Start_Sleep_Quality_App.bat`.

## Notes
- Use Python 3.12 for the backend environment.
- Keep port 8010 unless you update Flutter `API_BASE_URL` and the launcher consistently.
- SQLite and the ML model are stored in the runtime `data` directory so retraining remains writable after packaging.
