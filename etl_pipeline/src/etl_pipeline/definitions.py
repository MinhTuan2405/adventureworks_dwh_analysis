
import dagster as dg
from etl_pipeline.defs.dbt import dbt_models, dbt_resource
from etl_pipeline.defs.ingest_data import generated_assets, SeaweedFSParquetIOManager


# --- RESOURCES ---
# Config IO Manager

lakehouse_io = SeaweedFSParquetIOManager(
    s3_endpoint=dg.EnvVar("S3_ENDPOINT"),
    access_key=dg.EnvVar("S3_ACCESS_KEY"),
    secret_key=dg.EnvVar("S3_SECRET_KEY"),
    bucket="lakehouse"
)



# --- FINAL DEFINITIONS ---
defs = dg.Definitions(
    assets=[
        *generated_assets, # Bung list assets Postgres
        dbt_models    # Asset DBT
    ],
    resources={
        "lakehouse_io": lakehouse_io, # Tên này khớp với io_manager_key trong ingest
        "dbt": dbt_resource
    }
)