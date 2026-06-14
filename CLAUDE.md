# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the **CSAC 2023 High School Senior Survey** project — a collaboration between the California Education Lab (UC Davis) and the California Student Aid Commission (CSAC). A single survey wave of California high school graduating seniors (May 2023) is merged with CSAC admin data and CCC admin data to study summer school enrollment and financial aid receipt.

**Research outputs from this survey**:
1. [PACE Brief](https://edpolicyinca.org/publications/transition-college) — transition to college (published)
2. **AEA Papers & Proceedings** — summer school nudge experiment (forthcoming)
3. **The High School Journal** — LGBTQ+ high school experiences (accepted, forthcoming)
4. **Getting Down to Facts III (GDTF3)** — white paper (published)
5. **Financial-aid brief** — co-branded with CSAC (published); standalone code in `do/csac_survey_finaid.do`

**Team**: Christina Sun (CS, `ucsun@ucdavis.edu`), Baiyu Zhou (BZ, `baizhou@ucdavis.edu`)

**Data access**: Raw and cleaned restricted data lives on the remote server only. Local repo contains code, outputs (figs/tabs synced back), and documentation. Files are transferred to/from server via FileZilla (drag and drop).

## Execution Model

All Stata code runs on a **remote Linux research server** — not locally. The workflow is:
1. Edit do files locally
2. Upload to server via SSH
3. Execute on server where data lives

**Server paths** (defined in `do/settings.do`):
```
$csacprojdir     → /home/research/ca_ed_lab/projects/csac_survey2023
$csacrawdatadir  → /home/research/ca_ed_lab/data/restricted_access/raw/csac_survey/2023
$csacclndatadir  → /home/research/ca_ed_lab/data/restricted_access/clean/csac_survey/2023
```

There is no local build/test command — to run code, upload to server and execute in Stata (`do [filename].do`).

## Codebase Architecture

### Directory Structure

```
do/         Stata do files (all executable code)
  clean/      Data cleaning pipeline
  learn/      Analysis and visualization
  experiments/ Summer nudge RCT and admin data analysis (AEA P&P)
  getting_down_to_facts/  GDTF3 white paper analysis (draws on thsj_rr/ and paper_quant_analysis.do)
  thsj_rr/    High School Journal R&R analysis (paper accepted, forthcoming)
  archive/    Legacy code
dta/        Local data files (cleaned outputs synced back from server)
  cln/        Cleaned .dta files
fig/        Output figures (PNG/EPS), mirroring do/ subdirectory structure
tab/        Output tables (CSV, TEX, DOCX, RTF, XLS)
log/        Stata execution logs (.txt, .log, .smcl)
doc/        Documentation, codebooks, papers, presentations
lit/        Survey materials and literature
```

### Execution Pipeline

**Master file**: `do/do_all.do` — controls which scripts run via user toggles:
```stata
global user_cs 1   // Christina Sun's workflow
global user_bz 0   // Baiyu Zhou's workflow
```

**Data pipeline order**:
1. `do/clean/clean_qualtrics_export.do` — raw Qualtrics → cleaned survey data
2. `do/clean/genderso.do` — gender/sexual orientation variable construction
3. `do/clean/prep_brief.do` — prepare main brief dataset
4. `do/experiments/` — summer nudge RCT analysis (AEA P&P)
5. `do/learn/brief.do` — PACE brief figures and tables
6. `do/learn/paper_quant_analysis.do` — quantitative analysis for THSJ and GDTF3
7. `do/thsj_rr/` — High School Journal R&R analysis (figures/tables reused in GDTF3)
8. `do/getting_down_to_facts/gdtf_reg.do` — GDTF3 regressions (also draws on `paper_quant_analysis.do` and `thsj_rr/` outputs)

**Standalone toggle**: Each do file checks `local standalone` — set to `1` to run independently (loads `settings.do` itself), `0` when called from `do_all.do`.

### Key Cleaned Datasets

- `csac_hs_senior_2023_brief.dta` — main analysis dataset
- `csac_hs_senior_2023_genderso.dta` — gender/SO analysis dataset
- `csac_hs_senior_2023_brief_admin.dta` — survey + CSAC admin data merge

### Do File Conventions

**Standard preamble**:
```stata
version 17.0
set more off
set varabbrev off
set graphics off
set scheme s1color
set seed 1984
```

**Output naming**: figures go to `$csacprojdir/fig/[subdir]/[name].png`, tables to `$csacprojdir/tab/[subdir]/[name].[ext]`, logs to `$csacprojdir/log/[name].txt`.

**Variable naming**: snake_case with descriptive prefixes (e.g., `worry_index1`, `hsexp_index`, `gender_queer`, `so_queer`). Global macro lists group related variables (e.g., `global xtab`, `global hsexp`, `global plans`).

**Table export**: uses `esttab` for CSV/TEX regression tables, `asdoc` for Word/RTF output.

## GDTF3 Paper: Tables and Figures Reference

**Title**: "Navigating the Transition to College: LGBTQ+ Students' High School Experiences and Academic Plans"
**Authors**: Christina Sun, Alexandria Hurtt, Michal Kurlaender
**Paper files**: `doc/gdtf/GDTF LGBTQ paper - formatted.docx` (clean), `doc/gdtf/GDTF LGBTQ paper - formatted kjc.docx` (with reviewer comments)

The paper examines LGBTQ+ students' high school experiences and college expectations using the May 2023 survey (n=9,230). Key analytical dimensions: gender identity (cisgender, transgender, nonbinary, gender diverse/questioning) and sexual orientation.

### Tables in paper
- **Table 1**: Summary statistics — demographics (gender identity, sexual orientation, race/ethnicity, parental education)
- **Table 2**: Intended field of study by gender identity (row percentages)
- **Tables 3-4**: Logit models — intent to attend 4-year college, by gender identity (Table 3) and sexual orientation (Table 4); unconditional + demographic controls
- **Tables 5-6**: Ordered logit models — highest degree plans, by gender identity (Table 5) and sexual orientation (Table 6)
- **Table 7**: General high school experience index by gender identity
- **Table 8**: College concern items and PCA results (12 worry items → 3 constructs: general worries, discrimination worries, financial burden worries)
- **Table A1**: Two-way tabulation of gender identity × sexual orientation
- **Table A2**: CDE 12th grade enrollment summary statistics (state comparison)
- **Appendices B-D**: High school experience and college concern items by gender identity (detailed means)
- **Appendix E**: Summary statistics of qualitative response sample

### Figures in paper
- **Figure 1**: Plans for college enrollment (2-year vs 4-year by gender identity)
- **Figure 2**: Plans for degree completion (highest degree by gender identity)
- **Figure 3**: Regression of overall high school experience on gender identity (coefficient plot, unconditional + controls)
- **Figure 4**: Frequency of bullying/harassment in past year (by gender identity and sexual orientation)
- **Figure 5**: Bullying attributed to gender identity or sexual orientation (by gender identity and sexual orientation)
- **Figures 6-8**: Regression coefficient plots of college worries on gender identity:
  - Figure 6: General college worries
  - Figure 7: Worries about discrimination
  - Figure 8: Worries about financial burdens

### Key analytical methods
- **PCA**: Used for both high school experience (1 construct) and college worries (3 constructs: general, discrimination, financial)
- **OLS regressions**: Worry constructs on gender identity, with/without demographic controls + HS experience index
- **Logit/ordered logit**: 4-year enrollment intent and degree aspirations by gender identity and sexual orientation
- **Qualitative**: Open-ended responses on biggest college challenge and excitement (trans/gender expansive students only)
