{% macro true_positive(actuals, preds) -%}

case when {{actuals}} = 1 and {{preds}} = 1 then 1 else 0 end true_positive

{% endmacro %}