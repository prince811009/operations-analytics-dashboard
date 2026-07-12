from __future__ import annotations

import tempfile
from pathlib import Path

from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware

from python.forecast import build_forecast, load_sales_data


app = FastAPI(
    title="Operations Forecast API",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=(
        r"^https://.*\.vercel\.app$"
        r"|^http://(localhost|127\.0\.0\.1):\d+$"
    ),
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health_check() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/forecast")
async def create_forecast(
    file: UploadFile = File(...),
) -> dict[str, object]:
    if not file.filename:
        raise HTTPException(
            status_code=400,
            detail="A CSV file is required.",
        )

    if not file.filename.lower().endswith(".csv"):
        raise HTTPException(
            status_code=400,
            detail="Only CSV files are accepted.",
        )

    contents = await file.read()

    if not contents:
        raise HTTPException(
            status_code=400,
            detail="The uploaded CSV file is empty.",
        )

    temporary_path: Path | None = None

    try:
        with tempfile.NamedTemporaryFile(
            suffix=".csv",
            delete=False,
        ) as temporary_file:
            temporary_file.write(contents)
            temporary_path = Path(temporary_file.name)

        dataframe = load_sales_data(temporary_path)
        return build_forecast(dataframe)

    except ValueError as error:
        raise HTTPException(
            status_code=400,
            detail=str(error),
        ) from error

    except Exception as error:
        raise HTTPException(
            status_code=500,
            detail=f"Forecast generation failed: {error}",
        ) from error

    finally:
        if temporary_path and temporary_path.exists():
            temporary_path.unlink()