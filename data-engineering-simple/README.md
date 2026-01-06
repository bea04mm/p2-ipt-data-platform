# IPT Data Platform - Simple Demo

A minimal working example of a modern data platform using ELT architecture.

This demo simulates two IPT operational systems (Issues App and Room Reservations App), extracts their data into a central warehouse, transforms it with dbt, and visualizes it with Metabase.

**No local installations required** — everything runs in Docker containers.

## What You'll Learn

1. **ELT Pattern**: Extract raw data first, transform inside the warehouse
2. **Data Warehousing**: Central repository combining multiple sources
3. **dbt**: SQL-based transformation tool with version control
4. **BI Dashboards**: Self-service analytics with Metabase

## Architecture

```
┌────────────────────┐    ┌────────────────────┐
│   Issues App DB    │    │ Reservations App DB│
│   (PostgreSQL)     │    │   (PostgreSQL)     │
└─────────┬──────────┘    └──────────┬─────────┘
          │                          │
          │   ┌──────────────────┐   │
          └──►│  Tools Container │◄──┘
              │  (psql + dbt)    │
              │                  │
              │  1. ingest.sh    │
              │  2. dbt run      │
              └────────┬─────────┘
                       │
                       ▼
          ┌────────────────────────┐
          │    Data Warehouse      │
          │    (PostgreSQL)        │
          │                        │
          │  raw.* → analytics.*   │
          └────────────┬───────────┘
                       │
            ┌──────────┴──────────┐
            ▼                     ▼
    ┌──────────────┐      ┌──────────────┐
    │   Metabase   │      │   Adminer    │
    │  Port: 3000  │      │  Port: 8080  │
    │ (Dashboards) │      │ (DB Browser) │
    └──────────────┘      └──────────────┘
```

## Quick Start (5 minutes)

### Step 1: Start Everything

```bash
cd quarto/BigData/Examples/data-engineering-simple

# Build and start all services (first time takes ~2 minutes)
docker compose up -d --build

# Check all containers are running
docker compose ps
```

You should see 6 containers: `ipt_issues_db`, `ipt_reservations_db`, `ipt_warehouse`, `ipt_tools`, `ipt_metabase`, `ipt_adminer`.

### Step 2: Run the Pipeline

```bash
# Run the complete ELT pipeline (ingestion + dbt transforms)
docker compose exec tools bash /scripts/run_pipeline.sh
```

This single command:

1. Extracts data from both source databases
2. Loads it into the warehouse's `raw` schema
3. Runs dbt to transform data into `analytics` schema

### Step 3: Explore the Results

**Adminer** (database browser): http://localhost:8080

- Connect to `warehouse` with user `dbt_user` / password `dbt_pass`
- Browse `raw` schema (original data) and `analytics` schema (transformed)

**Metabase** (dashboards): http://localhost:3000

- First time: create an admin account
- Add database connection (see below)
- Start building visualizations!

---

## Detailed Walkthrough

### Exploring Source Databases

Open Adminer at http://localhost:8080 and connect to each source:

| Database     | Server            | User                | Password            | DB Name            |
| ------------ | ----------------- | ------------------- | ------------------- | ------------------ |
| Issues App   | `issues_db`       | `issues_user`       | `issues_pass`       | `issues_app`       |
| Reservations | `reservations_db` | `reservations_user` | `reservations_pass` | `reservations_app` |

Notice how each database has its own schema. They don't know about each other — this is the **data silo problem**.

### Running Steps Individually

Instead of `run_pipeline.sh`, you can run each step separately:

```bash
# Step 1: Only run ingestion (Extract & Load)
docker compose exec tools bash /scripts/ingest_docker.sh

# Step 2: Only run dbt transforms
docker compose exec tools dbt run
```

### Connecting Metabase to the Warehouse

When adding a database in Metabase:

- **Database type**: PostgreSQL
- **Host**: `warehouse` (Docker network name)
- **Port**: `5432`
- **Database name**: `warehouse`
- **Username**: `dbt_user`
- **Password**: `dbt_pass`

### Useful Commands

```bash
# View logs from any container
docker compose logs -f warehouse
docker compose logs -f tools

# Open a shell in the tools container
docker compose exec tools bash

# Run dbt commands interactively
docker compose exec tools dbt run
docker compose exec tools dbt test
docker compose exec tools dbt docs generate

# Query the warehouse directly
docker compose exec tools psql "$WAREHOUSE" -c "SELECT * FROM analytics.mart_rooms;"

# Restart everything
docker compose down && docker compose up -d --build
```

