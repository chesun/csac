---
name: word-to-latex
description: |
  Convert a Word (.docx) academic paper into a clean LaTeX chapter or article.
  Use when: importing a co-authored Word draft into a LaTeX dissertation/paper;
  converting a published paper PDF + Word source into LaTeX for a dissertation
  chapter; pandoc on .docx alone produces broken output (HTML tables flattened,
  refs as plain text, missing appendices, double-wrapped figures). The pipeline
  here was developed converting a 78-page GDTF paper to dissertation chapter 3
  in one session, hitting nine separate non-obvious gotchas.
author: Claude Code Academic Workflow
version: 1.0.0
argument-hint: "<path/to/paper.docx> [path/to/published.pdf]"
---

# Word → LaTeX Academic Paper Conversion Pipeline

## Problem

Converting a Word paper to LaTeX is "just run pandoc" until you actually try it.
Pandoc alone produces output with: flattened HTML tables, broken refs as plain
text, missing appendices, AI-generated alt-text junk in image captions, doubled
figure environments, and inverted-name corporate authors in the bib. A working
pipeline needs ~10 post-processing steps, each addressing a specific gotcha that
took trial-and-error to discover.

## Context / Trigger Conditions

Use this skill when:

- User wants to convert `.docx` paper to LaTeX (dissertation chapter, working paper, etc.)
- The Word doc has embedded figures, tables, and a references list
- A published PDF version exists for fidelity comparison
- pandoc-only conversion failed in the obvious ways (look for: bare `\includegraphics{extracted_media/media/imageN.png}`, plain-text refs, missing tables, "Not in outer par mode" errors)

Skip this skill if:

- Source is already in LaTeX (use diff/merge tools instead)
- Source has only prose, no figures/tables/refs (plain pandoc is enough)

## Solution — End-to-End Pipeline

### Step 0: Set up workspace

```bash
mkdir -p doc/dissertation/chapter{N}/{Figures,Tables,.workspace}
cd doc/dissertation/chapter{N}/.workspace
```

### Step 1: Convert .docx to markdown (extract media)

```bash
pandoc /path/to/paper.docx \
  --extract-media=extracted_media \
  --from=markdown+raw_html \
  -o v3.md
```

**Gotcha #1:** Use `--from=markdown+raw_html` (not just `--from=markdown`).
Tables in Word that became `<table>` HTML in pandoc's markdown output will
render as flat text without `+raw_html`. Tables 5/8/9 in the GDTF paper hit this.

**Fallback for stubborn HTML tables:** convert just that table block separately
with `pandoc --from=html --to=latex`.

### Step 2: Inspect structure

Find figure positions, table positions, references section, appendices:

```bash
grep -nE '^\*\*Figure |^\*\*Table |^# \*\*' v3.md
```

### Step 3: Build figure-number → local-file mapping

Read the v3 markdown for each `**Figure N**` caption to identify subject matter,
then map to existing local files (Stata `.png` outputs, Excel-styled charts).
Visually verify by reading both files (LLM can compare images).

Save the mapping to `.workspace/figure_mapping.md` for traceability.

### Step 4: Copy figures with descriptive names

```bash
cp /path/to/local/fig.png Figures/figNN_descriptive_slug.png
```

Use convention: `figNN_slug.png` for main, `fig_app{X}{N}_slug.png` for appendix.
Sortable filenames make ordering predictable downstream.

### Step 5: Parse references with anystyle-cli

```bash
gem install anystyle-cli  # one-time
# Extract references block (between # References and # Appendix)
sed -n '<refs_start>,<refs_end>p' v3.md > references_raw.md
# Clean markdown out (italic *, [text](url), em-dashes, escapes)
python3 -c "
import re
text = open('references_raw.md').read()
text = re.sub(r'\*([^*]+)\*', r'\1', text)
text = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', text)
text = text.replace('--', '-')
# Reflow into one-line-per-reference
out = []
buf = []
for line in text.splitlines():
    if line.strip(): buf.append(line.strip())
    elif buf: out.append(' '.join(buf)); buf = []
if buf: out.append(' '.join(buf))
open('references_clean.txt', 'w').write('\n\n'.join(out))
"
anystyle -f bib parse references_clean.txt > references.bib
```

