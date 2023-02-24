{% macro regression_aggregated(tables_,
                    materialize ='table',
                    window = 'day',
                    duration= 1) -%}

-- Macro to consolidate actuals to predictions at any level of granularity
-- i.e. one prediction per combination of n variables. For example,
-- usage of an api for different api clients on different days

{% if materialize == 'incremental' %}


    {{config(
        materialized='incremental',
        unique_key ='_pk'
    )}}


{% elif materialize == 'view' %}

    {{config(
        materialized='view',
        unique_key ='_pk'
    )}}

{% else %}

    {{config(
        materialized='table',
        unique_key ='_pk'
    )}}


{% endif %}

{% for item in tables_ %}
    select *,
      '{{item}}' table_name
    from {{ref(item)}}
    {% if is_incremental() %}
      -- this filter will only be applied on an incremental run
    where predictions_run_time >= dateadd({{window}}, -{{duration}}, current_date())
    {% endif %}
    {% if not loop.last %}
    union all
    {% endif %}
{% endfor %}


{% endmacro %}