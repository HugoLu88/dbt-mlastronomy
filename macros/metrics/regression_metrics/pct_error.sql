{% macro pct_error(acc, pred) -%}

div0(ifnull({{pred}},0) , ifnull({{acc}},0)) - 1 pct_error

{% endmacro %}