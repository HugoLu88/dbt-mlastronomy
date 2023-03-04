{% set actuals_variables = var('actuals_variables_clf') %}
with actuals_staging as (
    with actuals_first as (
        select 
            a.companyid as base_companyguid,
            b.first_ac_date,
            dateadd(day, 121, b.first_ac_date) as month4_elapsed_date,
            max(case when (b.first_ac_date BETWEEN dateadd(day, -120, a.date) AND dateadd(day, -90, a.date)) and a.standard_is_active_company = 1 then 1 else 0 end) AS is_active_in_month4
        from codat.public_aggregated.opportunity_pricing_signals_aggregated AS a
        left join codat.public_staging.client_usage_company_dates_staging AS b
        on a.companyid = b.companyid
        where month4_elapsed_date < current_date()
        group by 1, 2
    )
    select
        actuals_first.base_companyguid as companyguid,
        actuals_first.month4_elapsed_date,
        actuals_first.is_active_in_month4
    from actuals_first
    left join codat.public_staging.id_mapping_staging as id
    on actuals_first.base_companyguid = id.companyguid
    left join codat.public_clean.clients_db_dbo_clients_clean as clean_clients
    on id.clientguid = clean_clients.clientguid
    where clean_clients.client_type in ('Client Prod', 'Client StartUp')
) ,

{{classification(
    'actuals_staging',
    var('actuals_variables_clf'),
    'is_active_in_month4',
    'ds_company_retention_month4_v2',
    var('predictions_variables_clf'),
    'run_date',
    'run_date',
    'prediction'
)}}