**Gotcha #2:** anystyle inverts corporate-author names:
- `California Legislative Information` → `Information, California Legislative`
- `Equality California` → `California, Equality`
- `Movement Advancement Project` → no author, title becomes the org name
- `Exec. Order No. 14168` → `No, Exec Order` + title `14168, 90 Fed`

After running anystyle, grep for these patterns and rewrite as:

```bibtex
author = {{Equality California}}    % double braces preserve as-is
```

**Gotcha #3:** anystyle sometimes leaks markdown URL fragments into `note` field:
```
note = {[https://doi.org/...]{.underline}](https://doi.org/...},
```
Replace with a clean `doi = {...}` field.

### Step 6: Convert markdown tables to bare LaTeX `tabular` fragments

```python
# Per-table extraction loop
for start_line, fname, label in table_specs:
    block = '\n'.join(v3_lines[start_line - 1:end_line])
    proc = subprocess.run(
        ['pandoc', '--from=markdown+raw_html', '--to=latex', '--wrap=preserve'],
        input=block, capture_output=True, text=True
    )
    m = re.search(r'(\\begin\{longtable\}.*?\\end\{longtable\})', proc.stdout, re.DOTALL)
    Path(f'../Tables/{fname}').write_text(m.group(1))
```

For HTML tables specifically, use `--from=html` instead.

### Step 7: Convert prose markdown to LaTeX with post-processing

```bash
pandoc v3.md --from=markdown+raw_html --to=latex --wrap=preserve > v3_full.tex
```

Then post-process (see template script below).

### Step 8: Post-process the LaTeX output

#### 8a. Strip pandoc preamble (title page / abstract / acknowledgements)

Find `\section{...Introduction...}` and discard everything before it. The
chapter wrapper supplies `\chapter{}`.

#### 8b. Truncate at references — but keep appendices!

**Gotcha #4 (CRITICAL):** Word papers structure as Body → References → Appendices.
A naive `text[:text.find('# **References**')]` drops the appendices entirely,
which is silent and only caught when you notice missing figures (F1-J6, etc.)
or empty appendix sections.

**Fix:** Process body and appendices separately:
```python
body = v3_text[:ref_start]
appendix = v3_text[v3_text.find('# **Appendix A'):]
# Convert each, then concatenate with \appendix marker between
```

#### 8c. Clean section heading wrappers

Pandoc converts `# **Foo**` to `\section{\texorpdfstring{\textbf{Foo}}{Foo}}\label{foo}`.
Strip the wrapper:
```python
text = re.sub(
    r'\\section\{\\texorpdfstring\{(?:\\textbf\{)?([^}]+)\}?(?:\}\{[^}]*)?\}\}',
    r'\\section{\1}', text
)
```

#### 8d. Replace pandoc-rendered images with project paths

Pandoc emits `\includegraphics[width=...]{extracted_media/media/imageN.png}`.
Map by image number to your descriptive slug:
```python
text = re.sub(
    r'\\includegraphics\[[^\]]*\]\{extracted_media/media/image(\d+)\.png\}',
    lambda m: f'\\includegraphics[width=\\textwidth]{{{fig_map[int(m.group(1))]}.png}}',
    text
)
```

Also strip AI-generated alt-text junk that pandoc may leave as preceding text:
```python
text = re.sub(
    r'A graph (?:with|of)[^.]*?AI-generated content may be (?:in)?correct\.?\s*',
    '', text
)
```

#### 8e. Replace pandoc longtables with `\input{Tables/...}` calls

```python
table_iter = iter(table_filename_list)
text = re.sub(
    r'(?:\{\\def\\LTcaptype\{none\}[^\n]*\n)?\\begin\{longtable\}.*?\\end\{longtable\}\}?',
    lambda m: f'\\input{{Tables/{next(table_iter)}}}',
    text, flags=re.DOTALL
)
```

