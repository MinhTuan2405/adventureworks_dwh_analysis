{%- macro lakehouse_path(custom_name=none) -%}
  
    {%- set schema = this.schema -%}
    {%- set table_name = custom_name if custom_name else this.name -%}
    
    s3://lakehouse/{{ schema }}/{{ table_name }}.parquet
{%- endmacro -%}