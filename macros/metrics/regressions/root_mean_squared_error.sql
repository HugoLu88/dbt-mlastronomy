{% macro root_mean_squared_error(abs_error) -%}

avg(pow(pow({{abs_error}},2),0.5))


{% endmacro %}