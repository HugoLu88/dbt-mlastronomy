

with actuals_staging as (
    select
    distinct activity_date, acc
    from codat.public.ds_acc_90day_forecast
    where cast(RUN_DATE as date) = '2023-01-01' and ACC !='NaN'


    )

{{single_grain_macro(
'actuals_staging', 'ACTIVITY_DATE', 'ACC', 'ds_acc_90day_forecast', 'ACTIVITY_DATE', 'RUN_DATE', 'FCAST_ACC'
)}}