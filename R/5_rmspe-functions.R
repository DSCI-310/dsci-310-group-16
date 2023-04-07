#Author: Ammar Bagharib
library(data.table)
suppressMessages(library(tidyverse))
suppressMessages(library(here))
suppressMessages(library(tidymodels))
library(kknn)
#' This script contains functions that returns the rmspe tables
#' NOTE: It can only run after '2_load.R', '3_clean.R' and '4_exploratory-analysis.R' has been run
#' 
player_train <- read.csv(here::here("output/player_train.csv"))
player_test <- read.csv(here::here("output/player_test.csv"))


#' Slice dataframe based on regression model target variable and predictor variables
#' 
#' @param train_df original train/ test dataframe
#' @param target_variable desired outcome of regression. e.g. 'win_rate' . NOTE: input is a string. 
#' @param ... expects predictor variables as STRINGS e.g. "height", "age". can be entered separately, or as one vector containing strings of predictors
#' 
#' @return sliced train/ test dataframe containing only target variable and predictor variable(s) columns
#' @export
#' 
#' @examples
#' target_df(mtcars, 'gear', 'am')
#' target_df(mtcars, 'gear', 'am', "vs")
#' target_df(mtcars, 'gear', c("am", "vs"))
#' 
target_df <- function(df, target_variable, ...){
  df <- df %>% dplyr::select(target_variable, ...) 
  print("target df produced!")
  return(df)
}

#' Create a recipe using all columns of a dataframe, with target variable specified, and all other columns as predictors
#'
#' @param target_df a dataframe which consists ONLY the columns relevant to the entire regression model i.e, target variable and predictors 
#' @param target_variable desired outcome of regression. e.g. 'win_rate' . NOTE: input is a string. 
#'
#' @return a model recipe based on the predictors and target variable
#' @export
#'
#' @examples
#' df <- mtcars[, c('gear', 'am', 'vs')]
#' create_recipe(df, "gear")
#' 
create_recipe <- function(target_df, target_variable){
  recipe <- recipes::recipe(~., data=target_df) %>%
    recipes::update_role(target_variable, new_role="outcome") %>%
    recipes::step_scale(all_predictors()) %>%
    recipes::step_center(all_predictors())
  print("model recipe produced!")
  return(recipe)
}

#' Create a model specification for tennis project that will eventually be fitted onto train/test data
#'
#' @param train_df player train dataframe
#' @param method either "lm" or "kknn" - referring to linear or KKNN regression
#' @param kmin for kknn regression method, expects NUMERIC kmin if specified, if specified, else, kmin set to 'NA', and will be optimised within the function. kmin is not utilised for lm regression method
#' @param target_variable desired outcome of regression. e.g. 'win_rate' . NOTE: input is a string. 
#' 
#' @return list of 2 objects, in order: 1. model specification, 2. kmin
#' @export
#'
#' @examples
#' df <- target_df(mtcars, target_variable='gear', 'am', "vs")
#' model_recipe <- create_recipe(df, 'gear')
#' create_spec_kmin(df, model_recipe, method="lm", target_variable="gear")
#' create_spec_kmin(df, model_recipe, method="kknn", target_variable="gear")
#' create_spec_kmin(df, model_recipe, method="kknn", kmin=4, target_variable="gear")
#' 
create_spec_kmin <- function(df, model_recipe, method, kmin='NA', target_variable){

  if (method=="kknn"){ #if kknn regression is used
    if (kmin=='NA'){
      #tune model spec to find optimal kmin when kmin not specified
      model_spec <- parsnip::nearest_neighbor(weight_func="rectangular", neighbors=tune()) %>%
        parsnip::set_engine(method) %>% #whether KNN or Linear Regression
        parsnip::set_mode("regression")
      
      model_workflow <- workflows::workflow() %>%
        workflows::add_recipe(model_recipe) %>%
        workflows::add_model(model_spec)
      
      model_vfold <- rsample::vfold_cv(df, v=5, strata=target_variable)
      
      gridvals <- tibble(neighbors=seq(1,40))
      
      model_results <- model_workflow %>%
        tune::tune_grid(resamples=model_vfold, grid=gridvals) %>%
        tune::collect_metrics() %>%
        dplyr::filter(.metric=="rmse") %>%
        dplyr::filter(mean==min(mean))
      
      kmin <- dplyr::pull(model_results, neighbors) #derive k value that gives minimum rmspe value
      
      } else if (!is.numeric(kmin)) { #check if kmin specified is numeric
        stop("invalid kmin specified")
        }
    #create tennis model specification if kmin is specified
    model_spec <- parsnip::nearest_neighbor(weight_func="rectangular", neighbors=kmin) %>%
      parsnip::set_engine(method) %>%
      parsnip::set_mode("regression")
    
  } else if (method=="lm"){ #if linear regression is used
    model_spec <- parsnip::linear_reg() %>%
      parsnip::set_engine(method) %>%
      parsnip::set_mode("regression")
  } else {
    stop("Invalid method specified")
  }
  print("model spec produced!")
  return(list(model_spec, kmin))
}

