#!/bin/bash
# =============================================================
# IPT Data Platform - Generate and Load Seed Data
# =============================================================
# This script generates seed data and loads it into the source databases.
# Run this after 'docker compose up -d' to populate databases.
#
# The script runs Python locally (to generate SQL files) and uses the
# tools container (which has psql) to load the data into databases.
# =============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
GENERATORS_DIR="$PROJECT_DIR/generators"
DATA_DIR="$PROJECT_DIR/generated_data"

echo "========================================"
echo "IPT Data Platform - Seed Data Generator"
echo "========================================"
echo ""

# Create output directory
mkdir -p "$DATA_DIR"

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "ERROR: python3 is required but not installed."
    exit 1
fi

echo "Step 1: Generating seed data..."
echo ""

# Generate Issues data
echo "  → Generating issues data (250 issues)..."
python3 "$GENERATORS_DIR/generate_issues.py" --count 250 --output "$DATA_DIR/issues_seed.sql"

# Generate Reservations data
echo "  → Generating reservations data..."
python3 "$GENERATORS_DIR/generate_reservations.py" --output "$DATA_DIR/reservations_seed.sql"

# Generate Attendance data
echo "  → Generating attendance data..."
python3 "$GENERATORS_DIR/generate_attendance.py" --output "$DATA_DIR/attendance_seed.sql"

# Generate SIGQ data
echo "  → Generating SIGQ data..."
python3 "$GENERATORS_DIR/generate_sigq.py" --output "$DATA_DIR/sigq_seed.sql"

echo ""
echo "Step 2: Loading data into databases..."
echo ""

# Wait for databases to be ready
echo "  → Waiting for databases to be ready..."
sleep 3

# Load data using the tools container (which has psql)
echo "  → Loading data via tools container..."
docker compose exec -T tools bash /scripts/load_data.sh

echo ""
echo "========================================"
echo "Setup complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "  1. Explore the data using Adminer at http://localhost:8080"
echo "  2. Add a warehouse database to docker-compose.yml"
echo "  3. Create your ingestion script to load data into the warehouse"
echo "  4. Set up dbt to transform the data"
echo "  5. Add Metabase and create dashboards"
