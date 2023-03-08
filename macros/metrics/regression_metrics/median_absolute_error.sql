{% macro median_absolute_error(abs_error) -%}

median({{abs_error}})

{% endmacro %}