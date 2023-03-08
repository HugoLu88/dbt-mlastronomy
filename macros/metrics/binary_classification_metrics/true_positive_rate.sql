{% macro true_positive_rate(true_positive_count, false_negative_count) -%}

div0({{true_positive_count}} , ({{true_positive_count}} + {{false_negative_count}})) true_positive_rate

{% endmacro %}