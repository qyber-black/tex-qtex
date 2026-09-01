# TeX - QTeX document classes and styles

Unified LaTeX package providing three document classes: **qbook** (book-based, for theses, dissertations, reports), **qarticle** (article-based, section-level only), and **qslides** (beamer-based, with the Qyber dark theme). All share the same options, typography, and layout via `qtex.sty`.

> SPDX-FileCopyrightText: 2026 Frank Langbein <frank@langbein.org>
> SPDX-License-Identifier: CC-BY-SA-4.0

## Checking a build

`latexmk` exits 0 with undefined references and with text running past
the margin, so a build that "succeeded" says nothing about either.
`make checklog` reads the logs instead and fails on undefined
references, and on overfull boxes at or above `OVERFULL_PT` (default
1.0pt -- microtype and ragged-right leave a scatter of sub-point
overruns that are invisible on the page):

    make checklog                 # all three examples
    make checklog OVERFULL_PT=5   # only the gross ones

`make check` runs it before the REUSE lint, so both gate together.

`scripts/checklog.py [-t PT] LOG...` runs it on any logs; it checks every
log before returning, so one bad log does not hide the state of the
others. It is a
script rather than a shell one-liner because `grep` on some systems is
`ugrep`, whose `-c` prints nothing rather than `0` when there is no
match -- indistinguishable from success in a pipeline.

## Classes

### qbook

Extends `book`. Use for theses, dissertations, long reports. Has `\frontmatter`, `\mainmatter`, `\backmatter`, chapters, appendices.

- `\title{...}`, `\author{...}`, `\degree{...}`, `\university{...}`, `\date{...}`
- `\maketitle{abstract text}` — title page, optional copyright page, abstract, front lists (TOC, LOF, LOT, LOA, acronyms — each printed only if non-empty)
- `\dedication{...}` — right-aligned dedication page
- `\frontlists` — TOC + conditional LOF/LOT/LOA + acronyms
- `\bib{basename}` — bibliography with optional license section
- `\keywords{...}` — printed at end of abstract
- `\license{SPDX-ID}`, `\copyrightholder{...}`, `\licenseyear{...}` — copyright/license page and license section
- Page styles: `plain`, `chapter` (thick rule + chapter label), `plainchapter` (thick rule, no label)

### qarticle

Extends `article`. Use for papers and short documents. No front/main/back matter; sections only.

- `\author{Name}{Details}` — multiple calls for multiple authors; details are free-form text (institution, e-mail, URL, ORCID)
- `\maketitle` — article-style title block (title, author names separated by `\quad`, date)
- `\maketitlewithabstract{...}` — shorthand: `\maketitle` + abstract block
- `\begin{abstract}...\end{abstract}` — ruled abstract with optional keywords
- `\printauthors` — prints full author details (name + details) as a section near the end
- `\bib{basename}` — bibliography with optional license section
- `\keywords{...}`, `\license{SPDX-ID}`, `\copyrightholder{...}`, `\licenseyear{...}`

### qslides

Extends `beamer` (16:9, top-aligned). Uses the **qyber** beamer theme for layout and colours; fonts, citations, and general typography come from `qtex.sty` so slides match `qbook`/`qarticle`.

- `\title{...}`, `\subtitle{...}`, `\author{...}`, `\date{...}`
- `\license{SPDX-ID}`, `\copyrightholder{...}`, `\licenseyear{...}` — copyright footer on the title slide
- `\slidesbib{basename}` — load a `.bib` file; `\citep` and `\citet` produce inline markers with full references in a footer bar
- `\slidesurls{...}` — URLs shown in the header/footer bar right-hand box
- `\setqyberauthorurl{url}` — clickable author URL in the bar
- `\titlebox{...}` — arbitrary content for the left pane in `titlesplit` layout
- `\emph{...}` — theme-coloured emphasis (green); `\hi{...}` — highlighted text (orange bg)
- `\footnote{text}` — numbered footnotes rendered as a TikZ overlay bar at the slide bottom
- Layout helpers: `slidebox` (headerless content box, optional `[border]`), `twocolumns`/`leftcolumn`/`rightcolumn`, `\placebox[anchor]{x}{y}{w}{h}{content}` (positioned box in relative 0–1 units)
- Background layouts: `\setlayoutfull`, `\setlayoutleft`, `\setlayoutright`, `\setlayoutcorner`, `\setlayoutoverlay`
- Block types: standard, `code`, `example`, `result`, `success`, `error`, `info` (each with its own colour)

#### qslides-only options

- `large` — 17pt body text (default 12pt); bar heights scale accordingly
- `titlesplit` / `titlebasic` — title page layout variant (split = left content pane + right text; basic = centred, default)
- Any beamer option is passed through (`aspectratio=43`, `handout`, `notes`, ...)

## Options (all classes)

| Category | Options | Default |
|---|---|---|
| Font | `sans`, `serif`, `hacker` | `sans` |
| Layout | `oneside`, `twoside` | `oneside` |
| Citation | `numeric`, `harvard` | `numeric` |
| Alignment | `raggedright`, `justified` | `raggedright` |
| Line spacing | `single`, `onehalfspacing`, `linespread115`, `linespread12` | `single` |
| Paragraph | `parskip`, `parindent` | `parskip` |
| Other | `fullwidth`, `italic`, `noobfuscate`, `obfuscate` | `noobfuscate` |

