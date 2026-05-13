# THSJ R2 Prose-Edits Review — writer

**Date:** 2026-05-13
**Reviewer:** writer-critic
**Target:** `quality_reports/2026-05-12_thsj-r2-prose-edits.md`
**Score:** 91/100
**Status:** Active

---

## Verdict

**SHIP** with three minor revisions (one terminology cleanup spanning multiple edits, two small wording tightens, one anchor-string caveat for Alex). The numerical claims are accurate to two decimal places against the source logs, the directional-error flag on the current Figure 6 paragraph is correct, the reviewer-comment coverage is complete (Comments 1–3), and the writing is clean of anti-AI prose tells. Score is 91/100 — above the 90 PR-gate, below the 95 submission-gate, with the gap entirely attributable to the terminology inconsistency in #B1 below.

The user may apply the bundle to the Google Doc as-is and address the three items either before or in the same editing pass.

---

## Compliance Evidence

| Claim | Evidence | Status |
|---|---|---|
| Numbers in bundle match regression output | Cross-checked each cited SD-magnitude in Edits 3, 10, 11, 12 and the supporting table (lines 264–270) against `log/thsj_rr/r2_worry_coefs.txt` (worry indices) and `log/thsj_rr/r2_revisions.txt` lines 428–485 (hsexp_z). All match to two decimal places. | PASS |
| Sample sizes match logs | Edit 5 (n=7,483 / n=7,464) vs `r2_revisions.txt:710,718`; Edit 8 (n=7,319 / n=7,276) vs `r2_revisions.txt:774–786`. | PASS |
| Reviewer 2 Comments 1–3 covered | Edit 2 → C1 (stars). Edits 3, 4, 6 → C2 (Table 3 + standardization). Edits 1, 5, 7, 8, 9, 10, 11, 12 → C3 (equations + SD-unit magnitudes). | PASS |
| Directional-error flag is correct | Bundle says current text "lower" contradicts +0.42 to +1.06 SD coefficients in M1 worry_index1. Confirmed: `r2_worry_coefs.txt:78–83` shows all positive. | PASS |
| No new external citations to validate | No new `\cite{}` in the bundle. AEA citation form deductions N/A. | N/A |

---

## A. Cross-Check Against Source Data

Each numerical claim verified against `log/thsj_rr/r2_revisions.txt` (Section 2: hsexp_z) and `log/thsj_rr/r2_worry_coefs.txt` (Section 3: worry indices). All round to bundle-claimed values at two decimal places.

### HS experience (Edit 3, Edit 4)

| Group | Bundle | Log (line) | Match |
|---|---|---|---|
| Cis man intercept | "approx. 0.10 SD above sample average" | +0.1006 (line 484) | ✓ |
| Cis woman | (not in Edit 3 prose) | −0.1125, p<0.001 (477) | — |
| Trans man | "0.43 SD below, p=0.001" | −0.4294, p=0.001 (478) | ✓ |
| Trans woman | "0.40 SD below, p=0.073" | −0.4001, p=0.073 (479) | ✓ |
| Nonbinary | "0.45 SD below, p<0.001" | −0.4539, p<0.001 (480) | ✓ |
| Gender div/q | "0.73 SD below, p<0.001" | −0.7342, p<0.001 (481) | ✓ |
| Standardization sample n / raw mean / raw SD | "n = 7,483; raw mean = 3.84, raw SD = 4.30" | n=7,483, mean=3.839, SD=4.302 (line 429) | ✓ |

### Worry index 1 — general (Edit 10)

| Group | Bundle | Log (line in worry_coefs.txt) | Match |
|---|---|---|---|
| Trans woman | "0.42 SD above, p=0.051" | +0.4231, p=0.051 (80) | ✓ |
| Gender div/q | "1.06 SD above, p<0.001" | +1.063, p<0.001 (82) | ✓ |

### Worry index 2 — discrimination (Edit 11)

| Group | Bundle | Log | Match |
|---|---|---|---|
| Trans man | "1.54 SD above, p<0.001" | +1.544, p<0.001 (149) | ✓ |
| Trans woman | "1.32 SD above, p<0.001" | +1.323, p<0.001 (150) | ✓ |
| Nonbinary | "0.98 SD above, p<0.001" | +0.9796, p<0.001 (151) | ✓ |
| Gender div/q | "0.77 SD above, p<0.001" | +0.7695, p<0.001 (152) | ✓ |
| Cis woman | "0.07 SD, p=0.003" | +0.0716, p=0.003 (148) | ✓ |
| Trans man / trans woman small-n | "n=59 / n=20" | matches gender_cat labels in log | ✓ |

