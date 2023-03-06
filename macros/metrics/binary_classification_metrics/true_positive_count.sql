{% macro true_positive_count(true_positive) -%}

sum({{true_positive}}) true_positive_count

{% endmacro %}