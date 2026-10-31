# Project

A Quarto template for a research project: one set of R scripts feeds a paper,
a Beamer presentation, and a conference poster, all sharing the same
bibliography, author metadata, and output folder.

```
.
├── _quarto.yml                  # Project config: authors, bibliography, formats
├── _extensions
│   └── JozefRivest/quarto-poster-template   # Poster format (Gemini beamerposter)
├── .templates
│   ├── article                  # Paper: biblatex, appendix & supplementary styling
│   ├── beamer                   # Slides: title page, .notitle filter
│   └── umich                    # Beamer "umich" theme
├── code
│   ├── 01_cleaning.R
│   ├── 02_analysis.R
│   ├── 03_figures.R             # Plot functions shared by every document
│   └── 04_tables.R              # Models and table settings shared by every document
├── data
│   ├── processed
│   └── raw
├── issues
├── makefile
├── notes
│   ├── org_table.py
│   └── readings.yaml
├── paper
│   ├── paper.qmd                # Main file: includes the sections below
│   ├── 0_introduction.qmd
│   ├── 1_theory.qmd
│   ├── 2_design.qmd
│   ├── 3_results.qmd
│   ├── 4_discussion.qmd
│   ├── 5_conclusion.qmd
│   └── 6_appendix.qmd
├── supplementary_information
│   └── supplementary.qmd
├── presentation
│   └── presentation.qmd
├── poster
│   └── poster.qmd
├── references
│   └── refs.bib
├── renv                         # renv settings (the package library is not committed)
├── renv.lock                    # Exact R package versions
├── .Rprofile                    # Activates renv when R starts in the project
├── _output                      # Rendered PDFs land here
├── LICENSE
├── THIRD_PARTY_NOTICES.md
└── README.md
```

## Requirements

