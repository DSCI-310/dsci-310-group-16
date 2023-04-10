library(testthat)
library(data.table)

# Prepare train and test data frames
train_df <- mtcars[1:16, ]
test_df <- mtcars[17:32, ]

single_predictors <- list("mpg", "cyl", "disp", "hp", "am")
multiple_predictors <- list(c("mpg", "cyl"), c("disp", "am"), c("cyl", "am"))

# Test case 1: Check if the function returns a data frame with the correct number of rows for single predictor lm models
test_that("metric_bind returns a data frame with the correct number of rows for single predictor lm models", {
  output_df <- metric_bind(train_df, test_df, "rmse", "lm", "NA", "gear", single_predictors)
  expect_equal(nrow(output_df), length(single_predictors))
})

# Test case 2: Check if the function returns a data frame with the correct number of rows for multiple predictor lm models
test_that("metric_bind returns a data frame with the correct number of rows for multiple predictor lm models", {
  output_df <- metric_bind(train_df, test_df, "rmse", "lm", "NA", "gear", multiple_predictors)
  expect_equal(nrow(output_df), length(multiple_predictors))
})

# Test case 3: Check if the function returns a data frame with the correct column names for single predictor lm models
test_that("metric_bind returns a data frame with the correct column names for single predictor lm models", {
  output_df <- metric_bind(train_df, test_df, "rmse", "lm", "NA", "gear", single_predictors)
  expect_equal(colnames(output_df), c("metric", "method", "kmin", "target_variable", "predictor", ".estimate"))
})

# Test case 4: Check if the function returns a data frame with the correct column names for multiple predictor lm models
test_that("metric_bind returns a data frame with the correct column names for multiple predictor lm models", {
  output_df <- metric_bind(train_df, test_df, "rmse", "lm", "NA", "gear", multiple_predictors)
  expect_equal(colnames(output_df), c("metric", "method", "kmin", "target_variable", "predictor", ".estimate"))
})

# Test case 5: Check if the function raises an error when an unsupported metric is provided
test_that("metric_bind raises an error when an unsupported metric is provided", {
  expect_error(metric_bind(train_df, test_df, "unsupported_metric", "lm", "NA", "gear", single_predictors), "Please input a valid metric")
})
