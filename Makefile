# Define variables for file paths
eda_output = output/player_train.csv output/player_test.csv output/exploratory-data-analysis-table.csv output/player-quantitative-predictors.png
regression_input = output/player_train.csv output/player_test.csv
regression_output = output/kknn-single-regression.csv output/lm-single-regression.csv output/lm-multiple-regression.csv output/kknn-multiple-regression.csv output/all-methods.csv output/best-model-prediction.csv
reports_output: Analysis/Predicting_Win_Rate_of_Tennis_Players.html Analysis/Predicting_Win_Rate_of_Tennis_Players.pdf

# Define all target
.PHONY: all
all: eda regression report

# Define clean target
.PHONY: clean
clean:
	rm -f data/*.csv output/*.csv data/*.png Analysis/*.html 

#step 1 load libraries
data/atp2017-2019-1.csv: R/2_load.R
	Rscript R/2_load.R 

#step 2 load csv
data/cleaned_atp2017-2019-1.csv: data/atp2017-2019-1.csv R/3_clean.R
	Rscript R/3_clean.R

eda = $(eda_output)
#step 3 EDA
eda : data/cleaned_atp2017-2019-1.csv R/4_exploratory-analysis.R
	Rscript R/4_exploratory-analysis.R --input_file data/cleaned_atp2017-2019-1.csv --output_file $(eda)

regression = $(regression_output)
#step 4 regression 
regression: $(regression_input) R/6_regression.R
	Rscript R/6_regression.R --input_file $(regression_input) --output_file $(regression_output)

report = $(reports_output)
#step 5 render report
report: Analysis/Predicting_Win_Rate_of_Tennis_Players.Rmd
	Rscript -e "rmarkdown::render('Analysis/Predicting_Win_Rate_of_Tennis_Players.Rmd')" --output_file $(reports_output)
