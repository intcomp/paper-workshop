---
name: latex-paper-writing
description: A standardized workflow for writing academic papers in LaTeX, covering project layout, the shared preamble (packages, color theme, math macros), references, figures, and tables. AI-added BibTeX entries go only into bib/ai.bib, each annotated with its online source and a summary, never written from memory. Figures are plotted in figures/figures.ipynb at the template's exact physical width with LaTeX-rendered text and theme colors, with their plot data kept in figures/. Tables are fitted by editing content and spacing, with resizebox only as a last resort. Use whenever writing or editing a LaTeX paper, adding citations or .bib entries, or creating figures or tables for a paper.
---

# LaTeX Paper Writing

A standardized workflow for writing a paper in LaTeX. Every paper follows the same layout and rules, so humans and agents always know where things are and how they were produced.

## Project Layout

```text
paper/
├── main.tex
├── preamble.tex          # all packages, colors, and math macros
├── bib/
│   ├── refs.bib          # entries found by humans
│   └── ai.bib            # entries added by AI only
├── figures/
│   ├── figures.ipynb     # all plotting code
│   ├── data/             # plotted values, one file per figure
│   └── <name>-crop.pdf   # cropped figures, included in the paper
└── references/            # LaTeX sources of exemplar papers, read-only
```

`.gitignore` ignores all PDFs, so the compiled paper is never committed; the only exception is the cropped figures. It also ignores `references/`, because other authors' sources are not ours to redistribute:

```gitignore
*.pdf
!figures/*-crop.pdf
references/
```

## Preamble

All shared LaTeX setup lives in one file, `preamble.tex`: packages, the color theme, and math notation.

**Rules:**

- Load `preamble.tex` in `main.tex` right after the template, so the template's own settings come first:

  ```latex
  \documentclass[10pt,twocolumn,letterpaper]{article}
  \usepackage[review]{cvpr}   % the venue template
  \input{preamble}
  ```

- **One home for setup:** no `\usepackage`, `\definecolor`, or `\newcommand` anywhere else in the paper.
- **Template first:** do not reload packages the template already loads with different options, and do not override its layout (margins, fonts, spacing). Leave template-specific settings in `main.tex`.
- **Notation as macros:** every recurring math symbol is a macro, so notation is defined once and can be changed in one place.
  - Use `\newcommand`, never `\def`, so a name clash is an error rather than a silent override.
  - Use `\DeclareMathOperator` for operators.
  - Do not hand-type a symbol in the text if a macro exists for it.

```latex
% ---- packages ----
\usepackage{amsmath,amssymb}
\usepackage{graphicx}
\usepackage{overpic}    % LaTeX labels and math on top of images
\usepackage{xcolor}
\usepackage{booktabs}
\usepackage{makecell}   % line breaks inside table cells
\usepackage{tikz}
\usepackage{gradbars}   % compact bars and sparklines in tables and text

% ---- color theme (see Theme and Colors) ----
\definecolor{metablue}{HTML}{0866FF}    % our method
% ...

% ---- math notation ----
\newcommand{\R}{\mathbb{R}}             % real numbers
\newcommand{\E}{\mathbb{E}}             % expectation
\newcommand{\vx}{\mathbf{x}}            % input vector
\newcommand{\loss}{\mathcal{L}}         % loss
\DeclareMathOperator*{\argmin}{arg\,min}
\DeclareMathOperator*{\argmax}{arg\,max}
\DeclareMathOperator{\softmax}{softmax}
\DeclareMathOperator{\diag}{diag}
```

## Math Notation

**Rule:** math fonts and symbols must be professional and follow the field's conventions, so readers recognize each kind of object at a glance. When in doubt, follow the conventions in Goodfellow et al., *Deep Learning*, and the ICLR `math_commands.tex`.

