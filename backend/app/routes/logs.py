import sqlite3
from fastapi import APIRouter, HTTPException, status

from app.ml.predictor import predict_energy, train_model, retrain_model
from app.repository import (
    create_sleep_log,
    get_all_sleep_logs,
    update_sleep_log_feedback,
)
from app.schemas import (
    FeedbackRequest,
    FeedbackResponse,
    SleepLogCreate,
    SleepLogResponse,
)

router = APIRouter(tags=["logs"])


@router.post("/log", response_model=SleepLogResponse, status_code=status.HTTP_201_CREATED)
def save_daily_log(payload: SleepLogCreate):
    prediction_result = predict_energy(payload.model_dump())

    try:
        saved = create_sleep_log(
            payload=payload,
            predicted_energy_level=prediction_result["prediction"],
        )
    except sqlite3.IntegrityError as exc:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="A sleep log already exists for this date.",
        ) from exc

    if payload.actual_energy_level:
        train_model()

    return saved


@router.get("/logs", response_model=list[SleepLogResponse])
def list_logs():
    return get_all_sleep_logs()


@router.patch("/logs/{log_id}/feedback", response_model=FeedbackResponse)
def save_energy_feedback(log_id: int, payload: FeedbackRequest):
    updated = update_sleep_log_feedback(
        log_id=log_id,
        actual_energy_level=payload.actual_energy_level,
    )

    if updated is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Sleep log not found.",
        )

    retrain_result = retrain_model() if payload.auto_retrain else None

    return {
        "status": "updated",
        "message": (
            "Feedback saved and model retrained."
            if payload.auto_retrain
            else "Feedback saved. Auto retrain was skipped."
        ),
        "log": updated,
        "retrained": payload.auto_retrain,
        "retrain_result": retrain_result,
    }
