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
with
{% for item in tables_ %}
 staging_{{item}} as (

    select

    predictions_run_id,
    predictions_run_time,
    predictions_table_name,
    {{mean_absolute_error('abs_error')}} mean_absolute_error,
    {{mean_squared_error('abs_error')}} mean_squared_error,
    {{root_mean_squared_error('abs_error')}} root_mean_squared_error,
    {{mean_absolute_error('pct_error')}} mean_pct_error,
    {{median_absolute_error('pct_error')}} median_pct_error,
    {{total_sum_of_squares('squares')}} tss,
    {{residual_sum_of_squares('abs_error')}} rss,
    {{regression_coefficient('tss','rss')}} regression_coefficient


    from {{ref(item)}}
    {% if is_incremental() %}
      -- this filter will only be applied on an incremental run
    where predictions_run_time >= dateadd({{window}}, -{{duration}}, current_date())
    {% endif %}
    group by 1,2,3


),

{% endfor %}

aggregated as (
    {% for item in tables_ %}
        select
            *
        from staging_{{item}}

        {% if not loop.last %}
                union all
        {% endif %}
    {% endfor %}

    )


    select
    *
    from aggregated



{% endmacro %}