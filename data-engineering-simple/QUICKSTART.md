# Quick Start

**Prerequisites:** Docker and Docker Compose only.

```bash
# 1. Start all services
cd quarto/BigData/Examples/data-engineering-simple
docker compose up -d --build

# 2. Wait for containers (~30 seconds), then run the pipeline
docker compose exec tools bash /scripts/run_pipeline.sh

# 3. Open dashboards
# Metabase: http://localhost:3000
# Adminer:  http://localhost:8080
```

## Metabase Database Connection

When setting up Metabase, use these credentials:

| Setting  | Value       |
| -------- | ----------- |
| Host     | `warehouse` |
| Port     | `5432`      |
| Database | `warehouse` |
| Username | `dbt_user`  |
| Password | `dbt_pass`  |

## Other Database Connections (for Adminer)

| Database     | Host              | User                | Password            | DB                 |
| ------------ | ----------------- | ------------------- | ------------------- | ------------------ |
| Issues       | `issues_db`       | `issues_user`       | `issues_pass`       | `issues_app`       |
| Reservations | `reservations_db` | `reservations_user` | `reservations_pass` | `reservations_app` |
| Warehouse    | `warehouse`       | `dbt_user`          | `dbt_pass`          | `warehouse`        |

## Useful Commands

```bash
# Re-run pipeline
docker compose exec tools bash /scripts/run_pipeline.sh

# Run dbt only
docker compose exec tools dbt run

# Open shell in tools container
docker compose exec tools bash

# Clean restart
docker compose down -v && docker compose up -d --build
```

See `README.md` for full documentation.
