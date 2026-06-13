from typing import Literal, Optional
from pydantic import BaseModel, Field

EnergyLevel = Literal["Low", "Medium", "High"]


class SleepLogCreate(BaseModel):
    log_date: str = Field(..., examples=["2026-05-30"])
    sleep_hours: float = Field(..., gt=0, le=24)
    bedtime_hour: float = Field(..., ge=0, lt=24, examples=[22.5])
    wake_hour: float = Field(..., ge=0, lt=24, examples=[6.5])
    mood: int = Field(..., ge=1, le=5)
    activity_level: int = Field(..., ge=1, le=5)
    actual_energy_level: Optional[EnergyLevel] = None


class SleepLogResponse(SleepLogCreate):
    id: int
    predicted_energy_level: Optional[EnergyLevel] = None
    created_at: str


class RetrainResponse(BaseModel):
    status: str
    message: str
    seed_rows: int
    user_training_rows: int
    total_training_rows: int
    model_status: str


class FeedbackRequest(BaseModel):
    actual_energy_level: EnergyLevel
    auto_retrain: bool = True


class FeedbackResponse(BaseModel):
    status: str
    message: str
    log: SleepLogResponse
    retrained: bool
    retrain_result: Optional[RetrainResponse] = None


class PredictionResponse(BaseModel):
    prediction: EnergyLevel
    confidence: float
    tip: str
    explanation: list[str]
    source_log_id: int
    model_status: str


class ChartPoint(BaseModel):
    date: str
    value: float


class ChartsResponse(BaseModel):
    sleep_trend: list[ChartPoint]
    energy_trend: list[ChartPoint]
    mood_trend: list[ChartPoint]
    activity_trend: list[ChartPoint]


class WeeklyReportResponse(BaseModel):
    days_count: int
    average_sleep: float
    average_mood: float
    average_activity: float
    most_common_energy: Optional[EnergyLevel] = None
    best_sleep_day: Optional[str] = None
    worst_sleep_day: Optional[str] = None
    sleep_debt: float
    streak_days: int


class InsightsResponse(BaseModel):
    sleep_consistency_score: int
    sleep_debt_this_week: float
    average_sleep: float
    average_mood: float
    average_activity: float
    most_common_energy: Optional[EnergyLevel] = None
    best_sleep_day: Optional[str] = None
    worst_sleep_day: Optional[str] = None
    streak_days: int
    personalization_level: str
    model_status: str
    recommendation: str
    data_quality_warnings: list[str]
    latest_explanation: list[str]


class WhatIfRequest(BaseModel):
    sleep_hours: float = Field(..., gt=0, le=24)
    bedtime_hour: float = Field(..., ge=0, lt=24)
    wake_hour: float = Field(..., ge=0, lt=24)
    mood: int = Field(..., ge=1, le=5)
    activity_level: int = Field(..., ge=1, le=5)


class BaselinePrediction(BaseModel):
    source_log_id: int
    prediction: EnergyLevel
    confidence: float


class WhatIfResponse(BaseModel):
    scenario_prediction: EnergyLevel
    scenario_confidence: float
    tip: str
    explanation: list[str]
    baseline: Optional[BaselinePrediction] = None
    model_status: str