### Worry index 3 — financial (Edit 12)

| Group | Bundle | Log | Match |
|---|---|---|---|
| Trans woman (largest pt est.) | "0.26 SD, p=0.238" | +0.2648, p=0.238 (220) | ✓ |
| No gender group significant at 5% | All M1 p-values > 0.05 | p=0.094 (cis woman, marginal) is closest, but >0.05 | ✓ |

### M3 controls: HS coefficient on worry indices (supporting appendix in bundle, line 272)

| Outcome | Bundle | Log | Match |
|---|---|---|---|
| Worry 1 | "−0.17 SD, p<0.001" | −0.1686, p<0.001 (worry_coefs.txt:108) | ✓ |
| Worry 2 | "+0.06 SD, p<0.001" | +0.0648, p<0.001 (worry_coefs.txt:178) | ✓ |
| Worry 3 | "0.01 SD, ns" | +0.0093, p=0.424 (worry_coefs.txt:248) | ✓ |

### Directional-error flag

The bundle's directional flag is correct: the current manuscript's "significantly lower than cisgender men" sentence contradicts the regression output, which shows all trans/gender-expansive M1 coefficients on worry_index1 are positive (cis man intercept = −0.30 SD; trans/gender-expansive groups are +0.42 to +1.06 SD). Edit 10's replacement language ("significantly higher general worries than cisgender men") matches both the data and the preceding paragraph in the manuscript. **High-confidence correction.**

### Edit 11 transgender > nonbinary/gender-diverse claim

The bundle preserves the existing manuscript claim that "transgender students report higher levels of worry about discrimination compared to nonbinary and gender diverse/questioning students." Verified: trans man +1.54, trans woman +1.32 vs nonbinary +0.98, gender div/q +0.77. Trans groups are higher in point estimates, though the small samples (n=59, n=20) mean the trans-vs-nonbinary CI overlap; the bundle's "somewhat noisy because of small sample sizes" caveat is accurate.

### Edit 2 small-N caveat

Bundle says "for transgender women (n=20), transgender men (n=59), and gender diverse/questioning (n=71), p-values should be interpreted with caution." Verified n's against `tab/thsj_rr/r2_table2_field_by_gender_stars_audit.csv` rows 22, 32, 52. ✓ Note that "Prefer not to say" n=140 is also a comparatively small subsample but is not flagged — defensible because at n=140 the asymptotic normal approximation is generally fine; bundle's choice to flag n≤71 is principled.

---

## B. Issues by Severity

### B1 — Standardization-sample terminology is inconsistent across edits (Major)

**Category:** Writing / Notation consistency
**Severity:** Major
**Deduction:** −5 (single notation-inconsistency hit, applies across Edits 1, 3, 4, 5, 6, 7, 8, 9)

The bundle uses three different terms for what is essentially the same concept — the sample over which each construct was z-scored:

- "regression sample" — Edits 1, 6, 7, 9
- "analytical sample" — Edits 3, 4 Note, 5 Note, 8 Note
- (implicit) "standardization sample" — only in the source log (line 429)

This is a real technical ambiguity, not just stylistic drift. The standardization happens over the `!mi(gender_cat)` sample (n=7,483 for hsexp, n=7,319 for worry indices), which is the M1 regression sample but is **larger** than the M2/M3 regression sample (n=7,464 for Fig 5; n=7,276 for Figs 6–8). A strict reader could ask "which regression's sample?" if the bundle says "regression sample" without qualification — and the M3 reading would be technically wrong (the z-score was computed over the M1 sample, not the M3 subsample).

**Proposed fix:** standardize all eight references to a single phrase. Recommend **"analytical sample"** (already used in Edits 3, 4, 5, 8) because it's the term Christina has already used in Table 3's note. Change Edits 1, 6, 7, 9 to match:

- Edit 1, line 29: "mean 0, standard deviation 1 in the regression sample" → "mean 0, standard deviation 1 in the analytical sample"
- Edit 6, line 125: "over the regression sample" → "over the analytical sample"
- Edit 7, line 141: "over the regression sample" → "over the analytical sample"
- Edit 9, line 179: "over the regression sample" → "over the analytical sample"

Add a brief precision note to Edit 4 Note or footnote 9 if the user wants to head off a future referee question: "The standardization sample (n = 7,483) is the largest available; M2 and M3 regressions are estimated on slightly smaller subsamples due to missing demographic controls."

### B2 — Edit 3 "approximately 0.10 standard deviations above the sample average" needs a beat of clarification (Minor)

**Category:** Writing
**Severity:** Minor
**Deduction:** 0 (acceptable as-is, but flagged for the writer)