| Object | Style | Example |
|---|---|---|
| Scalar | italic lowercase (Greek for hyperparameters) | $x$, $\lambda$, $\eta$ |
| Count, dimension, index range | italic uppercase / lowercase index | $N$, $D$, $L$; $i = 1, \dots, N$ |
| Vector | bold lowercase | `\mathbf{x}`, `\boldsymbol{\mu}` |
| Matrix | bold uppercase | `\mathbf{W}` |
| Tensor (3+ dims) | bold sans-serif uppercase | `\mathsf{\mathbf{X}}` |
| Set, dataset | calligraphic uppercase | `\mathcal{D}`, `\mathcal{X}` |
| Loss | calligraphic L | `\mathcal{L}`, `\mathcal{L}_{\text{cls}}` |
| Number sets, expectation | blackboard bold | `\mathbb{R}^{N \times D}`, `\mathbb{E}` |
| Function, network | italic, parameters as subscript | $f_\theta$, $g_\phi$ |
| Named operator | upright, via `\DeclareMathOperator` | `\softmax`, `\argmin`, `\diag` |
| Transpose, norm | `^\top`, `\lVert \cdot \rVert` | `\mathbf{W}^\top`, `\lVert \mathbf{x} \rVert_2` |

- Word subscripts are upright: write `\mathcal{L}_{\text{cls}}`, not `\mathcal{L}_{cls}`.
- One symbol, one meaning across the whole paper. Never reuse a symbol for something else in another section.
- Define every symbol at its first use, and write symbols through the macros in `preamble.tex`.

**Use the symbols throughout the paper.** Once the method defines a symbol, refer to it wherever its value or role comes up, so readers can connect the text to the method. For example, if the method defines the number of layers $L$, the experiments should say: "We use ViT-B with 12 layers ($L = 12$)." Likewise, write "the loss weight $\lambda$ in Eq. (3) is set to 0.1", not just "the loss weight is 0.1".

## Source Formatting

Format the `.tex` source so that diffs, reviews, and comments work sentence by sentence.

**Rules:**

1. **One sentence per line block.** After every sentence ending (`.`, `!`, `?`), break the line and add a line containing only `%`. The `%` line separates sentences visually without starting a new paragraph, as a truly blank line would. Abbreviations such as `e.g.`, `i.e.`, `et al.`, and `Fig.` do not end a sentence.
2. **Lines at most 120 characters.** Wrap a long sentence with a plain line break (no `%`) at a natural point, such as after a comma or at the end of a clause or phrase. Never break inside a command, its arguments, or inline math.
3. **Paragraphs** are still separated by one truly blank line.

```latex
Vision Transformers split an image into patches and process them as a sequence of tokens,
which makes self-attention cost grow quadratically with the number of patches.
%
We propose a token pruning method that keeps only the most informative tokens at each layer.
%
On ImageNet, it reduces FLOPs by 40\% with less than 0.5\% accuracy drop.
%

Our contributions are as follows.
%
```

## References

**Rules:**

- All `.bib` files live in `bib/`.
- Entries added by AI go only into `bib/ai.bib`, never mixed with entries found by humans (e.g. `bib/refs.bib`). Likewise, never move human-found entries into `bib/ai.bib`.
- Every entry in `bib/ai.bib` must cite a verifiable online source. Never fabricate or reconstruct an entry from memory.

### Adding an Entry

1. **Find the work online.** Use DOI, the publisher's page, arXiv, DBLP, ACL Anthology, OpenReview, or Semantic Scholar. Confirm the title, authors, venue, and year match.
2. **Take the metadata from that source,** preferably its official BibTeX export (publisher, DBLP, or arXiv), not from memory. If a peer-reviewed version exists, cite it instead of the preprint.
3. **Annotate the entry.** Directly above each entry, add `%` comments with:
   - `Source:` the link to the page where the work was found and its metadata verified;
   - `Summary:` 2–3 sentences on what the paper does and its main contribution, based on the source (abstract or paper), not memory.

   The entry itself must also have a `doi` or `url`. Keep `@` out of the comments, because BibTeX parses it as the start of an entry.

