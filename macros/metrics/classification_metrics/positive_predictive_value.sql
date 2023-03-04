{% macro positive_predictive_value(true_positive_count, false_positive_count) -%}

div0({{true_positive_count}} , {{true_positive_count}} + {{false_positive_count}}) positive_predictive_value

{% endmacro %}