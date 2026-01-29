# IPT Data Platform - Complete Analytics Solution

This project implements a comprehensive, containerized data platform for IPT (Instituto Politécnico de Tomar), designed to centralize data from multiple operational systems and provide analytical and visualization capabilities using an open-source analytics stack.


## Project Overview

The platform is built on a Docker-based architecture and applies **ELT (Extract, Load, Transform)** principles to data integration and analytics. The platform centralizes operational data from multiple PostgreSQL source systems into a dedicated integration warehouse, while analytical and CSV-based datasets are ingested separately into an analytics database managed by dbt.

Rather than using a single database for all workloads, the platform adopts a two-database architecture by design:

- **Integration Warehouse**: One PostgreSQL database consolidates operational data from all source systems
- **Analytics Database**: A separate PostgreSQL database hosts dbt transformations, analytical models, and CSV seed data

Analytics and reporting are provided through Metabase, which queries the analytics-ready datasets.


## Architecture Layers

1. **Source Layer (OLTP Databases)**: Four PostgreSQL databases representing independent operational systems (Issues, Reservations, Attendance, and SIGQ), each initialized with its own schema and data.

2. **Ingestion Layer**: SQL-based extraction and loading processes that transfer operational data from source databases into the integration warehouse.

3. **Integration Warehouse Layer**: A centralized PostgreSQL database (ipt_warehouse) responsible for consolidating and storing raw or lightly processed operational data from all source systems.

4. **Analytics & Transformation Layer**: A separate PostgreSQL database (ipt_analytics) managed by dbt, where CSV files are ingested using dbt seeds, data is transformed through staging and mart models, and analytics-ready datasets are produced.

5. **Visualization Layer**: Metabase is used to create dashboards and reports.


### Architectural Decision: Separate Warehouse and Analytics Databases

The separation between the integration warehouse (ipt_warehouse) and the analytics database (ipt_analytics) is an intentional architectural decision.

This approach allows:

- **Isolation of raw operational data from analytical transformations**
- **Independent management of ingestion and analytics workloads**
- **Safer experimentation and modeling in the analytics layer without affecting raw data**

### Alternative Architecture (Single-Warehouse dbt Target)

An alternative design would be to run dbt directly against the integration warehouse, materializing analytical models inside the same database. This could be achieved with the following dbt configuration:

```yaml
ipt_warehouse:
    outputs:
        dev:
            type: postgres
            host: warehouse_db
            port: 5432
            user: warehouse_user
            password: warehouse_pass
            dbname: ipt_warehouse
            schema: analytics
            threads: 4
    target: dev
```

In this scenario, dbt models (including seeds, staging, and marts) would be created directly inside the warehouse database.

### Chosen Approach

For this project, the decision was made to separate operational data integration from analytical modeling by maintaining distinct databases. This results in a clearer separation of concerns and better reflects real-world analytics architectures where raw and analytical layers are isolated.

## System Components

### Source Databases

Five operational databases provide data for the platform:

| Database        | Port | Purpose                                               |
| --------------- | ---- | ----------------------------------------------------- |
| issues_db       | 5432 | Maintenance issue tracking system for buildings       |
| reservations_db | 5433 | Room booking system for classes, exams, and events    |
| attendance_db   | 5435 | Student attendance and class session management        |
| sigq_db         | 5436 | Quality management system for processes and audits     |
| ipt_analytics   | 5441 | Student questionnaire results (custom implementation)  |

### Analytics Infrastructure

- **Warehouse Database** (port 5440): Central PostgreSQL repository for consolidated and transformed data
- **ipt_analytics Database** (port 5441): PostgreSQL database targeted by dbt, responsible for:
                    Ingesting CSV-based datasets via dbt seeds

                    Storing staging and mart models

                    Hosting analytics-ready tables
- **Metabase** (port 3000): Web-based business intelligence and dashboard platform
- **Adminer**: Web-based database browser on port 8080
- **Tools Container**: Utility container with psql and automation scripts
- **dbt Container**: Dedicated container for running dbt transformations

## Getting Started

### Prerequisites

- Docker and Docker Compose
- Python 3 (for running data generators)
- Approximately 2GB of disk space for the databases

