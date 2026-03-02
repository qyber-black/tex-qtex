% qslides.cls -- Qyber slides class (beamer-based)
% Extends beamer; uses qtex.sty for shared options, fonts, and layout tweaks.
% SPDX-FileCopyrightText: 2026 Frank Langbein <frank@langbein.org>
% SPDX-License-Identifier: LPPL-1.3c

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{qslides}[2026/03/02 Qyber slides class]

% Ensure qtex knows this is a slides document
\PassOptionsToPackage{slides}{qtex}

% --------------------------------------------------------------------------
% Options forwarded to qtex (fonts, citations, layout flags)
% --------------------------------------------------------------------------
\newcommand{\qslides@fwd}[1]{\PassOptionsToPackage{#1}{qtex}}
\DeclareOption{sans}{\qslides@fwd{sans}}
\DeclareOption{serif}{\qslides@fwd{serif}}
\DeclareOption{hacker}{\qslides@fwd{hacker}}
\DeclareOption{noobfuscate}{\qslides@fwd{noobfuscate}}
\DeclareOption{obfuscate}{\qslides@fwd{obfuscate}}
\DeclareOption{harvard}{\qslides@fwd{harvard}}
\DeclareOption{numeric}{\qslides@fwd{numeric}}
\DeclareOption{twoside}{\qslides@fwd{twoside}}
\DeclareOption{oneside}{\qslides@fwd{oneside}}
\DeclareOption{single}{\qslides@fwd{single}}
\DeclareOption{onehalfspacing}{\qslides@fwd{onehalfspacing}}
\DeclareOption{linespread115}{\qslides@fwd{linespread115}}
\DeclareOption{linespread12}{\qslides@fwd{linespread12}}
\DeclareOption{parskip}{\qslides@fwd{parskip}}
\DeclareOption{parindent}{\qslides@fwd{parindent}}
\newif\ifqslides@large
\qslides@largefalse
\DeclareOption{large}{\qslides@largetrue}
% Title page layout: default = basic (legacy), alternative = split
\newif\ifqslides@titlesplit
\qslides@titlesplitfalse
\DeclareOption{titlesplit}{\qslides@titlesplittrue}
\DeclareOption{titlebasic}{\qslides@titlesplitfalse}
\DeclareOption{italic}{\qslides@fwd{italic}}

% Any other options are passed through to beamer (aspectratio, handout, notes, ...)
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{beamer}}

\ProcessOptions\relax

% --------------------------------------------------------------------------
% Base class and shared package
% --------------------------------------------------------------------------
% t = frame content top-aligned (not vertically centred)
% 12pt default; large = 17pt (no size16.clo in standard LaTeX).
% Pass size to beamer before LoadClass so it is in the option list.
\makeatletter
\ifqslides@large
  \PassOptionsToClass{17pt}{beamer}%
\else
  \PassOptionsToClass{12pt}{beamer}%
\fi
\LoadClass[aspectratio=169,t]{beamer}%

\RequirePackage{qtex}
\RequirePackage{bibentry}

% Override qtex's link text colour for slides:
% use fg_link_col (theme blue) instead of DarkBlue.
\@ifundefined{qtex@orig@href}{}{%
  \renewcommand{\href}[2]{\qtex@orig@href{#1}{\textcolor{fg_link_col}{#2}}}%
}

% Bridge qtex metadata into beamer's title/author/date inserts
\def\inserttitle{\qtex@title}
\def\insertauthor{\qtex@author}
\def\insertdate{\qtex@date}

% --------------------------------------------------------------------------
% Qyber beamer theme (layout and colours; local copies in tex-qtex)
% Bar and title-page header dimensions scale with 12pt vs 17pt (large).
% --------------------------------------------------------------------------
\mode<presentation>
\ifqslides@large
  \newcommand{\qyber@barheight}{0.12\paperheight}%
  \newcommand{\qyber@titlepagesep}{1.25\baselineskip}%
\else
  \newcommand{\qyber@barheight}{0.11\paperheight}%
  \newcommand{\qyber@titlepagesep}{1.2\baselineskip}%
\fi
\usetheme{qyber}

% Select title page variant (defined by beamerinnerthemeqyber.sty)
\ifqslides@titlesplit
  \setbeamertemplate{title page}[qyber-split]
\else
  \setbeamertemplate{title page}[qyber-basic]
\fi

% Title page: add minimal license/copyright in a footer bar when \license{...}
% is set (qtex). Same \license, \copyrightholder, \licenseyear as
% qbook/qarticle; only a short line on the slide.
\addtobeamertemplate{title page}{}{%
  \ifqtex@license
    \qtex@resolvelicense
    % Draw license bar exactly at the bottom, spanning the full slide width.
    \begin{tikzpicture}[remember picture,overlay]
      \node[anchor=south west,inner sep=0pt] at ([xshift=\beamer@leftmargin]current page.south west) {%
        \begin{beamercolorbox}[wd=\paperwidth,dp=0.5ex,ht=1.3ex,leftskip=0.75em,rightskip=0.75em]{footer}
          \usebeamerfont{date}\scriptsize
          Copyright \textcopyright\ \ifstrempty{\qtex@licenseyear}{\number\year}{\qtex@licenseyear}\ %
          \ifstrempty{\qtex@copyrightholder}{\qtex@author}{\qtex@copyrightholder}.%
          \hfill
          Licensed under \qtex@lic@name\ (SPDX: \qtex@licenseid).%
        \end{beamercolorbox}%
      };
    \end{tikzpicture}%
  \fi
}

% Optional title-page content box for split layout (image, highlights, etc.).
% Use \titlebox{...} to set arbitrary content shown on the left in titlesplit mode.
\newcommand{\qslides@titlebox}{}%
\newcommand{\titlebox}[1]{\gdef\qslides@titlebox{#1}}

% Text emphasis and highlight: use theme colours (fg_emph_col, fg_highlight_col, fg_head_col).
% \alert is from beamer and uses alerted text color (fg_highlight_col).
\renewcommand{\emph}[1]{\textcolor{fg_emph_col}{#1}}
\newcommand{\hi}[1]{\colorbox{fg_highlight_col}{\textcolor{fg_body_col}{#1}}}

% Link colours: fg_link_col (blue) for links, fg_ref_col (green) for URLs and citations.
\AtEndPreamble{%
  \hypersetup{linkcolor=fg_link_col,urlcolor=fg_ref_col,citecolor=fg_ref_col}%
  \def\UrlFont{\ttfamily\color{fg_ref_col}}%
}

% --------------------------------------------------------------------------
% Footnotes: collect per-frame in a global macro, render as a TikZ-overlay
% footer bar at the slide bottom after each \footnote / \qslides@footnotetextonly
% call.  Same styling as the title-page license footer (beamer colour
% "footer", \scriptsize, full \paperwidth).
%
% Beamer typesets frame bodies inside a \savebox; global toks/macro changes
% made during body typesetting are not visible in the footline template.
% Therefore each footnote call immediately draws a TikZ overlay bar
% containing ALL footnotes accumulated so far.  Because the overlay is
% absolute-positioned, only the last (most complete) bar is visible.
% --------------------------------------------------------------------------

% Suppress beamer's default per-footnote output and the default rule.
\setbeamertemplate{footnote}{}
\renewcommand{\footnoterule}{\relax}

% Global macro accumulating footnote entries for the current frame.
\gdef\qslides@fn@list{}

% Reset footnote counter and list at the start of every frame.
\def\qslides@fn@reset{\gdef\qslides@fn@list{}\setcounter{footnote}{0}}
\BeforeBeginEnvironment{frame}{\qslides@fn@reset}

% Draw the footer bar with all accumulated footnotes (TikZ overlay).
% \newblock is locally redefined to a space so bibentry references flow
% on a single line instead of breaking across lines.
\newcommand{\qslides@fn@render}{%
  \ifx\qslides@fn@list\@empty\else
    \begin{tikzpicture}[remember picture,overlay]
      \node[anchor=south west,inner sep=0pt]
        at ([xshift=\beamer@leftmargin]current page.south west) {%
        \begin{beamercolorbox}[wd=\paperwidth,
                               leftskip=0.75em,
                               rightskip=0.75em,
                               sep=0.5ex]{footer}%
          \usebeamerfont{date}\scriptsize
          \def\newblock{\ }%
          \qslides@fn@list
        \end{beamercolorbox}%
      };
    \end{tikzpicture}%
  \fi
}

% \footnote{text}: insert [N] marker in the text, append to list, redraw bar.
\renewcommand{\footnote}[1]{%
  \stepcounter{footnote}%
  {\ [\textcolor{fg_ref_col}{\thefootnote}]}%
  \protected@xdef\qslides@fn@list{%
    \unexpanded\expandafter{\qslides@fn@list}%
    {[\thefootnote]}~\unexpanded{#1}\noexpand\par
  }%
  \qslides@fn@render
}

% Append text to the footer bar with a [N] prefix matching the inline cite
% marker (used by \citep/\citet).  The marker number is passed as #1, the
% reference text as #2.
\newcommand{\qslides@fn@addcite}[2]{%
  \protected@xdef\qslides@fn@list{%
    \unexpanded\expandafter{\qslides@fn@list}%
    {[#1]}~\unexpanded{#2}\noexpand\par
  }%
  \qslides@fn@render
}

% --------------------------------------------------------------------------
% Bibliography integration for slides: \citep / \citet put full references
% into footnotes via \bibentry.  Optional arguments are not forwarded;
% use \qslides@orig@citep / \qslides@orig@citet directly if needed.
% --------------------------------------------------------------------------
\let\qslides@orig@citep\citep
\let\qslides@orig@citet\citet
\newcommand{\slidesbib}[1]{%
  \gdef\qslides@bibfile{#1}%
  \AtBeginDocument{%
    \qtex@bib@selectstyle
    \nobibliography{#1}%
  }%
}
\newcommand{\qslides@citep}[1]{%
  \qslides@orig@citep{#1}%
  \stepcounter{footnote}%
  \qslides@fn@addcite{\thefootnote}{\bibentry{#1}}%
}
\newcommand{\qslides@citet}[1]{%
  \qslides@orig@citet{#1}%
  \stepcounter{footnote}%
  \qslides@fn@addcite{\thefootnote}{\bibentry{#1}}%
}
\AtBeginDocument{%
  \let\citep\qslides@citep
  \let\citet\qslides@citet
}%

% --------------------------------------------------------------------------
% Slide layout helpers
% --------------------------------------------------------------------------

% Headerless content box: just your content, no red title bar.
% Optional: \begin{slidebox}[border] for a thin border; \begin{slidebox} for no border.
\newbox\qslides@slidebox
\newenvironment{slidebox}[1][]{%
  \def\qslides@slidebox@opt{#1}%
  \par\noindent
  \ifx\qslides@slidebox@opt\@empty
    \begin{beamercolorbox}[wd=\linewidth,sep=0.75ex,leftskip=0.75ex,rightskip=0.75ex]{normal text}%
  \else
    \setlength{\fboxrule}{0.5pt}%
    \setlength{\fboxsep}{0pt}%
    \global\setbox\qslides@slidebox=\vbox\bgroup
    \begin{beamercolorbox}[wd=\dimexpr\linewidth-2\fboxrule\relax,sep=0.75ex,leftskip=0.75ex,rightskip=0.75ex]{normal text}%
  \fi
}{%
  \ifx\qslides@slidebox@opt\@empty
    \end{beamercolorbox}%
  \else
    \end{beamercolorbox}%
    \egroup
    \fcolorbox{bar_text_col}{page_col}{\box\qslides@slidebox}%
  \fi
  \par
}

% Compensate frametitle's \vskip-3pt for columns environments so they get the
% same spacing as paragraph text.  Applied once to every \begin{columns}.
\AtBeginEnvironment{columns}{\vspace{1ex}}

% Two-column layout: whole slide or part of a slide.
% Use \begin{twocolumns}[t] or [c] or [b] for vertical alignment, then
% \begin{leftcolumn}...\end{leftcolumn} and \begin{rightcolumn}...\end{rightcolumn}.
\newenvironment{twocolumns}[1][t]{%
  \begin{columns}[onlytextwidth,#1]%
}{%
  \end{columns}%
}
\newenvironment{leftcolumn}{%
  \begin{column}{0.48\linewidth}%
}{%
  \end{column}%
}
\newenvironment{rightcolumn}{%
  \begin{column}{0.48\linewidth}%
}{%
  \end{column}%
}

% Place a box at a position and size given in relative units (0.0--1.0) over
% the full text area. Text area: width \textwidth, height 0.8\paperheight
% (between title bar and bottom). (0,0) = bottom-left, (1,1) = top-right.
% Optional: TikZ anchor (default south west). \placebox[anchor]{x}{y}{w}{h}{content}
\newcommand{\placebox}{\@ifnextchar[{\qslides@placeboxopt}{\qslides@placeboxnoopt}}
\newcommand{\qslides@placeboxnoopt}[5]{\qslides@placeboxdo{south west}{#1}{#2}{#3}{#4}{#5}}
\newcommand{\qslides@placeboxopt}[6][south west]{\qslides@placeboxdo{#1}{#2}{#3}{#4}{#5}{#6}}
\newcommand{\qslides@placeboxdo}[6]{%
  \begin{tikzpicture}[remember picture, overlay, shift={(current page.south west)}, inner sep=0pt]%
  \pgfmathsetlengthmacro{\qslides@px}{\beamer@leftmargin + #2*\textwidth}%
  \pgfmathsetlengthmacro{\qslides@py}{0.1*\paperheight + #3*0.8*\paperheight}%
  \pgfmathsetlengthmacro{\qslides@bw}{#4*\textwidth}%
  \pgfmathsetlengthmacro{\qslides@bh}{#5*0.8*\paperheight}%
  \node[anchor=#1] at (\qslides@px, \qslides@py) {%
    \begin{minipage}[t][\qslides@bh][t]{\qslides@bw}%
    #6%
    \end{minipage}%
  };%
  \end{tikzpicture}%
}

% Convenience wrapper: set the URLs shown in the header/footer right box.
% Usage: \slidesurls{\url{https://example.org/}\\\url{https://second.example/}}
\gdef\qslides@urls{}%
\newcommand{\slidesurls}[1]{\gdef\qslides@urls{#1}}
\AtBeginDocument{%
  \ifx\qslides@urls\@empty\else
    \@ifundefined{setqyberurls}{}{%
      \expandafter\setqyberurls\expandafter{\qslides@urls}%
    }%
  \fi
}

\makeatother