Override the acronym file: `\renewcommand{\qtexacronymfile}{yourfile.tex}` in the preamble.

## Shared commands

- `\epigraph{text}{attribution}` — right-aligned quotation
- `\newthought{text}` — small-caps opening for a new paragraph section
- `\cite` warns; use `\citep` or `\citet`
- `\version{...}` -- a revision identifying the source a PDF was built
  from, printed after the date on the title page of all three classes.
  Unset by default, in which case the date appears alone.

  To stamp the git commit, have the build write it and `\input` the
  result. LaTeX cannot obtain the hash itself: that needs `\write18`,
  which Overleaf disables. Reading `.git/HEAD` with `\openin` would work
  locally but cannot tell whether the tree is dirty, which is the part
  worth knowing. So:

  ```make
  gitinfo:
  	@printf '%% Auto-generated; do not edit, do not commit.\n' > gitinfo.tex
  	@printf '\\version{%s%s}\n' \
  	  "$$(git rev-parse --short HEAD 2>/dev/null || echo unknown)" \
  	  "$$(git diff --quiet 2>/dev/null || echo '-dirty')" >> gitinfo.tex

  paper: gitinfo
  	latexmk main.tex
  ```

  with `\InputIfFileExists{gitinfo.tex}{}{}` in the preamble and
  `gitinfo.tex` in `.gitignore`. Where the file is absent -- an Overleaf
  build, or a plain `latexmk` run -- the date stands alone.

- `\code{...}` -- typewriter text that may break after `.` `_` `-` `:` `/`
  without inserting a hyphen, for long identifiers such as
  `module.some_long_function`. Its argument is detokenized, so `_` and
  other specials need no escaping. `\texttt` may also hyphenate, via
  `hyphenat`, except under the `hacker` font option where the body font
  is already typewriter.
- `fullwidth`, `fullwidthfigure`, `fullwidthtable` environments. The
  `fullwidth` class option makes them overhang the margins; without it
  they are ordinary groups and floats, so a document compiles either
  way. `\setfullwidthoverhang{2.5cm}` changes the overhang from its
  2cm default -- the page has 3cm margins, so 2.5cm is about the
  practical maximum.

## Supported licenses

`\license{SPDX-ID}` resolves name and URL for: MIT, Apache-2.0, GPL-3.0-only, GPL-3.0-or-later, AGPL-3.0-only, AGPL-3.0-or-later, GFDL-1.3, CC-BY-4.0, CC-BY-SA-4.0, CC-BY-NC-4.0, CC-BY-NC-SA-4.0, CC-BY-NC-ND-4.0, CC-BY-ND-4.0, CC0-1.0, BSD-2-Clause, BSD-3-Clause, LPPL-1.3c. Unknown IDs fall back to the SPDX registry URL.

## Building the examples

From the package root:

```bash
make              # build all three examples (default: lualatex)
make qbook        # build examples/qbook/main.pdf only
make qarticle     # build examples/qarticle/main.pdf only
make qslides      # build examples/qslides/main.pdf only
make ENGINE=pdf   # use pdflatex (also: ENGINE=xe for xelatex)
make clean
make distclean
make wordcount    # word count for all three examples (via texcount)
make check        # REUSE lint
make hacker-font  # generate obfuscated fonts (optional SEED=n)
```

## Structure

- `texmf/tex/latex/qtex/` — LaTeX package and class files:
  - `qbook.cls`, `qarticle.cls`, `qslides.cls` — document classes
  - `qtex.sty` — shared package (options, fonts, layout, citations, glossaries, metadata, license handling)
  - `beamerthemeqyber.sty`, `beamerinnerthemeqyber.sty`, `beamerouterthemeqyber.sty`, `beamercolorthemeqyber.sty` — Qyber beamer theme
  - `qtex-licenses.tex` — full license texts for inline output
- `texcount.opt` — macro/environment rules for `texcount` word counting
- `bin/texdep` -- emits the Makefile dependencies of a document (the files its
  `.log` says it actually read), so a rebuild triggers on a changed class,
  style or included figure. Perl, GPL-2.0-or-later; the one tool worth keeping
  from the retired `/opt/texmf` tree, moved here 29 Aug 2026. On `PATH` via
  `app` on any host that selects `tex-qtex`.
- `examples/qbook/`, `examples/qarticle/`, `examples/qslides/` — minimal working examples
- `scripts/build-hacker-font.py` — build obfuscated fonts for the `obfuscate` option

## Engine support

- **LuaLaTeX** (default, recommended) — full feature set including font obfuscation
- **pdfLaTeX** — supported; uses `fontenc`/`inputenc`/`lmodern`; no obfuscation
- **XeLaTeX** — supported via `fontspec`; obfuscation is LuaLaTeX-only

## License

LPPL-1.3c. See [LICENSE](LICENSE) and [LICENSES/](LICENSES/).