### Step 1: Start the Containers

```bash
docker compose up -d --build
```

This command:
- Starts four PostgreSQL source databases with their schemas initialized
- Starts the ipt_analytics database for questionnaire data and dbt transformations
- Creates the warehouse database for consolidated data
- Starts Metabase (port 3000) for dashboard creation
- Starts Adminer for web-based database browsing (port 8080)
- Builds and starts the tools container and dbt runner

The `--build` flag ensures the tools container is built the first time (required for custom configurations).

### Step 2: Generate and Load Sample Data

```bash
./scripts/generate_and_load.sh
```

**Why Python Generators?**

Instead of using static CSV files, the platform uses Python-based data generators that:
- Create realistic, varied data across multiple runs
- Generate proper relationships and referential integrity
- Simulate realistic distributions (e.g., attendance patterns, issue severity)
- Allow easy volume scaling for testing (adjust `--count` parameter)
- Use only Python standard library (no external dependencies needed on host)

This script:
1. Runs Python locally to generate SQL INSERT statements
2. Uses the tools container's psql to load data into each source database
3. Populates approximately 30,000 attendance records, 250 issues, 600+ reservations, and SIGQ audit data

Sample data covers September 15 - December 19, 2025, with exam period in January 2026.

### Step 3: Explore the Data

**Using Adminer (Web UI):**
- Open http://localhost:8080
- Server: `issues_db`, `reservations_db`, `attendance_db`, or `sigq_db`
- Use the credentials in the Connection Details section

**Using psql CLI:**
```bash
docker compose exec tools psql -h issues_db -U issues_user -d issues_app
```

### Step 4: Data Transformation with dbt

The dbt project applies the ELT pattern, transforming raw data from source databases into the warehouse:

**Staging Layer (`models/staging/`)**:
- Raw data cleansing and standardization
- Column naming conventions
- Data type casting
- Calculated fields (e.g., resolution hours for issues)
- Materialized as views for efficiency

**Mart Layer (`models/marts/`)**:
- Business-ready dimensional and fact tables
- Aggregations and calculated metrics
- Customer-facing data models
- Materialized as tables for query performance

**Example transformation flow:**
- Raw `issues` table → `stg_issues` (cleaned) → stored in warehouse
- Raw attendance records → `stg_*` models → `dim_students` (comprehensive student dimension)

To run dbt transformations:
```bash
docker compose exec dbt dbt run
```

### Step 5: Connect to Warehouse Database

The warehouse database (`ipt_warehouse`) runs on port 5440 and contains consolidated data from all sources, ready for dbt transformations:

```bash
# From host machine
psql -h localhost -p 5440 -U warehouse_user -d ipt_warehouse

# From tools container
docker compose exec tools psql -h warehouse_db -U warehouse_user -d ipt_warehouse
```

Default credentials: `warehouse_user` / `warehouse_pass`

### Step 6: Access Analytics Database

The ipt_analytics database (port 5441) is used by dbt for transformations and stores student questionnaire data:

```bash
# From host machine
psql -h localhost -p 5441 -U dbt_user -d ipt_analytics

# From tools container
docker compose exec tools psql -h ipt_analytics -U dbt_user -d ipt_analytics
```

Default credentials: `dbt_user` / `dbt_password`

### Step 7: Visualization with Metabase

The platform includes Metabase (port 3000) for creating dashboards:
- Access: http://localhost:3000
- Connect to the warehouse database for analytics queries
- Build visualizations from transformed data in the warehouse
- Create interactive dashboards for business intelligence

## Design Decisions and Rationale

### Why Docker Compose?

- **Environment Consistency**: Ensures all team members work with identical database versions and configurations
- **Easy Setup**: Single command to spin up the entire platform
- **Isolation**: Each service runs in its own container without system-level conflicts
- **Scalability**: Simple to add new services or replicate for testing

### Why ELT Pattern (Extract, Load, Transform)?

Instead of ETL (Extract, Transform, Load), we use ELT:
- **Data Preservation**: Raw data is loaded as-is, preserving audit trail
- **Flexibility**: Transformations can be versioned and modified without re-ingesting
- **Performance**: Load operations don't require transformation overhead
- **Separation of Concerns**: Ingestion and transformation are independent