#' Getter function that retrieves n item from a list
#'
#' @param list_object 
#' @param n 
#'
#' @return returns nth item from a list
#' @export
#'
#' @examples
#' x <- list(1, 2, 3)
#' get_list_item(x, n=2)
#' get_list_item(x, n = 1)
#' 
get_list_item <- function(list_object, n){
  if (!is.numeric(n) | n < 1){
    stop("n has to be an interger > 0!")
  }
  return(list_object[[n]])
}

#' Create Model fit
#'
#' @param model_recipe a model recipe based on the predictors and target variable
#' @param model_spec a model specification that will eventually be fitted onto train/test data
#' @param df a dataframe that preferably consists ONLY the columns relevant to the entire regression model i.e, target variable and predictors 
#'
#' @return model fit
#' @export
#'
#' @example
#' df <- target_df(mtcars, 'gear', c("am", "vs"))
#' x_recipe <- create_recipe(df, target_variable="gear")
#' x_spec_list <- create_spec_kmin(df, model_recipe=x_recipe, method="lm", target_variable="gear")
#' x_spec <- get_list_item(x_spec_list, n=1)
#' class(create_fit(x_recipe, x_spec, df))
#' 
create_fit <- function(model_recipe, model_spec, df){
  model_fit <- workflows::workflow() %>%
    workflows::add_recipe(model_recipe) %>%
    workflows::add_model(model_spec) %>%
    fit(data=df)
  print("model fit produced!")
  return(model_fit)
}


#' Create prediction model
#'
#' @param target_test_df a dataframe which consists ONLY the columns relevant to the entire regression model i.e, target variable and predictors 
#' @param model_fit a "workflow" class object preferably generated from 'create_fit' function
#'
#' @return a dataframe with predicted values appended to target_test_df
#' @export
#'
#' @example
#' train_df <- target_df(mtcars[1:16, ], 'gear', c("am", "vs"))
#' test_df <- target_df(mtcars[17:32, ], 'gear', c("am", "vs"))
#' x_recipe <- create_recipe(train_df, target_variable="gear")
#' x_spec_list <- create_spec_kmin(train_df, model_recipe=x_recipe, method="lm", target_variable="gear")
#' x_spec <- get_list_item(x_spec_list, n=1) 
#' x_fit <- create_fit(x_recipe, x_spec, train_df)
#' create_model_prediction(test_df, x_fit )
#' 
create_model_prediction <- function(target_test_df, model_fit) {
  prediction_model <- model_fit %>%
    predict(target_test_df) %>%
    dplyr::bind_cols(target_test_df)
  print("prediction model produced!")
  return (prediction_model)
}

#' Pull metric from a prediction model
#'
#' @param prediction_model a dataframe with predicted values appended to target_test_df
#' @param metric metric to assess performance of prediction model
#' @param target_variable target variable of prediction model
#'
#' @return metric
#' @export
#'
#' @example
#' train_df <- target_df(mtcars[1:16, ], 'gear', c("am", "vs"))
#' test_df <- target_df(mtcars[17:32, ], 'gear', c("am", "vs"))
#' x_recipe <- create_recipe(train_df, target_variable="gear")
#' x_spec_list <- create_spec_kmin(train_df, model_recipe=x_recipe, method="lm", target_variable="gear")
#' x_spec <- get_list_item(x_spec_list, n=1) 
#' x_fit <- create_fit(x_recipe, x_spec, train_df)
#' prediction_model <- create_model_prediction(test_df, x_fit )
#' get_metric(prediction_model, "rmse", "gear")
get_metric <- function(prediction_model, metric, target_variable){
  metric_result <- prediction_model %>%
    metrics(truth=target_variable, estimate=.pred) %>% #rmse, rsq and mae metrics generated
    dplyr::filter(.metric==metric) %>%
    dplyr::select(.estimate) %>%
    dplyr::pull()
  print("metric extracted")
  return(metric_result)
}


#' Collapse string of arguments and join then by '+'
#' 
#' @param str_vector takes in a vector item(s) of class str
#' @returns returns input parameters combined as a string, separated by '+'
#' @export
#' 
#' @examples
#' str_collapse("my name")
#' str_collapse(c("my name", "is", "jake"))
#' str_collapse(c("my name", 2, "boy"))
#' str_collapse(c(3, 2, "boy"))
#' 
str_collapse <- function(str_vector){
 if (!all(is.character(str_vector))){
   stop("at least one item in str_vector should be of class 'character'")
 }
  return(paste(str_vector, collapse=" + "))
}

