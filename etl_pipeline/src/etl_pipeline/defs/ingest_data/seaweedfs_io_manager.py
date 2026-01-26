import pandas as pd
from dagster import ConfigurableIOManager, InputContext, OutputContext
import s3fs

class SeaweedFSParquetIOManager(ConfigurableIOManager):
    """
    IO Manager ghi file Parquet vào S3/SeaweedFS.
    """
    s3_endpoint: str
    access_key: str
    secret_key: str
    bucket: str = "lakehouse"
    
    _bucket_created: bool = False

    @property
    def _storage_options(self):
        return {
            "key": self.access_key,
            "secret": self.secret_key,
            "client_kwargs": {"endpoint_url": self.s3_endpoint},
            "use_ssl": False
        }

    def _ensure_bucket_exists(self, context):
        if self._bucket_created:
            return
        try:
            fs = s3fs.S3FileSystem(
                key=self.access_key,
                secret=self.secret_key,
                client_kwargs={'endpoint_url': self.s3_endpoint}
            )
            if not fs.exists(self.bucket):
                fs.mkdir(self.bucket)
                context.log.info(f"✅ Created bucket '{self.bucket}'")
            self._bucket_created = True
        except Exception as e:
            context.log.warning(f"⚠️ Bucket check skipped: {e}")

    def _get_path(self, context) -> str:
        # Path: s3://lakehouse/landing/schema/table.parquet
        key_path = context.asset_key.path
        relative_path = "/".join(key_path)
        return f"s3://{self.bucket}/{relative_path}.parquet"

    def handle_output(self, context: OutputContext, obj: pd.DataFrame):
        if obj is None: return
        self._ensure_bucket_exists(context)
        file_path = self._get_path(context)
        
        context.log.info(f"Writing {len(obj)} rows to: {file_path}")
        try:
            obj.to_parquet(
                file_path,
                storage_options=self._storage_options,
                index=False,
                engine="pyarrow"
            )
            context.add_output_metadata({
                "path": file_path, 
                "rows": len(obj), 
                "columns": list(obj.columns)
            })
        except Exception as e:
            raise Exception(f"❌ Error writing to SeaweedFS: {e}")

    def load_input(self, context: InputContext) -> pd.DataFrame:
        file_path = self._get_path(context)
        return pd.read_parquet(file_path, storage_options=self._storage_options)