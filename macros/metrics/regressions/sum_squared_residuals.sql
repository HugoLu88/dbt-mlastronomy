{% macro sum_squared_residuals(squares) -%}

sum(power({{squares}},2))


{% endmacro %}