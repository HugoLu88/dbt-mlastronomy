{% macro total_sum_of_squares(squares) -%}

sum(power({{squares}},2))


{% endmacro %}