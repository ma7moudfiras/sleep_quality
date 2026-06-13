from fastapi import APIRouter

from app.analytics import insights_payload
from app.schemas import InsightsResponse

router = APIRouter(tags=["insights"])


@router.get("/insights", response_model=InsightsResponse)
def get_insights():
    return insights_payload()
