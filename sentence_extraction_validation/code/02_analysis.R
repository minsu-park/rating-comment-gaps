################################################################################
# 02_analysis.R
#
# Compares the two sentence-extraction methods on the human ratings.
#
# Design. Sixty participants each saw the same six reviews in random order. For
# every review they saw two highlighted versions of the same text, one produced
# by the large language model and one by the dictionary method, and rated each
# version on two 1 to 7 sliders:
#     capture  to what extent did it capture ALL relevant text
#     avoid    to what extent did it AVOID highlighting irrelevant text
# Every participant therefore contributes twelve ratings and sees both methods on
# every review, so the comparison is within participant and the inference is
# paired. Treating the 720 rows as independent would overstate the precision.
#
# Input : data/validation_responses.csv
# Output: data/validation_long.csv, data/validation_results.csv,
#         data/validation_icc.csv,
#         figures/method_comparison.png
################################################################################
library(data.table)
library(ggplot2)

## Which option carried the model's highlighting in each review. This is a
## property of the survey, not of the response file: the highlighting is markup
## that the response export strips, so both options appear as identical plain
## text there. Read off the survey file and cross-checked against the extracted
## spans in stimuli/highlighted_spans.csv.
LLM_OPTION <- c(R1 = "B", R2 = "B", R3 = "A", R4 = "B", R5 = "A", R6 = "B")

## Qualtrics numbered the two sliders differently in the two option blocks:
## option A uses _5 and _6, option B uses _4 and _5. In both, the first is the
## capture item and the second is the avoid item.
SUFFIX <- list(A = c(capture = "5", avoid = "6"),
               B = c(capture = "4", avoid = "5"))

d <- fread("data/validation_responses.csv")
cat(sprintf("participants: %d\n", nrow(d)))

long <- rbindlist(lapply(names(LLM_OPTION), function(rv)
  rbindlist(lapply(c("A", "B"), function(op) {
    s <- SUFFIX[[op]]
    data.table(participant = d$participant, review = rv, option = op,
               capture = as.numeric(d[[paste0(rv, "_", op, "_", s["capture"])]]),
               avoid   = as.numeric(d[[paste0(rv, "_", op, "_", s["avoid"])]]))
  }))))
long[, method := fifelse(option == LLM_OPTION[review], "LLM", "Dictionary")]
long[, domain := fifelse(review %in% c("R1", "R2", "R3"), "Airbnb", "Professor")]
stopifnot(nrow(long) == nrow(d) * 12, !anyNA(long$capture), !anyNA(long$avoid))
fwrite(long, "data/validation_long.csv")

## ---- paired comparison on participant means ---------------------------------
compare <- function(reviews, label) {
  L <- long[review %in% reviews]
  rbindlist(lapply(c("capture", "avoid"), function(v) {
    w  <- dcast(L[, .(x = mean(get(v))), by = .(participant, method)],
                participant ~ method, value.var = "x")
    tt <- t.test(w$LLM, w$Dictionary, paired = TRUE)
    data.table(sample = label, measure = v,
               LLM = mean(w$LLM), Dictionary = mean(w$Dictionary),
               difference = mean(w$LLM - w$Dictionary),
               ci_low = tt$conf.int[1], ci_high = tt$conf.int[2],
               t = as.numeric(tt$statistic), p = tt$p.value,
               dz = mean(w$LLM - w$Dictionary) / sd(w$LLM - w$Dictionary))
  }))
}

res <- rbind(
  compare(paste0("R", 1:6),            "all six reviews"),
  compare(c("R4", "R5", "R6"),         "professor reviews"),
  compare(c("R1", "R2", "R3"),         "Airbnb reviews"),
  compare(c("R2", "R3", "R5", "R6"),   "excluding R1 and R4")
)
fwrite(res, "data/validation_results.csv")
cat("\nPaired comparison, LLM minus dictionary\n")
print(res[, .(sample, measure, LLM = round(LLM, 2), Dictionary = round(Dictionary, 2),
              difference = round(difference, 2),
              CI = sprintf("[%.2f, %.2f]", ci_low, ci_high),
              p = signif(p, 2), dz = round(dz, 2))])

