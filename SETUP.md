# Setup: SQL Server data warehouse + dbt + Airflow on Docker

Status as of 2026-10-20: **tools installed and verified; database and SQL login not created yet.**

## What runs where

| Piece | Where | Purpose |
|---|---|---|
| SQL Server 2022 Developer | Installed on Windows, `localhost:1433` | The data warehouse engine |
| dbt-core + dbt-sqlserver | Docker image `lakehouse_lab/airflow-dbt` (own virtualenv) | Transformations and tests |
| Airflow 2.10 (LocalExecutor) | Docker, UI at `http://localhost:8080` | Scheduling, retries, run history |
| Postgres 16 | Docker, internal only (no host port) | Airflow's own metadata, not a data engine |

Containers reach Windows SQL Server through `host.docker.internal:1433`. Docker project name is `lakehouse_lab`, so it never mixes with other containers on the same Docker.

## Folder layout

```
lakehouse-pipeline-dbt/
  README.md  SETUP.md  PROJECT_SUMMARY.md
  docker/   Dockerfile, docker-compose.yml, .env.example, .env (git-ignored), dags/, logs/
  dbt/      dbt_project.yml, profiles.yml, models/ (silver, gold), tests/, macros/
  powerbi/  churn_bi report and semantic model
```

## Prerequisites
1. Docker Desktop running, with at least 4 GB memory (8 GB set here).
2. SQL Server running with **mixed-mode** logins (already true: `IsIntegratedSecurityOnly = 0`). Linux containers cannot use Windows authentication, so they need a SQL login.
3. Ports 8080 free.

## Install (already done once; repeat on a new machine)

All commands run from `docker\`.

1. Create `.env` from the template and fill in random values (never commit it, never paste it in chat):
   ```powershell
   Copy-Item .env.example .env
   ```
   The Fernet key can be made with: `python -c "import base64,os;print(base64.urlsafe_b64encode(os.urandom(32)).decode())"`
2. Build the image (Airflow + ODBC Driver 18 + dbt). One service only, to avoid a build race:
   ```powershell
   docker compose build airflow-init
   ```
3. Start Airflow:
   ```powershell
   docker compose up -d
   ```
4. Check health (should return `healthy`):
   ```powershell
   curl http://localhost:8080/health
   ```
5. Log in at `http://localhost:8080` as `admin`. The password is `AIRFLOW_ADMIN_PASSWORD` in `.env`.

## Create the warehouse database and login (run once, in SSMS or sqlcmd as an admin)

```sql
CREATE DATABASE lakehouse_lab;
GO
CREATE LOGIN lakehouse_dbt WITH PASSWORD = '<MSSQL_PASSWORD from .env>', CHECK_POLICY = OFF;
GO
USE lakehouse_lab;
CREATE USER lakehouse_dbt FOR LOGIN lakehouse_dbt;
ALTER ROLE db_owner ADD MEMBER lakehouse_dbt;
GO
CREATE SCHEMA bronze; GO
CREATE SCHEMA silver; GO
CREATE SCHEMA gold;   GO
CREATE SCHEMA semantic; GO
CREATE SCHEMA audit;  GO
```
The login has rights only inside `lakehouse_lab`. No existing database is touched.

## Check dbt reaches SQL Server
```powershell
docker compose run --rm dbt debug
```
Expected: `All checks passed!`. (Not yet run: needs the database and login above.)

## Daily use
| Task | Command |
|---|---|
| Start / stop | `docker compose up -d` / `docker compose stop` |
| Run dbt | `docker compose run --rm dbt run` |
| Test models | `docker compose run --rm dbt test` |
| Docs and lineage | `docker compose run --rm dbt docs generate` |
| Logs | `docker compose logs -f airflow-scheduler` |
| Remove this stack only | `docker compose down -v` (run only inside `docker\`) |

## Safety notes
- Never run `docker system prune`: other containers share this Docker.
- `.env` holds throwaway passwords and is git-ignored.
- All data in this project is synthetic.

## Verified vs not verified
| Item | State |
|---|---|
| Image builds; `dbt --version` shows dbt-sqlserver 1.12.1 | Verified |
| Airflow metadata DB and scheduler healthy, UI answers on 8080 | Verified |
| Container reaches SQL Server on port 1433 | Verified (TCP only) |
| dbt login to `lakehouse_lab` | **Not verified** (database not created) |
| Any DAG or dbt model | **Not built yet** |

## Next
Create the database (above), run `dbt debug`, then build the synthetic generator and bronze load (README steps 1 and 2).
