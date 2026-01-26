import os
from pathlib import Path
import dagster as dg
from dagster_dbt import DbtProject, DbtCliResource
from functools import cache


@cache
def get_dbt_project() -> DbtProject:
    """
    Khởi tạo DbtProject với prepare_if_dev đơn giản
    """
    # Ưu tiên biến môi trường cho Docker
    dbt_project_dir = os.getenv("DBT_PROFILES_DIR")
    
    if dbt_project_dir:
        project_dir = Path(dbt_project_dir).resolve()
    else:
        # Local development path
        current_path = Path(__file__)
        project_dir = current_path.parents[5].joinpath("dbt_project").resolve()

    if not project_dir.exists():
        raise FileNotFoundError(f"Không tìm thấy thư mục dbt project tại: {project_dir}")

    project = DbtProject(project_dir=project_dir)
    
    project.prepare_if_dev()

    
    return project

# Tạo resource
dbt_resource = DbtCliResource(project_dir=get_dbt_project())
