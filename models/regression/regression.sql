
{% set actuals_variables = var('actuals_variables') %}
with actuals_staging as (
    select
        date,
        product,
        count(distinct companyguid) companies

    from codat.public_aggregated.codat_active_companies_aggregated
    where date > '2023-01-01'
    group by 1,2


    ) ,

{{regression(
'actuals_staging', var('actuals_variables'), 'companies',
  'ds_product_acc_forecast_v2', var('predictions_variables'), 'RUN_DATE', 'VALUE'
)}}






