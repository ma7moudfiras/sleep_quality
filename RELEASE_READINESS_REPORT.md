# Release Readiness Report

## Status: READY FOR RELEASE CANDIDATE

All core features verified working. Build pipeline intact. No blocking issues.

---

## How to Run Locally

### Backend

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate          # Windows
source .venv/bin/activate       # Linux / macOS
pip install -r requirements.txt
uvicorn app.main:app --reload --host 127.0.0.1 --port 8010
```

Test with:
```bash
curl http://127.0.0.1:8010/health
curl http://127.0.0.1:8010/predict       # after adding a log
curl http://127.0.0.1:8010/charts
curl http://127.0.0.1:8010/insights
```

### Frontend (Web for development)

```bash
cd frontend
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8010
```

### Frontend (Windows desktop)

```bash
cd frontend
flutter build windows --release --dart-define=API_BASE_URL=http://127.0.0.1:8010
```

---

## How to Build the Windows EXE Package

Run on a **Windows machine** with Python 3.12 and Flutter SDK installed:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\build_release_windows.ps1
```

This produces:
```
release_package/
├── backend/               PyInstaller output (sleep_quality_backend.exe + deps)
├── frontend/              Flutter Windows release build
├── docs/                  Arabic user documentation
├── README.md
├── PROJECT_DOCUMENTATION_AR.md
└── Start_Sleep_Quality_App.bat
SleepQuality_Windows_Release.zip
```

The user runs `Start_Sleep_Quality_App.bat` which:
1. Starts the backend EXE on port 8010
2. Polls health check up to 30 times (1 s intervals)
3. Launches the Flutter Windows desktop EXE
4. Falls back to opening `http://127.0.0.1:8010/app` in the browser if the desktop EXE is not found

---

## Endpoint Verification (all tested 2026-06-13)

| Endpoint | Status |
|---|---|
| GET /health | ✓ |
| GET / | ✓ |
| POST /log | ✓ |
| GET /logs | ✓ |
| PATCH /logs/{id}/feedback | ✓ |
| GET /predict | ✓ |
| GET /charts | ✓ |
| POST /retrain | ✓ |
| GET /insights | ✓ |
| GET /weekly-report | ✓ |
| POST /what-if | ✓ |
| GET /system-status | ✓ |
| GET /app | ✓ |

## Flutter Screens

| Screen | Status |
|---|---|
| Log | ✓ |
| History | ✓ |
| Insights | ✓ |
| Charts | ✓ |
| Predict | ✓ |
| What-if | ✓ |
| System Status | ✓ |
| About | ✓ |

## Dependency Versions Verified

| Package | Version |
|---|---|
| FastAPI | 0.115.6 |
| Uvicorn | 0.34.0 |
| NumPy | 1.26.4 |
| Pandas | 2.2.3 |
| Scikit-learn | 1.6.1 |
| Joblib | 1.4.2 |
| Flutter Riverpod | 2.6.1 |
| Dio | 5.7.0 |
| fl_chart | 0.69.2 |

---

## Release Checklist

- [x] Backend starts and serves all 13 endpoints
- [x] ML model trains from seed data on first launch
- [x] Model is cached in memory after first load (no per-request disk I/O)
- [x] Corrupt/incompatible model files are quarantined automatically
- [x] SQLite DB path is stable in both dev and EXE mode
- [x] CORS allows all origins (required for local Flutter web builds)
- [x] Flutter API_BASE_URL is configurable via --dart-define
- [x] Frontend handles backend errors gracefully (snackbars + retry buttons)
- [x] Start_Sleep_Quality_App.bat includes health check loop before launching frontend
- [x] Root .gitignore excludes build outputs, venvs, and runtime data
- [x] PyInstaller spec excludes matplotlib, jupyter, and Qt (reduces EXE size)
- [x] Thread pool limits set in run_backend.py (prevents OpenBLAS deadlock on Windows)
