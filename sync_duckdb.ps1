# PowerShell script to sync DuckDB for CloudBeaver viewing

$sourceDb = ".\dbt_project\dbt.duckdb"
$targetDb = ".\dbt_project\dbt_readonly.duckdb"

Write-Host "Syncing DuckDB for CloudBeaver..." -ForegroundColor Cyan

# Copy database file
Copy-Item -Path $sourceDb -Destination $targetDb -Force

# Set read-only attribute
Set-ItemProperty -Path $targetDb -Name IsReadOnly -Value $true

Write-Host "Sync completed! CloudBeaver can now read from: dbt_readonly.duckdb" -ForegroundColor Green
Write-Host "Update CloudBeaver connection path to: /opt/dbt_project/dbt_readonly.duckdb" -ForegroundColor Yellow
