# Operations Analytics Platform

A full-stack operations analytics platform built with Flutter, SQLite, SQL, Python, FastAPI, and machine-learning forecasting.

The application transforms uploaded CSV data into interactive dashboards, SQL query results, forecasting insights, management reports, and downloadable PDF reports.

## Overview

This project combines my professional experience in workflow digitization and reporting systems with my academic background in artificial intelligence and time-series forecasting.

Users can:

- Upload real CSV data
- Review KPI dashboards and trend charts
- Search, filter, sort, and export operational data
- Run read-only SQL queries against SQLite
- Generate forecasts through a Python FastAPI service
- Review MAE, RMSE, projected growth, and recommendations
- Export a management report as PDF

## Screenshots

### Dashboard

![Dashboard](screenshots/dashboard.png)

### Data Explorer

![Data Explorer](screenshots/data-explorer.png)

### SQL Query Explorer

![SQL Query Explorer](screenshots/sql-query.png)

### Forecast Analytics

![Forecast Analytics](screenshots/forecast.png)

### Management Report

![Management Report](screenshots/report.png)

## Core Features

### Dashboard

- Responsive SaaS-style interface
- Collapsible sidebar
- Total records, total sales, average sales, and growth KPIs
- Dynamic sales trend chart
- Recent imported records
- Data-driven operational recommendations

### CSV Import

- Upload real CSV files
- Validate required columns
- Parse and normalize sales records
- Update all application pages from shared imported data

Required CSV format:

```csv
month,sales
2025-01,120000
2025-02,135000
2025-03,128000

Data Explorer
Search records by month
Filter by minimum sales
Sort by sales value
Calculate filtered totals and averages
Export filtered results to CSV
SQLite and SQL Query Explorer
Store imported records in SQLite
Execute read-only SELECT queries
Display dynamic query columns and results
Provide reusable example queries

Example:
SELECT month, sales
FROM sales
WHERE sales > 150000
ORDER BY sales DESC;

Forecasting
Flutter sends imported data to FastAPI
Python processes the sales time series
Scikit-learn generates a linear-regression baseline
API returns forecast values and model metrics
Flutter displays historical and forecast trends
Includes MAE, RMSE, projected growth, and recommendations
Management Report
Total and average sales
Best and worst performing periods
Monthly growth calculations
Management recommendations
Downloadable PDF report
Architecture
CSV Upload
    |
    v
Flutter Data Model
    |
    +----------------------+
    |                      |
    v                      v
SQLite Database       Dashboard / Reports
    |                      |
    v                      v
SQL Query Explorer    Data Explorer
                           |
                           v
                    FastAPI Forecast API
                           |
                           v
                 Python / Pandas / NumPy
                           |
                           v
                Forecast Result + Metrics