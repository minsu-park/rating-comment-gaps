# Aggregate estimate files

These files are disclosure-safe outputs from the restricted review-level analysis. They are sufficient to redraw the two main-text figures and to reproduce the reported robustness numbers, but not to re-estimate the underlying models.

## Shared conventions

- `group` identifies the inferred race-or-ethnicity-by-gender cell. Categories represent demographic signals conveyed by names rather than self-identified attributes.
- `White_Male` is the omitted reference category; its rows are zero by construction.
- `n` is the number of reviews in the analysis sample, not the number of instructors. Fixed-effect singletons (257 reviews in the star text sample and 357 in the binary text sample) are dropped during estimation. Inference clusters standard errors by instructor unless a file states otherwise.
- `se` fields contain clustered standard errors.
- `lower` and `upper` fields are 95% confidence-interval endpoints.
- Star-rating quantities are in standard-deviation units. Would-take-again quantities are percentage-point differences in the probability of an explicit yes response.
- Full-precision values are retained so displayed numbers can be rounded only at the final reporting stage.

## Decomposition columns

`figure1_b.csv`, `figure2_b.csv`, and `si_supervised_decomposition.csv` share these columns:

| Column | Definition |
|---|---|
| `group` | Demographic cell |
| `observed` | Adjusted outcome gap from White men without text measures |
| `observed_se` | Clustered standard error of the observed gap |
| `text_predicted` | Gap predicted by group differences in the fitted text index |
| `text_predicted_se` | Standard error of the text-predicted gap |
| `text_predicted_lower`, `text_predicted_upper` | 95% confidence interval for `text_predicted` |
| `additional` | Group coefficient from the model that also contains the text measures |
| `additional_se` | Clustered standard error of the additional gap |
| `additional_lower`, `additional_upper` | 95% confidence interval for `additional` |
| `outcome` | `Star rating (SD)` or `Would take again (percentage points)` |
| `n` | Analysis-sample review count: 3,304,978 or 428,386 |

The identity `observed = text_predicted + additional` holds exactly. A negative `additional` value means that the group is rated lower than the content of its comments predicts. `si_supervised_decomposition.csv` adds `text_model`, which identifies the supervised full-comment model.

## `figure1_a.csv`

Associations between the seven text measures and each outcome (Fig. 1A shows the star rating; would-take-again rows are used in the robustness notebook).

| Column | Definition |
|---|---|
| `dimension` | Warmth, competence, brilliance, effort, complaint severity, positive affect, or negative affect |
| `specification` | `Marginal (each alone)` or `Joint (all seven)` |
| `estimate` | Standardized association with the outcome |
| `se` | Clustered standard error |
| `lower`, `upper` | 95% confidence interval |
| `outcome` | `Star rating` or `Would take again` |
| `n` | Analysis-sample review count |

The five embedding measures were scored on instructor-directed sentences after masking names and gendered terms. Positive and negative affect are LIWC-22 tone measures computed from the full review. Joint estimates come from the model that also includes the race-by-gender indicators and are the weights behind `text_predicted` in `figure1_b.csv` and `figure2_b.csv`.

## `figure1_b.csv` and `figure2_b.csv`

Star-rating (Fig. 1B) and would-take-again (Fig. 2B) decompositions with the seven text measures. See *Decomposition columns*.

## `figure2_a.csv`

Same-sample gaps for Fig. 2A. Both outcomes were standardized within the same 487,110-review sample before estimation.

| Column | Definition |
|---|---|
| `group` | Demographic cell |
| `estimate_star`, `estimate_wta` | Adjusted standardized gaps from White men |
| `se_star`, `se_wta` | Clustered standard errors of the two gaps |

The White-men coordinates are `(0, 0)` by construction. The plotted error bars are calculated as the estimate plus or minus 1.96 times its standard error.

## `si_sample_counts.csv`

| Column | Definition |
|---|---|
| `sample` | `A. Full star sample`, `B. Star text sample`, `C. Binary sample`, or `D. Binary text sample` |
| `group` | Demographic cell, or `Total` |
| `reviews`, `instructors` | Number of reviews and distinct instructors |

## `si_sensitivity_additional_gaps.csv`

Additional star-rating gaps in the star text sample under each sensitivity check.

| Column | Definition |
|---|---|
| `check` | Main specification; standard errors clustered by institution; instructor weighting (1/n_j); pronoun-confirmed gender; surname probability thresholds of 0.85, 0.90, and 0.95; mixed model with crossed instructor and institution intercepts; or separate models within the six largest disciplines |
| `text_model` | `Seven measures` or `Supervised full-comment model` |
| `observed`, `observed_se` | Observed gap and its standard error under that check |
| `additional`, `additional_se` | Additional gap and its standard error |
| `additional_lower`, `additional_upper` | 95% confidence interval for `additional` |
| `n` | Review count used for that check |

## `si_text_measure_vif.csv` and `si_text_measure_correlations.csv`

Variance inflation factors for the seven text measures (`vif_masked` for the gender-neutralized scores used in the paper; `vif_original` for the original scores) and their pairwise correlation matrix for the gender-neutralized scores.

## `si_masked_vs_original_scores.csv`

Star decomposition with gender-neutralized (`_masked`) and original (`_original`) embedding scores: `observed`, `text_predicted_masked`, `text_predicted_original`, `additional_masked`, `additional_original`.

## `si_pronoun_gender_agreement.csv`

| Column | Definition |
|---|---|
| `group` | Demographic cell |
| `instructors_with_pronouns` | Instructors whose reviews contain gendered pronouns |
| `agreement_share` | Share of those instructors for whom students' pronouns match the name-inferred gender |
| `instructors_3plus_pronouns`, `agreement_3plus_pronouns` | The same, restricted to instructors with at least three pronouns |

## `main_results_summary.json`

Stores sample sizes and instructor counts for the four samples, the full-sample star mean and SD, the White-men yes rates in the binary samples, the Fig. 2A correlations (all eight cells, seven nonreference groups, and without the two Black groups), the range of binary-to-star gap ratios and corresponding percentage reductions, the similarity of the star and binary joint text weights, within-R² for the seven-measure and supervised models, the supervised model's out-of-fold squared correlation, the pronoun agreement rate, and the reported agreement rates of the cross-check classifiers.
