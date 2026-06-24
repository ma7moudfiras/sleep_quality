# Final Project Structure

```
sleep_quality/
├── .gitignore                          Root gitignore (created during cleanup)
├── .idea/                              IntelliJ IDE config (gitignored)
│
├── backend/                            Python FastAPI backend
│   ├── .gitignore
│   ├── README.md
│   ├── requirements.txt                9 pinned runtime dependencies
│   ├── requirements-dev.txt            Dev tools (pyinstaller, etc.)
│   ├── runtime.txt                     Python 3.12 declaration (Render.com)
│   ├── Procfile                        Render.com deployment entry
│   ├── render.yaml                     Render.com service config
│   ├── run_backend.py                  Windows EXE entrypoint (PyInstaller)
│   ├── sleep_quality_backend.spec      PyInstaller build spec
│   │
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py                     FastAPI app init, middleware, lifespan
│   │   ├── config.py                   Data paths, frozen/dev mode detection
│   │   ├── database.py                 SQLite init and schema
│   │   ├── repository.py               Database CRUD operations
│   │   ├── schemas.py                  Pydantic request/response models
│   │   ├── analytics.py                Insights, consistency, debt, streaks
│   │   ├── health.py                   Health check payload
│   │   │
│   │   ├── ml/
│   │   │   ├── __init__.py
│   │   │   └── predictor.py            RandomForest ML model, training, prediction
│   │   │
│   │   ├── routes/
│   │   │   ├── __init__.py
│   │   │   ├── logs.py                 POST /log, GET /logs, PATCH feedback
│   │   │   ├── predict.py              GET /predict
│   │   │   ├── charts.py               GET /charts
│   │   │   ├── retrain.py              POST /retrain
│   │   │   ├── insights.py             GET /insights
│   │   │   ├── weekly_report.py        GET /weekly-report
│   │   │   ├── simulator.py            POST /what-if
│   │   │   ├── status.py               GET /system-status
│   │   │   └── web_ui.py               GET /app (backend HTML UI)
│   │   │
│   │   └── static/
│   │       ├── backend_ui.css
│   │       └── backend_ui.js
│   │
│   ├── data/
│   │   └── initial_sleep_dataset.csv   27-row seed training data (committed)
│   │   # sleep_energy.db               Runtime SQLite DB (gitignored)
│   │   # sleep_energy_model.joblib      Trained model cache (gitignored)
│   │
│   └── scripts/
│       └── train_initial_model.py      Standalone model training script
│
├── frontend/                           Flutter frontend
│   ├── README.md
│   ├── pubspec.yaml
│   ├── analysis_options.yaml
│   │
│   ├── lib/
│   │   ├── main.dart                   App entry point
│   │   └── src/
│   │       ├── core/
│   │       │   ├── api/api_client.dart  Dio HTTP client with base URL
│   │       │   └── theme/app_theme.dart Material theme
│   │       │
│   │       └── features/sleep/
│   │           ├── data/sleep_api.dart  All API calls
│   │           ├── domain/sleep_log.dart All Dart data models
│   │           └── presentation/
│   │               ├── providers/sleep_providers.dart  Riverpod providers
│   │               ├── screens/
│   │               │   ├── home_shell.dart        Navigation shell (rail + bar)
│   │               │   ├── log_screen.dart        Daily sleep entry
│   │               │   ├── history_screen.dart    Past logs with feedback
│   │               │   ├── insights_screen.dart   Analytics dashboard
│   │               │   ├── charts_screen.dart     4 fl_chart trend charts
│   │               │   ├── prediction_screen.dart Next-day energy prediction
│   │               │   ├── what_if_screen.dart    Scenario simulator
│   │               │   ├── system_status_screen.dart Backend health
│   │               │   └── about_screen.dart      Project info
│   │               └── widgets/
│   │                   ├── app_section_card.dart
│   │                   └── modern_widgets.dart
│   │
│   └── windows/                        Flutter Windows desktop config
│
├── release/                            End-user release utilities
│   ├── Start_Sleep_Quality_App.bat     Main launch script for packaged release
│   └── Reset_Backend_Model_Cache.bat   User utility: clear corrupt model files
│
├── scripts/
│   └── build_release_windows.ps1       Full Windows EXE release builder
│
├── docs/                               Arabic user documentation
│   ├── BUILD_EXE_PACKAGE_GUIDE_AR.md
│   ├── EXE_IMPORT_FIX_AR.md
│   ├── EXE_MODEL_CACHE_FIX_AR.md
│   ├── EXE_NUMPY_FIX_AR.md
│   ├── PROGRAM_FEATURES_AR.md
│   └── USER_OPERATION_GUIDE_AR.md
│
├── README.md
├── CHANGELOG.md
├── PROJECT_DOCUMENTATION_AR.md
├── RELEASE_CANDIDATE_NOTES.md
├── FINAL_RC_TEST_REPORT.md
├── BACKEND_TEST_REPORT.md
├── BACKEND_USER_UI_CHANGELOG.md
├── UI_MODERNIZATION_CHANGELOG.md
├── EXE_BUILDER_WINDOWS_DETECTION_FIX_AR.md
├── EXE_MODEL_CACHE_FIX_STATUS_AR.md
├── EXE_NUMPY_FIX_STATUS_AR.md
├── EXE_PACKAGE_BUILD_STATUS_AR.md
├── CLEANUP_REPORT.md                   (added during cleanup)
├── FINAL_PROJECT_STRUCTURE.md          (added during cleanup)
├── RELEASE_READINESS_REPORT.md         (added during cleanup)
└── KNOWN_LIMITATIONS.md                (added during cleanup)
```

---

## API Surface

| Method | Path | Purpose |
|---|---|---|
| POST | /log | Save daily sleep log (auto-predicts energy) |
| GET | /logs | List all logs newest-first |
| PATCH | /logs/{id}/feedback | Save actual energy + optional retrain |
| GET | /predict | Predict next-day energy from latest log |
| GET | /charts | Sleep/energy/mood/activity trend arrays |
| POST | /retrain | Manually retrain model |
| GET | /insights | Full analytics dashboard payload |
| GET | /weekly-report | 7-day summary |
| POST | /what-if | Simulate a scenario vs current baseline |
| GET | /system-status | Backend health, paths, counts |
| GET | /health | Simple health probe |
| GET | /app | Backend HTML web UI |
| GET | /docs | Swagger interactive docs |

---

## Database Schema

```sql
CREATE TABLE sleep_logs (
    id                    INTEGER PRIMARY KEY AUTOINCREMENT,
    log_date              TEXT    NOT NULL UNIQUE,
    sleep_hours           REAL    NOT NULL CHECK (sleep_hours > 0 AND sleep_hours <= 24),
    bedtime_hour          REAL    NOT NULL CHECK (bedtime_hour >= 0 AND bedtime_hour < 24),
    wake_hour             REAL    NOT NULL CHECK (wake_hour >= 0 AND wake_hour < 24),
    mood                  INTEGER NOT NULL CHECK (mood BETWEEN 1 AND 5),
    activity_level        INTEGER NOT NULL CHECK (activity_level BETWEEN 1 AND 5),
    predicted_energy_level TEXT   CHECK (predicted_energy_level IS NULL OR predicted_energy_level IN ('Low','Medium','High')),
    actual_energy_level   TEXT    CHECK (actual_energy_level IS NULL OR actual_energy_level IN ('Low','Medium','High')),
    created_at            TEXT    DEFAULT CURRENT_TIMESTAMP
);
```
