# Sleep Quality Analyzer and Daily Energy Predictor

A full-stack sleep tracking and daily energy prediction app.

## Stack
- Frontend: Flutter Web / Android / Windows
- State management: Riverpod
- HTTP client: Dio
- Charts: fl_chart
- Backend: Python FastAPI
- Database: SQLite
- ML: scikit-learn Random Forest

## Main flow
Log daily sleep data → Predict next-day energy → Save actual feedback → Retrain model → View insights → Run what-if simulations.

## Backend local run
```powershell
cd backend
py -3.12 -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app.main:app --reload --host 127.0.0.1 --port 8010
```

Open:
- API docs: `http://127.0.0.1:8010/docs`
- Backend user UI: `http://127.0.0.1:8010/app`
- System status: `http://127.0.0.1:8010/system-status`

## Flutter local run
```powershell
cd frontend
flutter clean
flutter pub get
flutter analyze
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8010
```

For Android Emulator:
```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8010
```

## Final Release Candidate additions
- EXE-safe backend data directory handling.
- `/system-status` endpoint.
- Flutter System Status screen.
- Flutter About Project screen.
- Data quality notices in the Log screen.
- `withOpacity` cleanup for current Flutter analyzer compatibility.
- PyInstaller backend spec.
- Windows release build script.
- One-click launcher template.

## Windows EXE release build
Run from project root:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/build_release_windows.ps1
```

The script creates:
```text
release_package/
├── backend/
├── frontend/
└── Start_Sleep_Quality_App.bat
```

Open `Start_Sleep_Quality_App.bat` to run the local executable bundle.

## API endpoints
- `POST /log`
- `GET /logs`
- `PATCH /logs/{log_id}/feedback`
- `GET /predict`
- `GET /charts`
- `POST /retrain`
- `GET /insights`
- `GET /weekly-report`
- `POST /what-if`
- `GET /system-status`
- `GET /health`
- `GET /app`


## Arabic Project Documentation

تمت إضافة ملفات توثيق عربية داخل المشروع:

- `PROJECT_DOCUMENTATION_AR.md` — فهرس التوثيق العربي.
- `docs/USER_OPERATION_GUIDE_AR.md` — دليل تشغيل النظام خطوة بخطوة.
- `docs/PROGRAM_FEATURES_AR.md` — مميزات البرنامج ووظائفه.

