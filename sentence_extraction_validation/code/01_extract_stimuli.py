#!/usr/bin/env python3
"""
01_extract_stimuli.py

Pulls the six reviews and their two highlighted versions out of the Qualtrics
survey file and writes them in two forms: a browsable HTML page and a
machine-readable table of the highlighted spans.

The highlighting is stored as inline HTML in the survey file. It does not
survive the response export or a PDF print, so the survey file is the only
record of what participants actually saw.

Input : survey/Human_entity_identification.qsf
Output: stimuli/stimuli.html, stimuli/highlighted_spans.csv
"""
import csv
import html
import json
import re

QSF = "survey/Human_entity_identification.qsf"
LLM_OPTION = {"R1": "B", "R2": "B", "R3": "A", "R4": "B", "R5": "A", "R6": "B"}
DOMAIN = {"R1": "Airbnb", "R2": "Airbnb", "R3": "Airbnb",
          "R4": "Professor", "R5": "Professor", "R6": "Professor"}
HL = r"<span style=['\"]background-color:\s*#fffb8b[^'\"]*['\"]>(.*?)</span>"

with open(QSF) as f:
    survey = json.load(f)
questions = {e["Payload"].get("DataExportTag"): e["Payload"]
             for e in survey["SurveyElements"] if e["Element"] == "SQ"}


def option_block(tag):
    """Return the option's HTML, stripped of the shared instruction text."""
    raw = questions[tag]["QuestionText"]
    m = re.search(r"<p><strong>Option [AB]</strong></p>(.*?)</div>", raw, re.S)
    return (m.group(1) if m else raw).strip()


def spans(block):
    return [html.unescape(re.sub("<[^>]+>", "", s)).strip()
            for s in re.findall(HL, block, re.S)]


def plain(block):
    return re.sub(r"\s+", " ", html.unescape(re.sub("<[^>]+>", "", block))).strip()


rows, sections = [], []
for i in range(1, 7):
    rv = f"R{i}"
    parts = []
    for opt in ("A", "B"):
        block = option_block(f"{rv}_{opt}")
        method = "LLM" if LLM_OPTION[rv] == opt else "Dictionary"
        for k, s in enumerate(spans(block), start=1):
            rows.append({"review": rv, "domain": DOMAIN[rv], "option": opt,
                         "method": method, "span_number": k, "span_text": s})
        parts.append(
            f"<div class='opt'><div class='lab'>Option {opt} &middot; {method}</div>"
            f"<div class='txt'>{block}</div></div>")
    sections.append(
        f"<section><h2>{rv} <span class='dom'>({DOMAIN[rv]} review)</span></h2>"
        + "".join(parts) + "</section>")

with open("stimuli/highlighted_spans.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=["review", "domain", "option", "method",
                                      "span_number", "span_text"])
    w.writeheader()
    w.writerows(rows)

STYLE = """body{font-family:Georgia,serif;max-width:820px;margin:40px auto;padding:0 20px;color:#222;line-height:1.6}
h1{font-size:22px}h2{font-size:17px;margin-top:34px;border-bottom:1px solid #ddd;padding-bottom:4px}
.dom{font-weight:normal;color:#777;font-size:14px}
.opt{margin:14px 0;padding:12px 14px;border:1px solid #ddd;border-radius:5px;background:#fbfbfb}
.lab{font-family:Helvetica,Arial,sans-serif;font-size:13px;font-weight:bold;color:#555;margin-bottom:6px}
.note{color:#555;font-size:14px}"""

with open("stimuli/stimuli.html", "w") as f:
    f.write(f"""<!doctype html><meta charset="utf-8"><title>Validation stimuli</title>
<style>{STYLE}</style>
<h1>Sentence-extraction validation: the six reviews as participants saw them</h1>
<p class="note">Each review was shown twice, once with the sentences selected by the
large language model and once with the sentences selected by the dictionary method.
Participants saw the option letters only and were not told which method produced which
highlighting. Option A always appeared above Option B; the order of the six reviews was
randomized.</p>
{''.join(sections)}""")

print(f"wrote stimuli/stimuli.html and stimuli/highlighted_spans.csv "
      f"({len(rows)} highlighted spans across 12 panels)")
