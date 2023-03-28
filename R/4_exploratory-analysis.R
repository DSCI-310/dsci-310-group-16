library(data.table)
suppressMessages(library(here))
suppressMessages(library(GGally))
suppressMessages(library(tidymodels))


############################################
# This script generates an exploratory table, player train and player test in .csv format 
# and a plot in .png format

#load cleaned data
player_career <- data.table::fread(here::here("data/cleaned_atp2017-2019-1.csv"))

set.seed(1)

prop = 0.75 #definte 75/25 proportion

player_split <- initial_split(player_career, prop = prop, strata = win_rate)
player_train <- training(player_split)
player_test <- testing(player_split)

#### NOTE: code below
# initial creation of test and train csv 
data.table::fwrite(player_train, here::here('output/player_train.csv'), row.names = FALSE)
data.table::fwrite(player_test, here::here('output/player_test.csv'), row.names = FALSE)

#table that has Mean Values for each Predictor Variable
exploratory_data_analysis_table <- player_train %>%
  select(-player_id) %>%
  map_df(mean, na.rm = TRUE)

#generate the table into a csv
data.table::fwrite(exploratory_data_analysis_table,'output/exploratory-data-analysis-table.csv', row.names = FALSE)

# select all quantitative predictors and visualize with ggpairs()
player_ggpairs <- player_train %>%
  select(-player_id) %>%
  ggpairs()

#save the plot
ggplot2::ggsave(
  filename = 'output/player-quantitative-predictors.png', 
  plot = player_ggpairs, 
  width = 13, 
  height = 10
  )

print("Exploratory Outputs succesfully produced")
