
import pandas as pd
from dagster import asset, AssetExecutionContext, Definitions
from sqlalchemy import create_engine, inspect
import os
from typing import List, Dict

# ============================================
# 1. DATABASE CONFIGURATION
# ============================================

def get_postgres_connection_string() -> str:
    host = os.getenv("DATASOURCE_POSTGRES_HOST", "adventureworks_postgresl_datasource")
    port = 5432
    user = os.getenv("DATASOURCE_POSTGRES_USER", "postgres")
    password = os.getenv("DATASOURCE_POSTGRES_PASSWORD", "admin123")
    database = "postgres"
    return f"postgresql://{user}:{password}@{host}:{port}/{database}"

def get_all_schemas_and_tables() -> Dict[str, List[str]]:
    """Auto-discover all schemas and tables from PostgreSQL"""
    try:
        engine = create_engine(get_postgres_connection_string())
        inspector = inspect(engine)
        
        all_schemas = inspector.get_schema_names()
        exclude_schemas = ['information_schema', 'pg_catalog', 'pg_toast']
        schemas = [s for s in all_schemas if s not in exclude_schemas]
        
        schema_tables = {}
        for schema in schemas:
            tables = inspector.get_table_names(schema=schema)
            if tables:
                schema_tables[schema] = tables
        
        engine.dispose()
        return schema_tables
    except Exception as e:
        # Quan trọng: In lỗi ra log của Dagster/Docker để debug
        print(f"❌ [Postgres Load Error] Could not connect to DB: {e}")
        return {}

def read_table_to_dataframe(engine, schema: str, table: str) -> pd.DataFrame:
    query = f'SELECT * FROM "{schema}"."{table}"'
    df = pd.read_sql(query, engine)
    for col in df.select_dtypes(include=['object']).columns:
        df[col] = df[col].astype(str)
    return df

# ============================================
# 2. ASSET FACTORY
# ============================================

def create_ingestion_asset(schema: str, table: str):
    schema_normalized = schema.lower()
    table_normalized = table.lower()
    
    @asset(
        name=f"{schema_normalized}_{table_normalized}",
        key_prefix=["landing", schema_normalized],
        io_manager_key="lakehouse_io", 
        group_name="landing_ingestion", # <--- Group bạn muốn hiện đây
        compute_kind="postgres",
        metadata={"schema": schema, "table": table}
    )
    def _ingestion_asset(context: AssetExecutionContext) -> pd.DataFrame:
        engine = create_engine(get_postgres_connection_string())
        try:
            context.log.info(f"Ingesting {schema}.{table}...")
            df = read_table_to_dataframe(engine, schema, table)
            context.add_output_metadata({"rows": len(df)})
            return df
        finally:
            engine.dispose()
            
    return _ingestion_asset

# ============================================
# 3. DYNAMIC ASSET GENERATION (CÓ FIX LỖI)
# ============================================

schema_tables = get_all_schemas_and_tables()

generated_assets = []
asset_names = []

# # --- LOGIC FIX: Nếu không tìm thấy bảng nào (do lỗi DB), tạo 1 asset báo lỗi ---
# if not schema_tables:
#     print("Warning: No tables found. Creating dummy alert asset.")
    
#     @asset(
#         name="WARNING_DB_CONNECTION_FAILED", 
#         group_name="landing_ingestion",
#         compute_kind="error"
#     )
#     def connection_failed_alert(context: AssetExecutionContext):
#         """
#         Asset này xuất hiện nghĩa là Dagster KHÔNG thể kết nối tới Postgres lúc khởi động.
#         Vui lòng đợi DB khởi động xong rồi bấm 'Reload Definitions'.
#         """
#         context.log.error("Postgres connection failed during definition load.")
#         raise Exception("Vui lòng Reload Code Location khi Database đã sẵn sàng!")
    
#     generated_assets.append(connection_failed_alert)
#     asset_names.append("WARNING_DB_CONNECTION_FAILED")

# else:
# Logic cũ của bạn: Tạo asset thật
for schema, tables in schema_tables.items():
    for table in tables:
        asset_func = create_ingestion_asset(schema, table)
        asset_name = f"{schema.lower()}_{table.lower()}"
        generated_assets.append(asset_func)
        asset_names.append(asset_name)

# Export assets_defs (Nếu bạn dùng load trực tiếp file này)
# assets_defs = Definitions(assets=generated_assets)

# Hack globals (Giữ lại nếu bạn thích style cũ)
for asset_func, asset_name in zip(generated_assets, asset_names):
    globals()[asset_name] = asset_func