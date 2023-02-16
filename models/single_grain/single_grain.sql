with actuals as (
    select
    {{var('run_time')}} run_time,
    {{var('actuals_value')}} actuals_value,
    {{var('variable')}}
    from {{ var('actuals') }}
),
predictions as (
    select
        {{var('pedictions_value')}} predictions_value,
        {{var('variable')}}
    from {{var('pedictions')}}

)
select
  a.*,
  b.predictions_value
from actuals a
left join predictions b
on a.{{var('variable')}} = b.a.{{var('variable')}}


/*
 with base as (
 select
     a.*,
    'revenue' model_name
 from revenue
 union all
 select
    a.*,
    'usage' model_name
 from usage
 )

 select
     model_name,
     run_time,
     avg(actuals - prediction) avg_absolute_delta,
     sum(actuals - prediction) ttl_absolute_delta,
     avg(div0((actuals - prediction),actuals)) avg_pct_delta
 from base
 group by 1,2


 */