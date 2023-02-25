{% macro squares(acc, mean_) -%}

ifnull({{acc}}, 0) - ifnull({{mean_}}, 0) squares

{% endmacro %}