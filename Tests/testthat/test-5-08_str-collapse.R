library(testthat)

# Test case 1: Check if the function correctly collapses a single string
test_that("str_collapse correctly collapses a single string", {
  input <- "my name"
  expected_output <- "my name"
  output <- str_collapse(input)
  expect_equal(output, expected_output)
})

# Test case 2: Check if the function correctly collapses a vector of strings
test_that("str_collapse correctly collapses a vector of strings", {
