

from typing import Any, Mapping, Optional
import dagster as dg
from dagster_dbt import DagsterDbtTranslator

class CustomAdventureWorksTranslator(DagsterDbtTranslator):
    
    # --- 1. Logic Automation (Giữ nguyên của bạn) ---
    def get_automation_condition(self, dbt_resource_props: Mapping[str, Any]) -> Optional[dg.AutomationCondition]:
        tags = dbt_resource_props.get('tags', [])
        
        if 'static' not in tags:
            if 'backlog_monthly' in tags:
                return dg.AutomationCondition.on_cron('@monthly')
            if 'ac_eager' in tags:
                return dg.AutomationCondition.eager()
            if 'ac_eager_multi_asset' in tags:
                return dg.AutomationCondition.eager().without(
                    ~dg.AutomationCondition.any_deps_missing()
                ).with_label("eager_multi_asset")
        
        return None

    def get_group_name(self, dbt_resource_props: Mapping[str, Any]) -> Optional[str]:
        """
        Lấy trực tiếp tên Schema trong Database làm tên Group trên UI Dagster.
        Ví dụ: 
         - Table nằm ở schema 'bronze' -> Group 'bronze'
         - Table nằm ở schema 'silver' -> Group 'silver'
        """
        # Thuộc tính 'schema' luôn có sẵn trong manifest của mỗi model
        return dbt_resource_props.get("schema", "default_group")
    

    # Code này tạo sự phụ thuộc của data ingest vào bronze layer

    # def get_asset_key(self, dbt_resource_props: Mapping[str, Any]) -> dg.AssetKey:
    #     resource_type = dbt_resource_props.get("resource_type")
        
    #     if resource_type == "source":
    #         source_name = dbt_resource_props["source_name"] 
    #         full_table_name = dbt_resource_props["name"]  # Ví dụ: "sales_salesorderheader"
            
    #         if source_name == "landing":
            
    #             # schema_part, table_part = full_table_name.split("_", 1)
                
            
    #             parts = full_table_name.split("_", 1)
    #             if len(parts) == 2:
    #                 schema_part = parts[0] # "sales"
                    
    #                 return dg.AssetKey(["landing", schema_part, full_table_name])
        
    #     return super().get_asset_key(dbt_resource_props)