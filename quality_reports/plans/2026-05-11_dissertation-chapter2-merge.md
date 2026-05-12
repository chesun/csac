# Plan: Merge GDTF LGBTQ Paper into Dissertation as Chapter 3

**Status:** DRAFT — awaiting Q1/Q2 answers (Q3–Q8 have defaults; Q5 resolved at source)
**Date:** 2026-05-11 (updated after chapter slot swap commit `70adfda`)
**Source repo:** `~/github_repos/csac/doc/dissertation/chapter3/`
**Target repo:** `~/github_repos/dissertation_template/Chapter3/`
**Reference:** `~/github_repos/dissertation_template/MERGING_CHAPTERS.md`

---

## 0. Today's prep work already done

Before drafting this plan, three issues were fixed *at the source* in `csac/doc/dissertation/chapter3/`:

1. **Appendix B created** (`Tables/tab_appB_hsexp_items_construct.tex` + section in `chapter3.tex` between Appendix A and C). Content extracted from `doc/gdtf/GDTF LGBTQ paper -- Final - clean.docx`: 6 Likert items + 1 construct row. Resolves Q5.
2. **All 13 in-prose hardcoded letter/number references converted to `\ref{}` form** in `chapter3.tex` — 11 "Appendix X" letter refs (lines 296, 331, 344, 351, 368, 398, 592, 624, 824, 859, 927) + "Figures 5 through 7" (line 659) + "Tables 8 and 9" (line 983). Standalone PDF: 72 pages, 0 errors, 0 undefined refs. Step 3.4 in this plan is therefore now a *verification only* step, not an edit step.
3. **Dissertation chapter slots swapped** (`dissertation_template` commits `7dfa776`, `70adfda`): DiD paper now occupies Chapter 2 slot; Chapter 3 slot is a fresh stub awaiting this merge.

---

## 1. Source inventory

| Asset | Path | Size |
|---|---|---|
| Body source | `chapter3.tex` | 1679 lines (was 1659; +20 for Appendix B section) |
| Standalone wrapper | `chapter3_standalone.tex` | NOT copied — drop |
| Local appendix.sty | `appendix.sty` | NOT copied — replaced by root shared appendix.sty |
| Local stylefile.sty | `stylefile.sty` | NOT copied — dissertation has its own |
| Local bibliography_all.bib | `bibliography_all.bib` | 79 entries (appended to dissertation root bib) |
| Figures | `Figures/*.png` | 27 PNG files (10 main + 17 appendix) |
| Tables | `Tables/*.tex` | **17 bare-tabular fragments** (was 16; +1 for `tab_appB_hsexp_items_construct.tex`) |

**Body file already designed as swap-in artifact:** starts with `\section{Introduction}\label{introduction}` (line 13). No `\documentclass`, no `\begin{document}`, no `\title`, no `\maketitle`, no `\printbibliography`. Structural elements to strip during integration: `\graphicspath` (line 11), `\appendix` (line ~1314 after Appendix B insertion). The `\input{appendix.sty}` immediately after will resolve to the **root** shared file (UC-Davis-compliant).

**Citation count:** 41 `\cite*{...}` calls. Cite-key set has **0 overlap** with the dissertation's existing 74 entries. Clean append of 79 new entries.

**Bib safety pre-flight:** 0 unescaped `#` in field values. 0 stray-`\\`-before-`\parbox` table bugs. 0 `\widetilde` / `\widehat` in body (no MnSymbol pitfall).

---

## 2. Critical UC Davis numbering issue (REMINDER — already handled at source)

UC Davis Grad Studies formatting requires **continuous chapter-level numbering** throughout. Under the dissertation's root `appendix.sty`:

- Appendix sections become **3.10, 3.11, 3.12, ...** (continuing from main-text section count)
- Appendix tables become **3.X+1, 3.X+2, ...** (continuing)
- Appendix figures continue similarly
- Section headings render as plain "3.10. Additional Demographics" (no "Appendix A." prefix)

**Source's local `appendix.sty` violates this** (resets to `\Alph{section}` style). Therefore at integration time: do NOT copy the local appendix.sty. Drop the source's `\appendix` macro before the `\input{appendix.sty}` line. The `\input{appendix.sty}` line is kept — it resolves to the root shared file which is UC-Davis-compliant.

All 13 prose letter/number references were already converted at source today. Under the source's local appendix.sty, those `\ref{}` calls resolve to letters (A.1, J.5, etc.); under the dissertation's root appendix.sty, they resolve to continuous numbers (3.11, 3.18.5, etc.). Both render correctly — that's the whole point of using `\ref{}`.

