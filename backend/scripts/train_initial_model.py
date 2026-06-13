from app.database import init_db
from app.ml.predictor import train_model, MODEL_PATH

if __name__ == "__main__":
    init_db()
    train_model()
    print(f"Model trained and saved to: {MODEL_PATH}")
