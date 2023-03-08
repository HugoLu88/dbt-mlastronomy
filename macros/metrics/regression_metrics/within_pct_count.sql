{% macro within_pct_count(pct_error, percentage_interval=1) -%}

sum(case when 100*{{pct_error}} <= {{percentage_interval}} or 100*{{pct_error}} >= -{{percentage_interval}} then 1 else 0 end) as within_pct_count

{% endmacro %}