## ---- mixed model crossing participant and review ----------------------------
if (requireNamespace("lmerTest", quietly = TRUE)) {
  cat("\nMixed model, random intercepts for participant and review\n")
  for (v in c("capture", "avoid")) {
    m  <- lmerTest::lmer(get(v) ~ method + (1 | participant) + (1 | review), data = long)
    cf <- summary(m)$coefficients["methodLLM", ]
    cat(sprintf("  %-8s LLM minus dictionary = %+.2f (SE %.2f), t = %.2f, p = %.2g\n",
                v, cf[["Estimate"]], cf[["Std. Error"]], cf[["t value"]], cf[["Pr(>|t|)"]]))
  }
}

## ---- agreement across raters ----------------------------------------------
## ICC(2,k) (Shrout and Fleiss): two-way random effects, absolute agreement, for
## the mean of the k = 60 raters. Targets are the 12 highlighted panels (six
## reviews by two methods); every rater rated every panel.
icc2k <- function(m) {
  n <- nrow(m); k <- ncol(m); gm <- mean(m)
  msr <- k * sum((rowMeans(m) - gm)^2) / (n - 1)
  msc <- n * sum((colMeans(m) - gm)^2) / (k - 1)
  res <- m - outer(rowMeans(m), rep(1, k)) - outer(rep(1, n), colMeans(m)) + gm
  mse <- sum(res^2) / ((n - 1) * (k - 1))
  (msr - mse) / (msr + (msc - mse) / n)
}
icc <- rbindlist(lapply(c("capture", "avoid"), function(v) {
  w <- dcast(long, review + option ~ participant, value.var = v)
  data.table(measure = v, icc2k = icc2k(as.matrix(w[, -(1:2)])))
}))
fwrite(icc, "data/validation_icc.csv")
cat("\nAgreement across raters, ICC(2,k)\n")
print(icc[, .(measure, icc2k = round(icc2k, 2))])

## ---- descriptive checks ------------------------------------------------------
cat("\nBy review\n")
print(dcast(long[, .(capture = round(mean(capture), 2)), by = .(review, method)],
            review ~ method, value.var = "capture"))
print(dcast(long[, .(avoid = round(mean(avoid), 2)), by = .(review, method)],
            review ~ method, value.var = "avoid"))

cat("\nPosition of the panel on the page, ignoring method\n")
print(long[, .(capture = round(mean(capture), 2), avoid = round(mean(avoid), 2)), by = option])

## ---- figure ------------------------------------------------------------------
pm <- melt(long, id.vars = c("participant", "method"),
           measure.vars = c("capture", "avoid"), variable.name = "measure")
pm <- pm[, .(v = mean(value)), by = .(participant, method, measure)]
sm <- pm[, .(mean = mean(v), se = sd(v) / sqrt(.N)), by = .(method, measure)]
sm[, `:=`(lo = mean - 1.96 * se, hi = mean + 1.96 * se)]
sm[, measure := factor(measure, c("capture", "avoid"),
                       c("Captured all relevant text", "Avoided irrelevant text"))]
sm[, method := factor(method, c("Dictionary", "LLM"))]

p <- ggplot(sm, aes(method, mean, fill = method)) +
  geom_col(width = 0.6, colour = "black", linewidth = 0.3) +
  geom_errorbar(aes(ymin = lo, ymax = hi), width = 0.12, linewidth = 0.6) +
  facet_wrap(~measure) +
  scale_fill_manual(values = c(Dictionary = "#C9C9C9", LLM = "#4C9F70"), guide = "none") +
  coord_cartesian(ylim = c(1, 7)) +
  scale_y_continuous(breaks = 1:7) +
  labs(x = NULL, y = "Mean rating (1 to 7)") +
  theme_classic(base_size = 13) +
  theme(strip.text = element_text(face = "bold"),
        strip.background = element_blank())
ggsave("figures/method_comparison.png", p, width = 8, height = 4.5, dpi = 300, bg = "white")
cat("\nwrote data/validation_long.csv, data/validation_results.csv, figures/method_comparison.png\n")
