# TODO — CSAC Project

Last updated: 2026-05-09 (end of day)

## Active (doing now)

(none — paused for the night)

## Up Next (chapter 3 — picking up tomorrow)

### Wide tables — if still cut off after `\footnotesize` + `\tabcolsep{3pt}`

In order of impact (largest first):

- [ ] **Drop the count columns** from Tables B.1, B.2, C.1, C.2 — keep only
      means. Halves the width. The N is in Tables 2/3 already.
- [ ] **Use `\scriptsize`** (one size smaller than `\footnotesize`)
- [ ] **Wrap tabular in `\resizebox{\textheight}{!}{...}`** for the
      `sidewaystable` envs (auto-scales — can get tiny on very wide tabs)
- [ ] **Shorter row labels** — alias survey items to short codes (e.g.,
      "Acad. exp." instead of full survey question) in either the Stata
      script or by editing the .tex post-output

### A.1 column-header patch is fragile

- [ ] Currently re-applied via Python in the integration step each time
      Tables/ is updated from `tab/dissertation_chapter3/`. Consider
      either: (a) automating in the wrapper script as a permanent fix;
      (b) finding an esttab option that relabels `unstack` columns
      (none known yet); (c) accepting it as a manual post-process step
      and documenting prominently.

### Cleanup

- [ ] Remove the now-redundant `decode gender_cat, gen(gender_cat_str)`
      and `decode so_cat, gen(so_cat_str)` lines from the .do file.
      The string variables aren't used anywhere — `coeflabels()` is
      doing the label mapping directly from numeric codes. Dead code.
- [ ] Extract the Python integration wrapper (auto-detect col count, add
      `\begin{tabular}`/`\bottomrule`/`\end{tabular}`, re-patch A.1
      column header) into a reusable script in `.workspace/` so the
      integration step is one command, not a paste.

## Up Next (lower priority polish)

- [ ] **Section-level diff against published PDF** for any remaining
      journal copyedits beyond placeholders, year fixes, and footnotes
      (~2 hours)
- [ ] **Add Table 5 (intended field of study) to the Stata script** if a
      `major_cat` variable exists on the cleaned data; currently it uses
      the pandoc-converted version which I rewrote to be clean booktabs

## Waiting On

- [ ] (none active — final Word arrived; chapter is converted from final
      and incremental edits going forward)

## Backlog

- [ ] Integrate chapter 3 into `~/github_repos/dissertation_template/`
      once content is finalized
- [ ] Begin chapter 1 and chapter 2 scaffolding (separate dissertation chapters)
- [ ] Update `dissertation.tex` chapter-3 title and label at integration time
- [ ] Update CLAUDE.md GDTF figure list (currently lists 8 figures; published
      paper has 12 — already noted on 2026-05-09 but never edited the file)

## Done (2026-05-09 end-of-day summary)

The day's work, in chronological commit order:

- [x] Pivoted from Path A to Path B (start from v3 + PDF diff); pandoc-
      converted v3 docx, anystyle-parsed bibliography, mapped 27 figures
      and 17 tables; first compile of 54-page draft (`aaa7a55`)
- [x] First cleanup pass: 5 corporate-author bib parses, 9 missing
      references added, 3 journal copyedits (Watson 2019→2020, Kosciw
      2013/2021→2022), 45 `\citep{}` resolved, 27 figures + 17 tables
      wrapped with caption + label, appendices appended (had been
      truncated) (`6cd777c`)
- [x] **Final cleanup pass**: 5 placeholders filled, 8 footnotes restored,
      14 orphan figure preludes + 11 orphan table preludes stripped,
      243-line Table 5 cell-content orphan stripped, 15 appendix figure
      captions cleaned of AI-alt-text, longtable→tabular conversion,
      appendix table numbering corrected to A.1/B.1/etc.; wrote
      `gdtf_latex_tables.do` for Stata-direct LaTeX tables; 72-page PDF
      compiles clean
- [x] Re-converted the WHOLE chapter from the **final post-copyedit Word
      doc** when it arrived mid-session (~5K char prose delta, +6 refs,
      Table B dropped); applied all 17 cleanup gotchas via
      `full_reconvert.py`; 73-page PDF (`55648a2`)
- [x] Stata script iterations: dropped `tex` (conflicts with `booktabs`)
      `4440f00`; replaced trailing `if` with control-flow `if{}` `4c9a0a6`;
      dropped `percent` from `estpost tabulate` `4ef37f2`; hardcoded
      coeflabels/mtitles from genderso.do `78ccb44`; compound double
      quotes for mtitles `6805970`
- [x] Wired `appendix.sty` into chapter 3 for proper appendix
      formatting (centered "Appendix A. Title", \\Alph sections, page
      break per section, A.1/B.1 auto-numbering) (`c9c0f9a`)
- [x] Stripped duplicate orphan title text (Table N. Title) that
      appeared in prose AND as caption in 25 places (`967f46b`)
- [x] Moved figure captions to TOP of figures (was below) (`967f46b`)
- [x] Re-mapped all 15 appendix figures (off-by-one because skipped F1)
      + restored missing Table 9 (`073a592`)
- [x] Round-trip table integrations with Stata outputs (`f4d521d`,
      `e5f9afe`, `58fc066`)
- [x] Table 5 cleanup + regression table row labels and centered coefs
      (`7ae77ae`)
- [x] Quadruple-bottom-rule fix + compact format for wide tables
      (`1fab7ed`)
- [x] **Skill v1.2 published** documenting the Word→LaTeX pipeline with
      19 documented gotchas (`6aba25b`, `7f46efb`)

## Done (earlier)

- [x] 2026-05-08 — Built standalone LaTeX scaffold at
      `doc/dissertation/chapter3/`
- [x] 2026-03-17 — GDTF v3 copyedit completed; passed to Alex Hurtt
