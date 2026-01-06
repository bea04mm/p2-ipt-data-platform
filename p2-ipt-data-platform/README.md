# IPT Data Platform - Source Databases

This folder contains the starting point for Project 2. It provides four PostgreSQL databases that simulate operational applications at IPT, each with realistic sample data covering the first semester of 2025/2026.

The idea is straightforward: start the databases, explore the data, then build your own data platform on top of them. You will add a warehouse database, create an ingestion mechanism to extract data from these sources, transform it with dbt, and visualize it with Metabase.

## What is included

Four source databases simulating IPT applications:

| Database        | Port | Description                                           |
| --------------- | ---- | ----------------------------------------------------- |
| issues_db       | 5432 | Maintenance issues reported by staff and students     |
| reservations_db | 5433 | Room reservations for classes, exams, and events      |
| attendance_db   | 5435 | Class summaries and student attendance records        |
| sigq_db         | 5436 | Quality management system (SIGQ) documents and audits |

There is also an Adminer instance on port 8080 for browsing the databases through a web interface, and a tools container with `psql` that you can use for database operations.

## Getting started

### Step 1: Start the containers

```bash
docker compose up -d --build
```

This starts all four source databases, the tools container, and Adminer. The databases are created with their schemas but without data yet. The `--build` flag ensures the tools container is built the first time.

### Step 2: Generate and load the sample data

```bash
./scripts/generate_and_load.sh
```

This script runs the Python generators locally to create realistic sample data, then uses the tools container (which has `psql`) to load it into each database. The generators use only the Python standard library, so no additional packages are needed on your machine.

After this step, you can explore the data using Adminer at http://localhost:8080 or by connecting directly with psql through the tools container:

```bash
docker compose exec tools psql -h issues_db -U issues_user -d issues_app
```

### Step 3: Build your data platform

From here, the project is yours. You will need to:

1. Add a warehouse database to the compose file
2. Create an ingestion mechanism to load data into the warehouse. You have several options:
   - SQL scripts using PostgreSQL's `dblink` extension
   - Bash scripts with `psql` and `COPY` commands
   - Python scripts with `psycopg2`
   - Airbyte (if you want to explore a dedicated integration tool)
3. Set up dbt to transform the raw data into staging and mart models
4. Connect Metabase to create dashboards

The tools container already has `psql` installed. You can extend the `tools/Dockerfile` to add dbt or other tools you need.

See the project sheet for detailed guidance on each approach.

## Database connections

When connecting from your host machine (for example, with psql or DBeaver):

| Database     | Host      | Port | User              | Password          | Database         |
| ------------ | --------- | ---- | ----------------- | ----------------- | ---------------- |
| Issues       | localhost | 5432 | issues_user       | issues_pass       | issues_app       |
| Reservations | localhost | 5433 | reservations_user | reservations_pass | reservations_app |
| Attendance   | localhost | 5435 | attendance_user   | attendance_pass   | attendance_app   |
| SIGQ         | localhost | 5436 | sigq_user         | sigq_pass         | sigq_app         |

When connecting from inside the Docker network (for example, from another container), use the service name instead of localhost (e.g., `issues_db` instead of `localhost`).

For Adminer at http://localhost:8080, use the service name as the server (e.g., `issues_db`).

## Data overview

The sample data covers the first semester of 2025/2026, from September 15 to December 19, with exam period in January.

**Issues database** contains around 250 maintenance issues reported across IPT buildings (blocks A, B, G, H, I, O, and student residences). Issues include electrical problems, HVAC failures, equipment malfunctions, plumbing issues, and more. Each issue has a status, priority, and may have comments from maintenance staff.

**Reservations database** has roughly 600 room reservations including regular class schedules for LEI and MEI-IoT courses, exams, thesis defenses, and special events. The rooms table includes details about capacity and available equipment.

**Attendance database** is the largest, with around 195 students, 16 course units, approximately 600 class sessions (summaries), and over 30,000 individual attendance records. Students are distributed across LEI years 1-3 and MEI-IoT year 1.

**SIGQ database** contains the quality management system data: 14 organizational processes, around 120 documents, 28 internal audits, and associated non-conformities, improvement opportunities, and corrective actions.

## Regenerating the data

If you want to generate fresh data or adjust the volume, you can run the generators directly:

```bash
# Generate 500 issues instead of the default 250
python3 generators/generate_issues.py --count 500 --output generated_data/issues_seed.sql

# Preview the output without saving to a file
python3 generators/generate_reservations.py | head -100

# Regenerate everything and reload
./scripts/generate_and_load.sh
```

The generators produce different data each time they run. If you want reproducible results, you can modify the scripts to use a fixed random seed.

## Project structure

```
p2-ipt-data-platform/
├── docker-compose.yml           # Container definitions
├── README.md                    # This file
├── source_databases/
│   ├── issues_db/init.sql       # Schema for issues app
│   ├── reservations_db/init.sql # Schema for reservations app
│   ├── attendance_db/init.sql   # Schema for attendance app
│   └── sigq_db/init.sql         # Schema for SIGQ platform
├── generators/
│   ├── generate_issues.py       # Issues data generator
│   ├── generate_reservations.py # Reservations data generator
│   ├── generate_attendance.py   # Attendance data generator
│   └── generate_sigq.py         # SIGQ data generator
├── scripts/
│   └── generate_and_load.sh     # Script to generate and load all data
└── generated_data/              # Generated SQL files (created by the script)
```

Students are expected to extend this structure by adding their own warehouse configuration, dbt project, and any other components needed for their data platform.

## Notes

All data is fictional but designed to be realistic for the IPT context. The course units, room codes, and organizational processes are based on real IPT structures, but people, issues, and events are generated.

The databases use PostgreSQL 15. If you use `dblink` or `postgres_fdw` for cross-database queries, you will need to enable those extensions in your warehouse database with `CREATE EXTENSION dblink;`.
