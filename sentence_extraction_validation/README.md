# Sentence-extraction validation

Which sentences of a review describe the instructor, rather than the course or the reviewer, is decided upstream of every text measure in the paper. This folder holds the study testing how well two ways of making that decision agree with human readers.

## What is compared

Two extraction methods, with human readers as judges: the model method (sentences selected by the language model classifier) and the dictionary method (sentences containing any of a fixed list of person terms). The study does not compare model families against each other, and it does not score either method against sentence-level labels, so it does not yield precision or recall.

## Design

Sixty Prolific participants each read the same six reviews in random order, three of accommodation (Airbnb listings) and three of instructors. For each review they saw the same text twice, highlighted once by each method, labelled only Option A and Option B, and rated each version on two sliders from 1 to 7 anchored "Not at all" (1), "Moderately" (4), and "Completely" (7): whether it captured all relevant text, and whether it avoided irrelevant text. Participants were told only that the highlighting came from two different approaches. Option A always appeared above Option B; the model method occupied Option A in two reviews and Option B in four. Each participant contributes twelve ratings, giving 720 observations.

## Results

Every participant rates both methods on every review, so the test is paired on participant means.

| sample | measure | model | dictionary | difference | 95% CI | dz |
|----|----|----|----|----|----|----|
| all six reviews | capture | 5.29 | 4.24 | +1.05 | [0.74, 1.37] | 0.87 |
| all six reviews | avoid | 4.62 | 3.44 | +1.18 | [0.90, 1.47] | 1.08 |
| instructor reviews | capture | 5.76 | 4.11 | +1.66 | [1.25, 2.06] | 1.06 |
| instructor reviews | avoid | 4.98 | 3.50 | +1.48 | [1.06, 1.89] | 0.92 |
| accommodation reviews | capture | 4.82 | 4.37 | +0.45 | [0.12, 0.78] | 0.35 |
| accommodation reviews | avoid | 4.27 | 3.38 | +0.89 | [0.55, 1.23] | 0.68 |

A mixed model with random intercepts for participant and review returns the same differences. Agreement across the 60 raters is high: ICC(2,k) = 0.94 for capture and 0.96 for avoid. The advantage is not uniform: the dictionary method rates higher on capture for R2 and on avoid for R3 and R4. Panel position does not account for the result, since Option A and Option B differ by little and in opposite directions on the two measures.

code/03_dictionary_baseline.R reproduces the dictionary method and, run on the six reviews, matches the highlighting shown to participants in four of them. In R1 and R4 the panel omits one sentence the code selects, in both cases making the dictionary condition look worse than the code. Excluding those two reviews the difference is +0.91 [0.59, 1.23] on capture and +1.38 [1.04, 1.72] on avoid.

## Files and reproduction

| file | contents |
|----|----|
| code/00_deidentify.R | builds the shared response file from the raw export |
| code/01_extract_stimuli.py | pulls the highlighted stimuli out of the survey file |
| code/02_analysis.R | all results and the figure |
| code/03_dictionary_baseline.R | the dictionary method and its reproduction check |
| data/ | de-identified responses, long format, results |
| stimuli/ | the six reviews with both highlightings, as shown to participants |
| survey/ | the survey file, including the highlighting |
| figures/method_comparison.png | the figure |

Requirements: R with data.table, ggplot2, and (for the mixed model) lmerTest; Python 3 with the standard library only. The results were produced with R 4.4.3, data.table 1.18.2.1, ggplot2 4.0.2, and lmerTest 3.1.3. Run code/02_analysis.R from this folder to reproduce every number above; it reads only data/validation_responses.csv. The raw Qualtrics export is not distributed because it carries IP addresses, approximate geolocation and worker IDs; code/00_deidentify.R records what was removed. Instructor and host names in the survey file and the stimuli are replaced with "[name]"; participants saw the original names.

## Limitations

Six reviews is a small base and half are outside the instructor domain, so review-level variation rests on few units. The ratings are readers' judgments of highlighting quality, not accuracy against a labelled standard, and they speak to these two implementations rather than to extraction methods in general.

