{% macro false_negative(actuals, preds) -%}

case when {{actuals}} = 1 and {{preds}} = 0 then 1 else 0 end false_negative

{% endmacro %}