```bibtex
% Source: https://proceedings.neurips.cc/paper/2017/hash/3f5ee243547dee91fbd053c1c4a845aa-Abstract.html
% Summary: Proposes the Transformer, a sequence transduction model built solely on attention,
% with no recurrence or convolution. It is more parallelizable and faster to train than
% recurrent and convolutional encoder-decoders, and sets new results on WMT 2014 translation.
@inproceedings{vaswani2017attention,
  title     = {Attention Is All You Need},
  author    = {Vaswani, Ashish and Shazeer, Noam and Parmar, Niki and Uszkoreit, Jakob and
               Jones, Llion and Gomez, Aidan N. and Kaiser, {\L}ukasz and Polosukhin, Illia},
  booktitle = {Advances in Neural Information Processing Systems},
  volume    = {30},
  year      = {2017},
  url       = {https://proceedings.neurips.cc/paper/2017/hash/3f5ee243547dee91fbd053c1c4a845aa-Abstract.html}
}
```

4. **Write only to `bib/ai.bib`.** Never edit the authors' own `.bib` files. If the work is already in another `.bib` file, reuse its existing key instead of adding a duplicate.
5. **Make sure the paper loads it:** `\bibliography{..., bib/ai}` or `\addbibresource{bib/ai.bib}`.

### If a Reference Cannot Be Verified

Do not add it, and do not cite a placeholder key. Tell the user which claim needs a citation and what you searched for.

## Theme and Colors

The whole paper follows one **color coding**: a single theme in which each color has one fixed meaning, applied everywhere. This covers plots, TikZ diagrams, the method overview figure, table highlights, and colored text. The figures in particular must look consistent: once readers learn that blue means our method, they can recognize it in every figure without checking the legend.

- **Define once.** Define a small palette (4–6 colors) once in `preamble.tex` with `\definecolor`. This is the single source of truth.
- **Fixed meanings.** Each color has one meaning everywhere, in every matplotlib plot, TikZ diagram, and table highlight. For example, `metablue` always marks our method (its curve, bars, dots, and diagram blocks); never switch it to another color, and never reuse it for anything else.
- **Restrained, not flashy.** Use few, muted colors. Draw most elements in neutral gray or black, and reserve the strong accent color for what matters, usually our method. Avoid rainbow palettes, saturated color mixes, gradients, and decorative color.
- **No ad-hoc colors.** Do not use matplotlib's default color cycle or hard-coded hex values. matplotlib reads the palette from `preamble.tex` (see the first cell below), and TikZ uses the names directly (`\draw[metablue]`).
- **Readable without color.** Pick colors that stay distinguishable for color-blind readers and in grayscale print. Also vary markers or line styles, so meaning never relies on color alone.

```latex
% ---- color theme in preamble.tex: one fixed meaning per color, used everywhere ----
\definecolor{metablue}{HTML}{0866FF}    % our method
\definecolor{metagray}{HTML}{8C8C8C}    % baselines
\definecolor{metaorange}{HTML}{E8710A}  % strongest competitor / highlight
\definecolor{metagreen}{HTML}{1E8E3E}   % ablation variants
```

## Figures

**Rules:**

- All figure files live in `figures/`.
- If figures are plotted with Python, all plotting code goes in a single notebook, `figures/figures.ipynb`.
- Its first cell sets the fonts, renders all text with LaTeX, and defines the physical figure widths.
- The data each figure plots also lives in `figures/`, as small, human-editable files (e.g. `figures/data/<name>.csv`) that the notebook reads, so values can be changed at any time without rerunning experiments.
  - This means the final evaluated numbers the plot draws: point and curve coordinates, bar heights, metrics.
  - It does not mean raw data or model outputs. For face recognition, store the evaluated accuracy per setting, not every per-sample prediction.
- Font sizes are only meaningful once the physical width is fixed. So each figure uses the exact width it will occupy on the page, and is included in LaTeX without scaling.

**Measure the widths from the paper's template.** Never assume them; they differ between templates. Put this after `\begin{document}`, compile, and read the values from the log:

```latex
\typeout{columnwidth=\the\columnwidth, textwidth=\the\textwidth}
```

Convert TeX points to inches with `1in = 72.27pt`.

**First cell of `figures/figures.ipynb`** (example for CVPR):

