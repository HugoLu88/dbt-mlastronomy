{% macro residual_sum_of_squares(residuals) -%}

sum(pow({{residuals}},2))


{% endmacro %}