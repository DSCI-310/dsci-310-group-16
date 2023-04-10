test_that("Metric_bind generates correct output for KKNN single regression", {
  train_df <- data.frame(win_rate = c(0.6, 0.5, 0.4), predictor1 = c(1, 2, 3), predictor2 = c(4, 5, 6))
  test_df <- data.frame(predictor1 = c(2, 3, 4), predictor2 = c(5, 6, 7))
  method <- "kknn"
  metric <- "rmse"
  target_variable <- "win_rate"
  model_list <- list("predictor1", "predictor2")
  
  output <- metric_bind(train_df = train_df, test_df = test_df, method = method, metric = metric, target_variable = target_variable, model_list = model_list)
  
  expected_output <- data.frame(
    method = "kknn",
    predictor = c("predictor2", "predictor1"),
    kmin = c(1L, 1L),
    metric_value = c(0.14142136, 0.26457513),
    stringsAsFactors = FALSE
  )
  
  expect_equal(output, expected_output, check.names = FALSE)
})

test_that("Metric_bind generates correct output for LM single regression", {
  train_df <- data.frame(win_rate = c(0.6, 0.5, 0.4), predictor1 = c(1, 2, 3), predictor2 = c(4, 5, 6))
  test_df <- data.frame(predictor1 = c(2, 3, 4), predictor2 = c(5, 6, 7))
  method <- "lm"
  metric <- "rmse"
  target_variable <- "win_rate"
  model_list <- list("predictor1", "predictor2")
  
  output <- metric_bind(train_df = train_df, test_df = test_df, method = method, metric = metric, target_variable = target_variable, model_list = model_list)
  
  expected_output <- data.frame(
    method = "lm",
    predictor = c("predictor2", "predictor1"),
    kmin = NA_integer_,
    metric_value = c(0.0970797370258968, 0.217944947177033),
    stringsAsFactors = FALSE
  )
  
  expect_equal(output, expected_output, check.names = FALSE)
})

test_that("Metric_bind generates correct output for LM multiple regression", {
  train_df <- data.frame(win_rate = c(0.6, 0.5, 0.4), predictor1 = c(1, 2, 3), predictor2 = c(4, 5, 6), predictor3 = c(7, 8, 9))
  test_df <- data.frame(predictor1 = c(2, 3, 4), predictor2 = c(5, 6, 7), predictor3 = c(8, 9, 10))
  method <- "lm"
  metric <- "rmse"
  target_variable <- "win_rate"
  model_list <- list(
    c("predictor1", "predictor2"),
    c("predictor1", "predictor3"),
    c("predictor2", "predictor3"),
    c("predictor1", "predictor2", "predictor3")
  )
  
  output <- metric_bind(train_df = train_df, test_df = test_df, method = method, metric = metric, target_variable
