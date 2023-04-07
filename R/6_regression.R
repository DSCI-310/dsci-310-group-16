#Author: Ammar Bagharib
############################################
# This script generates tables of the different regression models we will be working with
# namely, linear and KNN. Each method of regression will undergo both single and multiple regressions
# it will also generate these tables into a .csv format

#load functions
source(here::here("R/5_rmspe-functions.R")) 

player_train <- as.data.frame(data.table::fread(here::here('output/player_train.csv')))
player_test <- as.data.frame(data.table::fread(here::here('output/player_test.csv')))

### List of Single Regression Predictors
# create a list of predictors for the single variable regression
single_predictors <- list(
  'height','breakpoint_saved_pct','second_serve_win_pct','first_serve_pct',
  'first_serve_win_pct','age','mean_rank_points','ace_point_pct'
)

### 1. kknn single regression
kknn_single <-
  metric_bind(
    train_df = player_train, 
    test_df = player_test,
    method = "kknn", 
    metric = "rmse",
    target_variable = 'win_rate',
    model_list = single_predictors
  )

data.table::fwrite(kknn_single, here::here('output/kknn-single-regression.csv'), row.names = FALSE)

### 2. lm single regression
lm_single <-
  metric_bind(
    model_list = single_predictors, 
    train_df = player_train, 
    test_df = player_test,
    method = "lm", 
    metric = "rmse",
    target_variable = 'win_rate'
  )

data.table::fwrite(lm_single, here::here('output/lm-single-regression.csv'), row.names = FALSE)

### List of Multiple Regression Predictors
# create a list of predictors for the multiple variable regression
multiple_predictors <- list(
  c("mean_rank_points", "first_serve_win_pct"),
  c("mean_rank_points", "height"),
  c("mean_rank_points", "first_serve_pct"),
  c("mean_rank_points", "first_serve_pct", "first_serve_win_pct"),
  c("mean_rank_points", "first_serve_pct", "height")
)


### 3. lm multiple regression
lm_multiple <-
  metric_bind(
    model_list = multiple_predictors, 
    train_df = player_train, 
    test_df = player_test,
    method = "lm", 
    metric = "rmse",
    target_variable = 'win_rate'
  )

data.table::fwrite(lm_multiple, here::here('output/lm-multiple-regression.csv'), row.names = FALSE)

### 4. kknn multiple regression
kknn_multiple <-
  metric_bind(
    model_list = multiple_predictors, 
    train_df = player_train, 
    test_df = player_test,
    method = "kknn", 
    metric = "rmse",
    target_variable = 'win_rate'
  )

data.table::fwrite(kknn_multiple, here::here('output/kknn-multiple-regression.csv'), row.names = FALSE)

## combine all methods
all_methods <-
  data.table::rbindlist(
    list(
      kknn_single,
      kknn_multiple,
      lm_single,
      lm_multiple
    )
  ) %>% 
  arrange(metric_value)

data.table::fwrite(all_methods, here::here('output/all-methods.csv'), row.names = FALSE)

#########################################################################################
## BEST MODEL
# using best model which is KKNN Single

#extract best model kmin value
best_model_kmin <- all_methods %>% 
  filter(method=="kknn", predictor=="mean_rank_points") %>%
  select(kmin) %>%
  pull() %>%
  as.numeric()

#create train df with relevant columns for model
final_train_df <- target_df(df = player_train, target_variable = "win_rate", "mean_rank_points")

#create a test df where there are 3 new players (bad_player, player, good_player) with corresponding player statistics
final_test_df <- data.frame(
  name = c("player", "bad_player", "good_player"), 
  mean_rank_points = c(1400, 700, 2000)
)

#create model recipe
final_recipe <- create_recipe(final_train_df, target_variable="win_rate")

#create model specification
final_spec <- create_spec_kmin(final_train_df, model_recipe=final_recipe,
                                    method="kknn", kmin = best_model_kmin, 
                                    metric = "rmse", target_variable="win_rate") %>%
  get_list_item(., n=1) #extract model specification

#create model fit
final_fit <- create_fit(final_recipe, final_spec, final_train_df)

#create final predicition model
final_model <- create_model_prediction(final_test_df, final_fit )

#rename prediction column
final_model <- final_model %>% 
  dplyr::rename("Predicted Win Rate" = ".pred")

#export model to csv file
data.table::fwrite(final_model, here::here('output/best-model-prediction.csv'), row.names = FALSE)

print("Regression outputs succesfully produced!")
