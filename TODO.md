# TODO — CSAC Project

Last updated: 2026-05-09

## Active (doing now)

(none)

## Up Next (chapter 3 follow-ups — needs coauthor input)

- [ ] **Fill the "(CITE)" placeholder** on PDF page 4 (Theoretical Background, "trajectory (CITE)") — coauthor needs to provide missing citation
- [ ] **Fill "XX [number]" / "XX percent" placeholders** in Data and Methods section (page 6) — survey response counts and rates
- [ ] **Fix "Appendix Table 19" cross-reference** rendering — should show as "Table A.2"; needs `\appendix` numbering reset or table label tweak (~30 min)

## Up Next (lower priority polish)

- [ ] **Visual-verify all 17 tables and 27 figures** in compiled PDF
- [ ] **Section-level diff against published PDF** for journal copyedits beyond what I caught (Watson 2019→2020, Kosciw 2013/2021→2022) (~2-3 hours)
- [ ] **Recompute chapter1.X, chapter1.Y format** if dissertation prefers cleaner table/figure numbering

## Waiting On

- [ ] Final post-copyedit Word version of GDTF paper from coauthor (Alex Hurtt) — at that point, replace v3-converted prose with final-Word version

## Backlog

- [ ] Integrate chapter 3 into `~/github_repos/dissertation_template/` once content is finalized
- [ ] Begin chapter 1 and chapter 2 scaffolding (separate dissertation chapters)
- [ ] Update `dissertation.tex` chapter-3 title and label at integration time
- [ ] Update CLAUDE.md GDTF figure list (currently lists 8 figures; published paper has 12)

## Done (recent)

- [x] 2026-05-09 — **Cleanup pass**: fixed 5 corporate-author bib parses; added 9 missing references (Bergerson, Fernandes, Heck, James, Klasik, Pennell, Reed, Schultz, AB 9); applied 3 journal copyedits (Watson 2019→2020, Kosciw 2013/2021→2022); converted all citations (45 `\citep{}`); wrapped 27 figures + 17 tables in environments with caption + label; converted 47 figure + 27 table cross-refs to `\ref{}`; appended appendices (were truncated out of first pass); 84-page PDF compiles clean (0 errors, 0 undefined)
- [x] 2026-05-09 — Pivoted from Path A to Path B; pandoc-converted v3 docx, anystyle-parsed bibliography (71 entries), extracted 17 tables, copied 27 figures, compiled clean 54-page PDF
- [x] 2026-05-09 — Mapped 27 figures (12 main + 15 appendix) and 17 tables (9 main + 8 appendix) to local sources
- [x] 2026-05-08 — Built standalone LaTeX scaffold at `doc/dissertation/chapter3/` (compiles clean)
- [x] 2026-05-08 — Initial decision: Path A (wait for final Word); revised 2026-05-09 to Path B
- [x] 2026-03-17 — GDTF v3 copyedit completed; passed to Alex Hurtt
