# THSJ R2 — Proposed Prose Edits for Google Doc

**For:** Christina + Alex co-edit
**Source paper:** `doc/thsj_final_revision/THSJ - Main Document Manuscript-Revised.docx`
**Date:** 2026-05-12

Edits are ordered **top-to-bottom of the manuscript** for clean serial application. Each block has: (1) a unique **anchor string** (search Google Doc for that phrase to locate), (2) a **change type** (REPLACE / INSERT AFTER / UPDATE), (3) before/after text, and (4) a brief rationale.

Numbering follows the reviewer's comment IDs (1, 2, 3) where applicable.

---

## EDIT 1 — Methods § Data Analysis — INSERT new paragraph with equations

**Reviewer comment served:** #3 (equations for the regression coefplots).

**Anchor:** find the paragraph ending with this sentence (currently in the §Quantitative Analysis subsection):

> "Alternative functional forms for the high school experience variable were also tested." (currently footnote 5)

That paragraph ends with "we include it as a linear continuous variable in the regression model." **INSERT the following new paragraph immediately after that sentence**, before the §Qualitative Analysis subheading begins.

**Insert (new paragraph):**

> To estimate differences in standardized outcomes by gender identity, we estimate two ordinary least squares specifications. Let $$Y_i^z$$ denote the standardized outcome for individual $$i$$ (mean 0, standard deviation 1 in the analytical sample), and let $$D_{gi}$$ be a binary indicator equal to 1 if individual $$i$$ is in gender group $$g$$ and 0 otherwise, with cisgender man omitted as the reference category. Specification (1) is unconditional:
>
> $$Y_i^z = \alpha + \sum_g \beta_g D_{gi} + \epsilon_i$$
>
> Specification (2) adds demographic controls. When the outcome is the high-school-experience index (Figure 5), specification (2) is:
>
> $$Y_i^z = \alpha + \sum_g \beta_g D_{gi} + \gamma R_i + \delta P_i + \epsilon_i$$
>
> where $$R_i$$ is a vector of race/ethnicity indicators and $$P_i$$ is a vector of parental-education indicators. When the outcome is a college-worry index (Figures 6–8), specification (2) additionally controls for the standardized high-school-experience index $$H_i^z$$:
>
> $$Y_i^z = \alpha + \sum_g \beta_g D_{gi} + \gamma R_i + \delta P_i + \theta H_i^z + \epsilon_i$$
>
> Each $$\beta_g$$ is the difference in the standardized outcome relative to cisgender men, expressed in standard-deviation units.

**Rationale:** Reviewer 2 asked us to write out the equations producing the coefplot coefficients. This paragraph fits cleanly in §Quantitative Analysis after the existing PCA / index construction discussion. The two-equation structure makes the controls asymmetry between Figure 5 and Figures 6–8 transparent.

**Notation choices (deliberate, to keep the equations renderable in Google Docs):**
- $$D_{gi}$$ used instead of $$\mathbb{1}[\text{gender}_i = g]$$ — Google Docs' Auto-LaTeX add-on and built-in equation editor both struggle with `\mathbb{}` and bracket-style indicator notation. Plain dummy variables are equivalent and render cleanly.
- $$\epsilon$$ instead of $$\varepsilon$$, no primes on $$\gamma$$ or $$\delta$$, no `\text{}` wrappers, no `\cdot`. All symbols are basic Greek letters or Latin variables that render in any LaTeX engine.

**Note for Alex (paste workflow):** the Auto-LaTeX Equations add-on requires `$$...$$` delimiters (not single `$...$`). All math in this Edit 1 is wrapped accordingly. In Google Docs, paste the whole paragraph as plain text (`Cmd+Option+Shift+V`), then run `Add-ons → Auto-LaTeX Equations → Render Equations` once — every `$$...$$` block becomes a rendered equation in place.

---

## EDIT 2 — Findings § Academic Plans → Table 2 — UPDATE the Note

**Reviewer comment served:** #1 (significance stars on Table 2).

**Anchor:** Table 2's *Note* paragraph (currently a single sentence below the table):

> "Note. The rates depicted represent 7,499 respondents who indicated their intended field of study. Each cell represents the row percentage."

**Replace with:**

> "Note. The rates depicted represent 7,499 respondents who indicated their intended field of study. Each cell represents the row percentage. Stars indicate two-sample tests of proportions comparing each gender group's rate of a given field to the rate among the remaining respondents: * p<0.10, ** p<0.05, *** p<0.01. P-values use the asymptotic normal approximation; for transgender women (n=20), transgender men (n=59), and gender diverse/questioning (n=71), p-values should be interpreted with caution where expected cell counts are small."

