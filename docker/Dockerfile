FROM apache/airflow:2.10.5-python3.12

USER root
# Microsoft ODBC Driver 18 for SQL Server (Debian 12)
RUN apt-get update && apt-get install -y --no-install-recommends curl gnupg unixodbc-dev \
 && curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
 && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/debian/12/prod bookworm main" > /etc/apt/sources.list.d/mssql-release.list \
 && apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql18 \
 && rm -rf /var/lib/apt/lists/*

USER airflow
# dbt lives in its own virtualenv so its pins never clash with Airflow's
RUN python -m venv /home/airflow/dbt-venv \
 && /home/airflow/dbt-venv/bin/pip install --no-cache-dir dbt-core dbt-sqlserver pyodbc
ENV PATH="/home/airflow/dbt-venv/bin:${PATH}"
