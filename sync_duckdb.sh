#!/bin/bash
# Script to sync DuckDB for CloudBeaver viewing

SOURCE_DB="/opt/dagster/app/dbt_project/dbt.duckdb"
TARGET_DB="/opt/dagster/app/dbt_project/dbt_readonly.duckdb"

echo "Syncing DuckDB for CloudBeaver..."

# Copy database file
cp -f "$SOURCE_DB" "$TARGET_DB"

# Set read-only permissions
chmod 444 "$TARGET_DB"

echo "Sync completed! CloudBeaver can now read from: $TARGET_DB"