**Also:** replace the current Table 2 in the Google Doc with the contents of `tab/thsj_rr/r2_table2_field_by_gender_stars.docx` (or copy/paste the populated cells from that file into the existing table).

**Rationale:** Stars per cell come from two-sample tests of proportions (G vs. not-G), computed from microdata; "All respondents" row is the marginal proportion. The small-N caveat is a standard footnote for asymptotic tests in small subsamples.

---

## EDIT 3 — Findings § High School Experiences — UPDATE the magnitudes paragraph

**Reviewer comment served:** #2 (Table 3 standardization + t-tests) and #3 (SD-unit magnitudes throughout).

**Anchor:** the paragraph beginning with:

> "Students were also asked about their academic and social experiences in high school. We constructed an index for these experiences and compared average high school experiences by gender identity."

**Replace the current paragraph (which describes the −12 to 12 raw scale and prose-level comparison) with:**

> Students were also asked about their academic and social experiences in high school. We constructed an index based on a series of survey items capturing students' academic, social, advising, and college-preparation experiences (see Appendix B for the items). For interpretability, we standardize this index over the analytical sample (mean 0, standard deviation 1) and report differences in standard-deviation units. In Table 3, we present the average standardized high school experience for each gender identity, along with the difference relative to cisgender men. Cisgender men report the most positive high school experiences, scoring approximately 0.10 standard deviations above the sample mean. By contrast, transgender and gender expansive students report less positive experiences: nonbinary students score about 0.45 standard deviations below cisgender men (p<0.001), transgender men score about 0.43 standard deviations below (p=0.001), and gender diverse/questioning students score about 0.73 standard deviations below (p<0.001) — the largest gap in our sample. Transgender women score 0.40 standard deviations below cisgender men, although this estimate is more imprecise (p=0.073) due to the small subsample (n=20). We plotted these differences in Figure 5; they are statistically significant and robust to the inclusion of demographic controls. While not causal, these results indicate an association between gender identity and high-school experiences, which we then consider in later analyses.

**Rationale:** Drops the "−12 to 12 raw scale" framing and replaces it with SD-unit magnitudes drawn directly from the new Table 3 regression. Numbers are pulled from `do/thsj_rr/r2_revisions.do` log output. Preserves the existing transition into Figure 5 and the causal-claim hedge that follows.

---

## EDIT 4 — Table 3 — REPLACE table contents + Note

**Reviewer comment served:** #2.

**Anchor:** Table 3's existing body (5 rows × 8 cells of raw means) and the existing *Note*:

> "Note. The general high school experience index only applies to students who reported non-missing values for all six high school experience items and ranges from -12 to 12 (negative values indicate a negative experience, positive values indicate a positive experience, and zero indicates a neutral experience). High school experience items are available in Appendices B and C."

**Action:** Replace the existing 2-column raw-means table with the 5-column standardized table in `tab/thsj_rr/r2_table3_hsexp_standardized.docx`. Columns are: Gender (label), N, Std. mean, Diff. vs. cis man, Stars.

**Replace the Note with:**

> "Note. The general high school experience index has been standardized to mean 0 and standard deviation 1 over the analytical sample (n = 7,483; raw mean = 3.84, raw SD = 4.30). Standardized means by gender identity are reported in column 3. Column 4 reports the difference in standard-deviation units relative to cisgender men, estimated via OLS regression with cisgender man as the omitted reference category. Stars indicate t-tests of the difference: * p<0.10, ** p<0.05, *** p<0.01. High school experience items are available in Appendices B and C."

**Rationale:** Standardized scale (0 mean, 1 SD) per the reviewer's recommendation; reference category is cisgender men per the reviewer's suggested setup. The raw mean and SD are reported in the Note so readers can convert back to the original units if needed.

---

## EDIT 5 — Figure 5 — UPDATE the Note

**Reviewer comment served:** #3.

**Anchor:** Figure 5's existing Note:

> "Note. For the unconditional model, *n* = 7,483. For the model controlling for demographics (race/ethnicity and parental level of education), *n* = 7,464. The lines indicate 95 percent confidence intervals while the sample frequency and mean index of each gender identity are reported in parentheses. The vertical line at 0 represents the coefficient for the reference group (cisgender man)."

**Replace with:**

