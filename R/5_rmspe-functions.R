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

#' Selects target variable and additional columns from a dataframe
#'
#' @param df a dataframe
#' @param target_variable a character string representing the target variable
#' @param ... additional columns to select from the dataframe
#'
#' @return a dataframe with only the target variable and the additional columns selected
#'
#' @examples
#' # Selecting only the target variable
#' target_df(mtcars, "mpg")
#'
#' # Selecting the target variable and additional columns
#' target_df(mtcars, "mpg", cyl, disp)
#'
#' @export
target_df <- function(df, target_variable, ...){
  df <- df %>% dplyr::select(target_variable, ...)
  #print("target df produced!")
  return(df)
}


#' Create a recipe object for modeling
#'
#' This function creates a recipe object for modeling based on the specified target variable and predictors.
#'
#' @param target_df A data frame containing the target variable and predictors.
#' @param target_variable A string specifying the name of the target variable.
#'
#' @return A recipe object for modeling.
#'
#' @importFrom recipes recipe update_role step_scale step_center
#'
#' @examples
#' data("mtcars")
#' target_df <- target_df(mtcars, "gear", mpg, cyl, disp)
#' recipe <- create_recipe(target_df, "gear")
#' 
#' @export
create_recipe <- function(target_df, target_variable){
  recipe <- recipes::recipe(~., data=target_df) %>%
    recipes::update_role(target_variable, new_role="outcome") %>%
    recipes::step_scale(all_predictors()) %>%
    recipes::step_center(all_predictors())
  #print("model recipe produced!")
  return(recipe)
}

#' Create model specification with optional kmin tuning
#'
#' This function creates a model specification for either linear regression or k-nearest neighbor regression, with an optional kmin tuning for the latter. If kmin is not specified, the function performs a grid search to find the optimal k value that gives the minimum root mean squared error (RMSE) on a 5-fold cross-validation of the training data.
#'
#' @param df A data frame containing the training data.
#' @param model_recipe A recipe object created using the `create_recipe` function.
#' @param method A character string indicating the type of regression method to be used: "lm" for linear regression or "kknn" for k-nearest neighbor regression.
#' @param metric A character string specifying the performance metric to calculate ("rmse", "rsq", or "mae")
#' @param kmin A numeric value specifying the minimum number of neighbors to be considered when performing k-nearest neighbor regression. If set to "NA", the function performs a grid search to find the optimal k value. Default is "NA".
#' @param target_variable A character string indicating the name of the target variable to be predicted.
#'
#' @return A list containing the model specification and the kmin value (if applicable).
#'
#' @examples
#' train_df <- mtcars[1:16, ]
#' target_df <- target_df(train_df, "gear")
#' model_recipe <- create_recipe(target_df, "gear")
#' create_spec_kmin(train_df, model_recipe, "lm", metric="rmse", target_variable="gear")
#' create_spec_kmin(train_df, model_recipe, "kknn", metric="rmse", target_variable="gear")
#' create_spec_kmin(train_df, model_recipe, "kknn", metric="rmse", kmin=5, target_variable="gear")
#'
#' @import dplyr
#' @importFrom recipes recipe update_role step_scale step_center all_predictors
#' @importFrom parsnip nearest_neighbor set_engine set_mode linear_reg
#' @importFrom workflows workflow add_recipe add_model
#' @importFrom tune tune_grid collect_metrics filter pull
#' @importFrom tibble tibble
#' @importFrom rsample vfold_cv
#' @importFrom stats seq
#' @importFrom utils stop
create_spec_kmin <- function(df, model_recipe, method, kmin='NA', metric, target_variable){
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
        dplyr::filter(.metric==metric) %>%
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
  #print("model spec produced!")
  return(list(model_spec, kmin))
}

#' Getter function that retrieves n item from a list



#' Get List Item
#'
#' This function retrieves the nth element of a given list.
#'
#' @param list_object A list.
#' @param n The index of the element to retrieve.
#'
#' @return The nth element of the input list.
#'
#' @examples
#' my_list <- list(a = 1, b = 2, c = 3)
#' get_list_item(my_list, 2)
#'
#' @export