### Why dbt for Transformation?

dbt (data build tool) provides:
- **SQL-First Development**: Transformations in familiar SQL, not proprietary languages
- **Version Control**: All transformation logic is code and can be tracked in Git
- **Modularity**: Staging models feed into marts, enabling reusability
- **Testing & Documentation**: Built-in support for data quality tests and auto-generated docs
- **DAG Management**: Automatic dependency resolution (knows which models to run first)
- **Scalability**: Runs on the target database (PostgreSQL) without requiring additional infrastructure

### Why Separate Staging and Mart Layers?

- **Staging Layer**: Acts as a quality gate, cleaning inconsistent source data before business use
- **Mart Layer**: Provides stable, documented interfaces for analytics teams
- **Change Isolation**: Updates to source data don't require rewriting all downstream logic
- **Lineage Clarity**: Clear data flow from raw → cleaned → business-ready

## Database Connection Details

### From Host Machine

When connecting with psql, DBeaver, or other clients:

| Database     | Host      | Port | User              | Password          | Database         |
| ------------ | --------- | ---- | ----------------- | ----------------- | ---------------- |
| Issues       | localhost | 5432 | issues_user       | issues_pass       | issues_app       |
| Reservations | localhost | 5433 | reservations_user | reservations_pass | reservations_app |
| Attendance   | localhost | 5435 | attendance_user   | attendance_pass   | attendance_app   |
| SIGQ         | localhost | 5436 | sigq_user         | sigq_pass         | sigq_app         |
| Questionnaires | localhost | 5441 | dbt_user          | dbt_password      | ipt_analytics    |
| Warehouse    | localhost | 5440 | warehouse_user    | warehouse_pass    | ipt_warehouse    |

### From Docker Network

When connecting from inside containers (tools, dbt runner, etc.), use the service name instead of localhost:

```bash
# From tools container, connect to issues_db
psql -h issues_db -U issues_user -d issues_app
```

For Adminer at http://localhost:8080, use service names (e.g., `issues_db`, `ipt_analytics`)

## Data Overview

Sample data covers September 15 - December 19, 2025, with exam period in January 2026.

### Issues Database
- **~250 maintenance issues** across IPT buildings (blocks A, B, G, H, I, O, student residences)
- Issue types: electrical problems, HVAC failures, equipment malfunctions, plumbing issues, etc.
- Tracked attributes: status, priority, assignment, resolution notes
- Realistic time-to-resolution patterns (minutes to weeks depending on severity)

### Reservations Database
- **~600 room reservations** for classes, exams, thesis defenses, special events
- Coverage includes LEI and MEI-IoT course schedules
- Room information: capacity, available equipment, location
- Supports class timetable generation and exam scheduling

### Attendance Database
- **~195 students** (LEI years 1-3, MEI-IoT year 1)
- **16 course units** across both programs
- **~600 class sessions** with comprehensive summaries
- **30,000+ attendance records** showing student presence patterns
- Largest dataset for analytics and student performance analysis

### SIGQ Database
- **14 organizational processes** in the quality management system
- **~120 documents** including policies, procedures, and guidelines
- **28 internal audits** with findings and follow-ups
- Non-conformities, improvement opportunities, and corrective actions

### Student Questionnaire Database (ipt_analytics)
- **Custom implementation** added to enrich the analytics platform
- Collects feedback and responses from newly enrolled students
- Integrates with attendance and course data for comprehensive student profiling
- Data feeds directly into student-focused dashboards and analytics

## Advanced Usage

### Regenerating Data with Different Volumes

The Python generators support customization:

```bash
# Generate 500 issues instead of the default 250
python3 generators/generate_issues.py --count 500 --output generated_data/issues_seed.sql

# Preview output without writing file
python3 generators/generate_reservations.py | head -100

# Regenerate all data from scratch
./scripts/generate_and_load.sh
```

The generators produce different realistic data each run. For reproducible results, modify generator scripts to use a fixed random seed.

### Running dbt Transformations

Transform raw data into analytics-ready tables:

