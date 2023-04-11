library(testthat)
library(tidymodels)

# Prepare train data frame
train_df <- mtcars[1:16, ]

# Test case 1: Check if the function returns a workflow fit object for single predictor lm model
test_that("create_fit returns a workflow fit object for single predictor lm model", {
  target_train_df <- target_df(train_df, "gear", "am")
  model_recipe <- create_recipe(target_train_df, "gear")
  model_spec <- create_spec_kmin(target_train_df, model_recipe, "lm", target_variable = "gear")[[1]]
  output_fit <- create_fit(model_recipe, model_spec, target_train_df)
  expect_true("workflow_fit" %in% class(output_fit))
})

# Test case 2: Check if the function returns a workflow fit object for multiple predictor lm model
test_that("create_fit returns a workflow fit object for multiple predictor lm model", {
  target_train_df <- target_df(train_df, "gear", c("am", "vs"))
  model_recipe <- create_recipe(target_train_df, "gear")
  model_spec <- create_spec_kmin(target_train_df, model_recipe, "lm", target_variable = "gear")[[1]]
  output_fit <- create_fit(model_recipe, model_spec, target_train_df)
  expect_true("workflow_fit" %in% class(output_fit))
})

# Test case 3: Check if the function returns a workflow fit object for single predictor kknn model
test_that("create_fit returns a workflow fit object for single predictor kknn model", {
  target_train_df <- target_df(train_df, "gear", "am")
  model_recipe <- create_recipe(target_train_df, "gear")
  model_spec <- create_spec_kmin(target_train_df, model_recipe, "kknn", kmin = 3, target_variable = "gear")[[1]]
  output_fit <- create_fit(model_recipe, model_spec, target_train_df)
  expect_true("workflow_fit" %in% class(output_fit))
})

# Test case 4: Check if the function returns a workflow fit object for multiple predictor kknn model
test_that("create_fit returns a workflow fit object for multiple predictor kknn model", {
  target_train_df <- target_df(train_df, "gear", c("am", "vs"))
  model_recipe <- create_recipe(target_train_df, "gear")
  model_spec <- create_spec_kmin(target_train_df, model_recipe, "kknn", kmin = 3, target_variable = "gear")[[1]]
  output_fit <- create_fit(model_recipe, model_spec, target_train_df)
  expect_true("workflow_fit" %in% class(output_fit))
})
