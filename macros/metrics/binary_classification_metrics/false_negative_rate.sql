{% macro false_negative_rate(false_negative_count, true_positive_count) -%}

div0({{false_negative_count}} , ({{false_negative_count}} + {{true_positive_count}})) false_negative_rate

{% endmacro %}