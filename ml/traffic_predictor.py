"""Train and export a RandomForest model for Bengaluru travel time prediction."""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

DATA_PATH = Path("data/traffic_samples.csv")
MODEL_PATH = Path("artifacts/traffic_rf.pkl")
ONNX_PATH = Path("artifacts/traffic_rf.onnx")
TFLITE_PATH = Path("artifacts/traffic_rf.tflite")


@dataclass
class TrainingConfig:
    n_estimators: int = 300
    random_state: int = 42
    max_depth: int = 18


def synthesize_dataset(samples: int = 1200) -> pd.DataFrame:
    rng = np.random.default_rng(42)
    hour = rng.integers(0, 24, size=samples)
    day = rng.integers(0, 7, size=samples)
    precipitation = rng.gamma(2.0, 3.0, size=samples)

    silk_board = rng.normal(0.6, 0.15, size=samples).clip(0, 1)
    hebbal = rng.normal(0.5, 0.18, size=samples).clip(0, 1)
    marathahalli = rng.normal(0.55, 0.16, size=samples).clip(0, 1)

    base_delay = (
        8
        + (hour / 24) * 15
        + (day >= 5) * 5
        + precipitation * 0.8
        + silk_board * 12
        + hebbal * 10
        + marathahalli * 11
    )
    noise = rng.normal(0, 3, size=samples)
    delay = np.maximum(base_delay + noise, 1)

    return pd.DataFrame(
        {
            "hour": hour,
            "day": day,
            "precipitation": precipitation,
            "silk_board": silk_board,
            "hebbal": hebbal,
            "marathahalli": marathahalli,
            "delay_minutes": delay,
        }
    )


def train_model(data: pd.DataFrame, config: TrainingConfig) -> Pipeline:
    features = data.drop(columns=["delay_minutes"])
    target = data["delay_minutes"]

    x_train, x_test, y_train, y_test = train_test_split(
        features, target, test_size=0.2, random_state=config.random_state
    )

    model = Pipeline(
        [
            ("scaler", StandardScaler()),
            (
                "rf",
                RandomForestRegressor(
                    n_estimators=config.n_estimators,
                    random_state=config.random_state,
                    max_depth=config.max_depth,
                ),
            ),
        ]
    )
    model.fit(x_train, y_train)

    score = model.score(x_test, y_test)
    print(f"Model R^2 score: {score:.3f}")
    return model


def export_to_onnx(model: Pipeline, feature_names: list[str]) -> None:
    try:
        from skl2onnx import convert_sklearn
        from skl2onnx.common.data_types import FloatTensorType
    except ImportError:
        print("skl2onnx not installed; skipping ONNX export.")
        return

    initial_type = [("float_input", FloatTensorType([None, len(feature_names)]))]
    onnx_model = convert_sklearn(model, initial_types=initial_type)
    ONNX_PATH.parent.mkdir(parents=True, exist_ok=True)
    ONNX_PATH.write_bytes(onnx_model.SerializeToString())
    print(f"Saved ONNX model to {ONNX_PATH}")


def export_to_tflite() -> None:
    """Convert the ONNX model to TFLite if the converter stack is present."""
    try:
        import onnx
        from onnx_tf.backend import prepare
        import tensorflow as tf
    except ImportError:
        print("onnx, onnx-tf, or tensorflow not installed; skipping TFLite export.")
        return

    onnx_model = onnx.load(ONNX_PATH)
    tf_rep = prepare(onnx_model)
    tf_model_path = ONNX_PATH.parent / "tf_model"
    tf_rep.export_graph(str(tf_model_path))

    converter = tf.lite.TFLiteConverter.from_saved_model(str(tf_model_path))
    tflite_model = converter.convert()
    TFLITE_PATH.write_bytes(tflite_model)
    print(f"Saved TFLite model to {TFLITE_PATH}")


def main() -> None:
    data = synthesize_dataset()
    DATA_PATH.parent.mkdir(parents=True, exist_ok=True)
    data.to_csv(DATA_PATH, index=False)

    model = train_model(data, TrainingConfig())

    MODEL_PATH.parent.mkdir(parents=True, exist_ok=True)
    import joblib

    joblib.dump(model, MODEL_PATH)

    metadata = {
        "feature_order": [
            "hour",
            "day",
            "precipitation",
            "silk_board",
            "hebbal",
            "marathahalli",
        ]
    }
    (MODEL_PATH.parent / "metadata.json").write_text(json.dumps(metadata, indent=2))

    export_to_onnx(model, metadata["feature_order"])
    export_to_tflite()


if __name__ == "__main__":
    main()
