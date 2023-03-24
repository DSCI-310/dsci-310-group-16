############################################
# This script generates 5 tables of the different regression models we will be working with
# namely, linear and KNN. Each method of regression will undergo both single and multiple regressions
# it will also generate these tables into a .csv format

#load functions
source(here::here("R/4_exploratory-analysis.R"))
source(here::here("R/5_rmspe-functions.R")) 

### List of Single Regression Predictors
# create a list of predictors for the single variable regression
single_predictors <- list(
  'height','breakpoint_saved_pct','second_serve_win_pct','first_serve_pct',
  'first_serve_win_pct','age','mean_rank_points','ace_point_pct'
)

### 1. kknn single regression
kknn_single <-
  rmspe_bind(
    predictors_vector = single_predictors, 
    train_df = player_train, 
    test_df = player_test,
    method = "kknn", 
    mode = "single",
    target_variable = 'win_rate'
  )

data.table::fwrite(kknn_single, here::here('data/kknn-single-regression.csv'), row.names = FALSE)

### 2. lm single regression
lm_single <-
  rmspe_bind(
    predictors_vector = single_predictors, 
    train_df = player_train, 
    test_df = player_test,
    method = "lm", 
    mode = "single",
    target_variable = 'win_rate'
  )

data.table::fwrite(lm_single, here::here('data/lm-single-regression.csv'), row.names = FALSE)

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
  rmspe_bind(
    predictors_vector = multiple_predictors, 
    train_df = player_train, 
    test_df = player_test,
    method = "lm", 
    mode = "multiple",
    target_variable = 'win_rate'
  )

data.table::fwrite(lm_multiple, here::here('data/lm-multiple-regression.csv'), row.names = FALSE)

### 4. kknn multiple regression
kknn_multiple <-
  rmspe_bind(
    predictors_vector = multiple_predictors, 
    train_df = player_train, 
    test_df = player_test,
    method = "kknn", 
    mode = "multiple",
    target_variable = 'win_rate'
  )

data.table::fwrite(kknn_multiple, here::here('data/kknn-multiple-regression.csv'), row.names = FALSE)

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
  arrange(rmspe)

data.table::fwrite(all_methods, here::here('data/all-methods.csv'), row.names = FALSE)