- [Quarto](https://quarto.org) ≥ 1.8
- [R](https://www.r-project.org) (the lockfile was created with R 4.6.1) and
  the [renv](https://rstudio.github.io/renv/) package
- A LaTeX distribution. A full TeX Live or MacTeX install is recommended: the
  paper uses biblatex with biber, and the poster is compiled with LuaLaTeX and
  needs the Lato font (TeX Live's `lato` package), which TinyTeX does not
  include by default.
- GNU `make` (optional, to use the `makefile`)
- Python 3 with `pyyaml` (optional, for the reading notes; `openpyxl` for
  Excel export)

The template is developed and tested on Linux, and should work the same way on
macOS. On Windows (untested), the slides need one change: in `_environment`,
replace the trailing `:` in `TEXINPUTS=../.templates//:` with `;`, the
path separator Windows uses.

### R packages with renv

The R packages used by the project, and their exact versions, are recorded in
`renv.lock` with [renv](https://rstudio.github.io/renv/). The first time you
open the project, install them into a project library:

```r
install.packages("renv")   # if needed
renv::restore()
```

R activates renv automatically whenever it starts in the project (through
`.Rprofile`), including when Quarto renders the documents, so the paper,
slides, and poster are always built with the versions in the lockfile.

When you add or update a package, record the change:

```r
install.packages("fixest")  # or renv::install("fixest")
renv::snapshot()            # update renv.lock
```

Commit `renv.lock` along with your code. `renv::status()` reports whether the
installed packages and the lockfile agree. The project library itself
(`renv/library/`) is not committed.

## Rendering

Everything is built with [Quarto](https://quarto.org) (≥ 1.8) and R. To
render the paper, the presentation, and the poster at once, run

```bash
quarto render
```

or render a single document

```bash
quarto render paper/paper.qmd
quarto render presentation/presentation.qmd
quarto render poster/poster.qmd
```

The PDFs are written to `_output/paper`, `_output/presentation`, and
`_output/poster`.

Shared settings live in `_quarto.yml`: author name, email, ORCID, and
affiliation; the date; the bibliography (`references/refs.bib`); and the
default options for the `pdf` (paper) and `beamer` (slides) formats. Change
them once and every document picks them up.

### Freeze

Code chunks are not echoed (`echo: false`) and results are frozen
(`freeze: auto`): chunks are only re-run when the main `.qmd` file changes, and
the results are stored in `_freeze/`. **Freeze does not track files pulled in
with `{{< include >}}`.** If you edit only a section of the paper (e.g.
`paper/3_results.qmd`) or one of the scripts in `code/`, delete the cached
results before rendering:

```bash
rm -rf _freeze/paper && quarto render paper/paper.qmd
```

### Sharing code between documents

The figures and tables are defined once in `code/` and sourced in each
document, so the paper, slides, and poster always show the same results:

````markdown
```{r}
#| label: fig-scatter
#| fig-cap: "Horsepower and fuel economy"
source("../code/03_figures.R")
plot_hp_mpg()
```
````

Documents are rendered from their own folder, so paths to the scripts and the
data start with `../`.

## Paper

`paper/paper.qmd` holds the title and stitches the sections together with
`{{< include >}}`. Each section lives in its own numbered file, so you can
reorder, add, or drop sections by editing a single list.

The paper uses biblatex (author-date). Cite with `[@key]` and the references
are printed wherever the `:::{#refs}` div appears. Cross-reference figures,
tables, equations, and sections with `@fig-`, `@tbl-`, `@eq-`, and `@sec-`
labels.

### Appendix and supplementary materials

Two heading classes turn everything below them into back matter, with their
own numbering:

```markdown
# Appendix {.appendix #sec-appendix}
## Supporting material          <- becomes Section A, Figure A1, Table A1, (A1)

# Supplementary Materials {.supplementary #sec-supplementary}
## Mechanism tests              <- becomes Section S1, Figure S1, pages S-1, S-2, ...
```

The supplementary materials start on a new page with the paper's title and
their own table of contents. Headings inside each part are promoted by one
level, so `##` becomes a section. Because these headings are converted to raw
LaTeX, link to them with a regular link instead of `@sec-`:

```markdown
See the [Appendix](#sec-appendix) and the [Supplementary Materials](#sec-supplementary).
```

## Presentation

`presentation/presentation.qmd` uses Beamer with the University of Michigan
theme in `.templates/umich`. Level-1 headings (`#`) are sections shown in the
navigation bar, and level-2 headings (`##`) are slides. The title page shows
the author's ORCID, affiliation, and email from `_quarto.yml`.

Add `{.notitle}` to a slide to keep it in the navigation but hide its title
bar, which is useful for full-slide figures:

```markdown
## Raw relationship {.notitle}
```

Use `. . .` to reveal content step by step.

## Poster

`poster/poster.qmd` uses the `quarto-poster-template` extension (a Gemini
beamerposter theme in Michigan colors). The title, author, `university`,
`email`, and `github` fields fill the header and footer. `logo-right: true` or
`logo-left: true` adds a logo to the header; by default it is the Block M, and
you can use your own image and size:

```yaml
logo-right: true
logo: logos/my_logo.png   # path relative to poster.qmd
logo-height: 4cm          # default: 5cm
```

Content is laid out in columns:

```markdown
::: column
## Motivation
...
:::

::: column
## Results
...
:::
```

The poster template does not load `tabularray`, so `modelsummary`'s default
output will not compile there. Build the table with `knitr::kable(...,
format = "latex", booktabs = TRUE)` instead (see `poster/poster.qmd`).

## GitHub issues

If you wish to edit your issues within your terminal, without going to
GitHub website every time, you can add the following function to your
.bashrc or .zshrc

```bash
get_issue() {
  local issue="$1"
  gh issue view "${issue}" --json body --jq '.body' > issues/"issue_${issue}.md"
}
```

With this function, you can fetch issues from GitHub directly into a markdown
file that will be created in the `issues` directory. Once you make the changes
to the issue's text, you then run `gh issue edit $$ --body-file issues/issue_$$.md`
where the dollar signs stand for the number of the issue. This will update the
issue on GitHub.

Everybody is welcome to use this template to organize their working
environment. You can fork or clone the repo as you wish.

## makefile

The template comes with a `makefile`. A good practice is to update it as soon
as possible to keep track of the different dependencies in the project, and to
ease the process of submitting the replication package. A `makefile` works as
follows:

```makefile
target: dependency
    steps to build the target
```

The current `makefile` looks like this:

```makefile
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

_output/poster/poster.pdf: poster/poster.qmd $(FIGURES_TABLES) _quarto.yml \
	$(wildcard _extensions/JozefRivest/quarto-poster-template/*)
	quarto render poster/poster.qmd

clean:
	rm -rf _freeze _output
```

Once the `makefile` exists, we can run in the terminal different commands to
either build the entire project easily, or to build specific targets such as
the paper or the poster. Only documents whose dependencies changed are rebuilt.

```bash
make               # build the paper, presentation, and poster
make paper         # build only the paper
make clean         # remove _freeze and _output
```

As the analysis grows, add the data and analysis scripts as dependencies of
the documents that use them (e.g. `data/processed/clean_data.rds`).

## Reading notes

The folder `notes` contains a python and yaml file. The python file allows you
to import papers from Zotero and/or Obsidian into `readings.yaml` under a very
specific structure. You can also import collections from Zotero

```bash
# For Zotero
python org_table.py readings.yaml --from-zotero "RDD papers" # To import a collection
# For Obsidian
python org_table.py readings.yaml --from-obsidian ~/Vault/Literature
python org_table.py readings.yaml --from-obsidian note.md --category "RDD papers"
```

You can then create a spreadsheet using all the entries from the
`readings.yaml` file to visualize the different papers you have

```bash
python org_table.py readings.yaml --live
```

Or you can open a citation graph for the papers you have in your reading
notes, to see which papers you don't have that are cited by, or that cite, the
papers you have.

```bash
python org_table.py readings.yaml --graph
```

Finally, you can also export the table to a xlsx file

```bash
python org_table.py readings.yaml --xlsx
```

Other options: `--columns`, `--sort Date`, `--filter Journal=APSR`, and
`--html`. Run `python org_table.py --help` for the full list.

## License

The template is released under the [MIT License](LICENSE): you can use,
modify, and share it, including in your own projects, as long as you keep the
copyright notice. A few bundled components keep their own licenses: the
Beamer theme, adapted from [Metropolis](https://github.com/matze/mtheme) by
Matthias Vogelgesang (CC BY-SA 4.0), and the poster theme, based on
[Gemini](https://github.com/anishathalye/gemini) by Anish Athalye (MIT). The
University of Michigan Block M logo is a trademark and is not covered by any
license here. See
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) for details.