**Gotcha #5:** the wrapper `{\def\LTcaptype{none}...}` may leave a stray `}\n`
after the `\input`. Clean up:
```python
text = re.sub(r'(\\input\{Tables/[^}]+\})\n\}\n', r'\1\n', text)
```

#### 8f. Convert in-text citations to `\citep{}` / `\citet{}`

Build a `(lastname, year) → bib_key` index from the bib, then regex-replace
parentheticals:

```python
def replace_parenthetical(match):
    inner = match.group(1).replace('\n', ' ').replace('~', ' ')  # collapse multiline + nbsp
    inner = re.sub(r'\s+', ' ', inner).strip()
    parts = re.split(r';\s*', inner)
    keys = []
    for part in parts:
        # Try multi-word lastname first (corporate authors), then first word
        py = parse_authoryear(part)
        if not py: return match.group(0)
        k = find_key(py[0], py[1]) or find_key(py[0].split()[0], py[1])
        if not k: return match.group(0)
        keys.append(k)
    return f'\\citep{{{", ".join(keys)}}}'

text = re.sub(
    r'\(([A-Z][\w\s,;&\'’\-\.\n~]+?\d{4}[a-z]?(?:\s*,\s*\d{4}[a-z]?)*)\)',
    replace_parenthetical, text
)
```

**Gotcha #6:** Multi-line citations like `(Hunter et al.,\n2021)` (LaTeX line break
inside a citation) won't match unless you collapse `\n` and `~` (non-breaking
space) before parsing. Allow `\n~` in the character class.

**Gotcha #7:** Year mismatches between in-text and reference list (e.g., paper
text says "Watson et al., 2019" but bib has Watson 2020 — common when references
update during peer review). Add a `manual_aliases` dict and apply the journal
copyedit fixes to chapter3.tex BEFORE running citation conversion.

#### 8g. Wrap figures and tables in environments

```python
def wrap_figure(match):
    fname = match.group(1)
    num, slug, caption = fname_to_meta[fname]
    label = 'fig:' + re.sub(r'^fig\d+_|^fig_app[A-Z]\d?_', '', slug)
    return (
        f'\\begin{{figure}}[htbp]\n\\centering\n'
        f'\\includegraphics[width=\\textwidth]{{{fname}}}\n'
        f'\\caption{{{caption}}}\n\\label{{{label}}}\n\\end{{figure}}'
    )

text = re.sub(r'\\includegraphics\[width=\\textwidth\]\{(fig\w+\.png)\}',
              wrap_figure, text)
```

**Gotcha #8:** Use `[htbp]` placement, not `[H]`. The `[H]` option requires
`\usepackage{float}` which the dissertation `stylefile.sty` may not load. `[htbp]`
is the LaTeX built-in.

**Gotcha #9 (CRITICAL):** Pandoc may have already wrapped some images in its own
figure environment (with the AI alt text as caption). Your wrap creates a NESTED
figure-inside-figure → "Not in outer par mode" error. Strip pandoc's outer
wrapper:
```python
pattern = re.compile(
    r'\\begin\{figure\}\s*\n\s*\\centering\s*\n(\\begin\{figure\}\[htbp\].*?\\end\{figure\})\s*\n\\caption\{[^}]*?incorrect\.[^}]*?\}\s*\n\\end\{figure\}',
    re.S
)
text = pattern.sub(r'\1', text)
```

Same logic for tables (wrap `\input{Tables/...}` in `table` environment).

#### 8h. Convert "Figure N" / "Table N" cross-refs in prose

```python
text = re.sub(r'\bFigure (\d+|[A-Z]\d?)\b',
              lambda m: f'Figure~\\ref{{{fig_label_map.get(m.group(1), m.group(0))}}}', text)
text = re.sub(r'\bTable (\d+|[A-Z]\d?)\b',
              lambda m: f'Table~\\ref{{{tab_label_map.get(m.group(1), m.group(0))}}}', text)
```

#### 8i. Escape ampersands in bib

