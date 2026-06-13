# Final RC Test Report

## Backend validation
Executed in the working environment:

```text
python3 -m compileall app run_backend.py
```

Result: passed.

Smoke-tested with FastAPI TestClient using isolated runtime data directory:

```text
GET  /              -> 200
GET  /health        -> 200
GET  /system-status -> 200
GET  /app           -> 200
POST /log           -> 201
GET  /predict       -> 200
POST /what-if       -> 200
```

## Flutter validation
Flutter SDK is not available inside this generation environment. Run locally:

```powershell
cd frontend
flutter clean
flutter pub get
flutter analyze
```

Expected result: no `withOpacity` deprecation warnings remain. If any package-version info messages appear, they are not blockers.

## Release risk notes
- Use Python 3.12 for backend packaging.
- Keep backend and Flutter API URL aligned on port `8010`.
- Use `Start_Sleep_Quality_App.bat` only after building backend and frontend executables.
