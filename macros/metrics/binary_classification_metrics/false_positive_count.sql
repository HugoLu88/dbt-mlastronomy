{% macro false_positive_count(false_positive) -%}

sum({{false_positive}}) false_positive_count

{% endmacro %}