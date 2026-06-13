import sqlite3

from app.config import DATA_DIR, DB_PATH, ensure_runtime_files


def get_connection() -> sqlite3.Connection:
    ensure_runtime_files()
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db() -> None:
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS sleep_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            log_date TEXT NOT NULL UNIQUE,
            sleep_hours REAL NOT NULL CHECK (sleep_hours > 0 AND sleep_hours <= 24),
            bedtime_hour REAL NOT NULL CHECK (bedtime_hour >= 0 AND bedtime_hour < 24),
            wake_hour REAL NOT NULL CHECK (wake_hour >= 0 AND wake_hour < 24),
            mood INTEGER NOT NULL CHECK (mood BETWEEN 1 AND 5),
            activity_level INTEGER NOT NULL CHECK (activity_level BETWEEN 1 AND 5),
            predicted_energy_level TEXT CHECK (
                predicted_energy_level IS NULL OR predicted_energy_level IN ('Low', 'Medium', 'High')
            ),
            actual_energy_level TEXT CHECK (
                actual_energy_level IS NULL OR actual_energy_level IN ('Low', 'Medium', 'High')
            ),
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
        );
        """
    )

    conn.commit()
    conn.close()