---

## 3. Execution steps (in order)

### Step 3.1 — Stage Chapter3 dir and copy figures

```bash
cd ~/github_repos/dissertation_template
rm -f Chapter3/chapter3.tex                # discard stub created by swap commit
rmdir Chapter3/Figures 2>/dev/null || true # discard empty Figures dir
mkdir -p Chapter3/Figures Chapter3/tables
cp ~/github_repos/csac/doc/dissertation/chapter3/Figures/*.png Chapter3/Figures/
cp ~/github_repos/csac/doc/dissertation/chapter3/Tables/*.tex Chapter3/tables/
```

### Step 3.2 — Copy chapter body and retarget paths

```bash
cp ~/github_repos/csac/doc/dissertation/chapter3/chapter3.tex Chapter3/chapter3.tex
```

Then apply these edits (Python or sed) **on the file in the dissertation repo, not the source**:

1. **Drop `\graphicspath{...}`** (line 11) — single-line removal.
2. **Retarget figure paths**: `\includegraphics[...]{fig...png}` → `\includegraphics[...]{Chapter3/Figures/fig...png}`. 27 occurrences.
3. **Retarget table inputs**: `\input{Tables/tabNN_slug.tex}` → `\input{Chapter3/tables/tabNN_slug.tex}`. 17 occurrences.
4. **Strip `\appendix`** (line ~1314 — count shifted by ~20 due to Appendix B insertion).
5. **Keep `\input{appendix.sty}`** on the next line — resolves to root shared file.
6. **Update header comment** from "Chapter 3 of the dissertation: GDTF LGBTQ paper" to "Chapter 3 of the dissertation; integrated [date] from csac repo".

**⚠ git-add discipline (lesson from commit `7dfa776`):** every sed/Edit modification to the file must be followed by `git add Chapter3/chapter3.tex` BEFORE committing. The earlier chapter-swap commit had this exact failure mode — `git mv` staged the rename but subsequent `sed` mods were never staged, so the push went out with the rename but without the path updates, breaking the Overleaf compile. Fixed in `70adfda`. Don't repeat.

### Step 3.3 — Namespace generic labels and same-file `\ref{...}`

Apply per-file sed/Python to prefix collision-risk labels with `:ch3:` namespace. Targets (all `\label{...}` definitions plus matching `\ref{...}` calls in the same file):

| Current label | New label |
|---|---|
| `introduction` | `sec:ch3:introduction` |
| `theoretical-background-and-prior-literature` | `sec:ch3:theory` |
| `data-and-methods` | `sec:ch3:data` |
| `data-analysis` | `sec:ch3:analysis` |
| `findings` | `sec:ch3:findings` |
| `bullying-as-a-potential-mediator-of-college-worries` | `sec:ch3:bullying-mediator` |
| `postsecondary-educational-plans` | `sec:ch3:plans` |
| `limitations` | `sec:ch3:limitations` |
| `discussion-and-conclusion` | `sec:ch3:conclusion` |
| `appendix-a-additional-demographics` | `sec:ch3:app-demographics` |
| `appendix-b-high-school-experience-items-and-construct` | `sec:ch3:app-hsexp-construct` |
| `appendix-c-...hs-experience-items` | `sec:ch3:app-hsexp-items` |
| `appendix-d-...concern-items` | `sec:ch3:app-concern-items` |
| `appendix-e-additional-demographics` | `sec:ch3:app-qual-demographics` |
| `appendix-f-...` | `sec:ch3:app-hsexp-so-robustness` |
| `appendix-g-...` | `sec:ch3:app-worries-so-robustness` |
| `appendix-h-...` | `sec:ch3:app-degree-aspirations` |
| `appendix-i-...` | `sec:ch3:app-bullying-hsexp` |
| `appendix-j-...` | `sec:ch3:app-bullying-worries` |

Plus all `\label{tab:...}` (8 main + 7 appendix = 15) → `tab:ch3:...` and all `\label{fig:...}` (12 main + 16 appendix = 28) → `fig:ch3:...` for defensive namespacing per Q4 default.

Total: ~43 labels + corresponding `\ref` rewrites within the same file. One sed/Python pass handles both label definitions and refs because they share the same string.

### Step 3.4 — Verify in-prose `\ref{}` form (no edits expected)

This step was an edit step in the original plan but the conversions are now done at source. Just verify:

