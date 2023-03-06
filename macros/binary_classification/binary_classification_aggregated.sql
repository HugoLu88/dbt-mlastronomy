{% macro binary_classification_aggregated(tables_,
                    materialize = 'table',
                    window = 'day',
                    duration = 1) -%}

                    
{% if materialize == 'incremental' %}

    {{config(
        materialized = 'incremental',
        unique_key = '_pk'
    )}}

{% elif materialize == 'view' %}

    {{config(
        materialized = 'view',
        unique_key = '_pk'
    )}}

{% else %}

    {{config(
        materialized = 'table',
        unique_key = '_pk'
    )}}

{% endif %}

with
{% for item in tables_ %}
 staging_{{item}} as (

    select

    predictions_run_id,
    predictions_run_time,
    predictions_table_name,
    count(*) observations,
    {{true_positive_count('true_positive')}},
    {{true_negative_count('true_negative')}},
    {{false_positive_count('false_positive')}},
    {{false_negative_count('false_negative')}},
    {{true_positive_rate('true_positive_count', 'false_negative_count')}},
    {{true_negative_rate('true_negative_count', 'false_positive_count')}},
    {{accuracy('true_positive_count', 'true_negative_count', 'false_positive_count', 'false_negative_count')}},
    {{f1_score('true_positive_count', 'false_positive_count', 'false_negative_count')}}


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