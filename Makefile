# Define variables for file paths
DATA_PATH = data/raw_data.csv
CLEANED_DATA_PATH = data/cleaned_data.csv
EDA_PATH = results/eda.html
ANALYSIS_PATH = results/analysis.html

# Define all target
.PHONY: all
all: cleaned_data eda analysis report

# Define clean target
.PHONY: clean
clean:
    rm -f $(CLEANED_DATA_PATH) $(EDA_PATH) $(ANALYSIS_PATH) report.pdf

# Define targets for each step of the analysis
.PHONY: cleaned_data
cleaned_data: $(CLEANED_DATA_PATH)

$(CLEANED_DATA_PATH): $(DATA_PATH)
    python scripts/clean_data.py --input_file $(DATA_PATH) --output_file $(CLEANED_DATA_PATH)

.PHONY: eda
eda: $(EDA_PATH)

$(EDA_PATH): $(CLEANED_DATA_PATH)
    Rscript scripts/create_eda.R --input_file $(CLEANED_DATA_PATH) --output_file $(EDA_PATH)

.PHONY: analysis
analysis: $(ANALYSIS_PATH)

$(ANALYSIS_PATH): $(CLEANED_DATA_PATH)
    Rscript scripts/run_analysis.R --input_file $(CLEANED_DATA_PATH) --output_file $(ANALYSIS_PATH)

# Define target for final report
.PHONY: report
report: report.pdf

report.pdf: $(EDA_PATH) $(ANALYSIS_PATH)
    Rscript scripts/create_report.R --eda_file $(EDA_PATH) --analysis_file $(ANALYSIS_PATH) --output_file report.pdf
