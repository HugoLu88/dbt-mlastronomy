{% macro abs_error(acc, pred) -%}

ifnull({{pred}},0) - ifnull({{acc}},0) abs_error

{% endmacro %}