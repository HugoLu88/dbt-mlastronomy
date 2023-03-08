{% macro correct_classification(actuals, preds) -%}

case when {{actuals}} = {{preds}} then 1 else 0 end correct_classification

{% endmacro %}