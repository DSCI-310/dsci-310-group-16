library(testthat)

Test case 1: str_collapse returns a string with items of class 'character' separated by '+' when all items in 'str_vector' are of class 'character.'
test_that("str_collapse returns a string with items of class 'character' separated by '+' when all items in 'str_vector' are of class 'character.'", {
str_vector <- c("my name", "is", "jake")
expected_output <- "my name + is + jake"
expect_equal(str_collapse(str_vector), expected_output)
})

Test case 2: str_collapse raises an error when not all items in 'str_vector' are of class 'character.'
test_that("str_collapse raises an error when not all items in 'str_vector' are of class 'character.'", {
str_vector <- c("my name", "is", 2)
expected_error <- "All items in 'str_vector' should be of class 'character'."
expect_error(str_collapse(str_vector), expected_error)
})

Test case 3: str_collapse returns the single item in 'str_vector' when it has only one element
test_that("str_collapse returns the single item in 'str_vector' when it has only one element", {
str_vector <- "my name"
expected_output <- "my name"
expect_equal(str_collapse(str_vector), expected_output)
})

Test case 4: str_collapse returns an empty string when passed an empty vector
test_that("str_collapse returns an empty string when passed an empty vector", {
str_vector <- character(0)
expected_output <- ""
expect_equal(str_collapse(str_vector), expected_output)
})

Test case 5: str_collapse handles leading/trailing whitespace correctly
test_that("str_collapse handles leading/trailing whitespace correctly", {
str_vector <- c(" my name ", " is ", " jake ")
expected_output <- " my name + is + jake "
expect_equal(str_collapse(str_vector), expected_output)
})
