# TODO — CSAC Project

Last updated: 2026-05-09

## Active (doing now)

(none)

## Up Next (chapter 3 follow-ups)

- [ ] **Fill the "(CITE)" placeholder** on page 4 (Theoretical Background section) — coauthor input needed for the missing citation about academic trajectory
- [ ] **Convert remaining ~16 unmatched citations** by hand — multi-line patterns, corporate authors, anystyle parse failures (~1 hour)
- [ ] **Add `\label{}` to figures and tables**, convert "Figure 3" / "Table A1" cross-refs in prose → `\ref{fig:...}` / `\ref{tab:...}` (~2 hours)
- [ ] **Fix anystyle parse bugs** in `bibliography_all.bib`:
  - `Information, California Legislative` → `California Legislative Information`
  - `No, Exec Order` → `Executive Order` (corporate author)
  - Day 2018 has malformed `note` field
- [ ] **Visual-verify all 17 tables** in compiled PDF — Tables 5/8/9 came from HTML pandoc parse (separate path), worth checking data preservation
- [ ] **Section-level diff against published PDF** for journal copyedits (~2-3 hours)

## Waiting On

- [ ] Final post-copyedit Word version of GDTF paper from coauthor (Alex Hurtt) — at that point, replace v3-converted prose with final-Word version

## Backlog

- [ ] Integrate chapter 3 into `~/github_repos/dissertation_template/` once content is finalized
- [ ] Begin chapter 1 and chapter 2 scaffolding (separate dissertation chapters)
- [ ] Update `dissertation.tex` chapter-3 title and label at integration time
- [ ] Update CLAUDE.md GDTF figure list (currently lists 8 figures; published paper has 12)

## Done (recent)

- [x] 2026-05-09 — Pivoted from Path A to Path B; pandoc-converted v3 docx, anystyle-parsed bibliography (71 entries), extracted 17 tables, copied 27 figures, compiled clean 54-page PDF
- [x] 2026-05-09 — Mapped 27 figures (12 main + 15 appendix) and 17 tables (9 main + 8 appendix) to local sources
- [x] 2026-05-08 — Built standalone LaTeX scaffold at `doc/dissertation/chapter3/` (compiles clean)
- [x] 2026-05-08 — Initial decision: Path A (wait for final Word); revised 2026-05-09 to Path B
- [x] 2026-03-17 — GDTF v3 copyedit completed; passed to Alex Hurtt
