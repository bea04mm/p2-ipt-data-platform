#!/bin/bash

# Get the script directory and project directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# seeds files (using absolute paths)
SIGQ_SEEDS="$PROJECT_DIR/generated_data/sigq_seed.sql"
issues_SEEDS="$PROJECT_DIR/generated_data/issues_seed.sql"
attendance_SEEDS="$PROJECT_DIR/generated_data/attendance_seed.sql"
reservations_SEEDS="$PROJECT_DIR/generated_data/reservations_seed.sql"

# Logica da batata
echo "🚀 A começar a injeção..."

# SIGQ_SEEDS
if [ -f "$SIGQ_SEEDS" ]; then
    echo "📦 Seeding SIGQ Database..."
    # cat file | docker exec -i [container_name] psql -U [user] -d [db_name]
    cat "$SIGQ_SEEDS" | docker exec -i ipt_sigq_db psql -U sigq_user -d sigq_app
    echo "✅ SIGQ injetado com sucesso."
else
    echo "⚠️  Ficheiro de seed não encontrado: $SIGQ_SEEDS"
fi

if [ -f "$issues_SEEDS" ]; then
    echo "📦 Seeding SIGQ Database..."
    # cat file | docker exec -i [container_name] psql -U [user] -d [db_name]
    cat "$issues_SEEDS" | docker exec -i ipt_issues_db psql -U issues_user -d issues_app
    echo "✅ Issues injetado com sucesso."
else
    echo "⚠️  Ficheiro de seed não encontrado: $issues_SEEDS"
fi

if [ -f "$attendance_SEEDS" ]; then
    echo "📦 Seeding SIGQ Database..."
    # cat file | docker exec -i [container_name] psql -U [user] -d [db_name]
    cat "$attendance_SEEDS" | docker exec -i ipt_attendance_db psql -U attendance_user -d attendance_app
    echo "✅ attendance injetado com sucesso."
else
    echo "⚠️  Ficheiro de seed não encontrado: $attendance_SEEDS"
fi

if [ -f "$reservations_SEEDS" ]; then
    echo "📦 Seeding SIGQ Database..."
    # cat file | docker exec -i [container_name] psql -U [user] -d [db_name]
    cat "$reservations_SEEDS" | docker exec -i ipt_reservations_db psql -U reservations_user -d reservations_app
    echo "✅ reservations injetado com sucesso."
else
    echo "⚠️  Ficheiro de seed não encontrado: $reservations_SEEDS"
fi

echo "🎉 Todas as seeds injetadas!"