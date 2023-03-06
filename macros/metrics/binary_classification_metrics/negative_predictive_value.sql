{% macro negative_predictive_value(true_negative_count, false_negative_count) -%}

div0({{true_negative_count}} , {{true_negative_count}} + {{false_negative_count}}) negative_predictive_value

{% endmacro %}