#' RMSPE results dataframe function
#'
#' @param train_df 
#' @param test_df 
#' @param method 
#' @param mode 
#' @param target_variable 
#' @param ... 
#' 
#' @returns dataframe containing rmspe value, predictors, and if knn was specified, it returns best k value, else k value would be'NA'
#' @export
#' 
#' @examples
#' single_train_df <- target_df(mtcars[1:16, ], 'gear', "am")
#' single_test_df <- target_df(mtcars[17:32, ], 'gear', "am")
#' create_metric_df(single_train_df, single_test_df, , method='kknn', kmin=4, target_variable='gear', predictors_vector="am")
#' 
#' multiple_train_df <- target_df(mtcars[1:16, ], 'gear', c("am", "vs"))
#' multiple_test_df <- target_df(mtcars[17:32, ], 'gear', c("am", "vs"))
#' create_metric_df(multiple_train_df, multiple_test_df, , method='kknn', kmin=4, target_variable='gear', predictors_vector=c("am", "vs"))
#' 
create_metric_df <- function(train_df, test_df, metric="rmse", method, kmin="NA", target_variable, predictors_vector){
  
  #create train data, includes win rate and predictors
  target_train_df <- target_df(df=train_df, target_variable, predictors_vector)
  
  #create test data, includes win rate and predictors
  target_test_df <- target_df(df=test_df, target_variable, predictors_vector)
  
  #create model recipe
  model_recipe <- create_recipe(target_df=target_train_df, target_variable=target_variable)
  
  #apply create_spec_kmin function and obtain model specification and kmin (if applicable)
  model_spec_kmin_list <- create_spec_kmin(df=target_train_df, model_recipe=model_recipe, 
                                           method=method, kmin=kmin, 
                                           target_variable=target_variable)
  
  #extract model spec
  model_spec <- get_list_item(model_spec_kmin_list, n=1)
  
  #extract kmin
  model_kmin <- get_list_item(model_spec_kmin_list, n=2)
  
  #create model fit
  model_fit <- create_fit(model_recipe, model_spec, target_train_df)
  
  #create prediction model
  model_pred <- create_model_prediction(target_test_df, model_fit)
  
  #extract metric result
  metric_result <- get_metric(prediction_model=model_pred, metric, target_variable)
    
  #format predictors string
  if (length(predictors_vector) > 1){ #if there is more than 1 predictor i.e, multi-variable regression
    predictors_vector <- str_collapse(predictors_vector) #combine input arguments into a string
  }
  print("metric df successful")
  return (
    data.frame(
      outcome=target_variable,
      predictor=predictors_vector,
      rmspe=metric_result,
      kmin=model_kmin
    )
  )
}



#' Binds dataframes which consists of rmspe performances of different regression models
#' 
#' @param  predictors_vector a LIST of column names as STRINGS e.g. "height", "age"
#' @param  train_df initial train dataframe
#' @param  test_df initial test dataframe
#' @param  method either "lm" or "kknn" - referring to linear or KKNN regression
#' @param  mode referring to type of regression, default is "single", other values include: "multiple" - 
#' @param  target_variable  accepts only STRING desired outcome of regression. e.g. win_rate . NOTE: input is NOT a string. 
#' @param  kmin 
#' @returns  dataframe containing rmspe values of all the different recipes, predictors, and if knn was specified, it returns best k value

#' @examples
#' # single_predictors <- list('height','breakpoint_saved_pct','second_serve_win_pct','first_serve_pct')
#' # rmspe_bind(predictors_vector=single_predictors, train_df=player_train, test_df=player_test,method="lm", mode="single", target_variable='win_rate')
#' # rmspe_bind(predictors_vector=single_predictors, train_df=player_train, test_df=player_test,method="kknn", mode="single", target_variable='win_rate')
#' # multiple_predictors <- list(c("mean_rank_points", "first_serve_win_pct"), c("mean_rank_points", "height"), c("mean_rank_points", "first_serve_pct") )
#' # rmspe_bind(predictors_vector=multiple_predictors, train_df=player_train, test_df=player_test,method="lm", mode="multiple", target_variable='win_rate')
#' # rmspe_bind(predictors_vector=multiple_predictors, train_df=player_train, test_df=player_test,method="kknn", mode="multiple", target_variable='win_rate')

