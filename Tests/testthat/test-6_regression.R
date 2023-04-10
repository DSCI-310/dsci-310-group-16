library(testthat)
library(data.table)
library(dplyr)

test_file <- here::here('scripts/regression-tables.R')

test_that("Regression tables script produces expected output", {
  
  # generate tables using script
  source(test_file)
  
  # load expected output
  expected_kknn_single <- as.data.frame(fread(here::here('tests/testthat/expected/kknn-single-regression.csv')))
  expected_lm_single <- as.data.frame(fread(here::here('tests/testthat/expected/lm-single-regression.csv')))
  expected_lm_multiple <- as.data.frame(fread(here::here('tests/testthat/expected/lm-multiple-regression.csv')))
  expected_kknn_multiple <- as.data.frame(fread(here::here('tests/testthat/expected/kknn-multiple-regression.csv')))
  expected_all_methods <- as.data.frame(fread(here::here('tests/testthat/expected/all-methods.csv')))
  expected_best_model <- as.data.frame(fread(here::here('tests/testthat/expected/best-model-prediction.csv')))
  
  # test kknn single regression output
  expect_identical(kknn_single, expected_kknn_single)
  
  # test lm single regression output
  expect_identical(lm_single, expected_lm_single)
  
  # test lm multiple regression output
  expect_identical(lm_multiple, expected_lm_multiple)
  
  # test kknn multiple regression output
  expect_identical(kknn_multiple, expected_kknn_multiple)
  
  # test all methods output
  expect_identical(all_methods, expected_all_methods)
  
  # test best model prediction output
  expect_identical(final_model, expected_best_model)
  
})