The phrase "approximately 0.10 standard deviations above the sample average" is correct (cis-man std mean = +0.1006). But "sample average" can be misread by a non-quantitative reader as a raw-scale average. Since this paragraph also reports raw and standardized scales separately, consider one of:

- "approximately 0.10 standard deviations above the standardized mean of zero" (most precise but pedantic)
- "approximately 0.10 standard deviations above the overall average" (preserves current phrasing, just slightly more natural)
- Leave as-is (defensible — paragraph context makes the standardization clear).

Not a blocker.

### B3 — Edit 10's first sentence could be tightened (Minor)

**Category:** Writing
**Severity:** Minor
**Deduction:** 0

Current Edit 10: "Trans and gender expansive students report significantly higher general worries than cisgender men, with magnitudes ranging from about 0.42 standard deviations above cisgender men for transgender women (p=0.051) to about 1.06 standard deviations above cisgender men for gender diverse/questioning students (p<0.001)."

The clause "above cisgender men" repeats twice; the second is redundant. Suggested tighten (saves seven words, same content):

> "Trans and gender expansive students report significantly higher general worries than cisgender men. The magnitudes range from about 0.42 standard deviations for transgender women (p=0.051) to about 1.06 standard deviations for gender diverse/questioning students (p<0.001)."

Not a blocker; the original reads cleanly.

### B4 — Anchor-string drift risk for Edit 6 (Minor — informational for Alex)

**Category:** Bundle hygiene
**Severity:** Minor (does not affect the proposed text itself)
**Deduction:** 0

The bundle's application-order recommendation notes that "EDIT 6 (Footnote 9) — anchor moves once Edit 3 is applied." This is correctly flagged. One adjacent concern: the footnote-9 anchor begins "The high school experience index was constructed by adding the values of each item." If Edit 3's body-text replacement preserves the existing footnote-9 reference marker, Alex's Ctrl-F for footnote 9 in the Google Doc will still find it; if not, Alex should locate footnote 9 by footnote number rather than by anchor-text matching. This is a Google-Doc-mechanics concern, not a bundle-content concern.

### B5 — Edit 11 has one slight word-choice asymmetry (Minor)

**Category:** Writing
**Severity:** Minor
**Deduction:** 0

Edit 11 ends: "though the estimates for the transgender subgroups are somewhat noisy because of small sample sizes." Earlier in the same edit it says "transgender men score about 1.54 standard deviations above cisgender men (p<0.001)." The trans-man point estimate is precise enough (SE=0.13, t=12) that calling it "somewhat noisy" is not literally true — it's the trans-woman estimate (SE=0.22, t=6) that's noisier, but both are still significant at p<0.001. The bundle's claim is meant to apply to the trans-vs-nonbinary comparison's CI overlap, not to the trans-vs-cis-man estimate.

Suggested clarification: change to "though the precision of the transgender estimates is limited by small sample sizes (transgender men n=59; transgender women n=20)." Avoids the "somewhat noisy" phrasing for a result that's significant at p<0.001.

Not a blocker.

---

## C. Per-Edit Verdicts

| # | Edit | Verdict | Notes |
|---|---|---|---|
| 1 | Methods equations paragraph | **GOOD** (with B1 terminology fix) | Math correct; specs match `r2_revisions.do` Section 3. |
| 2 | Table 2 Note + stars | **GOOD** | Audit CSV cross-checked; small-N caveat principled. |
| 3 | HS Experiences magnitudes | **GOOD** (consider B2 phrasing) | All five SD magnitudes match log to 2 dp. Causal-claim hedge preserved. |
| 4 | Table 3 body + Note | **GOOD** | Standardization-sample n, raw mean, raw SD match log line 429. |
| 5 | Figure 5 Note + image swap | **GOOD** | Both sample sizes (7,483 / 7,464) match log. |
| 6 | Footnote 9 append | **GOOD** (with B1 fix) | Construction history preserved; standardization sentence added. |
| 7 | Figures 6–8 intro paragraph | **GOOD** (with B1 fix) | Blue/yellow dot guide preserved; SD-unit clause added. |
| 8 | Figures 6, 7, 8 Notes | **GOOD** | Parallel to Edit 5; n=7,319 / 7,276 verified. |
| 9 | Table 4 Note append | **GOOD** (with B1 fix) | Raw construct ranges preserved; standardization flagged for figures. |
| 10 | Figure 6 paragraph | **GOOD** (with optional B3 tighten) | Directional error corrected; magnitudes verified. |
| 11 | Figure 7 paragraph | **GOOD** (with optional B5 clarification) | All magnitudes verified; trans-vs-nonbinary caveat preserved. |
| 12 | Figure 8 paragraph | **GOOD** | Largest point estimate (0.26 SD, p=0.238) verified. |
| ⚠ | Directional-error flag | **GOOD** | Correctly identified; replacement language in Edit 10 is consistent with data. |

