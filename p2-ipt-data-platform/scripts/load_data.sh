#!/bin/bash
# =============================================================
# Load Seed Data into Source Databases
# =============================================================
# This script runs inside the tools container to load the
# generated SQL files into the source databases.
# =============================================================

set -e

echo "Loading seed data into source databases..."
echo ""

# Load Issues data
echo "  → Loading issues data into issues_db..."
PGPASSWORD=issues_pass psql -h issues_db -p 5432 -U issues_user -d issues_app -f /data/issues_seed.sql -q

# Load Reservations data
echo "  → Loading reservations data into reservations_db..."
PGPASSWORD=reservations_pass psql -h reservations_db -p 5432 -U reservations_user -d reservations_app -f /data/reservations_seed.sql -q

# Load Attendance data
echo "  → Loading attendance data into attendance_db..."
PGPASSWORD=attendance_pass psql -h attendance_db -p 5432 -U attendance_user -d attendance_app -f /data/attendance_seed.sql -q

# Load SIGQ data
echo "  → Loading SIGQ data into sigq_db..."
PGPASSWORD=sigq_pass psql -h sigq_db -p 5432 -U sigq_user -d sigq_app -f /data/sigq_seed.sql -q

echo ""
echo "Verifying loaded data..."
echo ""

# Get actual counts from each database
echo "Issues DB:"
PGPASSWORD=issues_pass psql -h issues_db -U issues_user -d issues_app -t -c "SELECT '  - Issues: ' || COUNT(*) FROM issues;"
PGPASSWORD=issues_pass psql -h issues_db -U issues_user -d issues_app -t -c "SELECT '  - Comments: ' || COUNT(*) FROM issue_comments;"

echo "Reservations DB:"
PGPASSWORD=reservations_pass psql -h reservations_db -U reservations_user -d reservations_app -t -c "SELECT '  - Rooms: ' || COUNT(*) FROM rooms;"
PGPASSWORD=reservations_pass psql -h reservations_db -U reservations_user -d reservations_app -t -c "SELECT '  - Reservations: ' || COUNT(*) FROM reservations;"

echo "Attendance DB:"
PGPASSWORD=attendance_pass psql -h attendance_db -U attendance_user -d attendance_app -t -c "SELECT '  - Students: ' || COUNT(*) FROM students;"
PGPASSWORD=attendance_pass psql -h attendance_db -U attendance_user -d attendance_app -t -c "SELECT '  - Summaries: ' || COUNT(*) FROM summaries;"
PGPASSWORD=attendance_pass psql -h attendance_db -U attendance_user -d attendance_app -t -c "SELECT '  - Attendance records: ' || COUNT(*) FROM attendance;"

echo "SIGQ DB:"
PGPASSWORD=sigq_pass psql -h sigq_db -U sigq_user -d sigq_app -t -c "SELECT '  - Documents: ' || COUNT(*) FROM documents;"
PGPASSWORD=sigq_pass psql -h sigq_db -U sigq_user -d sigq_app -t -c "SELECT '  - Audits: ' || COUNT(*) FROM audits;"
PGPASSWORD=sigq_pass psql -h sigq_db -U sigq_user -d sigq_app -t -c "SELECT '  - Non-conformities: ' || COUNT(*) FROM non_conformities;"

echo ""
echo "Done!"
