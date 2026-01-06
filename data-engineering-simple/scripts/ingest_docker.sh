#!/bin/bash
# =============================================================
# IPT Data Platform - Data Ingestion Script (Docker version)
# =============================================================
# Run this inside the tools container:
#   docker compose exec tools bash /scripts/ingest_docker.sh
# =============================================================

set -e

echo "========================================"
echo "IPT Data Platform - Data Ingestion"
echo "========================================"
echo ""

# Use environment variables (set in docker-compose.yml)
# These use Docker network hostnames (issues_db, reservations_db, warehouse)

# -------------------------------------------------------------
# Step 1: Create raw schema and tables in warehouse
# -------------------------------------------------------------
echo "Step 1: Preparing warehouse schema..."

psql "$WAREHOUSE" << 'EOF'
-- Create raw schema for landing data
CREATE SCHEMA IF NOT EXISTS raw;

-- Drop existing raw tables (for clean reload)
DROP TABLE IF EXISTS raw.issues CASCADE;
DROP TABLE IF EXISTS raw.buildings CASCADE;
DROP TABLE IF EXISTS raw.rooms CASCADE;
DROP TABLE IF EXISTS raw.reservations CASCADE;
DROP TABLE IF EXISTS raw.reservation_types CASCADE;

-- Create raw tables (matching source schemas)
-- We add _loaded_at to track when data was ingested

CREATE TABLE raw.buildings (
    id INTEGER,
    code VARCHAR(5),
    name VARCHAR(100),
    description TEXT,
    _source VARCHAR(50) DEFAULT 'issues_db',
    _loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE raw.issues (
    id INTEGER,
    room_code VARCHAR(10),
    building_code VARCHAR(5),
    category VARCHAR(50),
    priority VARCHAR(20),
    title VARCHAR(200),
    description TEXT,
    reported_by VARCHAR(100),
    reported_at TIMESTAMP,
    status VARCHAR(20),
    assigned_to VARCHAR(100),
    resolved_at TIMESTAMP,
    resolution_notes TEXT,
    _source VARCHAR(50) DEFAULT 'issues_db',
    _loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE raw.rooms (
    id INTEGER,
    code VARCHAR(10),
    building VARCHAR(5),
    name VARCHAR(100),
    room_type VARCHAR(50),
    capacity INTEGER,
    has_projector BOOLEAN,
    has_video_conference BOOLEAN,
    has_computers BOOLEAN,
    computer_count INTEGER,
    is_active BOOLEAN,
    notes TEXT,
    _source VARCHAR(50) DEFAULT 'reservations_db',
    _loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE raw.reservation_types (
    id INTEGER,
    code VARCHAR(20),
    name VARCHAR(100),
    requires_approval BOOLEAN,
    _source VARCHAR(50) DEFAULT 'reservations_db',
    _loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE raw.reservations (
    id INTEGER,
    room_id INTEGER,
    reservation_type_id INTEGER,
    title VARCHAR(200),
    description TEXT,
    reserved_by VARCHAR(100),
    contact_email VARCHAR(100),
    reservation_date DATE,
    start_time TIME,
    end_time TIME,
    status VARCHAR(20),
    attendee_count INTEGER,
    created_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    cancellation_reason TEXT,
    _source VARCHAR(50) DEFAULT 'reservations_db',
    _loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

EOF

echo "✓ Warehouse schema ready"
echo ""

# -------------------------------------------------------------
# Step 2: Extract from Issues DB and load to warehouse
# -------------------------------------------------------------
echo "Step 2: Extracting from Issues Database..."

# Extract buildings
psql "$ISSUES_DB" -c "\COPY (SELECT * FROM buildings) TO STDOUT WITH CSV HEADER" | \
psql "$WAREHOUSE" -c "\COPY raw.buildings(id, code, name, description) FROM STDIN WITH CSV HEADER"

# Extract issues
psql "$ISSUES_DB" -c "\COPY (SELECT * FROM issues) TO STDOUT WITH CSV HEADER" | \
psql "$WAREHOUSE" -c "\COPY raw.issues(id, room_code, building_code, category, priority, title, description, reported_by, reported_at, status, assigned_to, resolved_at, resolution_notes) FROM STDIN WITH CSV HEADER"

echo "✓ Issues data loaded"
echo ""

# -------------------------------------------------------------
# Step 3: Extract from Reservations DB and load to warehouse
# -------------------------------------------------------------
echo "Step 3: Extracting from Reservations Database..."

# Extract rooms
psql "$RESERVATIONS_DB" -c "\COPY (SELECT * FROM rooms) TO STDOUT WITH CSV HEADER" | \
psql "$WAREHOUSE" -c "\COPY raw.rooms(id, code, building, name, room_type, capacity, has_projector, has_video_conference, has_computers, computer_count, is_active, notes) FROM STDIN WITH CSV HEADER"

# Extract reservation types
psql "$RESERVATIONS_DB" -c "\COPY (SELECT * FROM reservation_types) TO STDOUT WITH CSV HEADER" | \
psql "$WAREHOUSE" -c "\COPY raw.reservation_types(id, code, name, requires_approval) FROM STDIN WITH CSV HEADER"

# Extract reservations
psql "$RESERVATIONS_DB" -c "\COPY (SELECT * FROM reservations) TO STDOUT WITH CSV HEADER" | \
psql "$WAREHOUSE" -c "\COPY raw.reservations(id, room_id, reservation_type_id, title, description, reserved_by, contact_email, reservation_date, start_time, end_time, status, attendee_count, created_at, cancelled_at, cancellation_reason) FROM STDIN WITH CSV HEADER"

echo "✓ Reservations data loaded"
echo ""

# -------------------------------------------------------------
# Summary
# -------------------------------------------------------------
echo "========================================"
echo "Ingestion Complete!"
echo "========================================"
echo ""
echo "Data loaded into warehouse (raw schema):"
psql "$WAREHOUSE" -c "SELECT 'buildings' as table_name, COUNT(*) as rows FROM raw.buildings UNION ALL SELECT 'issues', COUNT(*) FROM raw.issues UNION ALL SELECT 'rooms', COUNT(*) FROM raw.rooms UNION ALL SELECT 'reservation_types', COUNT(*) FROM raw.reservation_types UNION ALL SELECT 'reservations', COUNT(*) FROM raw.reservations ORDER BY table_name;"
echo ""
echo "Next step: Run 'dbt run' to transform the data."