```bash
# Run all dbt models
docker compose exec dbt dbt run

# Generate documentation
docker compose exec dbt dbt docs generate

# Run data quality tests
docker compose exec dbt dbt test
```

### PostgreSQL Extensions

To enable advanced features in the warehouse database (for FDW):

```bash
docker compose exec warehouse_db psql -U warehouse_user -d ipt_warehouse -c "CREATE EXTENSION IF NOT EXISTS postgres_fdw;"
```

To enable `dblink` in the analytics database:

```bash
docker compose exec ipt_analytics psql -U dbt_user -d ipt_analytics -c "CREATE EXTENSION IF NOT EXISTS dblink;"
```

## Project Structure

```
p2-ipt-data-platform/
├── docker-compose.yml              # Container definitions and services
├── README.md                       # This file
├── dbt_project/                    # dbt transformation project
│   ├── dbt_project.yml            # dbt configuration
│   ├── profiles.yml               # Database connection profiles
│   ├── models/
│   │   ├── staging/               # Raw data cleansing (views)
│   │   └── marts/                 # Business models (tables)
│   └── seeds/                     # Static reference data CSVs
├── source_databases/               # Source database schemas
│   ├── issues_db/init.sql
│   ├── reservations_db/init.sql
│   ├── attendance_db/init.sql
│   └── sigq_db/init.sql
├── generators/                     # Data generation scripts
│   ├── generate_issues.py
│   ├── generate_reservations.py
│   ├── generate_attendance.py
│   └── generate_sigq.py
├── scripts/                        # Automation scripts
│   ├── generate_and_load.sh       # Main setup script
│   ├── run.sh                     # Start environment
│   └── ingest.sh                  # Data ingestion script
├── generated_data/                 # Output directory for generated SQL files
├── metabase_data/                 # Metabase configuration and dashboards
└── tools/                          # Utility container Dockerfile
```

## Key Implementation Details

### Data Ingestion

The platform uses a **pull-based ingestion model**:
1. Python generators create SQL INSERT statements
2. Scripts execute INSERT statements through psql into source databases
3. Warehouse database consolidates data from all sources
4. dbt transforms raw warehouse data into cleaned staging and mart tables
5. Metabase queries the warehouse for visualization

This approach balances:
- **Simplicity**: No external ETL tool required initially
- **Transparency**: SQL statements are human-readable and versionable
- **Scalability**: Can be replaced with Airbyte or other tools later
- **Flexibility**: Warehouse acts as a central hub for all sources

### Transformation Pipeline

The dbt project implements a **medallion architecture**:
- **Bronze/Raw**: Data consolidated in warehouse from all source systems
- **Silver/Staging**: Cleaned, deduplicated, standardized data in ipt_analytics
- **Gold/Marts**: Aggregated, business-ready fact and dimension tables in ipt_analytics

Models are organized by layer with clear dependencies managed by dbt. Transformations run on the ipt_analytics database.

### Why This Architecture?

1. **Separation of Concerns**: Ingestion, transformation, and analytics are independent
2. **Maintainability**: Changes to transformation don't require re-ingestion
3. **Scalability**: Can swap components (generators → Airbyte, dbt → Apache Spark) without breaking others
4. **Learning Value**: Students experience production data platform patterns
5. **Transparency**: SQL-based transformations are auditable and version-controlled

## Data Warehouse Integration Strategies

The warehouse database needs access to data from source systems. The platform supports two integration approaches:

### Strategy 1: Live Link Using PostgreSQL Foreign Data Wrappers (FDW)

This approach creates real-time connections between the warehouse and source databases. Use this for:
- Real-time or near-real-time analytics
- When source data changes frequently
- To avoid data duplication

**Setup Instructions:**

```sql
-- 1. Enable the extension in the Warehouse
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- 2. Create a "Server" definition for the Issues DB
-- Note: Use the container name (from docker-compose) as the host
CREATE SERVER issues_server 
FOREIGN DATA WRAPPER postgres_fdw 
OPTIONS (host 'ipt_issues_db', dbname 'issues_app', port '5432');

-- 3. Map the User
-- Allow warehouse_user to login to issues_server as issues_user
CREATE USER MAPPING FOR warehouse_user
SERVER issues_server 
OPTIONS (user 'issues_user', password 'issues_pass');

-- 4. Import the Schema
-- This creates "foreign tables" in the warehouse pointing to real data
IMPORT FOREIGN SCHEMA public 
FROM SERVER issues_server 
INTO issues_schema;
```

