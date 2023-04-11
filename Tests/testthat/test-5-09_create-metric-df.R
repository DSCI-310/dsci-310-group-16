library(testthat)

# Prepare train and test data frames
train_df <- mtcars[1:16, ]
test_df <- mtcars[17:32, ]

# Test case 1: Check if the function returns a data frame with the correct column names for single predictor lm model
test_that("create_metric_df returns a data frame with the correct column names for single predictor lm model", {
  output_df <- create_metric_df(train_df, test_df, "rmse", "lm", "NA", "gear", "am")
  expect_equal(colnames(output_df), c("outcome", "predictor", "metric", "metric_value", "method", "kmin"))
})

# Test case 2: Check if the function returns a data frame with the correct column names for multiple predictor lm model
test_that("create_metric_df returns a data frame with the correct column names for multiple predictor lm model", {
  output_df <- create_metric_df(train_df, test_df, "rsq", "lm", "NA", "gear", c("am", "vs"))
  expect_equal(colnames(output_df), c("outcome", "predictor", "metric", "metric_value", "method", "kmin"))
})

# Test case 3: Check if the function returns a data frame with the correct column names for single predictor kknn model
test_that("create_metric_df returns a data frame with the correct column names for single predictor kknn model", {
  output_df <- create_metric_df(train_df, test_df, "mae", "kknn", 3, "gear", "am")
  expect_equal(colnames(output_df), c("outcome", "predictor", "metric", "metric_value", "method", "kmin"))
})

# Test case 4: Check if the function returns a data frame with the correct column names for multiple predictor kknn model
test_that("create_metric_df returns a data frame with the correct column names for multiple predictor kknn model", {
  output_df <- create_metric_df(train_df, test_df, "rsq", "kknn", "all", "gear", c("am", "vs"))
  expect_equal(colnames(output_df), c("outcome", "predictor", "metric", "metric_value", "method", "kmin"))
})

# Test case 5: Check if the function raises an error when an unsupported metric is provided
test_that("create_metric_df raises an error when an unsupported metric is provided", {
  expect_error(create_metric_df(train_df, test_df, "unsupported_metric", "lm", "NA", "gear", "am"), "Please input a valid metric")
})