```bash
grep -nE 'Appendix [A-J](\W|$)|Figure[s]? [0-9]+|Table[s]? [0-9]+|Section [0-9]+' Chapter3/chapter3.tex
```

Expected output: nothing (or only file-path matches like "Chapter3/Figures/..."). Any hardcoded letter/number reference that surfaces gets converted to `\ref{...}` form here.

### Step 3.5 — Wire `dissertation.tex` Chapter 3 slot

Edit `~/github_repos/dissertation_template/dissertation.tex`. Current state (after the swap):

```latex
\chapter{[Chapter 3 Title]} \label{chap:ch3}
\input{Chapter3/chapter3}
```

Replace with (assuming Q1 = "use thanks footnote"):

```latex
\chapter[Short title from Q3]%
        {LGBTQ+ Students' High School Experiences and Academic Plans%
         \footnotemark}\label{chap:ch3}
\footnotetext{[Text from Q2 — co-author info + acknowledgments]}
\input{Chapter3/chapter3}
```

If Q1 = "no footnote":

```latex
\chapter{LGBTQ+ Students' High School Experiences and Academic Plans}\label{chap:ch3}
\input{Chapter3/chapter3}
```

### Step 3.6 — Merge bibliography

Append 79 entries from source bib to dissertation root `bibliography_all.bib`:

```bash
cat ~/github_repos/csac/doc/dissertation/chapter3/bibliography_all.bib \
    >> ~/github_repos/dissertation_template/bibliography_all.bib
```

(0 cite-key overlap — straight concatenation.) Then re-verify:

```bash
grep -nE '[^\\]#[0-9]' ~/github_repos/dissertation_template/bibliography_all.bib
```

Expected: nothing.

### Step 3.7 — Compile test

```bash
cd ~/github_repos/dissertation_template
pdflatex dissertation
biber dissertation
pdflatex dissertation
pdflatex dissertation
```

Grep the log for the standard error patterns:

- `! LaTeX Error:`
- `! Undefined control sequence`
- `Citation .* undefined`
- `Reference .* undefined`
- `multiply defined`
- `File .* not found`

Expected: 0 of each. Page count: ~245 (175 current dissertation + ~70 for new Chapter 3).

### Step 3.8 — `stylefile.sty` additions (likely none)

Watch first compile pass for:

- `! Undefined control sequence \sym` → add `\providecommand{\sym}[1]{\ensuremath{^{#1}}}` to dissertation `stylefile.sty` (used by esttab significance stars)

`sidewaystable`, `\FloatBarrier`, `\allowbreak` — all already available in the dissertation preamble.

### Step 3.9 — Pre-PR checklist (MERGING_CHAPTERS.md §13)

```bash
# Residual-token check
grep -nE '\\(documentclass|begin\{document\}|end\{document\}|title\{|maketitle|printbibliography|bibliography\{|begin\{appendices\}|end\{appendices\}|appendix\b)' Chapter3/chapter3.tex

# Hardcoded number/letter ref check
grep -nE 'Appendix [A-J](\W|$)|Figure[s]? [0-9]+|Table[s]? [0-9]+|Section [0-9]+' Chapter3/chapter3.tex

# Wide-accent brace check
grep -E '\\(widetilde|widehat|overline|underline)[^{]' Chapter3/chapter3.tex

# Bib # check
grep -nE '[^\\]#[0-9]' bibliography_all.bib

# Spot-check appendix renders as 3.X not A
grep -A1 'High School Experience Items and Construct' dissertation.toc
```

All should return nothing. The TOC grep should show "3.X. High School Experience Items and Construct" (the new Appendix B section).

### Step 3.10 — Commit

`git add` EVERY file before committing (lesson from `7dfa776`):

```bash
git add Chapter3/ dissertation.tex bibliography_all.bib
git add stylefile.sty   # only if Q8 surfaces additions
git status              # verify no `M ` (red, unstaged) markers on tracked files
git commit -m "$(cat <<'EOF'
Integrate GDTF LGBTQ paper as Chapter 3

Adds chapter "LGBTQ+ Students' High School Experiences and Academic
Plans" (co-authored with Alexandria Hurtt and Michal Kurlaender) to
the Chapter 3 slot.

Integration follows MERGING_CHAPTERS.md:
- Source: doc/dissertation/chapter3/chapter3.tex from csac repo
- Stripped \appendix macro (UC Davis: continuous numbering)
- Replaced local A/B/C-letter appendix.sty with root shared appendix.sty
- Retargeted figure paths to Chapter3/Figures/, tables to Chapter3/tables/
- Namespaced ~43 section/table/fig labels with :ch3: prefix
- Appended 79 bib entries to bibliography_all.bib (0 key overlap)

[Optional stylefile.sty additions: ...]

Verified: pdflatex+biber+pdflatex+pdflatex clean — N pages, 0 errors,
0 undefined refs/cites, 0 multiply-defined labels.
EOF
)"
```

