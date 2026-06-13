from fastapi import APIRouter, HTTPException, status

from app.ml.predictor import retrain_model
from app.schemas import RetrainResponse

router = APIRouter(tags=["training"])


@router.post("/retrain", response_model=RetrainResponse)
def retrain_energy_model():
    try:
        return retrain_model()
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Model retraining failed: {exc}",
        ) from exc
