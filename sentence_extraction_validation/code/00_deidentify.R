################################################################################
# 00_deidentify.R
#
# Turns the raw Qualtrics export into the de-identified file that the rest of
# this folder uses. The raw export is not distributed: it carries IP addresses,
# approximate geolocation, and Prolific worker IDs. This script removes those
# fields and replaces the worker ID with a sequential participant number.
#
# Screening: a response is kept if it is marked finished and carries a worker ID
# that is not the pilot entry. Every kept response gave consent and chose to
# submit at the debriefing; the script checks both. Screening is deliberately
# not based on a calendar date, because the export timezone is a user setting
# and the same responses carry different dates in different exports.
#
# Input : a Qualtrics export of this survey (not distributed with this folder)
# Output: data/validation_responses.csv
#
# Scripts 01 to 03 read only files inside this folder and run without any edits.
################################################################################
library(data.table)

## The raw export is not distributed with this folder, so this script is here as a
## record of how the shared file was produced rather than as a step to re-run. To
## run it, point RAW at a Qualtrics export of this survey.
RAW <- Sys.getenv("QUALTRICS_EXPORT", "Human_entity_identification.csv")
raw <- fread(RAW)
raw <- raw[3:.N]                       # drop the two Qualtrics metadata rows

d <- raw[Finished == "True" & trimws(Q27) != "" & tolower(trimws(Q27)) != "test"]
stopifnot(!any(duplicated(trimws(d$Q27))))
stopifnot(all(d$Q1 == "Yes, I consent to participate in this study."),   # consent
          all(d$Q12 == "I agree, submit my responses."))                  # no withdrawals
setorder(d, StartDate)
d[, participant := sprintf("P%02d", .I)]

items <- c(outer(paste0("R", 1:6), c("_A_5", "_A_6", "_B_4", "_B_5"), paste0))
out <- d[, c("participant", "Duration (in seconds)", items), with = FALSE]
setnames(out, "Duration (in seconds)", "duration_seconds")

fwrite(out, "data/validation_responses.csv")
cat(sprintf("wrote data/validation_responses.csv: %d participants, %d rating items\n",
            nrow(out), length(items)))
cat("removed: IP address, latitude, longitude, worker ID, response ID, timestamps\n")