```python
import re
from pathlib import Path

import numpy as np
import matplotlib.pyplot as plt

# ---- color theme: read from preamble.tex, the single source of truth ----
COLORS = {
    name: "#" + code
    for name, code in re.findall(
        r"\\definecolor\{(\w+)\}\{HTML\}\{([0-9A-Fa-f]{6})\}",
        Path("../preamble.tex").read_text(),
    )
}  # usage: ax.plot(x, y, color=COLORS["metablue"], label="Ours")

# ---- CVPR two-column layout (measured from the compiled paper) ----
# \columnwidth = 237.13594pt, \textwidth = 496.85625pt; 1in = 72.27 TeX pt
COLUMN_WIDTH = 237.13594 / 72.27   # 3.281 in, single-column figure
TEXT_WIDTH = 496.85625 / 72.27     # 6.875 in, full-width figure*
# body text is 10pt, captions \small = 9pt, \footnotesize = 8pt
FONTSIZE = 8

plt.rcParams.update({
    "text.usetex": True,
    "font.family": "serif",
    # match the paper's fonts (CVPR uses Times)
    "text.latex.preamble": r"\usepackage{amsmath}\usepackage{newtxtext,newtxmath}",
    # every text element uses FONTSIZE
    "font.size": FONTSIZE,
    "axes.labelsize": FONTSIZE,
    "axes.titlesize": FONTSIZE,
    "xtick.labelsize": FONTSIZE,
    "ytick.labelsize": FONTSIZE,
    "legend.fontsize": FONTSIZE,
    "legend.title_fontsize": FONTSIZE,
    "figure.titlesize": FONTSIZE,
    # keep the figure exactly at its figsize when saved (no tight bbox cropping)
    "figure.constrained_layout.use": True,
    "savefig.bbox": None,
})
```

**For each figure:**

1. Use one cell per figure. It loads that figure's data from `data/<name>.csv` and uses `figsize=(COLUMN_WIDTH, h)` for a single-column `figure` or `(TEXT_WIDTH, h)` for a full-width `figure*`.
2. End the cell by saving it as vector PDF next to the notebook and cropping the white margins automatically:

   ```python
   fn = "bar.pdf"
   fig.savefig(fn)
   plt.show()
   !pdfcrop --margins=0 {fn}
   ```

   `pdfcrop` writes `bar-crop.pdf`. This cropped file is the one that is committed and included; `bar.pdf` is an ignored intermediate.
3. Include it at that width. Cropping removes only a thin margin, so the scale stays close to 1 and fonts print at about `FONTSIZE`: `\includegraphics[width=\columnwidth]{figures/<name>-crop.pdf}` (or `\textwidth`).

## Tables

**Rule:** use `\resizebox`, `\scalebox`, or `adjustbox` to fit a table only as a last resort. Scaling changes the font size, so text no longer matches the paper or the other tables.

First, fit the table by changing its content and spacing, in this order:

1. **Find what makes it too wide.** Often a single long cell or header stretches its column and the whole table.
2. **Break long cell content into lines,** with `p{<width>}` columns or `\makecell{first\\second}`.
3. **Shorten the text:** abbreviate headers (define them in the caption), drop redundant words or units, and round numbers to meaningful precision.
4. **Reduce column spacing,** e.g. `\setlength{\tabcolsep}{4pt}` inside the table environment.

If the table still does not fit after all of these, scale it with `\resizebox{\columnwidth}{!}{...}` (or `\textwidth`), as close to 1 as possible.

Fit figures by drawing them at the right physical size (see Figures), not by scaling.

## Reference Papers

Before and while writing, study a few exemplar papers and follow their structure and writing style.

- **Choose 3–5 papers** in the same field and a similar direction, from top groups (e.g. MIT, Stanford, CMU, Berkeley), preferably recent and published at the target venue.
- **Download their LaTeX sources from arXiv** into `references/`, one folder per paper:

  ```bash
  id=2010.11929
  mkdir -p references/$id && curl -sL https://arxiv.org/src/$id | tar -xz -C references/$id
  ```

  If `tar` fails, the source is a single gzipped `.tex` file: `curl -sL https://arxiv.org/src/$id | gunzip > references/$id/main.tex`.
