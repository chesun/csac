# TODO — CSAC Project

Last updated: 2026-05-12 (end of day)

## Active (doing now)

(none — paused for the night)

## Up Next

### User-side dissertation polish (manual, in `dissertation_template/`)

- [ ] Add chapter-3 thanks/acknowledgments footnote to `dissertation.tex`
      (~line 133) following the Ch 1 / Ch 2 pattern: co-authors
      Alexandria Hurtt and Michal Kurlaender + funding/data acks
- [ ] Drop dissertation umbrella abstract paragraph into the abstract
      section (paragraph drafted in conversation, not written to file)
- [ ] Drop in three chapter abstracts (one per paragraph) below the
      umbrella
- [ ] Add Audre Lorde epigraph block (LaTeX provided in conversation)
      between the dedication and `\chapter*{Acknowledgments}` (~line 84)

### Chapter 3 (csac standalone) follow-ups

- [ ] Remove the now-redundant `decode gender_cat, gen(gender_cat_str)`
      and `decode so_cat, gen(so_cat_str)` lines from `gdtf_latex_tables.do`.
      Dead code — `coeflabels()` is doing the label mapping directly
      from numeric codes.
- [ ] A.1 column-header patch is fragile (currently re-applied via
      Python in `.workspace/integrate_stata_tables.py` on each
      integration). Consider promoting to a permanent fix in the
      wrapper script or finding an esttab option.
- [ ] Extract the Python integration wrapper into a reusable script in
      `.workspace/` so the integration step is one command, not a paste.

## Waiting On

- [ ] (none active)

## Backlog

- [ ] Section-level prose diff against published PDF for any remaining
      journal copyedits beyond placeholders, year fixes, and footnotes
      (~2 hours)
- [ ] Add Table 5 (intended field of study) to the Stata script if a
      `major_cat` variable exists on the cleaned data
- [ ] Update CLAUDE.md GDTF figure list (currently lists 8 figures;
      published paper has 12)
- [ ] Begin Chapter 1 (belief distortion JMP) scaffolding for csac if
      we want a working copy outside `dissertation_template/Chapter1/`
- [ ] Begin Chapter 2 (peer-effects DiD) scaffolding for csac if we
      want a working copy outside `dissertation_template/Chapter2/`

## Done (2026-05-12 end-of-day summary)

The two-day arc, in roughly chronological commit order:

- [x] **2026-05-10**: Wide-table fit cycle — stack mean/N, wrap data-col
      labels, strip esttab `\multicolumn` wrappers, widen p{} cols,
      `\allowbreak{}` after slashes. All wide tables (5, A.1, B.1, B.2,
      C.1, C.2) now fit within margins
- [x] **2026-05-11**: Appendix float confinement — `\FloatBarrier` in
      appendix.sty `\titleformat`, `[!ht]` for appendix tables
- [x] **2026-05-11**: Convert F–J appendix headers from `\textbf{}` to
      `\section{}` so they get auto-letter numbering (`44e8fba`)
- [x] **2026-05-12**: **Created Appendix B** (HS Experience Items +
      Construct) — new table fragment + new section in chapter3.tex.
      Content extracted from Word source (6 Likert items + 1 construct
      row with N and mean columns)
- [x] **2026-05-12**: Converted 13 hardcoded letter/number refs to
      `\ref{}` form in chapter3.tex — 11 "Appendix X" letters + Figures
      5–7 + Tables 8–9. Now portable across appendix.sty variants
- [x] **2026-05-12**: Polished `tab_appE_qual_demographics.tex` with
      `\midrule` panel separators
- [x] **2026-05-12**: **Dissertation integration** —
      `~/github_repos/dissertation_template/` chapter swap (DiD →
      Ch 2; GDTF → fresh Ch 3) and full GDTF integration. Result:
      246-page dissertation PDF, 0 errors, 0 undefined refs/cites,
      0 multiply-defined labels. Lessons surfaced about `git mv`
      requiring explicit `git add` of post-rename sed mods
- [x] **2026-05-12**: Drafted dissertation umbrella abstract paragraph
      + chose Audre Lorde epigraph (delivered in conversation, not
      written to dissertation files per user instruction)
- [x] **2026-05-12**: Merge plan + session logs + .gitignore polish
      (Microsoft Office lock files, texput.log) committed (`06e0f5d`)

## Done (earlier)

- [x] 2026-05-09 — Full chapter 3 conversion from Final Word doc;
      heavy table polish; 73-page compiled PDF
- [x] 2026-05-08 — Built standalone LaTeX scaffold at
      `doc/dissertation/chapter3/`
- [x] 2026-03-17 — GDTF v3 copyedit completed; passed to Alex Hurtt
