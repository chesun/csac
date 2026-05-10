# TODO — CSAC Project

Last updated: 2026-05-09

## Active (doing now)

(none)

## Up Next (chapter 3 — server round-trip)

- [ ] **Run `do/getting_down_to_facts/gdtf_latex_tables.do` on the server** to produce clean Stata-direct LaTeX tables (replaces 12+ pandoc-converted ones)
- [ ] **FileZilla `tab/dissertation_chapter3/*.tex` back** to local repo, then copy/replace `doc/dissertation/chapter3/Tables/` files
- [ ] **Recompile** and verify Stata-direct tables render properly

## Up Next (lower priority polish)

- [ ] **Section-level diff against published PDF** for any remaining journal copyedits beyond placeholders, year fixes, and footnotes (~2 hours)
- [ ] **Add Table 5 (intended field of study) to the Stata script** if a `major_cat` variable exists; otherwise keep hand-formatted

## Waiting On

- [ ] Final post-copyedit Word version of GDTF paper from coauthor (Alex Hurtt) — at that point, replace v3-converted prose with final-Word version

## Backlog

- [ ] Integrate chapter 3 into `~/github_repos/dissertation_template/` once content is finalized
- [ ] Begin chapter 1 and chapter 2 scaffolding (separate dissertation chapters)
- [ ] Update `dissertation.tex` chapter-3 title and label at integration time
- [ ] Update CLAUDE.md GDTF figure list (currently lists 8 figures; published paper has 12)

## Done (recent)

- [x] 2026-05-09 — **Final cleanup pass**: filled 5 placeholders (`(CITE)` → 3 citations, `XX [number]` → 323,555, `XX percent` → 3.2%, qual questions block); restored 8 footnotes; stripped 14 orphan figure preludes + 11 orphan table preludes + giant Table 5 cell-content block; fixed 15 appendix figure captions (had AI-generated alt-text); wrote `do/getting_down_to_facts/gdtf_latex_tables.do` for 12+ Stata-direct LaTeX tables (server-run, FileZilla back); converted all longtable → tabular in Tables/; appendix table numbering now matches published (A.1, B.1, C.1, C.2, D.1, D.2, E.1); 72-page PDF, 0 errors
- [x] 2026-05-09 — **Cleanup pass**: fixed 5 corporate-author bib parses; added 9 missing references (Bergerson, Fernandes, Heck, James, Klasik, Pennell, Reed, Schultz, AB 9); applied 3 journal copyedits (Watson 2019→2020, Kosciw 2013/2021→2022); converted all citations (45 `\citep{}`); wrapped 27 figures + 17 tables in environments with caption + label; converted 47 figure + 27 table cross-refs to `\ref{}`; appended appendices (were truncated out of first pass); 84-page PDF compiles clean (0 errors, 0 undefined)
- [x] 2026-05-09 — Pivoted from Path A to Path B; pandoc-converted v3 docx, anystyle-parsed bibliography (71 entries), extracted 17 tables, copied 27 figures, compiled clean 54-page PDF
- [x] 2026-05-09 — Mapped 27 figures (12 main + 15 appendix) and 17 tables (9 main + 8 appendix) to local sources
- [x] 2026-05-08 — Built standalone LaTeX scaffold at `doc/dissertation/chapter3/` (compiles clean)
- [x] 2026-05-08 — Initial decision: Path A (wait for final Word); revised 2026-05-09 to Path B
- [x] 2026-03-17 — GDTF v3 copyedit completed; passed to Alex Hurtt
