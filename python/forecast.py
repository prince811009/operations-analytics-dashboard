from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_absolute_error, mean_squared_error


def load_sales_data(csv_path: Path) -> pd.DataFrame:
    dataframe = pd.read_csv(csv_path)

    required_columns = {"month", "sales"}
    missing_columns = required_columns - set(dataframe.columns)

    if missing_columns:
        missing = ", ".join(sorted(missing_columns))
        raise ValueError(f"Missing required CSV columns: {missing}")

    dataframe = dataframe[["month", "sales"]].copy()
    dataframe["month"] = dataframe["month"].astype(str)
    dataframe["sales"] = pd.to_numeric(dataframe["sales"], errors="coerce")
    dataframe = dataframe.dropna(subset=["sales"]).reset_index(drop=True)

    if len(dataframe) < 3:
        raise ValueError("At least 3 valid sales records are required.")

    return dataframe


def build_forecast(dataframe: pd.DataFrame) -> dict[str, object]:
    x = np.arange(len(dataframe), dtype=float).reshape(-1, 1)
    y = dataframe["sales"].to_numpy(dtype=float)

    model = LinearRegression()
    model.fit(x, y)

    fitted_values = model.predict(x)
    next_index = np.array([[float(len(dataframe))]])
    next_forecast = float(model.predict(next_index)[0])

    mae = float(mean_absolute_error(y, fitted_values))
    rmse = float(np.sqrt(mean_squared_error(y, fitted_values)))

    latest_sales = float(y[-1])
    growth_rate = (
        ((next_forecast - latest_sales) / latest_sales) * 100
        if latest_sales != 0
        else 0.0
    )

    if growth_rate > 5:
        trend = "increasing"
        recommendation = (
            "Projected sales show a positive trend. "
            "Prepare inventory and operational capacity for increased demand."
        )
    elif growth_rate < -5:
        trend = "decreasing"
        recommendation = (
            "Projected sales show a declining trend. "
            "Review demand drivers and possible operational bottlenecks."
        )
    else:
        trend = "stable"
        recommendation = (
            "Projected sales remain relatively stable. "
            "Continue monitoring monthly performance."
        )

    return {
        "model": "Linear Regression Baseline",
        "forecast_month": "next_period",
        "forecast_sales": round(next_forecast, 2),
        "latest_sales": round(latest_sales, 2),
        "growth_rate_percent": round(growth_rate, 2),
        "trend": trend,
        "mae": round(mae, 2),
        "rmse": round(rmse, 2),
        "recommendation": recommendation,
        "historical": [
            {
                "month": str(row.month),
                "sales": float(row.sales),
            }
            for row in dataframe.itertuples(index=False)
        ],
    }


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate a sales forecast JSON file from CSV data."
    )
    parser.add_argument(
        "--input",
        required=True,
        help="Path to the input CSV file.",
    )
    parser.add_argument(
        "--output",
        required=True,
        help="Path to the output JSON file.",
    )
    args = parser.parse_args()

    input_path = Path(args.input)
    output_path = Path(args.output)

    dataframe = load_sales_data(input_path)
    forecast_result = build_forecast(dataframe)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(
        json.dumps(forecast_result, indent=2),
        encoding="utf-8",
    )

    print(f"Forecast generated: {output_path}")
    print(f"Next forecast: {forecast_result['forecast_sales']}")
    print(f"RMSE: {forecast_result['rmse']}")
    print(f"MAE: {forecast_result['mae']}")


if __name__ == "__main__":
    main()