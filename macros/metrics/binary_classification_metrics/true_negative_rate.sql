{% macro true_negative_rate(true_negative_count, false_positive_count) -%}

div0({{true_negative_count}} , ({{true_negative_count}} + {{false_positive_count}})) true_negative_rate

{% endmacro %}