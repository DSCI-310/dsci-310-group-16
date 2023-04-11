library(testthat)
library(tidymodels)
library(dplyr)

# Create test data frame
train_df <- target_df(mtcars[1:16, ], 'gear', c("am", "vs"))
test_df <- target_df(mtcars[17:32, ], 'gear', c("am", "vs"))
x_recipe <- create_recipe(train_df, target_variable="gear")
x_spec_list <- create_spec_kmin(train_df, model_recipe=x_recipe, method="lm", target_variable="gear")
x_spec <- get_list_item(x_spec_list, n=1) 
x_fit <- create_fit(x_recipe, x_spec, train_df)
prediction_model <- create_model_prediction(test_df, x_fit)

# Test case 1: Check if the function returns the correct metric value for 'rmse'
test_that("get_metric returns the correct metric value for 'rmse'", {
  rmse_value <- get_metric(prediction_model, "rmse", "gear")
  expect_true(is.numeric(rmse_value))
})

# Test case 2: Check if the function returns the correct metric value for 'rsq'
test_that("get_metric returns the correct metric value for 'rsq'", {
  rsq_value <- get_metric(prediction_model, "rsq", "gear")
  expect_true(is.numeric(rsq_value))
})

# Test case 3: Check if the function returns the correct metric value for 'mae'
test_that("get_metric returns the correct metric value for 'mae'", {
  mae_value <- get_metric(prediction_model, "mae", "gear")
  expect_true(is.numeric(mae_value))
})

# Test case 4: Check if the function raises an error when an unsupported metric is provided
test_that("get_metric raises an error when an unsupported metric is provided", {
  expect_error(get_metric(prediction_model, "unsupported_metric", "gear"), "Please input a valid metric")
})
