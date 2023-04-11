library(testthat)

Test case 1: All items in str_vector are characters
test_that("str_collapse returns a string with items of class 'character' separated by '+", {
str_vector <- c("my name", "is", "jake")
expect_equal(str_collapse(str_vector), "my name + is + jake")
})

Test case 2: Some items in str_vector are not characters
test_that("str_collapse raises an error when not all items in 'str_vector' are of class 'character'", {
str_vector <- c("my name", "is", 2)
expected_error <- "All items in 'str_vector' should be of class 'character'."
expect_error(str_collapse(str_vector), expected_error)
})

Test case 3: str_vector has only one element
test_that("str_collapse returns the single item in 'str_vector' when it has only one element", {
str_vector <- "my name"
expect_equal(str_collapse(str_vector), "my name")
})
