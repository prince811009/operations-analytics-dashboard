from __future__ import annotations

import csv
import math
from pathlib import Path


def load_sales_data(csv_path: Path) -> list[dict[str, object]]:
    records: list[dict[str, object]] = []

    with csv_path.open(
        "r",
        encoding="utf-8-sig",
        newline="",
    ) as csv_file:
        reader = csv.DictReader(csv_file)

        if reader.fieldnames is None:
            raise ValueError("The CSV file has no header.")

        normalized_headers = {
            header.strip().lower()
            for header in reader.fieldnames
            if header
        }

        required_columns = {"month", "sales"}
        missing_columns = required_columns - normalized_headers

        if missing_columns:
            missing = ", ".join(sorted(missing_columns))
            raise ValueError(
                f"Missing required CSV columns: {missing}"
            )

        for row in reader:
            month = str(row.get("month", "")).strip()
            raw_sales = str(row.get("sales", "")).replace(",", "").strip()

            if not month and not raw_sales:
                continue

            try:
                sales = float(raw_sales)
            except ValueError as error:
                raise ValueError(
                    f"Invalid sales value for {month}: {raw_sales}"
                ) from error

            records.append({
                "month": month,
                "sales": sales,
            })

    if len(records) < 3:
        raise ValueError(
            "At least 3 valid sales records are required."
        )

    return records


def build_forecast(
    records: list[dict[str, object]],
) -> dict[str, object]:
    sales_values = [
        float(record["sales"])
        for record in records
    ]

    count = len(sales_values)
    x_values = list(range(count))

    x_mean = sum(x_values) / count
    y_mean = sum(sales_values) / count

    numerator = sum(
        (x - x_mean) * (y - y_mean)
        for x, y in zip(x_values, sales_values)
    )

    denominator = sum(
        (x - x_mean) ** 2
        for x in x_values
    )

    slope = numerator / denominator if denominator != 0 else 0.0
    intercept = y_mean - slope * x_mean

    fitted_values = [
        intercept + slope * x
        for x in x_values
    ]

    next_forecast = intercept + slope * count

    absolute_errors = [
        abs(actual - predicted)
        for actual, predicted in zip(
            sales_values,
            fitted_values,
        )
    ]

    squared_errors = [
        (actual - predicted) ** 2
        for actual, predicted in zip(
            sales_values,
            fitted_values,
        )
    ]

    mae = sum(absolute_errors) / count
    rmse = math.sqrt(sum(squared_errors) / count)

    latest_sales = sales_values[-1]

    growth_rate = (
        ((next_forecast - latest_sales) / latest_sales) * 100
        if latest_sales != 0
        else 0.0
    )

    if growth_rate > 5:
        trend = "increasing"
        recommendation = (
            "Projected sales show a positive trend. "
            "Prepare inventory and operational capacity "
            "for increased demand."
        )
    elif growth_rate < -5:
        trend = "decreasing"
        recommendation = (
            "Projected sales show a declining trend. "
            "Review demand drivers and possible "
            "operational bottlenecks."
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
        "historical": records,
    }