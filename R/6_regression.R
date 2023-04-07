#Author: Ammar Bagharib
############################################
# This script generates tables of the different regression models we will be working with
# namely, linear and KNN. Each method of regression will undergo both single and multiple regressions
# it will also generate these tables into a .csv format

#load functions
source(here::here("R/5_rmspe-functions.R")) 

player_train <- data.table::fread(here::here('output/player_train.csv'))
player_test <- data.table::fread(here::here('output/player_test.csv'))

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

data.table::fwrite(kknn_single, here::here('output/kknn-single-regression.csv'), row.names = FALSE)

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
  rmspe_bind(
    predictors_vector = multiple_predictors, 
    train_df = player_train, 
    test_df = player_test,
    method = "lm", 
    mode = "multiple",
    target_variable = 'win_rate'
  )

data.table::fwrite(lm_multiple, here::here('output/lm-multiple-regression.csv'), row.names = FALSE)

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
  arrange(rmspe)

data.table::fwrite(all_methods, here::here('output/all-methods.csv'), row.names = FALSE)

#########################################################################################
## BEST MODEL
# using best model which is KKNN Single
tennis_recipe_final <- recipe(win_rate ~ mean_rank_points, data = player_train) %>%
  step_scale(all_predictors()) %>%
  step_center(all_predictors())

tennis_model_final <- nearest_neighbor(weight_func = "rectangular", neighbors = 6) %>%
  set_engine("kknn") %>%
  set_mode("regression")

tennis_fit_final <- workflow() %>%
  add_recipe(tennis_recipe_final) %>%
  add_model(tennis_model_final) %>%
  fit(data = player_train)

# create three new players (bad_player, player, good_player) with corresponding player statistics
new_players <- data.frame(
  name = c("player", "bad_player", "good_player"), 
  mean_rank_points = c(1400, 700, 2000)
)

prediction <- predict(tennis_fit_final, new_players) 

best_model_table <- bind_cols(new_players, prediction) %>%
  rename(predicted_win_rate = .pred)

data.table::fwrite(best_model_table, here::here('output/best-model-prediction.csv'), row.names = FALSE)

print("Regression outputs succesfully produced!")
