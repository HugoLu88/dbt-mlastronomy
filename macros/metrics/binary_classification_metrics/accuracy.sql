{% macro accuracy(true_positive_count, true_negative_count, false_positive_count, false_negative_count) -%}

div0({{true_positive_count}} + {{true_negative_count}} , {{true_positive_count}} + {{true_negative_count}} + {{false_positive_count}} + {{false_negative_count}}) accuracy

{% endmacro %}