# Append outcome, predictor, best k, and rmspe value to the results dataframe
rmspe_bind(predictors_vector, train_df, test_df, method, mode, target_variable, kmin){
  
  if (!is.character(target_variable)){
    stop ("Please input target variable as a string!")
  }
  # predictors_vector <- list('height','breakpoint_saved_pct','second_serve_win_pct','first_serve_pct')
  # train_df <- player_train
  # test_df <- player_test
  # method="kknn"
  # mode="single"
  # target_variable <- 'win_rate'

  #intiate dataframe by creating first instance of rmspe result dataframe
  rmspe_result_df <- create_rmspe_df(train_df, test_df, method, mode, target_variable, predictors_vector[[1]])

  #instantiate for loop, using the remaining items in predictors_vector
  for (i in predictors_vector[-1]){
    #print(i)
    rmspe_result_df <- data.table::rbindlist(
      list(
        rmspe_result_df,
        create_rmspe_df(train_df, test_df, method, mode, target_variable, predictors_vector[[i]])
      )
    )
  }
  return (rmspe_result_df)
}

single_predictors <- list('height','breakpoint_saved_pct','second_serve_win_pct','first_serve_pct')
rmspe_bind(predictors_vector=single_predictors, train_df=player_train, test_df=player_test,method="lm", mode="single", target_variable='win_rate') %>% View()







rmspe_bind <- function(predictors_vector, train_df, test_df, method, mode, target_variable){
  
  if (!is.character(target_variable)){
    return ("Please input target variable as a string!")
  }
  # predictors_vector <- list('height','breakpoint_saved_pct','second_serve_win_pct','first_serve_pct')
  # train_df <- player_train
  # test_df <- player_test
  # method="kknn"
  # mode="single"
  # target_variable <- 'win_rate'
  
  #intiate dataframe by creating first 
  model_pred_list <- model_prediction(train_df, test_df, method, target_variable, predictors_vector[[1]])
  rmspe_result_df <- create_rmspe_df(model_pred_list, mode=mode)
  
  rmspe_result_df <- rmspe_results(train_df=train_df, test_df=test_df, 
                                   method=method, mode=mode, 
                                   target_variable=target_variable, #glue converts the string into the name of the column
                                   predictors_vector[[1]])
  
  #instantiate for loop, using the remaining items in predictors_vector
  for (i in predictors_vector[-1]){
    #print(i)
    rmspe_result_df <- data.table::rbindlist(list(
      rmspe_result_df,
      rmspe_results(train_df=train_df, test_df=test_df, 
                    method=method, mode=mode, 
                    target_variable=target_variable, i)
    )
    )
  }
  
  if (method=="lm"){
    # assign NA to kmin column if method is linear
    rmspe_result_df <- rmspe_result_df %>% 
      dplyr::mutate(kmin="N/A", method="lm") 
    
  } else if (method=="kknn"){
    rmspe_result_df <- rmspe_result_df %>% 
      dplyr::mutate(method="kknn") 
  }
  
  # fill in output column
  rmspe_result_df <- rmspe_result_df %>% 
    dplyr::mutate(outcome=target_variable)
  
  return (rmspe_result_df)
}

# TEST: invalid target_variable
# invalid_str <- rmspe_bind(
#   predictors_vector=multiple_predictors,
#   train_df=player_train,
#   test_df=player_test,
#   method="kknn",
#   mode="multiple",
#   target_variable=2
# )
# 
# testthat::expect_equal(invalid_str, "Please input target variable as a string!")

# rmspe_results <- function(train_df, test_df, method, mode="single", target_variable, ...) {
#   
#   # train_df=player_train
#   # test_df=player_test
#   # method="kknn"
#   
#   #create train data, includes win rate and predictors
#   train_data <- train_df %>% dplyr::select(target_variable, ...) 
#   
#   #create test data, includes win rate and predictors
#   test_data <- player_test %>%
#     dplyr::select(target_variable, ...)
#   
#   tennis_spec <- 
#     
#     tennis_fit <- workflows::workflow() %>%
#     workflows::add_recipe(tennis_recipe) %>%
#     workflows::add_model(tennis_spec) %>%
#     fit(data=train_data)
#   
#   rmspe_val <- tennis_fit %>%
#     predict(test_data) %>%
#     dplyr::bind_cols(test_data) %>%
#     metrics(truth=target_variable, estimate=.pred) %>%
#     dplyr::filter(.metric=="rmse") %>%
#     dplyr::select(.estimate) %>%
#     dplyr::pull()
#   
#   if (mode=="multiple"){
#     predictor_str <- str_collapse(c(...)) #combine input arguments into a string
#   } else if (mode=="single") {
#     predictor_str <- c(...)
#   }
#   
#   return (
#     data.frame(
#       #outcome=deparse(substitute(target_variable)),
#       outcome=target_variable,
#       predictor=predictor_str,
#       rmspe=rmspe_val,
#       kmin=ifelse(method=="kknn", kmin, "N/A")
#     )
#   )
# }
