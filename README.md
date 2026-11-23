# Ratings carry larger demographic gaps than words in the same evaluations

Replication materials for ***Ratings carry larger demographic gaps than words in the same evaluations*** by Chao Yu and Minsu Park.

This repository reproduces the two main-text figures and the numbers reported for the robustness checks from aggregate estimates, and it includes the materials of the sentence-extraction validation study. It does **not** re-estimate the models from review-level records and does not contain review text (apart from the six reviews shown to validation participants, with names masked), instructor names, individual demographic classifications, or licensed LIWC dictionaries.

## Quick start

Python 3.9 or later is recommended.

```bash
git clone https://github.com/minsu-park/rating-comment-gaps.git
cd rating-comment-gaps
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

### Recommended route for reproducing results

Open the notebooks and run every cell from top to bottom:

| Notebook | Output | Role |
|---|---|---|
| `code/Figure_1.ipynb` | `figures/Figure1.pdf` | Main-text Figure 1 |
| `code/Figure_2.ipynb` | `figures/Figure2.pdf` | Main-text Figure 2 |
| `code/robustness_checks.ipynb` | Printed tables and checks | Supervised text model, text-measure diagnostics, alternative text scores, cross-format comparison, sensitivity analyses, and sentence-extraction validation |

The figure notebooks display each panel in the notebook client and write vector PDFs. The robustness notebook prints the released estimates and checks each corresponding statement in the paper and SI Appendix. The working directory may be either the repository root or `code/`; the notebooks search upward for `data/derived/`.

### Command-line convenience script

For a noninteractive rendering of both figures from the same aggregate tables:

```bash
python code/draw_figures.py
```

`draw_figures.py` runs the same drawing code as the two figure notebooks and writes identical PDFs to `figures/Figure1.pdf` and `figures/Figure2.pdf`.

### Sentence-extraction validation

`sentence_extraction_validation/` holds the human-rating study that validates the instructor-directed sentence extraction: de-identified ratings from 60 participants, the six stimuli, the survey file, and the analysis code. Its own [README](sentence_extraction_validation/README.md) describes the design and files. To reproduce its results and figure, run from that folder (R with `data.table` and `ggplot2`; `lmerTest` for the optional mixed model):

```bash
cd sentence_extraction_validation
Rscript code/02_analysis.R
```

The robustness notebook recomputes the numbers reported in the SI Appendix from the same ratings, using only the Python standard library.

## Repository contents

```text
rating-comment-gaps/
├── code/                 Figure and robustness notebooks, command-line renderer
├── data/derived/         Disclosure-safe aggregate estimates
├── figures/              Vector PDFs generated from those estimates
├── sentence_extraction_validation/
│                         Human-rating validation of the sentence extraction
├── LICENSE               MIT license for the repository's code
├── README.md             Package overview and instructions
└── requirements.txt      Python dependencies
```

The aggregate files map to the paper as follows:

| File | Paper output |
|---|---|
| `figure1_a.csv` | One-at-a-time and joint text-measure associations in Fig. 1A |
| `figure1_b.csv` | Observed, text-predicted, and additional star-rating gaps in Fig. 1B |
| `figure2_a.csv` | Same-sample standardized star and would-take-again gaps in Fig. 2A |
| `figure2_b.csv` | Observed, text-predicted, and additional would-take-again gaps in Fig. 2B |
| `si_sample_counts.csv` | Reviews and instructors by sample and group (SI Appendix, *Analysis Samples*) |
| `si_supervised_decomposition.csv` | Star and binary decompositions with the supervised full-comment model |
| `si_text_measure_vif.csv`, `si_text_measure_correlations.csv` | Collinearity among the seven text measures |
| `si_text_weights_alternative_scores.csv` | Text-association models with original embedding scores and with LIWC-22 emotion words |
| `si_bootstrap_correlation.csv` | Instructor-bootstrap replicates of the Fig. 2A correlation |
| `si_sensitivity_additional_gaps.csv` | Additional star gaps under each sensitivity check and within disciplines |
| `si_masked_vs_original_scores.csv` | Star decomposition with gender-neutralized versus original embedding scores |
| `si_pronoun_gender_agreement.csv` | Agreement between name-inferred gender and students' pronouns |
| `main_results_summary.json` | Sample sizes, base rates, and summary statistics quoted in the text |

See [`data/derived/README.md`](data/derived/README.md) for units, column
definitions, and interpretation.

## Analysis decisions represented in the released estimates

- One invalid `student_star = -1` sentinel was excluded, yielding 4,050,824
  valid reviews in the full star sample.
- Star ratings were standardized within the cleaned full star sample. For
  Fig. 2A, both outcomes were standardized within the identical 2017–2018
  complete-response sample (`N = 487,110`).
- Models adjust for standardized difficulty and log class size and absorb
  discipline, institution, and review-year fixed effects. Standard errors are
  clustered by instructor.
- Text analyses are restricted to reviews containing more than 10 characters
  of instructor-directed text (`N = 3,304,978` for stars; `N = 428,386` for the
  binary response). Fixed-effect singletons are dropped during estimation
  (257 and 357 reviews); the `n` fields report the sample counts.
- All text panels use the five embedding measures rescored after masking the
  instructor's name and listed gendered terms. LIWC-22 positive and negative
  tone are dictionary counts and were not rescored.
- Fig. 1A joint coefficients come from the decomposition model, which also
  includes the race-by-gender indicators. They are therefore the weights that
  produce the text-predicted gaps in Fig. 1B.
- Fig. 2A displays all eight cells, including the White-men reference at
  `(0, 0)`. The correlation rounds to 0.998 with or without that reference.

## Terminology

- **Text-predicted gap:** the gap implied by group differences in the text
  measures, weighted by their joint association with the rating.
- **Additional gap:** the observed gap minus the text-predicted gap, that is,
  how much lower a group is rated than the content of its comments predicts.

## Data access and disclosure

The reviews analyzed in the paper come from the RateMyProfessor.com data set
compiled by He (2020), available on Mendeley Data
([doi:10.17632/fvtfjyvw7d.2](https://doi.org/10.17632/fvtfjyvw7d.2)). The
review-level analysis files are not redistributed here because they link
instructor identifiers to inferred demographic attributes. Researchers who
wish to work with the reviews should obtain them from the original source.

## Citation

> [PLACEHOLDER: Citation for the Paper]

## License

The repository's code is released under the [MIT License](LICENSE). Third-party
data, models, software, and licensed dictionaries remain subject to their own
terms.

## Contact

- Chao Yu: `chao.yu@northwestern.edu`
- Minsu Park: `minsu.park@nyu.edu`
