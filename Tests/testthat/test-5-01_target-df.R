test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})


Test case 1: Selecting only the target variable
test_that("target_df selects only the target variable when no additional columns are specified", {
df <- mtcars
target_variable <- "mpg"
output <- target_df(df, target_variable)
expect_equal(ncol(output), 1)
expect_equal(colnames(output), target_variable)
})

Test case 2: Selecting the target variable and additional columns
test_that("target_df selects the target variable and additional columns when specified", {
df <- mtcars
target_variable <- "mpg"
additional_columns <- c("cyl", "disp")
output <- target_df(df, target_variable, additional_columns)
expect_equal(ncol(output), 3)
expect_equal(colnames(output), c(target_variable, additional_columns))
})

Test case 3: Selecting only additional columns
test_that("target_df selects only the additional columns when no target variable is specified", {
df <- mtcars
additional_columns <- c("cyl", "disp")
output <- target_df(df, additional_columns)
expect_equal(ncol(output), length(additional_columns))
expect_equal(colnames(output), additional_columns)
})