Repeat this process for each source database (reservations_db, attendance_db, sigq_db, ipt_analytics).

**Advantages:**
- Real-time data access
- No data duplication
- Simple setup

**Disadvantages:**
- Network dependent
- Query performance depends on network latency
- Less control over data quality

### Strategy 2: Python Worker with Scheduled Ingestion

This approach uses ETL scripts that periodically extract, transform, and load data. Use this for:
- Batch processing and scheduled updates
- Data cleansing before loading
- Complete control over ingestion logic

**Implementation:**

Create a scheduled Python worker or bash script (e.g., `scripts/ingest.sh`) that:
1. Connects to each source database
2. Extracts relevant data
3. Applies transformations
4. Loads into warehouse using COPY or INSERT

This can be run as a cron job for scheduled execution:

```bash
# Run ingest script every hour
0 * * * * /path/to/scripts/ingest.sh >> /var/log/ingest.log 2>&1
```

**Advantages:**
- Batch optimization
- Full control over data quality
- Can implement complex transformations
- Predictable performance

**Disadvantages:**
- Data latency (depends on schedule)
- More complex to implement
- Storage overhead (full copies)

### Recommended Approach

For this project, we recommend **Strategy 1 (FDW)** for development and learning because:
- Simpler to set up
- Demonstrates real database linking concepts
- Good for exploring source data structures
- Can transition to Strategy 2 for production

## Data Ingestion

Once your warehouse has access to source data (via FDW or ETL), populate it using the ingest script:

```bash
./scripts/ingest.sh
```

This script:
- Extracts data from source databases
- Loads it into the warehouse database
- Prepares data for dbt transformations

After running this script, the warehouse contains all necessary data for analytics.

## dbt Transformation Commands

Essential dbt commands for managing transformations:

```bash
# Load static reference data from CSV seeds
docker compose exec dbt dbt seed --full-refresh

# Run all dbt models (staging and marts)
docker compose exec dbt dbt run

# Run specific model and its dependencies
docker compose exec dbt dbt run --select +dim_students

# Test data quality rules
docker compose exec dbt dbt test

# Generate documentation
docker compose exec dbt dbt docs generate

# View compiled SQL
docker compose exec dbt dbt parse
```

**Common Workflows:**

```bash
# Full refresh after major changes
docker compose exec dbt dbt seed --full-refresh && docker compose exec dbt dbt run

# Build and test a specific model
docker compose exec dbt dbt run --select dim_students && docker compose exec dbt dbt test --select dim_students

# Check for upstream/downstream dependencies
docker compose exec dbt dbt parse && docker compose exec dbt dbt list --select +dim_students
```

## Troubleshooting

**FDW Connection Issues:**
- Verify container names match docker-compose service names (e.g., `ipt_issues_db`, `ipt_warehouse_db`)
- Check credentials are correct for source databases
- Ensure network connectivity: `docker compose exec warehouse_db ping ipt_issues_db`
- Make sure `postgres_fdw` extension is created in warehouse database

**dbt Transformation Failures:**
- Check source data exists in warehouse using `SELECT * FROM public.issues LIMIT 5;`
- Review dbt logs: `docker compose exec dbt cat logs/dbt.log`
- Verify dbt profiles.yml has correct connection details for ipt_analytics

**Metabase Connection:**
- Navigate to http://localhost:3000 and setup admin account on first launch
- Add database connection to warehouse database
- Host: `warehouse_db` (container name), Port: `5432`, User: `warehouse_user`, Password: `warehouse_pass`, Database: `ipt_warehouse`
- Test connection before saving

## Notes

- All data is fictional but designed to be realistic for the IPT context
- Course units, room codes, and processes are based on real IPT structures
- People, issues, and events are synthetically generated
- Databases use PostgreSQL 15 for compatibility and feature set
- Data volumes are realistic for typical analytics workloads (thousands to millions of records)