**Gotcha #10:** Journal names like "Social Science & Medicine", "Gender & Society"
break LaTeX with "Misplaced alignment tab character &". Escape:
```python
bib_text = re.sub(r' & ', ' \\& ', bib_text)
```

### Step 9: Compile and verify

```bash
pdflatex chapter3_standalone.tex
biber chapter3_standalone
pdflatex chapter3_standalone.tex
pdflatex chapter3_standalone.tex
```

Check log:
```bash
grep -cE '^!' chapter3_standalone.log              # errors (target: 0)
grep -E "Citation '.*' undefined" chapter3_standalone.log | wc -l  # target: 0
grep -E "Reference '.*' undefined" chapter3_standalone.log | wc -l  # target: 0
```

### Step 10: PDF diff against published version

```bash
pdftotext -layout chapter3_standalone.pdf compiled.txt
pdftotext -layout published_paper.pdf published.txt
# wc -w on each for sanity check
# diff section-by-section for journal copyedits
```

Apply identified copyedits (year fixes, prose changes) BEFORE re-running citation
conversion so they propagate.

## Verification

The pipeline is complete when:

- [ ] `pdflatex + biber + pdflatex × 2` produces a PDF with **0 errors**
- [ ] `grep "undefined" log` returns **0**
- [ ] All figures and tables visible in compiled PDF
- [ ] All citations render as `(Author, Year)` not plain text
- [ ] Cross-refs render as numbers (e.g., "Figure 1.3"), not literal "Figure 3"

Visually inspect 3-4 random pages of the compiled PDF to catch:
- Highlighted placeholders (`(CITE)`, `XX [number]`) — these are unfilled in source
- Page breaks mid-table (use `[htbp]` or longtable)
- Broken section numbering

## Example: Real-world conversion (GDTF LGBTQ paper, May 2026)

Source: `doc/gdtf/GDTF_LGBTQ_paper_v3.docx` (78-page paper, 27 figures, 17 tables, 71 refs)

Target: `doc/dissertation/chapter3/` standalone-compilable LaTeX

Output: 84-page PDF, 0 errors, 80 bib entries, 27 figures + 17 tables wrapped
with caption + label, 74 cross-refs converted, 45 `\citep{}` resolved.

Time: ~3 hours including all 10 gotchas hit + recovery.

Without this skill: estimated 6-8 hours of trial-and-error to rediscover gotchas.

## Common Pitfalls Checklist

| # | Symptom | Cause | Fix |
|---|---|---|---|
| 1 | Tables render as flat text | Pandoc parsed HTML tables as raw HTML | `--from=markdown+raw_html` |
| 2 | Bib entries with author "Information, California Legislative" | anystyle inverted corporate names | `author = {{Org Name}}` (double braces) |
| 3 | `note = {[https://...]{.underline}]...}` | anystyle leaked markdown | Replace with `doi = {...}` |
| 4 | Empty appendix sections | Truncated at "References" | Process appendix block separately |
| 5 | Stray `}` after `\input{Tables/...}` | Pandoc longtable wrapper | Regex-strip `}\n` after `\input` |
| 6 | Multi-line citations not converted | Newline in citation | Collapse `\n` and `~` before parsing |
| 7 | Year mismatch causes unconverted citation | Journal updated year during peer review | Apply PDF-diff fixes BEFORE citation conversion |
| 8 | `Unknown float option 'H'` | `\usepackage{float}` not loaded | Use `[htbp]` instead |
| 9 | `Not in outer par mode` errors | Nested `\begin{figure}` inside `\begin{figure}` | Strip pandoc's outer wrapper |
| 10 | `Misplaced alignment tab character &` | Unescaped `&` in journal name | `s/ & / \\& /` in bib |

## References

- pandoc docs: https://pandoc.org/MANUAL.html
- anystyle: https://anystyle.io and `gem install anystyle-cli`
- Project rules: `.claude/rules/tables.md`, `.claude/rules/figures.md`,
  `.claude/rules/working-paper-format.md`
- Reference run: commits `aaa7a55` and `1ceaf57` in this repo
- Working artifacts: `doc/dissertation/chapter3/.workspace/` (preserved)
