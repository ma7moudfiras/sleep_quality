import sqlite3
from typing import Any
from app.database import get_connection
from app.schemas import SleepLogCreate


def row_to_dict(row: sqlite3.Row) -> dict[str, Any]:
    return {key: row[key] for key in row.keys()}


def create_sleep_log(payload: SleepLogCreate, predicted_energy_level: str | None) -> dict[str, Any]:
    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            """
            INSERT INTO sleep_logs (
                log_date,
                sleep_hours,
                bedtime_hour,
                wake_hour,
                mood,
                activity_level,
                predicted_energy_level,
                actual_energy_level
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                payload.log_date,
                payload.sleep_hours,
                payload.bedtime_hour,
                payload.wake_hour,
                payload.mood,
                payload.activity_level,
                predicted_energy_level,
                payload.actual_energy_level,
            ),
        )
        conn.commit()
        log_id = cursor.lastrowid
        cursor.execute("SELECT * FROM sleep_logs WHERE id = ?", (log_id,))
        row = cursor.fetchone()
        return row_to_dict(row)
    finally:
        conn.close()


def get_all_sleep_logs() -> list[dict[str, Any]]:
    conn = get_connection()
    try:
        rows = conn.execute(
            "SELECT * FROM sleep_logs ORDER BY log_date DESC, id DESC"
        ).fetchall()
        return [row_to_dict(row) for row in rows]
    finally:
        conn.close()


def get_logs_for_training() -> list[dict[str, Any]]:
    conn = get_connection()
    try:
        rows = conn.execute(
            """
            SELECT sleep_hours, bedtime_hour, wake_hour, mood, activity_level, actual_energy_level
            FROM sleep_logs
            WHERE actual_energy_level IS NOT NULL
            ORDER BY log_date ASC
            """
        ).fetchall()
        return [row_to_dict(row) for row in rows]
    finally:
        conn.close()


def get_latest_sleep_log() -> dict[str, Any] | None:
    conn = get_connection()
    try:
        row = conn.execute(
            "SELECT * FROM sleep_logs ORDER BY log_date DESC, id DESC LIMIT 1"
        ).fetchone()
        return row_to_dict(row) if row else None
    finally:
        conn.close()


def count_user_training_rows() -> int:
    conn = get_connection()
    try:
        row = conn.execute(
            "SELECT COUNT(*) AS c FROM sleep_logs WHERE actual_energy_level IS NOT NULL"
        ).fetchone()
        return int(row["c"])
    finally:
        conn.close()


def update_log_prediction(log_id: int, prediction: str) -> None:
    conn = get_connection()
    try:
        conn.execute(
            "UPDATE sleep_logs SET predicted_energy_level = ? WHERE id = ?",
            (prediction, log_id),
        )
        conn.commit()
    finally:
        conn.close()

def update_sleep_log_feedback(log_id: int, actual_energy_level: str) -> dict[str, Any] | None:
    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute(
            """
            UPDATE sleep_logs
            SET actual_energy_level = ?
            WHERE id = ?
            """,
            (actual_energy_level, log_id),
        )
        conn.commit()

        if cursor.rowcount == 0:
            return None

        row = conn.execute(
            "SELECT * FROM sleep_logs WHERE id = ?",
            (log_id,),
        ).fetchone()
        return row_to_dict(row) if row else None
    finally:
        conn.close()



def count_all_sleep_logs() -> int:
    conn = get_connection()
    try:
        row = conn.execute("SELECT COUNT(*) AS c FROM sleep_logs").fetchone()
        return int(row["c"])
    finally:
        conn.close()
