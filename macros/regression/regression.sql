{% macro regression(actuals_table_name,
                    actuals_variables,
                    actuals_value_name,
                    predictions_table_name,
                    predictions_variables,
                    predictions_run_id,
                    predictions_value_name) -%}

-- Macro to consolidate actuals to predictions at any level of granularity
-- i.e. one prediction per combination of n variables. For example,
-- usage of an api for different api clients on different days

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
        {{predictions_value_name}} predictions_value
    from {{predictions_table_name}}
)
select

    predictions.*,
    actuals.actuals_value,
       (actuals.actuals_value - predictions.predictions_value) abs_error,
       div0((actuals.actuals_value - predictions.predictions_value), actuals.actuals_value) pct_error

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
{% endmacro %}