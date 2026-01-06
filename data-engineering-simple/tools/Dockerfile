# Simple image with psql + dbt for the data pipeline
FROM python:3.11-slim

# Install PostgreSQL client (for psql command)
RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Install dbt-postgres (pinned version that works)
RUN pip install --no-cache-dir dbt-postgres==1.8.2

# Set working directory
WORKDIR /dbt

# Default command (can be overridden)
CMD ["bash"]
