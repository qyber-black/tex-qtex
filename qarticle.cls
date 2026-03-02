% qarticle.cls -- Qyber article class (section-level, no chapters)
% Extends article; uses qtex.sty for shared options and layout.
% No front/main/back matter.
% SPDX-FileCopyrightText: 2026 Frank Langbein <frank@langbein.org>
% SPDX-License-Identifier: LPPL-1.3c

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{qarticle}[2026/03/02 Qyber article class]

\PassOptionsToPackage{article}{qtex}

% Options known to qtex are forwarded; twoside/oneside also go to article.
% Everything else goes to the base class.
\newcommand{\qarticle@fwd}[1]{\PassOptionsToPackage{#1}{qtex}}
\DeclareOption{twoside}{\PassOptionsToClass{twoside}{article}\qarticle@fwd{twoside}}
\DeclareOption{oneside}{\PassOptionsToClass{oneside}{article}\qarticle@fwd{oneside}}
\DeclareOption{sans}{\qarticle@fwd{sans}}
\DeclareOption{serif}{\qarticle@fwd{serif}}
\DeclareOption{hacker}{\qarticle@fwd{hacker}}
\DeclareOption{noobfuscate}{\qarticle@fwd{noobfuscate}}
\DeclareOption{obfuscate}{\qarticle@fwd{obfuscate}}
\DeclareOption{harvard}{\qarticle@fwd{harvard}}
\DeclareOption{numeric}{\qarticle@fwd{numeric}}
\DeclareOption{single}{\qarticle@fwd{single}}
\DeclareOption{onehalfspacing}{\qarticle@fwd{onehalfspacing}}
\DeclareOption{linespread115}{\qarticle@fwd{linespread115}}
\DeclareOption{linespread12}{\qarticle@fwd{linespread12}}
\DeclareOption{parskip}{\qarticle@fwd{parskip}}
\DeclareOption{parindent}{\qarticle@fwd{parindent}}
\DeclareOption{fullwidth}{\qarticle@fwd{fullwidth}}
\DeclareOption{italic}{\qarticle@fwd{italic}}
\DeclareOption{raggedright}{\qarticle@fwd{raggedright}}
\DeclareOption{justified}{\qarticle@fwd{justified}}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}

\ProcessOptions\relax
\LoadClass[12pt,a4paper]{article}
\RequirePackage{qtex}

\makeatletter

% Section formatting, page styles, and parindent handling provided by qtex.sty.

\renewcommand{\sectionmark}[1]{\markboth{\ifnum\c@secnumdepth>\z@\thesection\ \fi#1}{}}
\renewcommand{\subsectionmark}[1]{\markright{\ifnum\c@secnumdepth>\m@ne\thesubsection\ \fi#1}}

\AtBeginDocument{%
  \@ifundefined{qtex@opened@lof}{}{\immediate\closeout\tf@lof}%
  \@ifundefined{qtex@opened@lot}{}{\immediate\closeout\tf@lot}%
  \@ifundefined{qtex@opened@loa}{}{\immediate\closeout\tf@loa}%
}

% ------------------------------------------------------------------------------
% Abstract: no heading; rule above and below (same width as text); keywords inside; minimal vspace
% ------------------------------------------------------------------------------
\renewenvironment{abstract}{%
  \par\noindent
  \small
  \quotation
  \noindent\rule{\linewidth}{0.4pt}\par\vspace{0.1ex}\noindent%
}{%
  \ifqtex@haskeywords
    \par\vspace{0.25ex}\noindent\textbf{Keywords:}\ \qtex@keywords%
  \fi
  \par\vspace*{-\baselineskip}\vspace{1ex}%
  \noindent\rule{\linewidth}{0.4pt}%
  \endquotation
}

% ------------------------------------------------------------------------------
% Authors
% \author{Name}{Details}
% - Name: printed under the title (names separated by \quad, no commas).
% - Details: free-form text (e.g. institution, e-mail, URL, ORCID), printed via
%   \printauthors near the end of the document.
% ------------------------------------------------------------------------------
\newcounter{qarticle@authorcount}
\newif\ifqarticle@hasauthors
\qarticle@hasauthorsfalse

\renewcommand{\author}[2]{%
  \global\qarticle@hasauthorstrue
  \stepcounter{qarticle@authorcount}%
  \expandafter\gdef\csname qarticle@authorname@\theqarticle@authorcount\endcsname{#1}%
  \expandafter\gdef\csname qarticle@authordetails@\theqarticle@authorcount\endcsname{#2}%
}

\newcommand{\printauthors}{%
  \ifqarticle@hasauthors
    \section*{Authors}\label{sec:authors}%
    \@tempcnta=\z@
    \loop
      \advance\@tempcnta by \@ne
      \ifnum\@tempcnta > \value{qarticle@authorcount}\relax
      \else
        \expandafter\let\expandafter\qarticle@name\csname qarticle@authorname@\the\@tempcnta\endcsname
        \expandafter\let\expandafter\qarticle@details\csname qarticle@authordetails@\the\@tempcnta\endcsname
        \par\noindent\textbf{\qarticle@name:}%
        \ifx\qarticle@details\@empty\else\ \qarticle@details\fi
        \par\vspace{0.75\baselineskip}%
      \fi
    \ifnum\@tempcnta < \value{qarticle@authorcount}\relax \repeat
  \fi
}

% ------------------------------------------------------------------------------
% Maketitle: article-style (no titlepage) — title, author, institution, date
% Use \begin{abstract}...\end{abstract} after \maketitle for the abstract.
% \maketitlewithabstract{...} is a shorthand for \maketitle + abstract block.
% ------------------------------------------------------------------------------
\renewcommand{\maketitle}{%
  \par
  \begingroup
    \if@twocolumn
      \ifnum \col@number=\@ne
        \@maketitle
      \else
        \twocolumn[\@maketitle]%
      \fi
    \else
      \global\@topnum\z@
      \@maketitle
    \fi
    \thispagestyle{empty}%
  \endgroup
  \setcounter{footnote}{0}%
  \let\thanks\relax
  \let\maketitle\relax
  \let\@maketitle\relax
  \gdef\@author{}%
  \gdef\@title{}%
  \gdef\@date{}%
}
\def\@maketitle{%
  \begin{center}%
    \vspace*{1.5ex}%
    {\LARGE\bfseries \qtex@title\par}%
    \vspace{1.5ex}%
    {\large
      \lineskip .5em
      \ifqarticle@hasauthors
        \@tempcnta=\z@
        \loop
          \advance\@tempcnta by \@ne
          \ifnum\@tempcnta > \value{qarticle@authorcount}\relax
          \else
            \ifnum\@tempcnta > \@ne \quad\fi
            \csname qarticle@authorname@\the\@tempcnta\endcsname
          \fi
        \ifnum\@tempcnta < \value{qarticle@authorcount}\relax \repeat
        \par
      \else
        % Fallback for legacy single-author use via \author{Name} in qtex.sty
        \qtex@author\par
      \fi
    }%
    \vspace{0.5ex}%
    {\normalsize \qtex@date\par}%
    \vspace{0.5ex}%
  \end{center}%
}
\newcommand{\maketitlewithabstract}[1]{%
  \maketitle
  \begin{abstract}
    #1%
  \end{abstract}
}

% ------------------------------------------------------------------------------
% Bibliography (optional License section before refs)
% ------------------------------------------------------------------------------
\newcommand{\bib}[1]{%
  \qtex@bib@selectstyle
  \ifqtex@license
    \qtex@resolvelicense
    \section*{License}\label{sec:license}{\small%
    Copyright\ \textcopyright\ \ifstrempty{\qtex@licenseyear}{\number\year}{\qtex@licenseyear}\ %
    \ifstrempty{\qtex@copyrightholder}{\qtex@author}{\qtex@copyrightholder}.\\
    This work is licensed under the \qtex@lic@name.\\{\ttfamily SPDX-License-Identifier: \qtex@licenseid}\\
    Full text: \url{\qtex@lic@url}}\par
  \fi
  \bibliography{#1}%
}

\makeatother
