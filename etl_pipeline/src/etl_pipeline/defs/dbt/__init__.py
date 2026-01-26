"""DBT module exports."""
from etl_pipeline.defs.dbt.assets import get_dbt_models
from etl_pipeline.defs.dbt.resources import dbt_resource

dbt_models = get_dbt_models()

__all__ = ["dbt_models", "dbt_resource"]