# lakehouse-pipeline-dbt

A dbt pipeline on SQL Server 2022 that takes raw Telco customer data through bronze, silver and gold layers, with tests at every layer and a Power BI report on top. Everything runs locally in Docker. Personal project, public data only.

## What it shows

| Skill | Where |
|---|---|
| Layered modeling (bronze, silver, gold) | `dbt/models/silver`, `dbt/models/gold` |
| Staging, intermediate and mart models | `stg_customers`, `stg_billing`, `int_customer_activity`, `fct_customer_churn`, `dim_customer` |
| Data quality tests | 27 tests: unique, not null, accepted values, relationships, and custom reconciliation tests in `dbt/tests` |
| Sources, macros, project config | `dbt/models/sources.yml`, `dbt/macros`, `dbt/dbt_project.yml` |
| Docs and lineage | `dbt docs generate` (lineage graph from bronze to gold) |
| Orchestration environment | Airflow in Docker (installed, **no DAG yet**) |
| Consumption | Power BI report (`powerbi/`) with a semantic model, 13 measures and a Descriptive / Diagnostic view |

## Data flow

```
Telco CSV (Kaggle)  ->  bronze.telco_customers   (loaded unchanged, all text)
tenure + TotalCharges -> bronze.telco_billing    (SYNTHETIC monthly rows, labeled)

bronze -> silver.stg_customers, silver.stg_billing -> silver.int_customer_activity
       -> gold.dim_customer, gold.fct_customer_churn -> Power BI
```

## Status

| Item | State |
|---|---|
| `dbt build` | 5 models, 27 tests: 31 passed, 1 expected warning, 0 errors |
| Warning | 11 customers with tenure 0 have a blank `TotalCharges` (kept as NULL on purpose) |
| Reconciliation | Billed total per customer equals `TotalCharges`; billing rows equal tenure months; gold counts equal silver |
| Power BI report | Opens in Desktop; Descriptive and Diagnostic pages work through bookmarks |
| Airflow | Installed and healthy; **no DAG yet** |
| Incremental models, snapshots (Type 2) | Not done |

## Honest limits
- The billing table is **synthetic**: the CSV has one row per customer and no monthly history. Billing dates are invented, so there are no real monthly trends.
- Loading uses local PowerShell scripts, not a production ingestion tool.
- SQL Server only. Postgres and Databricks versions are not started.
- Not tested in the Power BI service.

## Run it
See [`SETUP.md`](SETUP.md). In short: start Docker, then from `docker\`:

```powershell
docker compose up -d
docker compose exec dbt dbt build
docker compose exec dbt dbt docs generate
```

## Out of scope
Machine learning, and performance testing. Neither is part of this project.
