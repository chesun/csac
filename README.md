# CSAC 2023 High School Senior Survey

> **Part of the [CEL Resource Hub](https://christinasun.net/cel_resource_hub/)** — Christina Sun's index of CEL code handoffs plus setup and workflow guides for inheriting them. Hub page for this repo: <https://christinasun.net/cel_resource_hub/repositories/csac/>.

Code, outputs, and documentation for the **2023 California high school senior survey** project, a collaboration between the California Education Lab (UC Davis) and the California Student Aid Commission (CSAC).

A single survey wave was fielded to graduating California high school seniors in **May 2023**. The survey is merged with CSAC administrative data and California Community Colleges (CCC) administrative data to study the college transition, summer-school enrollment, and financial aid.

**Team:** Christina Sun (CS, `ucsun@ucdavis.edu`) and Baiyu Zhou (BZ, `baizhou@ucdavis.edu`).

**CS Offboarding:** Entire code pipeline ran successfully June 20, 2026. README finalized. Project offboarding complete June 21, 2026.

---

## Research outputs

This survey supports five outputs:

| Output | Status | Code lives in |
|---|---|---|
| [PACE brief](https://edpolicyinca.org/publications/transition-college) — transition to college | Published | `do/clean/`, `do/learn/` |
| AEA Papers & Proceedings — summer-school nudge RCT | Published | `do/experiments/` |
| The High School Journal — LGBTQ+ high school experiences | Accepted, forthcoming | `do/learn/`, `do/thsj_rr/` |
| Getting Down to Facts III (GDTF3) white paper | Published | `do/getting_down_to_facts/` |
| Financial-aid brief (co-branded with CSAC) | Published | `do/csac_survey_finaid.do` |

The GDTF3 analysis was also adapted into CS's dissertation Chapter 3. `do/getting_down_to_facts/gdtf_latex_tables.do` produces the LaTeX table fragments for that chapter.

## Project history (brief)

- **Mid-2023** — Survey fielded May 2023. Cleaning pipeline and codebook written by CS and BZ (`do/settings.do` dated 2023-07-05). Initial descriptive work feeds the PACE brief.
- **Late 2023 – 2024** — Gender/sexual-orientation analysis built out (`genderso.do`, `paper_quant_analysis.do`). Betsey Friedmann adds a standalone financial-aid analysis (`csac_survey_finaid.do`, April 2024).
- **2024–2025** — Summer-school nudge RCT analysis: survey data merged with CSAC and CCC admin data (`do/experiments/`), written up for AEA P&P.
- **2025–2026** — The High School Journal paper accepted (forthcoming) after two R&R rounds (`do/thsj_rr/`); GDTF3 white paper published, and adapted into dissertation Chapter 3 (`do/getting_down_to_facts/`).
- **2026-05-31** — `do_all.do` consolidated into a single end-to-end pipeline. Removed the per-user toggle and absorbed the former `do_all_baiyu.do` (now in `do/archive/`); nothing was dropped in the merge.

---

## Execution model

All Stata code runs on a **remote Linux research server**, not locally. Restricted data lives on the server only; the local repo holds code, synced-back outputs (figures and tables), and documentation. File transfer is via FileZilla.

Workflow: edit do files locally, upload to the server, run in Stata (`do <filename>.do`). There is no local build or test command.

Server paths are defined in `do/settings.do`:

```stata
global csacprojdir    "/home/research/ca_ed_lab/projects/csac_survey2023"
global csacrawdatadir "/home/research/ca_ed_lab/data/restricted_access/raw/csac_survey/2023"
global csacclndatadir "/home/research/ca_ed_lab/data/restricted_access/clean/csac_survey/2023"
global cccrawdatadir  "/home/research/ca_ed_lab/data/restricted_access/raw/ccc"
global cccclndatadir  "/home/research/ca_ed_lab/data/restricted_access/clean/ccc"
```

### Running the full pipeline

`do/do_all.do` runs everything start to finish:

```stata
do do/do_all.do
```

It sets the working directory, sources `do/settings.do`, opens a master log (`log/do_all.smcl` → `log/do_all.txt`), and runs the five stages below in order. The first time you run it on a fresh checkout, set `local mkdir 1` near the top to create the output folders.

---

## Repository structure

```
do/                       Stata do files (all executable code)
  do_all.do                 Master pipeline — runs everything in order
  settings.do               Global path macros (server paths)
  clean/                    Data-cleaning pipeline
  learn/                    PACE brief + gender/SO paper analysis
  experiments/              Summer-nudge RCT (AEA P&P): survey + CSAC + CCC admin
  thsj_rr/                  The High School Journal R&R analysis
  getting_down_to_facts/    GDTF3 / dissertation Chapter 3 analysis
  csac_survey_finaid.do     Standalone financial-aid brief (not in do_all.do)
  archive/                  Legacy / superseded code (not run)
  resources/                Reference scripts (not run)
dta/                      Local data (.dta live on server; only synced exports here)
  cln/                      Cleaned datasets (on server)
fig/                      Output figures (PNG/EPS), mirroring do/ subdirs
tab/                      Output tables (CSV, TEX, DOCX, RTF, XLS)
log/                      Stata execution logs
doc/                      Codebooks, papers, presentations, survey instruments
lit/                      Survey materials and literature
```

Note: the repo also contains Claude Code workflow scaffolding (`.claude/`, `quality_reports/`, `templates/`, `master_supporting_docs/`, `CHANGELOG.md`, `SESSION_REPORT.md`). These are AI-assistant tooling, not part of the survey analysis, and can be ignored by a researcher onboarding to the data work.

---

## The pipeline, file by file

Paths below use the `do/settings.do` globals. Inputs marked **[external]** are not produced by any code in this repo — see [External inputs](#external-inputs).

### Stage 1 — Data cleaning (`do/clean/`)

| File | Purpose | Inputs | Outputs |
|---|---|---|---|
| `clean_qualtrics_export.do` | Import raw Qualtrics export; rename, recode, and label all variables; strip PII | `$csacrawdatadir/csac_hs_senior_2023_export_07_05_2023.csv` **[external]** | `csac_hs_senior_2023_clean.dta` (saved to **both** `$csacclndatadir/` and `$csacprojdir/dta/cln/`); `$csacrawdatadir/csac_hs_senior_2023_id_xwalk.dta`; log |
| `create_codebook.do` | Export an Excel codebook of the cleaned data | `$csacclndatadir/csac_hs_senior_2023_clean.dta` | `doc/codebook.xls` |
| `prep_brief.do` | Restrict to HS seniors; build race/gender/SO dummy and categorical variables | `$csacprojdir/dta/cln/csac_hs_senior_2023_clean.dta` (see handoff note below) | `$csacprojdir/dta/cln/csac_hs_senior_2023_brief.dta`; log |
| `genderso.do` | Detailed gender/SO categorization for the LGBTQ+ paper; export quant + qual datasets | `$csacprojdir/dta/cln/csac_hs_senior_2023_brief.dta` | `csac_hs_senior_2023_genderso.dta`; `..._genderso_qual.dta`; gender/SO codebooks; `tab/learn/genderso/*.xls`; log |

> **Handoff note:** `prep_brief.do` reads the cleaned data from `$csacprojdir/dta/cln/`, while `create_codebook.do` reads it from `$csacclndatadir/`. `clean_qualtrics_export.do` therefore saves to **both** locations so every downstream reader resolves. (`genderso.do` reads `..._brief.dta`, not the clean file.)

### Stage 2 — PACE brief + gender/SO paper (`do/learn/`)

| File | Purpose | Inputs | Outputs |
|---|---|---|---|
| `brief.do` | Descriptive crosstabs and stacked-bar figures by demographics (PACE brief) | `csac_hs_senior_2023_brief.dta` | `fig/learn/brief/*.png`; log |
| `expression.do` | Tabulate and export raw gender/SO open-text responses (word-cloud input) | `csac_hs_senior_2023_brief.dta` | `tab/learn/genderso/expression_raw.xls`; log |
| `paper_quant_analysis.do` | Cronbach's alpha, PCA (3 worry constructs), index construction, regressions, coefplots | `csac_hs_senior_2023_genderso.dta` | `csac_hs_senior_2023_genderso_constructs.dta`; summary-stat tables (`tab/share/`); `fig/learn/reg/*.png`, `fig/learn/fn_form/*.png`; log |
| `qual_export.do` | Export open-ended college responses for qualitative coding | `csac_hs_senior_2023_genderso.dta` | `dta/open_response_lgbtq.csv` |

> **Key intermediate:** `paper_quant_analysis.do` produces `csac_hs_senior_2023_genderso_constructs.dta` (adds `worry_index1/2/3`, `hsexp_index`, and consolidated gender/SO variables). The THSJ and GDTF3 scripts depend on it, so this file must run before Stages 4 and 5.

### Stage 3 — Summer-school nudge RCT (`do/experiments/`)

Merges survey data with CSAC admin data and CCC admin data. Run in this order:

| File | Purpose | Inputs | Outputs |
|---|---|---|---|
| `make_csac_data.do` | Keep survey records that matched CSAC admin | `csac_hs_senior_2023_brief_admin.dta` **[external]** | `csac_admin.dta`; log |
| `clean_ccc.do` | Build SSN↔college/student-ID crosswalk; collapse CCC enrollment and aid to individual level | `$cccrawdatadir/HF_FIRST.dta`, `$cccclndatadir/SX_yearcollapsed`, `$cccclndatadir/SFA_Collapsed_year` **[external]** | `ccc_ssn_id_xwalk.dta`; `sx_2023_indiv_level.dta`; `sfa_2023_indiv_level.dta`; log |
| `merge_ccc.do` | Merge survey to CCC enrollment/aid via SSN | `csac_hs_senior_2023_brief_admin.dta` **[external]**; `ccc_xwalk_winnie.dta` **[external]**; `sx_2023_indiv_level.dta`; `sfa_2023_indiv_level.dta` | `csac_survey_ccc_merged.dta`; `csac_survey_noxwalk.dta`; log |
| `clean_csac_admin.do` | Clean CSAC financial-aid variables (income, EFC, Cal Grant, first-gen) | `csac_survey_ccc_merged.dta` | `csac_survey_ccc_merged_clean.dta` (final RCT analysis dataset); log |
| `explore_rct.do` | Exploratory crosstabs / t-tests on treatment effects | `csac_survey_ccc_merged_clean.dta` | `fig/experiments/*.png`; log |
| `sum_stats.do` | Treatment/control balance table | `csac_survey_ccc_merged_clean.dta` | `tab/experiments/sum_stats.{tex,csv}`; log |
| `reg_tab.do` | Main regression tables (summer enrollment, units, GPA) | `csac_survey_ccc_merged_clean.dta` | `tab/experiments/reg_main.{tex,csv}`; log |
| `reg_share.do` | Final regression results with robust SEs and balance tests | `csac_survey_ccc_merged_clean.dta` | log |
| `het.do` | Heterogeneity by 2yr/4yr, Pell status, baseline intent | `csac_survey_ccc_merged_clean.dta` | `fig/experiments/het_coef.{png,eps}`; log |

Helper: `int_gen_year_term.doh` parses a 3-digit CCC term ID into year and term (`include`-style helper).

### Stage 4 — The High School Journal R&R (`do/thsj_rr/`)

Some R&R changes were also implemented in `paper_quant_analysis.do`.

| File | Purpose | Inputs | Outputs |
|---|---|---|---|
| `check_csac_data.do` | Audit CSAC admin data availability for LGBTQ+ students | `csac_hs_senior_2023_genderso.dta`; `csac_admin.dta` | log |
| `hsexp_worry_tab.do` | HS-experience and worry-item tables by gender/SO | `csac_hs_senior_2023_genderso.dta` | `tab/thsj_rr/*.docx`; log |
| `qual_demo_tab.do` | Demographics table for the qualitative subsample | `csac_hs_senior_2023_genderso.dta` | `tab/thsj_rr/qual_sample_demo.doc`; log |
| `r2_revisions.do` | Round-2 reviewer comments 1–3: starred Table 2, standardized Table 3, Figures 5–8 | `csac_hs_senior_2023_genderso_constructs.dta` | `tab/thsj_rr/r2_table{2,3}_*.docx` + audit CSV; `fig/thsj_rr/r2_fig{5,6,7,8}_*.png`; log |
| `r2_worry_coefs.do` | Print standardized worry-index regression coefficients for prose edits | `csac_hs_senior_2023_genderso_constructs.dta` | `tab/thsj_rr/r2_worry_coefs_table.txt`; log |

### Stage 5 — Getting Down to Facts III (`do/getting_down_to_facts/`)

| File | Purpose | Inputs | Outputs |
|---|---|---|---|
| `cde_demographics.do` | Clean CDE 2022-23 annual enrollment; demographic summary stats (state comparison) | `$csacprojdir/dta/raw/enr202022.txt` **[external]** | `$csacprojdir/dta/cln/cde/enr_2023_clean.dta`; log |
| `gdtf_reg.do` | Logit (4yr intent) and ordered logit (degree plans) by gender/SO; predicted-probability stacked bars | `csac_hs_senior_2023_genderso.dta` | `tab/getting_down_to_facts/*.{rtf,csv}`, some to `tab/thsj_rr/`; `fig/getting_down_to_facts/*.png`; log |
| `gdtf_adhoc.do` | Reviewer questions on "Other" write-in rates for gender/SO | `csac_hs_senior_2023_genderso_constructs.dta` | log |
| `gdtf_latex_tables.do` | Bare LaTeX `tabular` fragments for dissertation Chapter 3 (personal/non-production) | `csac_hs_senior_2023_genderso_constructs.dta` | `tab/dissertation_chapter3/*.tex`; log |

---

## Key datasets

### Produced by the pipeline (intermediates)

| Dataset | Produced by | Used by |
|---|---|---|
| `csac_hs_senior_2023_clean.dta` | `clean_qualtrics_export.do` | `create_codebook.do`, `prep_brief.do` |
| `csac_hs_senior_2023_brief.dta` | `prep_brief.do` | `brief.do`, `expression.do`, `genderso.do` |
| `csac_hs_senior_2023_genderso.dta` | `genderso.do` | `paper_quant_analysis.do`, `qual_export.do`, `thsj_rr/`, `gdtf_reg.do`, `check_csac_data.do` |
| `csac_hs_senior_2023_genderso_constructs.dta` | `paper_quant_analysis.do` | `r2_revisions.do`, `r2_worry_coefs.do`, `gdtf_adhoc.do`, `gdtf_latex_tables.do` |
| `csac_survey_ccc_merged_clean.dta` | `clean_csac_admin.do` | all `experiments/` analysis files |
| `csac_admin.dta` | `make_csac_data.do` | `check_csac_data.do` |

### External inputs

These are **required** but produced outside this repo. Provenance is recorded as the code comments state; verify before a fresh run.

| Input | What it is | Provenance |
|---|---|---|
| `csac_hs_senior_2023_export_07_05_2023.csv` | Raw Qualtrics survey export (the survey itself) | CSAC / Qualtrics |
| `csac_hs_senior_2023_brief_admin.dta` | Survey merged with CSAC admin data | Comment in `make_csac_data.do:12`: "Jaime's dataset." *Confirm with Jaime.* |
| `ccc_xwalk_winnie.dta` | Survey-ID ↔ CCC student-SSN crosswalk | Comment in `merge_ccc.do:22`: "winnie xwalk." *Confirm with Winnie.* |
| `HF_FIRST.dta`, `SX_yearcollapsed`, `SFA_Collapsed_year` | CCC enrollment header + cleaned enrollment/aid by college-student-year | CCC admin data (`$cccrawdatadir`, `$cccclndatadir`). The CCC-cleaning logic is documented in `do/resources/DataCleaning.do` (reference only). *Confirm who maintains the cleaned CCC files.* |
| `enr202022.txt` | CDE annual enrollment, 2022-23 | California Department of Education public data |

---

## Standalone and non-pipeline files

- **`do/csac_survey_finaid.do`** — Financial-aid brief by Betsey Friedmann (April 2024), a short brief by EFC and college segment co-branded with CSAC (published). Not run by `do_all.do`. Reads `csac_hs_senior_2023_brief_admin.dta`; produces crosstabs plus `fig/finaid/Loan_ten.png` and `fig/finaid/Loan_fifty.png`. It defines its own `$main` global instead of sourcing `settings.do`.
- **`do/archive/`** — Legacy and superseded code, including the former `do_all_baiyu.do` (now absorbed into `do_all.do`) and earlier exploratory scripts and word-cloud helpers. Not run.
- **`do/csac_survey_finaid_analysis_bf.do`, `do/csac_survey_finaid_cleaning_bf.do`** — Earlier (Aug 2023) drafts superseded by `csac_survey_finaid.do`. Not run.
- **`do/resources/DataCleaning.do`** — Reference script documenting how the raw CCC Chancellor's Office files are cleaned. Not run; kept for data-provenance documentation.

---

## Gotchas for the next person

- **`paper_quant_analysis.do` must run before THSJ/GDTF3.** It produces the `_constructs.dta` those stages depend on. `do_all.do` already orders this correctly; preserve it if you reorganize.
- **`csac_survey_finaid.do` is self-contained.** It does not source `settings.do` (defines its own `$main`). Run it on its own, not through `do_all.do`.
- **`gdtf_reg.do` writes some outputs to `tab/thsj_rr/`** (not only `tab/getting_down_to_facts/`).
- **Network packages.** `do_all.do` and a few cleaning scripts call `ssc install` (e.g., `ngram`, `codebookout`). The server needs internet access on first run, or pre-install the packages.
- **Stata version.** Authored against Stata 17; Server version is Stata 18, code is forward compatible.
