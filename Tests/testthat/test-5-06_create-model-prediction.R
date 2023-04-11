library(testthat)
library(tidymodels)

# Prepare train and test data frames
train_df <- mtcars[1:16, ]
test_df <- mtcars[17:32, ]

# Test case 1: Check if the function returns a data frame with the same number of rows as the input data frame
test_that("create_model_prediction returns a data frame with the same number of rows as the input data frame", {
  target_train_df <- target_df(train_df, "gear", "am")
  target_test_df <- target_df(test_df, "gear", "am")
  model_recipe <- create_recipe(target_train_df, "gear")
  model_spec <- create_spec_kmin(target_train_df, model_recipe, "lm", target_variable = "gear")[[1]]
  model_fit <- create_fit(model_recipe, model_spec, target_train_df)
  output_df <- create_model_prediction(target_test_df, model_fit)
  expect_equal(nrow(target_test_df), nrow(output_df))
})

# Test case 2: Check if the function returns a data frame with the '.pred' column
test_that("create_model_prediction returns a data frame with the '.pred' column", {
  target_train_df <- target_df(train_df, "gear", "am")
  target_test_df <- target_df(test_df, "gear", "am")
  model_recipe <- create_recipe(target_train_df, "gear")
  model_spec <- create_spec_kmin(target_train_df, model_recipe, "lm", target_variable = "gear")[[1]]
  model_fit <- create_fit(model_recipe, model_spec, target_train_df)
  output_df <- create_model_prediction(target_test_df, model_fit)
  expect_true(".pred" %in% colnames(output_df))
})

# Test case 3: Check if the function returns a data frame with the same number of columns as the input data frame + 1
test_that("create_model_prediction returns a data frame with the same number of columns as the input data frame + 1", {
  target_train_df <- target_df(train_df, "gear", "am")
  target_test_df <- target_df(test_df, "gear", "am")
  model_recipe <- create_recipe(target_train_df, "gear")
  model_spec <- create_spec_kmin(target_train_df, model_recipe, "lm", target_variable = "gear")[[1]]
  model_fit <- create_fit(model_recipe, model_spec, target_train_df)
  output_df <- create_model_prediction(target_test_df, model_fit)
  expect_equal(ncol(target_test_df) + 1, ncol(output_df))
})
