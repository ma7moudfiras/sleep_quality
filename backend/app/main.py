from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware

from app.config import get_static_dir, ensure_runtime_files
from app.database import init_db
from app.ml.predictor import load_or_train_model
from app.health import health_payload
from app.routes import charts, insights, logs, predict, retrain, simulator, status, weekly_report, web_ui


@asynccontextmanager
async def lifespan(app: FastAPI):
    ensure_runtime_files()
    init_db()
    load_or_train_model()
    yield


app = FastAPI(
    title="Sleep Quality Analyzer and Daily Energy Predictor API",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(logs.router)
app.include_router(predict.router)
app.include_router(charts.router)
app.include_router(retrain.router)
app.include_router(insights.router)
app.include_router(weekly_report.router)
app.include_router(simulator.router)
app.include_router(status.router)
app.include_router(web_ui.router)
app.mount("/static", StaticFiles(directory=str(get_static_dir())), name="static")


@app.get("/")
def root():
    return {
        "app": "Sleep Quality Analyzer and Daily Energy Predictor",
        "status": "running",
        "docs": "/docs",
        "user_interface": "/app",
        "endpoints": ["POST /log", "GET /logs", "PATCH /logs/{log_id}/feedback", "GET /predict", "GET /charts", "POST /retrain", "GET /insights", "GET /weekly-report", "POST /what-if", "GET /system-status"],
    }


@app.get("/health")
def health():
    return health_payload()
