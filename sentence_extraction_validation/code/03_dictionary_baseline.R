################################################################################
# 03_dictionary_baseline.R
#
# The dictionary method that produced one of the two highlighted versions, and a
# check of how closely the survey stimuli reproduce it.
#
# The method splits a review into sentences and keeps every sentence containing
# one of a fixed list of person terms. Two lists were used, one for the
# professor reviews and one for the accommodation reviews. Both the sentence
# splitter and the lists are reproduced here verbatim from the project code that
# built the person-directed text variable.
#
# Input : stimuli/highlighted_spans.csv
# Output: data/dictionary_reproduction_check.csv
################################################################################
library(data.table)

KEYWORDS_PROFESSOR <- paste0(
  "\\bprofessor\\b|\\bprof\\b|\\bprof.\\b|\\binstructor\\b|\\blecturer\\b|",
  "\\bresearcher\\b|\\bhe\\b|\\bhis\\b|\\bhim\\b|\\bshe\\b|\\bher\\b|",
  "\\bthey\\b|\\btheir\\b|\\bthem\\b")

KEYWORDS_ACCOMMODATION <- paste0(
  "\\bpeople\\b|\\bperson\\b|\\bhuman\\b|\\bindividual\\b|\\bhost\\b|\\bhosts\\b|",
  "\\bhe\\b|\\bhis\\b|\\bhim\\b|\\bshe\\b|\\bher\\b|\\bthey\\b|\\btheir\\b|",
  "\\bthem\\b|\\byou\\b|\\byour\\b")

chunk_into_sentences <- function(text) {
  break_points <- c(1, as.numeric(gregexpr('[[:alnum:] ][.!?]', text)[[1]]) + 1)
  sentences <- NULL
  for (i in 1:length(break_points)) {
    res <- substr(text, break_points[i], break_points[i + 1])
    if (i > 1) sentences[i] <- sub('. ', '', res) else sentences[i] <- res
  }
  sentences[!is.na(sentences)]
}

extract_person_sentences <- function(text, keywords) {
  s <- chunk_into_sentences(tolower(text))
  trimws(s[grep(keywords, s)])
}

## ---- reconstruct each review and compare ------------------------------------
sp <- fread("stimuli/highlighted_spans.csv")
reviews <- fread("stimuli/review_text.csv")

norm <- function(x) gsub("[^a-z0-9 ]", "", tolower(x))

out <- rbindlist(lapply(reviews$review, function(rv) {
  kw <- if (reviews[review == rv, domain] == "Airbnb") KEYWORDS_ACCOMMODATION else KEYWORDS_PROFESSOR
  code_sentences <- extract_person_sentences(reviews[review == rv, text], kw)
  shown <- paste(norm(sp[review == rv & method == "Dictionary", span_text]), collapse = " ")
  ## a sentence counts as shown if its opening words appear inside the highlighted
  ## text, which tolerates panels that merge several sentences into one span
  present <- sapply(code_sentences, function(cs) {
    key <- substr(norm(cs), 1, 30)
    nchar(key) > 10 && grepl(key, shown, fixed = TRUE)
  })
  data.table(review = rv,
             sentences_selected_by_code = length(code_sentences),
             sentences_shown_in_panel = sum(present),
             missing_from_panel = paste(substr(code_sentences[!present], 1, 60), collapse = " | "))
}))
fwrite(out, "data/dictionary_reproduction_check.csv")
print(out)
