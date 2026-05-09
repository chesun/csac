---
name: dissertation chapter 3 — standalone scaffold
description: Build/integration guide for the GDTF LGBTQ paper as dissertation chapter 3
---

# Chapter 3 — Standalone Scaffold

The GDTF LGBTQ paper ("LGBTQ+ Students' High School Experiences and Academic Plans") will become chapter 3 of Christina Sun's UC Davis Economics dissertation. This directory holds a standalone-compilable LaTeX version that drops cleanly into `~/github_repos/dissertation_template/Chapter3/` when ready to integrate.

## Files

- `chapter3.tex` — **the swap-in artifact.** Bare `\section{}`-level content. No `\documentclass`, no `\chapter{}` wrapper. Copy verbatim to `dissertation_template/Chapter3/chapter3.tex` at integration time.
- `chapter3_standalone.tex` — wrapper that supplies `\documentclass`, title page, `\chapter{}`, and `\printbibliography` for standalone compilation. Do not copy into the dissertation.
- `stylefile.sty` — copy of `dissertation_template/stylefile.sty`. Kept in sync manually; if the dissertation template's stylefile changes, recopy.
- `bibliography_all.bib` — chapter-3 bib entries. Filename matches `stylefile.sty`'s `\addbibresource{bibliography_all.bib}` call. At integration, merge entries into the dissertation's shared `bibliography_all.bib`.
- `Figures/` — chapter figures. Capital `F` matches the dissertation template's `Chapter3/Figures/` convention so paths resolve in both standalone and integrated builds.

## Build

From this directory:

```bash
pdflatex chapter3_standalone.tex
biber chapter3_standalone
pdflatex chapter3_standalone.tex
pdflatex chapter3_standalone.tex
```

Or with `latexmk`:

```bash
latexmk -pdf chapter3_standalone.tex
```

## Path conventions

`chapter3.tex` declares `\graphicspath{{Figures/}{Chapter3/Figures/}}` so `\includegraphics{foo.png}` resolves in:

- **Standalone build** (compiled from this directory): finds `Figures/foo.png`.
- **Integrated build** (compiled from dissertation root): finds `Chapter3/Figures/foo.png`.

No further changes needed to `dissertation.tex` for figures.

## Citation conventions

Use `\citet{key}` for textual citations (e.g., "Smith (2020) shows...") and `\citep{key}` for parenthetical (e.g., "...as shown elsewhere (Smith 2020)"). Both work under:

- **Standalone:** biblatex `style=apa` (inherited from `stylefile.sty`).
- **Integrated:** same — dissertation also uses APA.

(The project's `working-paper-format.md` specifies AEA/Chicago author-date for working papers; the dissertation overrides with APA for committee preferences.)

## Integration checklist (when ready)

1. Copy `chapter3.tex` → `~/github_repos/dissertation_template/Chapter3/chapter3.tex`.
2. Copy `Figures/*` → `~/github_repos/dissertation_template/Chapter3/Figures/`.
3. Merge `bibliography_all.bib` entries into `~/github_repos/dissertation_template/bibliography_all.bib` (append, deduplicate by key).
4. Update `dissertation.tex` chapter-3 title: `\chapter{LGBTQ+ Students' High School Experiences and Academic Plans} \label{chap:ch3}`.
5. Compile dissertation end-to-end to confirm cross-refs and bib resolve.

## Status

Awaiting final Word version from coauthor before content import. v3 draft and published PDF available in `doc/gdtf/`.
