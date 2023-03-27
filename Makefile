# Define variables for file paths
DATA_PATH = data/player_train.csv
DATA_TEST_PATH = data/player_test.csv
EDA_PATH = output/Predicting_Win_Rate_of_Tennis_Players.html
ANALYSIS_PATH = results/Predicting_Win_Rate_of_Tennis_Players.Rmd
REPORT_PATH = report.pdf

# Define all target
.PHONY: all
all: report

# Define clean target
.PHONY: clean
clean:
	rm -f $(EDA_PATH) $(ANALYSIS_PATH) $(REPORT_PATH)

# Define target for scripts step
.PHONY: scripts
scripts: eda analysis report

eda: $(EDA_PATH)

$(EDA_PATH): $(DATA_PATH)
	Rscript R/5_rmspe-functions.R --input_file $(DATA_PATH) --output_file $(EDA_PATH)

analysis: $(ANALYSIS_PATH)

$(ANALYSIS_PATH): $(DATA_PATH) $(DATA_TEST_PATH)
	Rscript R/6_generate-model-comparison-tables.R --input_file $(DATA_PATH) --input_file_test $(DATA_TEST_PATH) --output_file $(ANALYSIS_PATH)

report: $(REPORT_PATH)

$(REPORT_PATH): $(EDA_PATH) $(ANALYSIS_PATH)
	Rscript scripts/create_report.R --eda_file $(EDA_PATH) --analysis_file $(ANALYSIS_PATH) --output_file $(REPORT_PATH)
