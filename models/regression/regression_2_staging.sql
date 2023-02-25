
{% set actuals_variables = var('actuals_variables') %}
with actuals_staging as (
    select
        date,
        case when product = 'Banking API' then 'BANKING_ACC'
        when product = 'Other' then 'x'
        when product = 'Accounting API' then 'ACCOUNTING_ACC'
        when product = 'Commerce API' then 'COMMERCE_ACC'
        when product = 'Sync for Expenses' then 'SYNC_EXP_ACC'
        when product = 'Bank Feeds' then 'x'
        when product = 'Assess' then 'ASSESS_ACC'
        when product = 'Sync for Commerce' then 'SYNC_COMM_ACC'
        else null end product,
        count(distinct companyguid) companies

    from codat.public_aggregated.codat_active_companies_aggregated
    where date > '2023-01-01'
    group by 1,2


    ) ,

{{regression(
'actuals_staging', var('actuals_variables'), 'companies',
'ds_acc_product_forecast', var('predictions_variables'), 'RUN_DATE', 'RUN_DATE', 'VALUE', materialize = 'incremental',

  duration = 30
)}}






