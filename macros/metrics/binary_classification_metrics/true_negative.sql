{% macro true_negative(actuals, preds) -%}

case when {{actuals}} = 0 and {{preds}} = 0 then 1 else 0 end true_negative

{% endmacro %}