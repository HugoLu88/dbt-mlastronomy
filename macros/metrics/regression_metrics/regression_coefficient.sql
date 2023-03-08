{% macro regression_coefficient(tss,rss) -%}

1 - div0({{rss}},{{tss}})


{% endmacro %}