get_list_item <- function(list_object, n){
  if (!is.numeric(n) | n < 1){
    stop("n has to be an integer > 0!")
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
#' @examples
#' # Load data
#' data(mtcars)
#' 
#' # Create a target dataset
#' target_df <- target_df(mtcars, "gear", "wt", "qsec")
#' 
#' # Create recipe
#' model_recipe <- create_recipe(target_df, "gear")
#' 
#' # Create model specification with kmin
#' model_list <- list("mpg", "cyl", "disp", "hp", "am")
#' model_spec_kknn <- create_spec_kmin(target_df, model_recipe, "kknn", kmin=5, target_variable="gear")
#' model_spec_lm <- create_spec_kmin(target_df, model_recipe, "lm", target_variable="gear")
#' 
#' # Get first item from model_spec_kknn list
#' model_spec <- get_list_item(model_spec_kknn, 1)
#' 
#' # Fit model using kknn
#' model_fit_kknn <- create_fit(model_recipe, model_spec, target_df)
#' 
#' # Get first item from model_spec_lm list
#' model_spec <- get_list_item(model_spec_lm, 1)
#' 
#' # Fit model using lm
#' model_fit_lm <- create_fit(model_recipe, model_spec, target_df)
#' 
create_fit <- function(model_recipe, model_spec, df){
  model_fit <- workflows::workflow() %>%
    workflows::add_recipe(model_recipe) %>%
    workflows::add_model(model_spec) %>%
    fit(data=df)
  #print("model fit produced!")
  return(model_fit)
}

#' Create prediction model
#'
#' @param target_test_df A dataframe with columns relevant to the regression model, i.e., target variable and predictors 
#' @param model_fit A "workflow" class object generated by the `create_fit` function
#'
#' @return A dataframe with predicted values appended to target_test_df
#' @export
#'
#' @examples
#' train_df <- target_df(mtcars[1:16, ], 'gear', c("am", "vs"))
#' test_df <- target_df(mtcars[17:32, ], 'gear', c("am", "vs"))
#' x_recipe <- create_recipe(train_df, target_variable="gear")
#' x_spec_list <- create_spec_kmin(train_df, model_recipe=x_recipe, method="lm", target_variable="gear")
#' x_spec <- get_list_item(x_spec_list, n=1) 
#' x_fit <- create_fit(x_recipe, x_spec, train_df)
#' create_model_prediction(test_df, x_fit )
#'
#' @import dplyr
#' @importFrom workflows predict
#' @importFrom dplyr bind_cols
create_model_prediction <- function(target_test_df, model_fit) {
  prediction_model <- model_fit %>%
    predict(new_data = target_test_df) %>%
    dplyr::bind_cols(target_test_df, .)
  #print("Prediction model produced!")
  return (prediction_model)
}

#' Get metric from a prediction model
#'
#' Extracts a specified metric from a prediction model.
#'
#' @param prediction_model A dataframe with predicted values appended to target_test_df.
#' @param metric The name of the metric to assess performance of the prediction model.
#'   Supported metrics include "rmse", "rsq", and "mae".
#' @param target_variable The name of the target variable of the prediction model.
#'
#' @return The specified metric value.
#' @export
#'
#' @examples
#' train_df <- target_df(mtcars[1:16, ], 'gear', c("am", "vs"))
#' test_df <- target_df(mtcars[17:32, ], 'gear', c("am", "vs"))
#' x_recipe <- create_recipe(train_df, target_variable="gear")
#' x_spec_list <- create_spec_kmin(train_df, model_recipe=x_recipe, method="lm", target_variable="gear")
#' x_spec <- get_list_item(x_spec_list, n=1) 
#' x_fit <- create_fit(x_recipe, x_spec, train_df)
#' prediction_model <- create_model_prediction(test_df, x_fit )
#' get_metric(prediction_model, "rmse", "gear")
#' 
get_metric <- function(prediction_model, metric, target_variable){
  if(!(metric %in% c("rmse", "rsq", "mae"))){
    stop("Please input a valid metric")
  }
  metric_result <- prediction_model %>%
    metrics(truth=target_variable, estimate=.pred) %>% #rmse, rsq and mae metrics generated
    dplyr::filter(.metric==metric) %>%
    dplyr::select(.estimate) %>%
    dplyr::pull()
  #print("Metric extracted")
  return(metric_result)
}


#' Collapse string of arguments and join them by '+'
#' 
#' @param str_vector a vector of strings to be collapsed
#' 
#' @return A string with the input parameters combined as a string, separated by '+'
#' 
#' @export
#' 
#' @examples
#' str_collapse("my name")
#' str_collapse(c("my name", "is", "jake"))
#' str_collapse(c("my name", "is", 2))
#' str_collapse(c(3, 2, "boy"))
#' 
#' @keywords string manipulation
#' 
str_collapse <- function(str_vector) {
  if (!all(sapply(str_vector, is.character))) {
    stop("All items in 'str_vector' should be of class 'character'.")
  }
  paste(str_vector, collapse = " + ")
}

#' Create a dataframe of performance metrics for a prediction model
#'
#' @description
#' This function takes as input two data frames (train_df and test_df) that contain the training and test data for a prediction model, respectively. It also takes a character string specifying the performance metric to calculate (metric), a character string specifying the prediction model to use (method), an integer specifying the minimum number of neighbors to consider when using the "kknn" method (kmin), a character string specifying the name of the target variable in the data frames (target_variable), and a character vector specifying the names of the predictor variables in the data frames (predictors_vector). The function returns a data frame containing the specified performance metric, the predictor variables, the prediction model method, and the value of kmin (if applicable).
#'
#' @details
#' The function calculates the specified performance metric (rmse, rsq, or mae) for the prediction model specified by the method argument (lm or kknn). If the method argument is "kknn", the function uses the kmin argument to determine the minimum number of neighbors to consider. If the kmin argument is not specified or is set to "NA", the function uses the default value of 4. The function assumes that the target variable and predictor variables have already been identified in the data
#' 
#' 
#' @param train_df A data frame containing the training data for the prediction model
#' @param test_df A data frame containing the test data for the prediction model
#' @param metric A character string specifying the performance metric to calculate ("rmse", "rsq", or "mae")
#' @param method A character string specifying the prediction model to use ("lm" or "kknn")
#' @param kmin An integer specifying the minimum number of neighbors to consider when using the "kknn" method (ignored if "lm" method is used)
#' @param target_variable A character string specifying the name of the target variable in the data frames
#' @param predictors_vector A character vector specifying the names of the predictor variables in the data frames

#' 
#' @return A data frame containing the specified performance metric, the predictor variables, the prediction model method, and the value of kmin (if applicable)
#' @export
#' 
#' @examples
#' # Example 1: Using single variable regression with lm method
#' train_df <- target_df(mtcars[1:16, ], 'gear', "am")
#' test_df <- target_df(mtcars[17:32, ], 'gear', "am")
#' create_metric_df(train_df, test_df, metric = "rmse", method = "lm", target_variable = "gear", predictors_vector = "am")
#'
#' # Example 2: Using multi-variable regression with lm method
#' train_df <- target_df(mtcars[1:16, ], 'gear', c("am", "vs"))
#' test_df <- target_df(mtcars[17:32, ], 'gear', c("am", "vs"))
#' create_metric_df(train_df, test_df, metric = "rsq", method = "lm", target_variable = "gear", predictors_vector = c("am", "vs"))
#'
#' # Example 3: Using k-nearest neighbor method with optimal k
#' train_df <- target_df(mtcars[1:16, ], 'gear', c("am", "vs"))
#' test_df <- target_df(mtcars[17:32, ], 'gear', c("am", "vs"))
#' create_metric_df(train_df, test_df, metric = "mae", method = "kknn", kmin = 3, target_variable = "gear", predictors_vector = c("am", "vs"))
#'
#' # Example 4: Using k-nearest neighbor method with all k values
#' train_df <- target_df(mtcars[1:16, ], 'gear', c("am", "vs"))
#' test_df <- target_df(mtcars[17:32, ], 'gear', c("am", "vs"))
#' create_metric_df(train_df, test_df, metric = "rsq", method = "kknn", kmin = "all", target_variable = "gear", predictors_vector = c("am", "vs"))
#'
#' # Example 5: Using a different target variable
#' train_df <- target_df(mtcars[1:16, ], 'mpg', c("am", "vs"))
#' test_df <- target_df(mtcars[17:32, ], 'mpg', c("am", "vs"))
#' create_metric_df(train_df, test_df, metric = "rmse", method = "lm", target_variable = "mpg", predictors_vector = c("am", "vs"))

create_metric_df <- function(train_df, test_df, metric, method, kmin="NA", target_variable, predictors_vector){
  
  
  #' Check if all variables are of correct class
  #' 
  #' @param x a variable to be checked
  #' @param cls a character vector specifying the expected class(es)
  #'
  #' @return invisible NULL if all variables are of the expected class
  check_class <- function(x, cls) {
    if (!all(sapply(x, function(y) class(y) %in% cls))) {
      stop(paste("At least one", cls, "is of the wrong class."))
    }
    invisible(NULL)
  }
  
  check_class(list(train_df, test_df), "data.frame")
  check_class(list(metric, method, target_variable), "character")
  check_class(predictors_vector, "character")
  
  #create train data, includes win rate and predictors
  target_train_df <- target_df(df=train_df, target_variable, predictors_vector)
  
  #create test data, includes win rate and predictors
  target_test_df <- target_df(df=test_df, target_variable, predictors_vector)
  
  #create model recipe
  model_recipe <- create_recipe(target_df=target_train_df, target_variable=target_variable)
  
  #apply create_spec_kmin function and obtain model specification and kmin (if applicable)
  model_spec_kmin_list <- create_spec_kmin(df=target_train_df, model_recipe=model_recipe, 
                                           method=method, kmin=kmin, metric=metric,
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
  #print("metric df successful")
  return (
    data.frame(
      outcome=target_variable,
      predictor=predictors_vector,
      metric=metric,
      metric_value=metric_result,
      method=method,
      kmin=model_kmin
    )
  )
}


#' Bind metric result data frames using rbindlist function
#'
#' This function binds together data frames created from the \code{create_metric_df()} function using the \code{rbindlist()} function from the \code{data.table} package. The data frames are created by fitting linear models to the training data using the predictor variables provided in \code{model_list}, and then calculating the specified metric on the test data.
#'
#' @param train_df A data frame containing the training data
#' @param test_df A data frame containing the test data
#' @param metric A character string indicating the metric to be calculated. Possible values are "rmse", "mae", "r2"
#' @param method A character string indicating the type of model to be fitted. Possible values are "lm" (for linear regression) and "glm" (for generalized linear models).
#' @param kmin An integer indicating the minimum value of k for k-fold cross-validation. If set to "NA", no cross-validation is performed.
#' @param target_variable A character string indicating the name of the target variable.
#' @param model_list A list containing the names of the predictor variables to be used in the linear models.
#'
#' @return A data frame containing the metric results for each predictor variable.
#' @export
#' 
#' @include 5.09-create_metric_df.R
#'
#' @examples
#' train_df <- mtcars[1:16, ]
#' test_df <- mtcars[17:32, ]
#' 
#' single_predictors <- list("mpg", "cyl", "disp", "hp", "am")
#' multiple_predictors <- list(c("mpg", "cyl"), c("disp", "am"), c("cyl", "am") )
#' 
#' # Single predictor lm regression model 
#' metric_bind(train_df=train_df, test_df=test_df, metric="rmse", method="lm", kmin="NA", target_variable='gear', model_list=single_predictors)
#' 
#' # Single predictor kknn regression model 
#' metric_bind(train_df=train_df, test_df=test_df, metric="rmse", method="kknn", kmin=8, target_variable='gear', model_list=single_predictors)
#' 
#' # Multiple predictors lm regression model 
#' metric_bind(train_df=train_df, test_df=test_df, metric="rmse", method="lm", kmin="NA", target_variable='gear', model_list=multiple_predictors)
#' 
#' # Multiple predictors kknn regression model
#' metric_bind(train_df=train_df, test_df=test_df, metric="rmse", method="lm", kmin="NA", target_variable='gear', model_list=multiple_predictors)
#'  
#' @importFrom data.table rbindlist
#' @importFrom dplyr bind_rows
#' @importFrom purrr map_dfr
#' @importFrom tidyr unnest
#' @importFrom magrittr %>%
metric_bind <- function(train_df, test_df, metric, method, kmin="NA", target_variable, model_list){
  metric_result_df <- data.table::data.table()
  # Iterate over the models in the list and create a data.frame for each model
  for (i in seq_along(model_list)){
    # Call create_metric_df() function with correct arguments
    metric_result <- create_metric_df(train_df, test_df, metric, method, kmin, target_variable, model_list[[i]])
    # Bind the new metric result to the metric_result_df
    metric_result_df <- data.table::rbindlist(list(metric_result_df, metric_result))
  }
  return(metric_result_df)
}

# 
# single_predictors <- list('height','breakpoint_saved_pct','second_serve_win_pct','first_serve_pct')
# multiple_predictors <- list(c("mean_rank_points", "first_serve_win_pct"), c("mean_rank_points", "height"), c("mean_rank_points", "first_serve_pct") )
# train_df = player_train
# test_df = player_test
# metric_bind(train_df=train_df, test_df=test_df, metric="rmse", method="lm", kmin="NA", target_variable='win_rate', model_list=single_predictors) %>% View()
# metric_bind(train_df=train_df, test_df=test_df, metric="rmse", method="kknn", kmin="NA", target_variable='win_rate', model_list=single_predictors) %>% View()
# metric_bind(train_df=train_df, test_df=test_df, metric="rmse", method="lm", kmin="NA", target_variable='win_rate', model_list=multiple_predictors) %>% View()
# metric_bind(train_df=train_df, test_df=test_df, metric="rmse", method="kknn", kmin="NA", target_variable='win_rate', model_list=multiple_predictors) %>% View()


