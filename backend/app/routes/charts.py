from fastapi import APIRouter

from app.ml.predictor import energy_score
from app.repository import get_all_sleep_logs
from app.schemas import ChartsResponse

router = APIRouter(tags=["charts"])


@router.get("/charts", response_model=ChartsResponse)
def get_chart_data():
    logs = list(reversed(get_all_sleep_logs()))

    return {
        "sleep_trend": [
            {"date": item["log_date"], "value": float(item["sleep_hours"])} for item in logs
        ],
        "energy_trend": [
            {"date": item["log_date"], "value": energy_score(item["predicted_energy_level"])}
            for item in logs
        ],
        "mood_trend": [
            {"date": item["log_date"], "value": float(item["mood"])} for item in logs
        ],
        "activity_trend": [
            {"date": item["log_date"], "value": float(item["activity_level"])}
            for item in logs
        ],
    }
