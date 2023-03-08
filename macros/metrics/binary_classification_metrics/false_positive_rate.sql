{% macro false_positive_rate(false_positive_count, true_negative_count) -%}

div0({{false_positive_count}} , ({{false_positive_count}} + {{true_negative_count}})) false_positive_rate

{% endmacro %}