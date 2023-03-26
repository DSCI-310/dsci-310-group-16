# Define variables for file paths
DATA_PATH = data/atp2017-2019-1.csv
CLEANED_DATA_PATH = data/cleaned_atp2017-2019-1.csv
EDA_PATH = output/Predicting_Win_Rate_of_Tennis_Players.html
ANALYSIS_PATH = results/Predicting_Win_Rate_of_Tennis_Players.Rmd
REPORT_PATH = report.pdf

# Define all target
.PHONY: all
all: report

# Define clean target
.PHONY: clean
clean:
	rm -f $(CLEANED_DATA_PATH) $(EDA_PATH) $(ANALYSIS_PATH) $(REPORT_PATH)

# Define target for data step
.PHONY: data
data: $(CLEANED_DATA_PATH)

$(CLEANED_DATA_PATH): $(DATA_PATH)
	python scripts/clean_data.py --input_file $(DATA_PATH) --output_file $(CLEANED_DATA_PATH)

# Define target for scripts step
.PHONY: scripts
scripts: eda analysis report

eda: $(EDA_PATH)

$(EDA_PATH): $(CLEANED_DATA_PATH)
	Rscript scripts/create_eda.R --input_file $(CLEANED_DATA_PATH) --output_file $(EDA_PATH)

analysis: $(ANALYSIS_PATH)

$(ANALYSIS_PATH): $(CLEANED_DATA_PATH)
	Rscript scripts/run_analysis.R --input_file $(CLEANED_DATA_PATH) --output_file $(ANALYSIS_PATH)

report: $(REPORT_PATH)

$(REPORT_PATH): $(EDA_PATH) $(ANALYSIS_PATH)
	Rscript scripts/create_report.R --eda_file $(EDA_PATH) --analysis_file $(ANALYSIS_PATH) --output_file $(REPORT_PATH)