---

## Understanding the Data Flow

### Layer 1: Source Systems (OLTP)

These simulate real operational apps:

- **Issues App**: Staff report maintenance problems
- **Reservations App**: Users book rooms

Each has its own database, schema, and business logic.

### Layer 2: Raw Layer (Extract & Load)

The `raw` schema contains exact copies of source data:

- No transformations
- Added metadata (`_source`, `_loaded_at`)
- Preserves original data for auditing

### Layer 3: Staging & Marts (Transform)

dbt transforms raw data into analytics-ready tables:

- **Staging models** (`stg_*`): Clean and standardize
- **Mart models** (`mart_*`): Join sources, calculate metrics

```
raw.issues ──► analytics.stg_issues ──┐
raw.rooms  ──► analytics.stg_rooms  ──┼──► analytics.mart_rooms
raw.reservations ──► analytics.stg_reservations ──┘
```

### Layer 4: Serving (Dashboards)

Metabase connects to the `analytics` schema and provides:

- Self-service queries
- Visualizations and charts
- Shareable dashboards

---

## Creating Your First Dashboard (Metabase)

After running the pipeline, open Metabase at http://localhost:3000:

### Initial Setup (first time only)

1. Create an admin account (any email/password)
2. Click **"I'll add my data later"** to skip the initial wizard
3. Go to **Settings** (gear icon) → **Admin settings** → **Databases** → **Add database**
4. Fill in:
   - **Type**: PostgreSQL
   - **Display name**: IPT Warehouse
   - **Host**: `warehouse`
   - **Port**: `5432`
   - **Database**: `warehouse`
   - **Username**: `dbt_user`
   - **Password**: `dbt_pass`
5. Click **Save**

### Create a Quick Chart

1. Click **+ New** → **Question**
2. Select **IPT Warehouse** → **Analytics** → **Mart Rooms**
3. Click **Visualize** to see a table of all rooms
4. Change visualization: click the **chart icon** → select **Bar**
5. Configure: X-axis = `room_code`, Y-axis = `open_issues`
6. Click **Save** → name it "Issues by Room"

### Dashboard Ideas

Once comfortable, try building these:

1. **Room Health Overview**: Table from `mart_rooms` showing room_code, health_status, open_issues
2. **Issues by Building**: Bar chart from `mart_buildings` (building_code vs total_issues)
3. **Open Issues List**: Filtered table from `mart_issues` where status = 'open'
4. **Room Utilization**: Horizontal bar from `mart_rooms` (utilization_pct_90d by room)

---

## Files Overview

```
data-engineering-simple/
├── docker-compose.yml              # All services
├── tools/
│   └── Dockerfile                  # psql + dbt container
├── source_databases/
│   ├── issues_db/init.sql          # Issues app schema + data
│   └── reservations_db/init.sql    # Reservations schema + data
├── scripts/
│   ├── run_pipeline.sh             # Full pipeline runner
│   ├── ingest_docker.sh            # Extract & Load script
│   └── ingest.sh                   # (for local psql, if needed)
├── dbt/
│   ├── dbt_project.yml
│   ├── profiles.yml                # DB connection (Docker + local)
│   └── models/
│       ├── sources.yml
│       ├── staging/                # stg_issues, stg_rooms, stg_reservations
│       └── marts/                  # mart_rooms, mart_issues, mart_buildings
└── README.md
```

---

## Cleanup

```bash
# Stop all containers
docker compose down

# Stop and remove all data (fresh start)
docker compose down -v
```

---

## Troubleshooting

**Containers not starting?**

```bash
docker compose logs issues_db
docker compose logs warehouse
```

**Pipeline fails?**

```bash
# Check if databases are healthy
docker compose ps

# Try running ingestion manually to see errors
docker compose exec tools bash /scripts/ingest_docker.sh
```

**dbt errors?**

```bash
# Test database connection
docker compose exec tools dbt debug

# See detailed output
docker compose exec tools dbt run --debug
```

**Metabase can't connect?**

- Use hostname `warehouse` (not `localhost`)
- Port is `5432` (internal Docker port, not 5434)

---

## Next Steps

This demo shows the foundation. To extend it:

1. **Add more sources**: Create additional `*_db` services
2. **Add dbt tests**: Data quality checks
3. **Schedule refreshes**: Use cron or Airflow
4. **Use Airbyte**: Replace bash scripts with a proper ingestion tool
