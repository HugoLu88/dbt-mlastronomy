{% macro f1_score(true_positive_count, false_positive_count, false_negative_count) -%}

2 * div0((div0({{true_positive_count}},({{true_positive_count}} + {{false_positive_count}})) * div0({{true_positive_count}},({{true_positive_count}} + {{false_negative_count}}))) , (div0({{true_positive_count}},({{true_positive_count}} + {{false_positive_count}})) + div0({{true_positive_count}},({{true_positive_count}} + {{false_negative_count}})))) f1_score

{% endmacro %}