> "Note. The outcome is the standardized general high school experience index (mean 0, standard deviation 1 over the analytical sample). For the unconditional model, *n* = 7,483. For the model controlling for demographics (race/ethnicity and parental level of education), *n* = 7,464. The lines indicate 95 percent confidence intervals; the sample frequency and standardized mean for each gender identity are reported in parentheses. The vertical line at 0 represents the coefficient for the reference group (cisgender man). Coefficients are interpretable in standard-deviation units. See the §Quantitative Analysis subsection for the regression specifications."

**Action:** Replace the existing Figure 5 image with `fig/thsj_rr/r2_fig5_hsexp_z_color.png`.

**Rationale:** Outcome now standardized; clarifies units for the reader; adds back-reference to the new equations paragraph in Methods.

---

## EDIT 6 — Methods footnote 9 — UPDATE

**Reviewer comment served:** #2.

**Anchor:** Footnote 9 (currently after the HS Experiences paragraph):

> "9. The high school experience index was constructed by adding the values of each item. All items range from -2 to 2, with -2 indicating a very negative experience, 2 indicating a very positive experience, and 0 indicating a neutral experience. The construct of the overall high school experience ranges from -12 to 12 and applies to students who reported non-missing values for all six high school experience items. For survey items overall and by gender identity, see Appendices B and C."

**Append at the end (do not delete the existing content):**

> "For analysis purposes in Table 3 and Figures 5–8, we standardize this index to mean 0 and standard deviation 1 over the analytical sample."

**Rationale:** The raw construction (−12 to 12 sum of items) is still factually correct and worth describing. The standardization step is what we apply for analytical interpretability — adding one sentence at the end keeps the construction history intact while documenting the standardization.

---

## EDIT 7 — Findings § Concerns About College Experiences — light wording update (worry-figure intro)

**Reviewer comment served:** #3 (extends standardization to Figures 6–8 per "the other coefplots").

**Anchor:** the paragraph beginning:

> "Figures 6 through 8 present ordinary least squares (OLS) regression estimates for each component of worry by gender identity both with and without controls for high school experiences and demographics. In all regressions, *cisgender men* was set as the baseline comparison category. The point estimates represent the difference in a component of worry for each gender identity relative to cisgender men. The blue dots show the point estimates of the unconditional OLS estimates, while the yellow dots indicate OLS estimates that include race/ethnicity indicators, parental education indicators, and the constructed high school experience index as covariates."

**Replace with:**

> "Figures 6 through 8 present ordinary least squares (OLS) regression estimates for each component of worry by gender identity, with each worry construct standardized to mean 0 and standard deviation 1 over the analytical sample. In all regressions, *cisgender men* was set as the baseline comparison category, so point estimates represent the difference (in standard-deviation units) for each gender identity relative to cisgender men. The blue dots show the unconditional OLS estimates, while the yellow dots indicate OLS estimates that include race/ethnicity indicators, parental education indicators, and the standardized high school experience index as covariates."

**Rationale:** Adds the standardization clause and clarifies SD units. The existing "blue dots / yellow dots" color guide is preserved (matches the aggieblue + aggiegold coefplot palette).

---

## EDIT 8 — Figures 6, 7, 8 — UPDATE the three Notes (parallel changes)

**Reviewer comment served:** #3.

**Anchor:** each of the three figure Notes currently begins:

> "Note. We estimate regression models with gender indicators for an unconditional model (*n* = 7,319) and include race/ethnicity indicators, parental education indicators, and a constructed high school experience index as covariates for the specification with control variables (*n* = 7,276). The lines indicate 95 percent confidence intervals while the sample frequency and mean for each gender identity are reported in parentheses. The vertical line at 0 represents the coefficient for the reference group (cisgender man)."

**Replace each (Figures 6, 7, 8) with the same edit:**

> "Note. The outcome is the standardized worry construct (mean 0, standard deviation 1 over the analytical sample). We estimate regression models with gender indicators for an unconditional model (*n* = 7,319) and include race/ethnicity indicators, parental education indicators, and the standardized high school experience index as covariates for the specification with control variables (*n* = 7,276). The lines indicate 95 percent confidence intervals; the sample frequency and standardized mean for each gender identity are reported in parentheses. The vertical line at 0 represents the coefficient for the reference group (cisgender man). Coefficients are interpretable in standard-deviation units."

**Action:** Replace the three figure images with:

- Figure 6 → `fig/thsj_rr/r2_fig6_worry_index1_z_color.png`
- Figure 7 → `fig/thsj_rr/r2_fig7_worry_index2_z_color.png`
- Figure 8 → `fig/thsj_rr/r2_fig8_worry_index3_z_color.png`

**Rationale:** Same standardization clause for all three worry figures; consistent with Figure 5's new Note.

---

