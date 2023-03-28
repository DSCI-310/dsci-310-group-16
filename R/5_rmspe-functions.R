library(data.table)
suppressMessages(library(tidyverse))
suppressMessages(library(here))
suppressMessages(library(tidymodels))
library(kknn)
#' This script contains functions that returns the rmspe tables
#' 

str_collapse <- function(...){
  #this function is used to collapse arguments in a string vector to a function as a string, separated by '+'
  return(paste(c(...), collapse = " + "))
}
#' This function takes in the data, method and regression recipe
#' 
#' @param  train_df initial train dataframe
#' @param  test_df initial test dataframe
#' @param  method either "lm" or "kknn" - referring to linear or KKNN regression
#' @param  mode referring to type of regression, default is "single", other values include: "multiple" - 
#' @param  target_variable  desired outcome of regression. e.g. 'win_rate' . NOTE: input is a string. 
#' @param  ... expects column names as STRINGS e.g. "height", "age". can be entered separately, or as one vector containing strings of predictors
#' @returns dataframe containing rmspe value, predictors, and if knn was specified, it returns best k value
#' 
#' @examples
#' # rmspe_results(train_df = player_train, test_df = player_test, method = "kknn", mode = "single", target_variable = 'win_rate', "mean_rank_points")
#' # rmspe_results(train_df = player_train, test_df = player_test, method = "lm", mode = "single", target_variable = 'win_rate', "mean_rank_points")
#' # rmspe_results(train_df = player_train, test_df = player_test, method = "lm", mode = "multiple", target_variable = 'win_rate', "mean_rank_points", "first_serve_win_pct")
#' # rmspe_results(train_df = player_train, test_df = player_test, method = "kknn", mode = "multiple", target_variable = 'win_rate', "mean_rank_points", "first_serve_win_pct")
#' # rmspe_results(train_df = player_train, test_df = player_test, method = "lm", mode = "multiple", target_variable = 'win_rate', c("mean_rank_points", "first_serve_win_pct"))
rmspe_results <- function(train_df, test_df, method, mode = "single", target_variable, ...) {
  
  # train_df = player_train
  # test_df = player_test
  # method = "kknn"

  #create train data, includes win rate and predictors
  train_data <- train_df %>% dplyr::select({{target_variable}}, ...) 

  #create test data, includes win rate and predictors
  test_data <- player_test %>%
    dplyr::select({{target_variable}}, ...)
  
  #create recipe with predictors and outcome
  tennis_recipe <- recipes::recipe(~ ., data = train_data) %>%
    recipes::update_role({{target_variable}}, new_role = "outcome") %>%
    recipes::step_scale(all_predictors()) %>%
    recipes::step_center(all_predictors())
  
  if (method == "kknn"){
    tennis_spec <- parsnip::nearest_neighbor(weight_func = "rectangular", neighbors = tune()) %>%
      parsnip::set_engine(method) %>% #whether KNN or Linear Regression
      parsnip::set_mode("regression")
  
    tennis_workflow <- workflows::workflow() %>%
      workflows::add_recipe(tennis_recipe) %>%
      workflows::add_model(tennis_spec)

    tennis_vfold <- rsample::vfold_cv(train_data, v = 5, strata = {{target_variable}})
    
    gridvals <- tibble(neighbors = seq(1,40))
    
    tennis_results <- tennis_workflow %>%
      tune::tune_grid(resamples = tennis_vfold, grid = gridvals) %>%
      tune::collect_metrics() %>%
      dplyr::filter(.metric == "rmse") %>%
      dplyr::filter(mean == min(mean))
    
    kmin <- dplyr::pull(tennis_results, neighbors) #derive k value that gives minimum rmspe value
    
    tennis_spec <- parsnip::nearest_neighbor(weight_func = "rectangular", neighbors = kmin) %>%
      parsnip::set_engine(method) %>%
      parsnip::set_mode("regression")
  }
  else if (method == "lm"){ #if linear regression is used
    tennis_spec <- parsnip::linear_reg() %>%
      parsnip::set_engine(method) %>%
      parsnip::set_mode("regression")
  }
  
  tennis_fit <- workflows::workflow() %>%
    workflows::add_recipe(tennis_recipe) %>%
    workflows::add_model(tennis_spec) %>%
    fit(data = train_data)
  
  rmspe_val <- tennis_fit %>%
    predict(test_data) %>%
    dplyr::bind_cols(test_data) %>%
    metrics(truth = {{target_variable}}, estimate = .pred) %>%
    dplyr::filter(.metric == "rmse") %>%
    dplyr::select(.estimate) %>%
    dplyr::pull()
  
    if (mode == "multiple"){
      predictor_str <- str_collapse(c(...)) #combine input arguments into a string
    } else if (mode == "single") {
      predictor_str <- c(...)
    }
  
    return (
      data.frame(
        #outcome = deparse(substitute(target_variable)),
        outcome = target_variable,
        predictor = predictor_str,
        rmspe = rmspe_val,
        kmin = ifelse(method == "kknn", kmin, "N/A")
      )
    )
}

