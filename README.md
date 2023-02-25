# Hello and welcome to ML Astronomy!
*By Hugo Lu and Carlos Noble Jesus*

Welcome to ML Astronomy. ML Astronomy is a package that allows you to seamlessly integrate your actuals with predictions, provided they are in
your data warehouse of choice already. The basic premise is using raw sources (predictions) to get
staging tables (consolidated predictions with actuals) and then to union into aggregated tables (aggregated model-level data) which you surface
in a BI tool.

![alt text](https://github.com/HugoLu88/dbt-mlastronomy/blob/main/images/staging_data.JPG?raw=true)

## Quickstart

1. Find your actuals

  Find the table in your warehouse that corresponds to the actual values. This might be 
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

Staging tables have the same structure as predictions but some more columns

  - PREDICTION_VALUE
  - {{metrics}}

mlastronomy auto-includes all the metrics we think you may need, but it is straightforward to add additional columns
by nesting the macro call in a sub-query or submit a PR for mlastronomy :)

### Aggregate tables

Aggregate tables are one row per model per model run. They contain aggregated information on different models that are of the same
type. See Quickstart (5) for more info on this. These tables should also have nicely defined yml files
that can be surfaced into semantic layers / BI Tools, as they are the final level.

## Why would we want to do this?

There are lots of reasons we might want to monitor actual model performance over time.

- See if a model is actually performing as expected
- Monitor the performance of alternative models to inform switching models
- Monitor changes in performance metrics relative to a specific event in time

# Considerations

This approach will not be appropriate for a few use cases.

1. Super quick ML

  If you are doing super quick ML where you continually train, test and deploy models, then this package won't be relevant
  for you! You hopefully have a much more mature stack that allows real-time data ingestion, transformation,
  model training, model selecting and model deployment. This means you don't need to do this in dbt :)

2. You have loads and loads of data
  
  If you have loads and loads of data, these dbt models are going to get expensive quite quickly. mlastronomy
  supports incremental loads so you don't need to recreate all the tables every time, but be aware this may be expensive
  in terms of cloud compute. You could get around this by *limiting* the amount of data you include from the predictions
  in a random way.

3. You run models very frequently

  This is basically the same point as (2). If you have loads of models, you'll need to run these macros more regularly
  or do larger runs less frequently. This could be expensive.
  
  However, in a well-designed Machine Learning infrastructure, there is arguably little reason to re-train, predict and 
  store data at more than say an hour's frequency. If there is and you are considering using this package, then a 
  more sophisticated streaming approach may be best.

### Accuracy metrics

Implicitly, these sets of models join in actuals for predictions *wherever they are available*.

This means that as time goes by, there may be more and more actuals available for a particular model. This means that accuracy
metrics will change over time which may be undesirable. It also makes comparing models difficult.
For example, if you use the aggregated table to compare a regression model which is 1 year old to one which is only 
1 month old, then the year-old one will have more predictions than the month-old one, and may be more / less
accurate.

There are two solutions to this problem

1. Model accuracy metrics only on specific joins or sets of data
   This would require tracking metrics for models after a specified date or time period. It could even rate "the first n"
   observations
2. Use the same test set across all models of the same type
   This ensures that every set of predictions is for an observation specifically designated for testing. This is probably 
   not a very practical solution because as time goes by, the observations in the test set which are unlabelled become labelled,
   which means the test set will need to change anyway

Generally we prefer the first approach combined with good planning. For example, if you want to monitor 3 separate models
for the same thing, then planning how to track them really helps. You can implement all three at once, have them all make predictions
to your warehouse at once, and monitor them in real-time without needing to worry about these factors (because they're implemented together).
This is greatly preferable to essentially "normalisising" metrics.


   

### To dos
- Abstract metrics calcs into their own macros
- Classifier model
- Add grouping to aggregate model and dynamic variable selection