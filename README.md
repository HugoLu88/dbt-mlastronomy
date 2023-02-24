# Hello and welcome to ML Astronomy!
*By Hugo Lu and Carlos Noble Jesus*

Welcome to ML Astronomy. ML Astronomy is a package that allows you to seamlessly integrate your actuals with predictions, provided they are in
your data warehouse of choice already. The basic premise of using raw sources (predictions),
staging tables (consolidated predictions with actuals) and aggregated tables (aggregated model-level data).

![alt text](https://github.com/HugoLu88/dbt-mlastronomy/blob/main/images/staging_data.JPG?raw=true)

## Quickstart

1. Find your actuals

Firstly, you should find the table in your warehouse that corresponds to the actual values. This might be 
historical clicks on a movie users have made after being recommended a menu of movies. It might be
historical revenue or usage numbers.

2. Pick your model and macro

Pick your model predictions that you want to consolidate with actuals. If this is a regression model, choose the regression macro.
If this is a binary classifier model, choose the binary_classifier macro etc. 

3. Create a new SQL file calling the macro

You should call the macro in a new SQL file to create the staging table. Ideally the name should be "model_name_staging".
You may need to form a sub-query to get your actuals. If you do this, start the model with a 
```
with actuals as (...),
```

4. Pick parameters

The parameters are

- actuals_table_name: the name of the table to pick actuals. This can be a ref to a subquery
- actuals_variables: a comma separated list of column names for which predictions are made e.g. ['CLIENT','DATE']
  - These can be specified as a var in dbt_project.yml and referenced in the macro *without* curly brackets
- actuals_value_name: the name of the column storing the prediction value
- predictions_table_name: as above, for predictions
- predictions_variables as above, for predictions
- predictions_run_id: the column name containing the run_id, a unique identifier for every model run
- predictions_run_time: the column name containing the model run time, the time the model was run
- predictions_value_name:as above, for predictions
- materialize: how to materialize the model, defaults to 'table'. Incrementality is supported
- window: the window type incremental models look back, defaults to 'day'
- duration: the window length incremental models look back, defaults 1. This means incremental models will fetch 1 days' worth of data and update by default

5. Create aggregate tables

This simply involes creating another sql file in "aggregate" which can be called {{model_type}}_statistics_aggregated.
This model will be one row per model per model run and contain aggregated metrics across all models over time
for models of a specific type. What this means is we can happily lump all regression models together as they 
all should have the same set of metrics we care about e.g. absolute error.

Similarly, we may wish to store classifiers in their own aggregate table because aggregate metrics such as true positive
rates are simply not relevant for regression models.

Only one variable needs to be specified here which is a list of table names. Again, this can be stored in the dpt_project.yml file like:

```

'regression_models': ['revenue_predictions_staging','usage_predictions_staging']

```

## What the data should look like

### Predictions

Predictions should be one row per prediction. The prediction tables should also have a model run ID column
and a model run time column. This is necessary to group predictions by model run and to monitor model run
performance over time. The other columns should be the features for which the predictions are made.

For example, if I am predicting a value for every client for every day, then the table structure should be:

- RUN_ID (str)
- RUN_TIME (date or ideally timestamp)
- CLIENT_ID (str)
- DAY (date)
- VALUE (char)



### Staging tables

Staging tables represent

## Why would we want to do this?


### To dos
- Abstract metrics calcs into their own macros
- Better docs

- Single grain classifier model (currently we just have absolute)

- Create a macro to union tables together and group by run id and run date
- Add model name