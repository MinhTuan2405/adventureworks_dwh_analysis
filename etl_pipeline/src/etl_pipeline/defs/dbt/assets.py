
import dagster as dg
from dagster_dbt import DbtCliResource, dbt_assets
from typing import List, Optional
from pydantic import Field
from functools import cache

from etl_pipeline.lib_custom.dbt.translator import CustomAdventureWorksTranslator
from etl_pipeline.defs.dbt.resources import get_dbt_project


class AdventureWorksDbtConfig(dg.Config):
    full_refresh: bool = Field(
        default=False, 
        description="Force full refresh run."
    )
    select_model: List[str] = Field(
        default=[], 
        description="List of models to include (dbt syntax)."
    )
    exclude_model: List[str] = Field(
        default=[], 
        description="List of models to exclude."
    )


@cache
def get_dbt_models(
    custom_translator: Optional[CustomAdventureWorksTranslator] = None,
):
    """
    Cache dbt_assets definition
    Học theo Dagster's best practice
    """
    dbt_project = get_dbt_project()
    
    @dbt_assets(
        manifest=dbt_project.manifest_path,
        project=dbt_project,
        dagster_dbt_translator=custom_translator or CustomAdventureWorksTranslator(),
        name="adventureworks_dbt_assets",
    )
    def dbt_models(
        context: dg.AssetExecutionContext, 
        dbt: DbtCliResource, 
        config: AdventureWorksDbtConfig
    ):
        dbt_build_args = ["build"]
        
        if config.full_refresh:
            dbt_build_args.append("--full-refresh")
            
        if config.select_model:
            dbt_build_args += ["--select", " ".join(config.select_model)]
            
        if config.exclude_model:
            dbt_build_args += ["--exclude", " ".join(config.exclude_model)]
            
        context.log.info(f"Running dbt command: dbt {' '.join(dbt_build_args)}")
        
        yield from dbt.cli(dbt_build_args, context=context).stream().fetch_row_counts()
    
    return dbt_models


# ✅ Gọi cached function
adventureworks_dbt_assets = get_dbt_models()