### Step 3.11 — Push (with HTTPS buffer override)

```bash
git -c http.postBuffer=524288000 push origin main
```

If Overleaf-side divergence error: `git fetch && git pull --no-edit && git push`. Then verify the remote file via `gh api repos/chesun/dissertation_template/contents/Chapter3/chapter3.tex --jq '.content' | base64 -d | sed -n '125p'` matches local.

---

## 4. Open questions

### Need your answer

**Q1. Chapter-title footnote — yes or no?**
- (a) Full: co-authors + acknowledgments (mirrors Ch 1 / Ch 2 in template)
- (b) Co-authors only, no acks
- (c) No footnote — plain `\chapter{title}`

**Q2. Footnote text (only if Q1 = a or b).** Verbatim text needed:
- Co-author affiliations + emails — format like Ch 2: `Briana Ballis (UC Merced; bballis@ucmerced.edu)`. Need for Alexandria Hurtt and Michal Kurlaender.
- Acknowledgments: funding (PACE / CSAC / other?), data acks (CSAC restricted data?), IRB language, anything else.

### Defaults (I'll use unless you redirect)

**Q3. Short TOC title** → plain `\chapter{full title}`. The full title is 57 chars, no math, no `\halign` pitfall — no need for `[short]` bracket.

**Q4. Label namespacing scope** → defensive: prefix ALL `sec:` / `tab:` / `fig:` labels with `:ch3:`. ~43 labels + same-file ref rewrites. Reduces collision risk going forward.

**Q6. Tables dir naming** → `tables/` (lowercase) to match template convention (Ch 1 and Ch 2 both use lowercase).

**Q7. Caption positioning** → no-op; the dissertation template already sets `\captionsetup[table]{position=top}` which matches source.

**Q8. `\sym` provider in stylefile.sty** → add the one line if the first compile errors on `! Undefined control sequence \sym`. Used by esttab significance stars; harmless if added.

### Resolved

**Q5.** ~~Missing "Appendix B"~~ — Appendix B now exists in source (created today). 11 hardcoded "Appendix X" letter references in source converted to `\ref{}` form. Both standalone-PDF rendering (under local appendix.sty: "Appendix B") and integrated rendering (under dissertation appendix.sty: "Appendix 3.11" or similar) work correctly.

---

## 5. Order of operations (TL;DR)

1. Copy assets (figures, tables, body) into `dissertation_template/Chapter3/`
2. Path retargeting (`\graphicspath` drop + `Chapter3/Figures/` + `Chapter3/tables/`)
3. Strip `\appendix`; keep `\input{appendix.sty}` (resolves to root shared)
4. Label namespacing (`:ch3:` prefix on sec/tab/fig)
5. Verify no hardcoded letter/number refs remain (no edits — already done at source)
6. Wire `dissertation.tex` Chapter 3 slot (per Q1/Q2)
7. Append bibliography (79 entries, 0 conflicts)
8. Compile (pdflatex → biber → pdflatex → pdflatex)
9. Fix stylefile.sty if `\sym` error fires (likely no-op)
10. Run §13 pre-PR checklist
11. **`git add` EVERY edit** then commit then push with HTTPS buffer override

---

## 6. Sanity totals (verification snapshot)

| Item | Count |
|---|---|
| Chapter body lines (after edits) | ~1677 (drop 2 lines: graphicspath, \\appendix) |
| Figure files copied | 27 |
| Table fragment files copied | 17 (was 16; +1 for Appendix B) |
| Bibliography entries appended | 79 |
| Label namespace edits (defensive) | ~43 labels + same-file refs |
| Prose hardcoded refs to convert at integration | 0 (already done at source) |
| `dissertation.tex` lines touched | 2 (title swap) + footnote block if Q1=a |
| `stylefile.sty` lines touched | 0–1 (only if `\sym` missing) |
| Expected commit count | 1 |
| Expected push size | <10 MB |

---

**Awaiting Q1 + Q2 answers. Q3–Q8 will default to the values above unless you redirect.**
