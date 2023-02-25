{% macro mean_squared_error(abs_error) -%}

avg(pow({{abs_error}},2))


{% endmacro %}