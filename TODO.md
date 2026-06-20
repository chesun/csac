# TODO — CSAC Project

Last updated: 2026-06-20 (code-offboarding scope; CLAUDE.md GDTF figure list corrected to the published 12)

## Active (doing now)

(none)

## Up Next

- [ ] **(Optional) One clean full run of `do do/do_all.do`** to confirm an
      r(0) end-to-end exit. Every stage already ran successfully on the
      server across staged runs; `do_all.do` is restored to all-active with
      the log-close fix. Before the run, upload the restored `do_all.do`
      plus the three server-fixed analysis files: `experiments/sum_stats.do`,
      `experiments/reg_tab.do`, `getting_down_to_facts/cde_demographics.do`.

## Waiting On

- [ ] (none active)

## Backlog

- [ ] (none)

## Done (2026-06-20)

- [x] **Full `do_all.do` pipeline debugged on the server** — ran every stage
      across staged runs; fixed four bugs surfaced live: `first_gen` dup
      (`sum_stats.do`), `primary_eng` typo (`reg_tab.do`), CDE column renames
      (`cde_demographics.do`), and the final `log close` r(606) (`do_all.do`).
      `do_all.do` restored to all-active with the log-close fix.
- [x] **CLAUDE.md GDTF figure list corrected** — replaced the stale
      8-figure draft list with the published 12 figures (new ordering:
      HS-experience regressions by gender/SO, two bullying figures,
      worry regressions by gender then SO, enrollment + degree plans
      last). Captions verified against the published PDF in `doc/gdtf/`.
- [x] **TODO scoped to code offboarding** — removed paper/dissertation
      document tasks (all papers published, dissertation filed).

## Done (2026-06-13)

- [x] **The High School Journal paper accepted** (forthcoming). R2
      submission close-out complete; the prior "submission close-out"
      task block is retired.
- [x] **Offboarding pass**: README expanded with full per-file
      inputs/outputs, project structure, history, external-input
      provenance, and gotchas. Output-path bugs fixed in
      `clean_qualtrics_export.do`, `cde_demographics.do` (incl. latent
      undefined `fall_year`), and `csac_survey_finaid.do`. Status
      updated across README and CLAUDE.md (GDTF3 + finaid brief
      published; THSJ accepted). Coder-critic review: 94/100.

## Done (2026-05-12 end-of-day summary)

### THSJ R2 revision — Christina's portion (Reviewer 2 Comments 1–3)

- [x] **Reviewer comments extracted** from the R2 round-two .docx;
      Christina owns Comments 1–3, Alex owns 4–7
- [x] **Plan drafted** in `quality_reports/plans/2026-05-12_thsj-r2-revisions.md`;
      full table/figure → source-code mapping; resolved 5 open questions
- [x] **`do/thsj_rr/r2_revisions.do`** written + iterated (4 rounds with
      coder-critic, final score 94/100): Section 1 = Table 2 with
      two-sample prtest G-vs-not-G + stars; Section 2 = Table 3 with
      standardized HS-experience index + t-tests vs. cis man;
      Section 3 = Figures 5–8 standardized coefplots in color version
- [x] **Three Stata bugs fixed mid-flight**: `bitesti`/`prtest` r() scalar
      case-sensitivity (`r(p)` lowercase, not `r(P)`); `putdocx table`
      `memtable` option silently orphans tables in memory (produces
      empty docx); `gender_cat` value-label name is mutated by
      upstream code (use `: value label var` to fetch at runtime).
      Captured as new "Common Patterns and Pitfalls" sections in the
      project-scoped `stata` skill at `.claude/skills/stata/SKILL.md`
- [x] **Outputs produced**: `tab/thsj_rr/r2_table2_field_by_gender_stars.docx`,
      `r2_table3_hsexp_standardized.docx`, the audit CSV, 4 PNG figures
      (`r2_fig{5,6,7,8}_*_z_color.png`)
- [x] **Directional-error caught in published manuscript**: Figure 6
      paragraph said "general worries was significantly lower than
      cisgender men" but M1 unconditional regression shows all
      trans/gender expansive groups have POSITIVE coefficients (higher
      worry, not lower). Flagged at top of prose-edits bundle; Edit 10
      proposes the corrected language. Likely a leftover from an
      earlier sign-flipped PCA construct
- [x] **Prose-edits bundle** at `quality_reports/2026-05-12_thsj-r2-prose-edits.md`:
      12 concrete edits + directional-error flag, anchored by search-string,
      ordered top-to-bottom of manuscript. Writer-critic verified 91/100
      → ~99/100 post-fixes (terminology drift "regression sample" →
      "analytical sample"; 3 stylistic tightenings applied)
- [x] **Google Docs equation portability**: rewrote equations using
      minimal-LaTeX (only Latin + basic Greek α β γ δ ε θ + `\sum`);
      switched `\mathbb{1}[gender_i=g]` to `D_{gi}` dummy variables;
      wrapped all 13 math blocks in `$$...$$` (Auto-LaTeX add-on
      requirement, not single `$...$`)
- [x] **All 12 edits + directional-error correction applied** by
      Christina in the Google Doc co-edit with Alex (this session)

### Earlier dissertation work (Ch 3 / GDTF)

The two-day arc on dissertation chapter 3, in roughly chronological commit order:

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
