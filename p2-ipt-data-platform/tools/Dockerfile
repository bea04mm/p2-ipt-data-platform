# Tools container with psql for database operations
# Students can extend this to add dbt and other tools as needed
FROM python:3.11-slim

# Install PostgreSQL client (for psql command)
RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Default command
CMD ["bash"]
