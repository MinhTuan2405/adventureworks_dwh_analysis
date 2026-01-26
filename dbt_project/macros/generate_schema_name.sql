{%- macro generate_lakehouse_path() -%}
    {%- set layer = model.fqn[1] -%}
    
    {%- set table_name = this.name -%}
    
    s3://lakehouse/{{ layer }}/{{ table_name }}.parquet
{%- endmacro -%}