from fastapi import APIRouter

from app.analytics import weekly_report_payload
from app.schemas import WeeklyReportResponse

router = APIRouter(tags=["insights"])


@router.get("/weekly-report", response_model=WeeklyReportResponse)
def get_weekly_report():
    return weekly_report_payload()