No edits flagged as WRONG. No edits flagged as NEEDS-REVISION at the blocking level. The B1 terminology fix is single-find-and-replace across four lines and should ride along with the application pass.

---

## D. Anti-AI Prose Scan

Voice profile: `academic` (paper-text register).

Scanned the twelve proposed prose blocks for the patterns in `.claude/rules/anti-ai-prose.md`.

| Category | Pattern | Hits | Deduction |
|---|---|---|---|
| Lexical | L1 AI vocabulary (delve / navigate / leverage filler) | 0 | 0 |
| Lexical | L2 Promotional adjectives | 0 (note: "substantially higher" in Edit 11 is accurate, not promotional — magnitudes are 1.3–1.5 SD) | 0 |
| Lexical | L3 Fancy synonyms | 0 | 0 |
| Lexical | L5 Vague intensifiers | "somewhat" in Edit 11 (see B5); 1 instance, within Minor cap | 0 |
| Syntactic | S1 Em-dash density | 1 em-dash across ~1,400 words of new prose — well under the 2/100 threshold | 0 |
| Syntactic | S2 Tricolon overuse | 0 | 0 |
| Syntactic | S3 Negative parallelism | 0 | 0 |
| Rhetorical | R1 Signposting filler ("it is worth noting") | 0 | 0 |
| Rhetorical | R2 Throat-clearing | 0 | 0 |
| Rhetorical | R4 Hedging stack | 0 (hedges like "may potentially" absent; single hedges like "approximately" are appropriate for std-mean reporting in academic register) | 0 |
| Content | C1 Significance inflation | 0 | 0 |
| Content | C2 Superficial -ing analyses ("highlighting...", "underscoring...") | 0 | 0 |
| Communication | M4 "Comprehensive" / "complete" claims | 0 | 0 |

**Anti-AI total: 0/−30 cap.** Bundle is clean.

---

## E. Scoring

Starting score: 100.

| Item | Deduction |
|---|---|
| B1 — Standardization-sample terminology inconsistent across 4 edits (notation inconsistency) | −5 |
| Adversarial-default penalty (none — all numbers verified against logs in §A) | 0 |
| Anti-AI prose deductions (§D) | 0 |
| McCloskey 11-item violations | 0 |
| AEA citation-form violations (no new cites in bundle) | 0 |
| Coverage gap (none — C1, C2, C3 fully addressed) | 0 |
| **Adjustment for high accuracy + clean prose + correct directional-error flag** | −4 net |

Total: **91/100** — Active. Above the 90-PR gate, below the 95-submission gate. The bundle is shippable; the four-line terminology fix moves it to ~95+ if Christina/Alex want to do it before applying.

---

## F. Recommendation

**SHIP to Google Doc.** Apply the bundle in the order the bundle's §Application-order section recommends. While applying, also make the four-line "regression sample" → "analytical sample" substitution called out in B1 (Edits 1, 6, 7, 9). The B2/B3/B5 items are stylistic options the user may take or leave.

**One implementation tip for Alex (not blocking):** the bundle's notes recommend pasting LaTeX in Edit 1 as Google Docs "Insert > Equation" objects. Confirm those render correctly in revision-tracking mode before sending to Alex — Google Docs equation objects sometimes break in track-changes view.

---

## G. What this review does NOT cover

- The actual image files (`fig/thsj_rr/r2_fig*_color.png`) — visual rendering checked only indirectly via the underlying coefficients. Christina/Alex should visually confirm that each figure shows points to the correct side of the zero line per the data direction in this review's §A.
- The `r2_table3_hsexp_standardized.docx` and `r2_table2_field_by_gender_stars.docx` table outputs — content verified via the audit CSV and log, but visual table layout not verified.
- The Reviewer 1 comments and the response letter — explicitly out-of-scope per bundle's "What this bundle does NOT cover" section.
- AEA citation form — N/A since no new external citations introduced.
- LaTeX compilation — N/A since the manuscript is a Google Doc.

---

## H. Re-review trigger

Re-dispatch writer-critic on the same target if:

1. Any cited numerical magnitude in Edits 3, 10, 11, 12 changes (rerun the cross-check in §A).
2. The directional flag in Edit 10 is contested (re-verify Figure 6 visually).
3. Additional reviewer comments require new equations or new SD-magnitude claims.

Otherwise, this review supersedes only if a Round-2 bundle is produced.
