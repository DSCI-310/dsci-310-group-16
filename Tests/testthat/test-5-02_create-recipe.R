library(testthat)

test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})


create some example data for testing
set.seed(123)
train_df <- mtcars[1:16, ]
target_df <- target_df(train_df, "gear", mpg, cyl, disp)

Test case 1: Test that the function returns a recipe object
test_that("create_recipe returns a recipe object", {
output <- create_recipe(target_df, "gear")
expect_true(is.recipe(output))
})

Test case 2: Test that the recipe object has the correct roles
test_that("create_recipe returns a recipe object with correct roles", {
output <- create_recipe(target_df, "gear")
expect_equal(recipes::role(output$roles, "outcome"), "gear")
expect_equal(recipes::role(output$roles, "predictor"), c("mpg", "cyl", "disp"))
})

Test case 3: Test that the recipe object has the correct preprocessing steps
test_that("create_recipe returns a recipe object with correct preprocessing steps", {
output <- create_recipe(target_df, "gear")
expect_true("step_scale" %in% class(output$steps[[1]]$recipe))
expect_true("step_center" %in% class(output$steps[[2]]$recipe))
})
