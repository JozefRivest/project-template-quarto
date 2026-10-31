# Building the paper
paper: paper/paper.pdf

# Data directory
data/processed: code/00_makedata.R
	mkdir -p data/processed
	Rscript code/00_makedata.R

paper/tables: code/01_table.R
	mkdir -p paper/tables
	Rscript code/01_table.R

# Creating the data
data/processed/clean_data.rds: code/00_makedata.R
	Rscript code/00_makedata.R

paper/paper.pdf: paper/00_main.tex \
	paper/01_introduction.tex \
	paper/02_analyses.tex \
	data/processed/clean_data.rds 
	Rscript code/01_table.R
	pdflatex paper/00_main.tex
