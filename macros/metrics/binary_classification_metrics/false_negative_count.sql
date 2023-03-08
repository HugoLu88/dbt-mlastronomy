{% macro false_negative_count(false_negative) -%}

sum({{false_negative}}) false_negative_count

{% endmacro %}