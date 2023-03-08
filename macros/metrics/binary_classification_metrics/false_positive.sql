{% macro false_positive(actuals, preds) -%}

case when {{actuals}} = 0 and {{preds}} = 1 then 1 else 0 end false_positive

{% endmacro %}