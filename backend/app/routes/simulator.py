from fastapi import APIRouter

from app.ml.predictor import generate_explanation, generate_tip, predict_energy
from app.repository import get_latest_sleep_log
from app.schemas import WhatIfRequest, WhatIfResponse

router = APIRouter(tags=["simulation"])


@router.post("/what-if", response_model=WhatIfResponse)
def run_what_if(payload: WhatIfRequest):
    scenario = payload.model_dump()
    scenario_result = predict_energy(scenario)
    baseline = None
    latest = get_latest_sleep_log()

    if latest:
        latest_result = predict_energy(latest)
        baseline = {
            "source_log_id": latest["id"],
            "prediction": latest_result["prediction"],
            "confidence": latest_result["confidence"],
        }

    return {
        "scenario_prediction": scenario_result["prediction"],
        "scenario_confidence": scenario_result["confidence"],
        "tip": generate_tip(scenario, scenario_result["prediction"]),
        "explanation": generate_explanation(scenario, scenario_result["prediction"]),
        "baseline": baseline,
        "model_status": scenario_result["model_status"],
    }
