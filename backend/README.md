# Backend — Sleep Quality Analyzer

## Run locally
```powershell
py -3.12 -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app.main:app --reload --host 127.0.0.1 --port 8010
```

## User UI
Open:
```text
http://127.0.0.1:8010/app
```

## API docs
```text
http://127.0.0.1:8010/docs
```

## System status
```text
http://127.0.0.1:8010/system-status
```

## EXE packaging
```powershell
pip install -r requirements-dev.txt
pyinstaller sleep_quality_backend.spec --clean --noconfirm
```

The backend writes SQLite and model files to the runtime `data` directory. You can override it with:
```powershell
$env:SLEEP_QUALITY_DATA_DIR="C:\\SleepQualityData"
```
