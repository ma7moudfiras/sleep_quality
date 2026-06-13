# Backend Test Report

Backend smoke test was executed with FastAPI `TestClient`.

## Tested endpoints

- `GET /`
- `GET /health`
- `POST /log`
- `GET /predict`
- `GET /insights`
- `GET /weekly-report`
- `POST /what-if`

## Result

All tested backend endpoints returned successful responses in the local validation run.

## Important local run note

Use Python 3.12 or 3.13 for the backend environment. Python 3.14 may force `scikit-learn` to build from source and fail because the pinned dependency set is intended for stable wheel availability.

Recommended backend command:

```powershell
cd backend
py -3.12 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
uvicorn app.main:app --reload --host 127.0.0.1 --port 8010
```

Recommended Flutter web command:

```powershell
cd frontend
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8010
```

Recommended Android Emulator command:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8010
```