## EDIT 9 — Table 4 — light Note addition (PCA construct ranges still raw)

**Reviewer comment served:** #3 (consistency between Table 4's raw scales and the standardized scales used in Figures 6–8).

**Anchor:** the end of Table 4's current Note:

> "Constructs were only created for high school students that reported non-missing values for all twelve items. The PCA proportion explained is reported in parentheses after each construct. For college concern items by gender identity, see Appendix D."

**Append:**

> "For analysis purposes in Figures 6–8, we standardize each construct to mean 0 and standard deviation 1 over the analytical sample."

**Rationale:** The raw PCA construct ranges (`general worries` 0 to 10.23, `discrimination` −3.83 to 5.12, etc.) remain factually correct and worth keeping in Table 4 as the construct summary. One sentence flags that the figures present standardized versions.

---

## ⚠️ IMPORTANT — directional error in current manuscript (please verify)

While extracting SD-unit magnitudes for Edits 10–12 below, I noticed the **Figure 6 discussion paragraph in the current manuscript contradicts the regression output**. The current text says:

> "the general worries of transgender men, transgender women, and nonbinary or gender questioning students **was significantly lower than cisgender men**"

But the unconditional M1 regression shows trans/gender expansive groups all have **HIGHER** (positive) coefficients vs. cisgender men:

| Group | M1 coef (SD) | t | p |
|---|---|---|---|
| Cisgender woman | +0.42 | 17.3 | <0.001 |
| Transgender man | +0.77 | 6.0 | <0.001 |
| Transgender woman | +0.42 | 1.95 | 0.051 |
| Nonbinary | +0.95 | 15.0 | <0.001 |
| Gender diverse/questioning | +1.06 | 9.0 | <0.001 |
| Prefer not to say | +0.78 | 9.3 | <0.001 |

This is also consistent with the immediately *preceding* paragraph in the manuscript:

> "we find trans and gender expansive students experience a **higher** level of general worries compared to cisgender students"

So the "significantly lower" sentence is almost certainly a leftover error from an earlier sign-flipped PCA construct. Edit 10 below treats it as a correction. **Please sanity-check Figure 6 visually before merging** — if the figure shows the points to the RIGHT of zero (positive coefficients), the text needs to read "higher" not "lower."

---

## EDIT 10 — Findings § Concerns About College Experiences — Figure 6 paragraph (general worries) — REPLACE with corrected text + SD magnitudes

**Reviewer comment served:** #3 (SD-unit magnitudes throughout) + opportunistic correction of the directional error above.

**Anchor:**

> "Regression estimates for general college worries on gender identity categories are presented in Figure 6. Among trans and gender expansive students, we find no statistical differences in general worries between different gender identities. That is, the general worries of transgender men, transgender women, and nonbinary or gender questioning students was significantly lower than cisgender men, but not significantly different from each other."

**Replace with:**

> "Regression estimates for general college worries on gender identity categories are presented in Figure 6. Trans and gender expansive students report significantly higher general worries than cisgender men, with differences ranging from about 0.42 standard deviations for transgender women (p=0.051) to about 1.06 standard deviations for gender diverse/questioning students (p<0.001). Cisgender women, transgender men, nonbinary students, and students who preferred not to disclose their gender identity all fall within this range and are also significantly different from cisgender men. Across trans and gender expansive subgroups, these differences are not statistically distinguishable from each other (overlapping 95% confidence intervals). The pattern is robust to controls for demographics and standardized high school experience."

**Rationale:** Corrects the "lower / higher" directional error; replaces "no statistical differences in general worries between different gender identities" with the more accurate framing that the differences across trans subgroups are not statistically distinguishable but each is significantly different from cis men. Adds SD-unit magnitudes drawn from the M1 regression output (log lines 660–700 of `log/thsj_rr/r2_worry_coefs.txt`).

---

## EDIT 11 — Findings § Concerns About College Experiences — Figure 7 paragraph (discrimination worries) — UPDATE with SD magnitudes

**Reviewer comment served:** #3.

**Anchor:**

> "Additionally, results illustrate that trans and gender expansive students maintain higher levels of worry about discrimination compared to cisgender students (Figure 7), as the magnitude of the difference between transgender men and cisgender men exceeds the mean level of worry about discrimination for cisgender men. Additionally, among trans and gender expansive students, transgender students report higher levels of worry about discrimination compared to nonbinary and gender diverse/questioning students, although this estimate is somewhat noisy due to sample size."

**Replace with:**

