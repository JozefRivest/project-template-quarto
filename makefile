# Build everything with `make`, or a single document with e.g. `make paper`.
.PHONY: all paper presentation poster clean

FIGURES_TABLES = code/03_figures.R code/04_tables.R

all: paper presentation poster

paper: _output/paper/paper.pdf
presentation: _output/presentation/presentation.pdf
poster: _output/poster/poster.pdf

# Data
data/processed/clean_data.rds: code/01_cleaning.R
	Rscript code/01_cleaning.R

# Documents
# freeze: auto ignores {{< include >}}d files, so clear the paper's cache first.
_output/paper/paper.pdf: paper/*.qmd supplementary_information/supplementary.qmd \
	$(FIGURES_TABLES) references/refs.bib _quarto.yml
	rm -rf _freeze/paper
	quarto render paper/paper.qmd

_output/presentation/presentation.pdf: presentation/presentation.qmd \
	$(FIGURES_TABLES) _quarto.yml
	quarto render presentation/presentation.qmd

_output/poster/poster.pdf: poster/poster.qmd $(FIGURES_TABLES) _quarto.yml
	quarto render poster/poster.qmd

clean:
	rm -rf _freeze _output
