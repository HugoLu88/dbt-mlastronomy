{% macro root_mean_squared_error(actuals_table_name, actuals_variable_name, actuals_value, predictions_table_name, predictions_variable_name, predictions_run_id, predictions_value) -%}

actuals as (
    select
    {{actuals_value}} actuals_value,
    {{actuals_variable_name}} actuals_variable_name
    from {{actuals_table_name }}
),
predictions as (
    select
        {{predictions_run_id}} predictions_run_id,
        {{predictions_value}} predictions_value,
        {{predictions_variable_name}} predictions_variable_name
    from {{predictions_table_name}}

)
select

    predictions.*,
    actuals.actuals_value,

       (actuals.actuals_value - predictions.predictions_value) abs_error,
       div0((actuals.actuals_value - predictions.predictions_value), actuals.actuals_value) pct_error


from predictions
left join actuals
on predictions.predictions_variable_name = actuals.actuals_variable_name
where predictions.predictions_value is not null and lower(predictions.predictions_value) != 'nan'



{% endmacro %}