# Known Limitations

## Machine Learning

**Small seed dataset (27 rows)**
The initial model trains on 27 hand-crafted seed rows. Predictions are directionally correct but confidence values are not clinically meaningful until the user accumulates 20+ labeled feedback rows. The UI displays `personalization_level` so the user can track this.

**No cross-validation or held-out test set**
The model trains on all available data without a validation split. This is acceptable for a demo/graduation project but means there is no measured accuracy metric at runtime.

**Energy label is subjective**
The "actual energy level" feedback is self-reported. Users may rate the same energy state differently on different days, which adds noise to the training data over time.

**Three-class output only**
The model predicts Low / Medium / High. It does not produce a numeric energy score or probability distribution visible to the user (confidence is shown but not broken down per class).

---

## Architecture

**Single-user, local data**
The SQLite database stores all data on the local machine. There is no cloud sync, multi-device support, or account system.

**No authentication**
The API has no authentication. It is designed for localhost-only use. The CORS policy (`allow_origins=["*"]`) is intentionally open to support local Flutter web and desktop builds.

**No automatic backup**
There is no built-in backup for the SQLite database. Users should manually back up `data/sleep_energy.db` from the backend folder.

---

## Windows EXE Build

**Must be built on Windows**
PyInstaller Windows EXE and Flutter Windows desktop builds are OS-specific. The build script (`scripts/build_release_windows.ps1`) explicitly rejects non-Windows hosts.

**EXE is not a single-file installer**
The packaged release is a ZIP containing two folders (`backend/` and `frontend/`) plus the launcher BAT file. It is not a Windows `.msi` or `.exe` installer. Users extract the ZIP and run `Start_Sleep_Quality_App.bat`.

**Model compatibility across EXE rebuilds**
If a user runs an older EXE version and then upgrades to a new EXE built with a different NumPy version, the saved `sleep_energy_model.joblib` may be incompatible. The app handles this automatically: the old model file is renamed as a backup and the model is retrained from seed data. User feedback logs in the SQLite database are preserved.

**Console window is visible**
The backend EXE runs with `console=True` in the PyInstaller spec. A console window appears while the backend is running. This is intentional to show startup logs and errors.

---

## Frontend

**No offline mode**
The Flutter app requires the backend to be running. If the backend is not reachable, each screen shows an error with a retry button. There is no offline cache.

**Bedtime after midnight**
Bedtime hours of 1:00–5:00 trigger a data quality warning in both the frontend and the backend. The app treats `wake_hour` as the next-day wake-up time for these entries, which is correct, but there is no explicit 24-hour spanning calculation for `sleep_hours` — the user must enter the correct duration manually.

**Date uniqueness enforced server-side**
Submitting a second log for the same date returns HTTP 409. The frontend displays this as a snackbar error message but does not offer an "edit existing log" flow. Users who want to correct an entry must use the feedback endpoint or the backend web UI at `/app`.

---

## Deployment

**Not production-ready for multi-user cloud deployment**
While the project includes Render.com deployment files (`Procfile`, `render.yaml`, `runtime.txt`), the application uses SQLite (single-file, single-writer) and has no authentication. It is suitable for local demo use or single-user cloud deployment only.