# player_train <- read.csv(here::here("output/player_train.csv"))
# player_test <- read.csv(here::here("output/player_test.csv"))

#' This function rmspe_bind takes in the following parameters
#' @param  predictors_vector a LIST of column names as STRINGS e.g. "height", "age"
#' @param  train_df initial train dataframe
#' @param  test_df initial test dataframe
#' @param  method either "lm" or "kknn" - referring to linear or KKNN regression
#' @param  mode referring to type of regression, default is "single", other values include: "multiple" - 
#' @param  target_variable  accepts only STRING desired outcome of regression. e.g. win_rate . NOTE: input is NOT a string. 
#' @returns  dataframe containing rmspe values of all the different recipes, predictors, and if knn was specified, it returns best k value

#' @examples
#' # single_predictors <- list('height','breakpoint_saved_pct','second_serve_win_pct','first_serve_pct')
#' # rmspe_bind(predictors_vector = single_predictors, train_df = player_train, test_df = player_test,method = "lm", mode = "single", target_variable = 'win_rate')
#' # rmspe_bind(predictors_vector = single_predictors, train_df = player_train, test_df = player_test,method = "kknn", mode = "single", target_variable = 'win_rate')
#' # multiple_predictors <- list(c("mean_rank_points", "first_serve_win_pct"), c("mean_rank_points", "height"), c("mean_rank_points", "first_serve_pct") )
#' # rmspe_bind(predictors_vector = multiple_predictors, train_df = player_train, test_df = player_test,method = "lm", mode = "multiple", target_variable = 'win_rate')
#' # rmspe_bind(predictors_vector = multiple_predictors, train_df = player_train, test_df = player_test,method = "kknn", mode = "multiple", target_variable = 'win_rate')

# Append outcome, predictor, best k, and rmspe value to the results dataframe
rmspe_bind <- function(predictors_vector, train_df, test_df, method, mode, target_variable){
  
  if (!is.character(target_variable)){
    return ("Please input target variable as a string!")
  }
  # predictors_vector <- list('height','breakpoint_saved_pct','second_serve_win_pct','first_serve_pct')
  # train_df <- player_train
  # test_df <- player_test
  # method = "kknn"
  # mode = "single"
  # target_variable <- 'win_rate'

  #intiate dataframe by creating first 
  rmspe_result_df <- rmspe_results(train_df = train_df, test_df = test_df, 
                                   method = method, mode = mode, 
                                   target_variable = target_variable, #glue converts the string into the name of the column
                                   predictors_vector[[1]])

  #instantiate for loop, using the remaining items in predictors_vector
  for (i in predictors_vector[-1]){
    #print(i)
    rmspe_result_df <- data.table::rbindlist(list(
      rmspe_result_df,
      rmspe_results(train_df = train_df, test_df = test_df, 
                    method = method, mode = mode, 
                    target_variable = target_variable, i)
      )
    )
  }
  
  if (method == "lm"){
    # assign NA to kmin column if method is linear
    rmspe_result_df <- rmspe_result_df %>% 
      dplyr::mutate(kmin = "N/A", method = "lm") 
    
  } else if (method == "kknn"){
    rmspe_result_df <- rmspe_result_df %>% 
      dplyr::mutate(method = "kknn") 
  }

  # fill in output column
  rmspe_result_df <- rmspe_result_df %>% 
    dplyr::mutate(outcome = target_variable)
  
  return (rmspe_result_df)
}

# TEST: invalid target_variable
# invalid_str <- rmspe_bind(
#   predictors_vector = multiple_predictors,
#   train_df = player_train,
#   test_df = player_test,
#   method = "kknn",
#   mode = "multiple",
#   target_variable = 2
# )
# 
# testthat::expect_equal(invalid_str, "Please input target variable as a string!")