> "Trans and gender expansive students report substantially higher worry about discrimination than cisgender men (Figure 7). The differences are large in standardized terms: transgender men score about 1.54 standard deviations above cisgender men (p<0.001), transgender women about 1.32 standard deviations above (p<0.001), nonbinary students about 0.98 standard deviations above (p<0.001), and gender diverse/questioning students about 0.77 standard deviations above (p<0.001). Cisgender women also report higher worry about discrimination than cisgender men (about 0.07 standard deviations, p=0.003), though the magnitude is small relative to the trans and gender expansive groups. Among trans and gender expansive students, transgender students report higher levels of worry about discrimination than nonbinary and gender diverse/questioning students; the comparisons across trans and gender expansive subgroups are less precise because of small subsample sizes (transgender men n=59; transgender women n=20)."

**Rationale:** Preserves the substantive claims (trans > nonbinary/gender diverse > cis women > cis men) but anchors each in SD-unit magnitudes from the M1 regression. The transgender-vs-nonbinary comparison in the original is now more precise. Sample-size caveat moved to the trailing position where it modifies the right estimates.

---

## EDIT 12 — Findings § Concerns About College Experiences — Figure 8 paragraph (financial worries) — UPDATE (light)

**Reviewer comment served:** #3 (consistency with the other worry paragraphs).

**Anchor:**

> "Finally, Figure 8 suggests that worries about financial burdens do not differ by gender identity."

**Replace with:**

> "Finally, Figure 8 shows that worries about financial burdens do not differ meaningfully by gender identity: in the unconditional model, no gender group's standardized worry differs significantly from cisgender men at the 5% level (the largest point estimate is about 0.26 standard deviations for transgender women, p=0.238)."

**Rationale:** Same conclusion the manuscript already reports, but adds the supporting magnitude so the reader can verify the claim from the figure. M1 coefficients ranged from −0.16 SD (transgender men) to +0.26 SD (transgender women); none significant at p<0.05.

---

## EDITS 10/11/12 — supporting data appendix

For your reference, the full M1 (unconditional) standardized-coefficient table from `log/thsj_rr/r2_worry_coefs.txt`:

| Group | Worry index 1 (general) | Worry index 2 (discrimination) | Worry index 3 (financial) |
|---|---|---|---|
| Cisgender man (ref.) | −0.30 SD (intercept) | −0.11 SD | −0.02 SD (ns) |
| Cisgender woman | +0.42 SD *** | +0.07 SD ** | +0.04 SD * |
| Transgender man | +0.77 SD *** | +1.54 SD *** | −0.16 SD (ns) |
| Transgender woman | +0.42 SD * (p=0.051) | +1.32 SD *** | +0.26 SD (ns) |
| Nonbinary | +0.95 SD *** | +0.98 SD *** | +0.01 SD (ns) |
| Gender diverse/questioning | +1.06 SD *** | +0.77 SD *** | +0.17 SD (ns) |
| Prefer not to say | +0.78 SD *** | +0.71 SD *** | −0.09 SD (ns) |

M3 (with controls: race + parent education + standardized HS index) attenuates worry-index-1 magnitudes by ~0.05–0.10 SD but does not change the sign or significance pattern of any coefficient. The HS-experience coefficient itself is −0.17 SD on worry-index-1 (lower HS experience → more general worry, p<0.001), +0.06 SD on worry-index-2 (modest positive, p<0.001 — but unusual sign, may be worth a sanity check), and 0.01 SD on worry-index-3 (ns).

---

## Application order recommendation

1. EDIT 4 (Table 3 body + Note) — replace the table first so downstream prose references are coherent.
2. EDIT 3 (HS Experiences magnitudes paragraph) — references Table 3.
3. EDIT 5 (Figure 5 image + Note).
4. EDIT 6 (Footnote 9) — anchor moves once Edit 3 is applied, so do this after 3.
5. EDIT 1 (Methods equations paragraph) — once Figure 5 is updated.
6. EDIT 7 (Figure 6–8 intro paragraph).
7. EDIT 8 (Figure 6, 7, 8 image + Notes).
8. EDIT 9 (Table 4 Note).
9. EDIT 2 (Table 2 image + Note).
10. EDIT 10 (worry magnitudes, optional).

## What this bundle does NOT cover

- **Alex's comments (4–7).** Already drafted in the reviewer-response file from a prior round.
- **Reviewer 1's comments.** R1 said "you have addressed all my concerns."
- **Response letter.** Once these edits land, separate response-letter drafting is needed for the editor.

If anything in here is ambiguous, doesn't match the Google Doc's current state, or you'd rather phrase differently, ping back with the specific spot and I'll revise.
