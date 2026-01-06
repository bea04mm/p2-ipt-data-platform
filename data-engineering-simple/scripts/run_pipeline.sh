#!/bin/bash
# =============================================================
# IPT Data Platform - Full Pipeline Runner
# =============================================================
# This script runs the complete ELT pipeline:
# 1. Ingests data from source DBs to warehouse
# 2. Runs dbt transformations
#
# Usage: docker compose exec tools bash /scripts/run_pipeline.sh
# =============================================================

set -e

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║       IPT Data Platform - Running Full Pipeline        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Data Ingestion (Extract & Load)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "PHASE 1: Data Ingestion (Extract & Load)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash /scripts/ingest_docker.sh

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "PHASE 2: Data Transformation (dbt)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd /dbt
dbt run

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "PIPELINE COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Your data is ready! Next steps:"
echo ""
echo "  📊 Open Metabase:  http://localhost:3000"
echo "  🔍 Open Adminer:   http://localhost:8080"
echo ""
echo "In Metabase, connect to the warehouse database:"
echo "  Host: warehouse | Port: 5432 | DB: warehouse"
echo "  User: dbt_user  | Password: dbt_pass"
echo ""
