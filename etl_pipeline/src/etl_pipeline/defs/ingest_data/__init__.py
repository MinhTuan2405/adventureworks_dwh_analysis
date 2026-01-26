from .postgres_ingestion_assets import generated_assets
from .seaweedfs_io_manager import SeaweedFSParquetIOManager

# Export ra để definitions.py import 1 dòng là đủ
__all__ = ["generated_assets", "SeaweedFSParquetIOManager"]