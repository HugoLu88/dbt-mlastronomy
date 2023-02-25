{% macro mean_absolute_error(abs_error) -%}

avg({{abs_error}})


{% endmacro %}