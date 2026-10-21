# lakehouse-pipeline-dbt: summary

Updated: 2026-10-21. Scope: a **dbt pipeline** (bronze, silver, gold) on SQL Server with a Power BI report on top. Machine learning (predictive and prescriptive tiers) and performance testing are out of scope.

## What was built

| Layer | Objects (in `lakehouse_lab` on SQL Server 2022) | Rows |
|---|---|---|
| bronze | `telco_customers` (Kaggle CSV, all text), `telco_billing` (**synthetic**, derived from tenure and TotalCharges), `raw_events` + `ref_device` (synthetic pose events, kept for performance tests) | 7,043 / 227,990 / 50,000 / 200 |
| silver | `stg_customers`, `stg_billing`, `int_customer_activity` | 7,043 / 227,990 / 7,043 |
| gold | `dim_customer`, `fct_customer_churn` | 7,043 / 7,043 |

Tooling: dbt 1.12 (dbt-sqlserver) and Airflow 2.10 in Docker (project `lakehouse_lab`), SQL Server on Windows, loaders in PowerShell (local, git-ignored).

## Verified
- `dbt build`: 5 models, 27 tests, PASS=31, WARN=1, ERROR=0.
- The one warning is expected: 11 customers with tenure 0 have a blank `TotalCharges` (kept as NULL, flagged by a `warn` test).
- Reconciliation: billed total per customer equals `TotalCharges` (0 mismatches); billing rows equal tenure months; gold row counts equal silver.
- Docs site and lineage generated (`dbt docs generate`, served on `localhost:8085`).

## Results from gold (real Telco columns)
Overall churn 26.5% (1,869 of 7,043). By contract: month-to-month 42.7%, one year 11.3%, two year 2.8%.

## Honest limits
- Billing history is **synthetic**: the CSV has no monthly rows. Billing dates are invented, so monthly trend charts would be artificial.
- SQL Server has no native lakehouse. Schemas imitate bronze/silver/gold; Delta/Parquet behaviour needs Databricks.
- The performance work (double explode, join skew, scaling, recovery) is **not done**. Only the pose-event bronze data exists; the scorecard is empty.
- Airflow is installed and healthy but has **no DAG** yet. Loads are manual PowerShell scripts.
- Postgres and Databricks versions are not started.

## Not done / next
1. Four-Tier BI Framework on `gold`: descriptive and diagnostic dashboards, then a churn model (predictive), then a what-if and ranking (prescriptive).
2. Airflow DAG: load, `dbt build`, publish.
3. Silver/gold for the pose-event data and the performance scorecard.
4. Repeat on Postgres and Databricks.

## Where things are
`SETUP.md` (install and run), `EXPLORE_BRONZE.md` (pose data), `dbt\` (models, tests, macros), `docker\` (Dockerfile, compose, `.env` git-ignored), `scripts\` and `data\` (local, git-ignored).
