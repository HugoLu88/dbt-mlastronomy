{% macro regression(actuals_table_name,
                    actuals_variables,
                    actuals_value_name,
                    predictions_table_name,
                    predictions_variables,
                    predictions_run_id,
                    predictions_run_time,
                    predictions_value_name,
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

actuals as (
    select
        {% for val in actuals_variables %}
        {{val}} as  {{val}},
        {% endfor %}
        {{actuals_value_name}} actuals_value
    from {{actuals_table_name }}
),

predictions as (
    select
        {% for val in predictions_variables %}
        {{val}} as  {{val}},
        {% endfor %}
        {{predictions_run_id}} predictions_run_id,
        {{predictions_run_time}} predictions_run_time,
        {{predictions_value_name}} predictions_value,
        '{{predictions_table_name}}' predictions_table_name
    from {{predictions_table_name}}
)
select

    predictions.*,
    actuals.actuals_value,
    -- This only works if empty values are excluded
    avg(actuals.actuals_value) over (partition by predictions.predictions_run_id order by predictions.predictions_run_id) model_average,
    count(*) over (partition by predictions.predictions_run_id order by predictions.predictions_run_id) observations,
    -- Macro calcs
    {{abs_error('actuals_value', 'predictions_value')}},
    {{pct_error('actuals_value', 'predictions_value')}},
    {{squares('predictions_value', 'model_average')}},
    -- Primary  key
    sha2_binary(concat(
       {% for val in predictions_variables %}
       ifnull(cast(predictions.{{val}} as string), 'null'),
       {% endfor %}
       ifnull(cast(predictions.predictions_run_id as string), 'null'),
       ifnull(cast(predictions.predictions_table_name as string), 'null')
       )) _pk

from predictions
left join actuals
on
{% for item in actuals_variables %}
    actuals.{{ item }}=predictions.{{predictions_variables[loop.index0]}}
    {% if not loop.last %}
        and
    {% endif %}

{% endfor %}
where predictions.predictions_value is not null and lower(predictions.predictions_value) != 'nan'
and actuals.actuals_value is not null and lower(actuals.actuals_value) != 'nan'
{% if is_incremental() %}
  -- this filter will only be applied on an incremental run
  and predictions_run_time >= dateadd({{window}}, -{{duration}}, current_date())
{% endif %}
{% endmacro %}