- **Learn from them:**
  - section structure and length;
  - how the introduction builds up to the contributions;
  - paragraph flow and how claims are supported;
  - figure and table design, captions, and notation.
- **Never copy text.** Reference papers are models for structure and style, not sources of sentences. Do not `\input` them or reuse their wording.


## Submission and Revision

**Tag every milestone.** After each submission, tag the exact submitted version so it can always be recovered and compared against. Git tag names cannot contain spaces, so use hyphens:

```bash
git tag -a initial-submission -m "Initial submission to <venue>"
git tag -a revision-1 -m "Revision 1"
git push origin --tags
```

**During revision,** highlight every change, and build a marked and a clean PDF from the same source.

1. Define a conditional highlight command in `preamble.tex`:

   ```latex
   \ifdefined\marked
     \newcommand{\rev}[1]{{\color{metablue}#1}}
   \else
     \newcommand{\rev}[1]{#1}
   \fi
   ```

2. Wrap every changed or added piece of text in `\rev{...}`: sentences, table cells, and figure and table captions. For a new or redrawn figure or table, highlight its caption.
3. Build the marked version, with changes in `metablue`, as `marked.pdf`:

   ```bash
   latexmk -pdf -shell-escape -jobname=marked -usepretex='\def\marked{}' main.tex
   ```

   A plain `latexmk -pdf main.tex` builds the clean version, without highlighting.
4. Before sending the revision, make sure nothing is missed. Compare against the previous tag with `git diff initial-submission -- '*.tex'`, and check that every change is inside `\rev{}`.

## Response

### Structure

Write the response with the [TempLaTeX response template](https://github.com/intcomp/TempLaTeX/blob/main/response.tex).

**Rule:** split each reviewer comment into sub-comments by its logic, quote each one, and answer it directly below the quote.

- **One concern per sub-comment.** Reviewers often combine several questions in one paragraph. Split them into separate sub-comments, numbered by reviewer (e.g. `R1 Comment1`, `R1 Comment2`), so that each one gets its own complete answer.
- **Quote verbatim.** Put the reviewer's original wording for each sub-comment in a `\cmt{<title>}{<comment>}` box. Do not paraphrase, shorten, or soften it, and never drop any part of the comment.
- **Answer below the quote.** Put the response to each sub-comment immediately after its box.
- **State the revision.** If the manuscript was revised because of a sub-comment, end its response with an explicit, highlighted sentence that says where and what changed, referenced by label:

  ```latex
  \rev{We have revised Section~\ref{M-sec:experiments} of the revised manuscript
  to add the comparison with X that the reviewer requested.}
  ```

  Name the exact location (section, table, figure, or equation) and the specific change, matching what the reviewer asked for.

### Referring to Figures, Tables, and Equations

**Rule:** every reference to a figure, table, equation, or section in the response must state which document it is in, so reviewers never have to guess.

| Where the item is | How to refer to it |
|---|---|
| Only in the response | "As shown in Table 5 of this response, ..." |
| Only in the revised manuscript | "As shown in Figure 3 of the revised manuscript, ..." |
| In both | Give both numbers: "As shown in Table 5 of this response (also Table 8 of the revised manuscript), ..." |
| In the original submission (e.g. quoted by a reviewer) | Map it to the new number: "Table 3 of the original submission (now Table 4 of the revised manuscript)" |

- Never write a bare "Table 5" or "Fig. 3" without naming the document.
- Numbers shift during revision. Numbers that cannot come from labels, such as those of the original submission, must be taken from its compiled PDF.
- **Never hard-code manuscript numbers.** Reference the manuscript's tables, figures, and equations from the response through their labels, with `\externaldocument`. The numbers then always match the revised manuscript.

  ```latex
  \usepackage{xr-hyper}        % in response.tex; use xr if hyperref is not loaded
  \usepackage{hyperref}
  \externaldocument[M-]{main}  % reads main.aux; prefix M- avoids label clashes
  ...
  As shown in Table~\ref{M-tab:ablation} of the revised manuscript, ...
  ```

  Compile the manuscript first, because `\externaldocument` reads its `.aux` file. Rebuild the response after every manuscript change.
