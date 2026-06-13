from fastapi import APIRouter, HTTPException, status

from app.ml.predictor import generate_explanation, generate_tip, predict_energy
from app.repository import get_latest_sleep_log, update_log_prediction
from app.schemas import PredictionResponse

router = APIRouter(tags=["prediction"])


@router.get("/predict", response_model=PredictionResponse)
def predict_next_day_energy():
    latest = get_latest_sleep_log()
    if not latest:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No sleep logs found. Add one log first.",
        )

    result = predict_energy(latest)
    prediction = result["prediction"]
    update_log_prediction(latest["id"], prediction)

    return {
        "prediction": prediction,
        "confidence": result["confidence"],
        "tip": generate_tip(latest, prediction),
        "explanation": generate_explanation(latest, prediction),
        "source_log_id": latest["id"],
        "model_status": result["model_status"],
    }
