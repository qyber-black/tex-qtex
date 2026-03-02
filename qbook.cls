% qbook.cls -- Qyber book class (thesis/dissertation style)
% Extends book; uses qtex.sty for shared options and layout.
% SPDX-FileCopyrightText: 2026 Frank Langbein <frank@langbein.org>
% SPDX-License-Identifier: LPPL-1.3c

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{qbook}[2026/03/02 Qyber book class]

\PassOptionsToPackage{book}{qtex}

% Options known to qtex are forwarded; twoside/oneside also go to book.
% Everything else goes to the base class.
\newcommand{\qbook@fwd}[1]{\PassOptionsToPackage{#1}{qtex}}
\DeclareOption{twoside}{\PassOptionsToClass{twoside}{book}\qbook@fwd{twoside}}
\DeclareOption{oneside}{\PassOptionsToClass{oneside}{book}\qbook@fwd{oneside}}
\DeclareOption{sans}{\qbook@fwd{sans}}
\DeclareOption{serif}{\qbook@fwd{serif}}
\DeclareOption{hacker}{\qbook@fwd{hacker}}
\DeclareOption{noobfuscate}{\qbook@fwd{noobfuscate}}
\DeclareOption{obfuscate}{\qbook@fwd{obfuscate}}
\DeclareOption{harvard}{\qbook@fwd{harvard}}
\DeclareOption{numeric}{\qbook@fwd{numeric}}
\DeclareOption{single}{\qbook@fwd{single}}
\DeclareOption{onehalfspacing}{\qbook@fwd{onehalfspacing}}
\DeclareOption{linespread115}{\qbook@fwd{linespread115}}
\DeclareOption{linespread12}{\qbook@fwd{linespread12}}
\DeclareOption{parskip}{\qbook@fwd{parskip}}
\DeclareOption{parindent}{\qbook@fwd{parindent}}
\DeclareOption{fullwidth}{\qbook@fwd{fullwidth}}
\DeclareOption{italic}{\qbook@fwd{italic}}
\DeclareOption{raggedright}{\qbook@fwd{raggedright}}
\DeclareOption{justified}{\qbook@fwd{justified}}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{book}}

\ProcessOptions\relax
\LoadClass[12pt,a4paper]{book}
\RequirePackage{qtex}

\makeatletter

% ------------------------------------------------------------------------------
% Front matter: roman numerals, secnumdepth/tocdepth, close LOF/LOT/LOA
% ------------------------------------------------------------------------------
\AtBeginDocument{%
  \@ifundefined{qtex@opened@lof}{}{\immediate\closeout\tf@lof}%
  \@ifundefined{qtex@opened@lot}{}{\immediate\closeout\tf@lot}%
  \@ifundefined{qtex@opened@loa}{}{\immediate\closeout\tf@loa}%
  \@mainmatterfalse
  \pagenumbering{roman}%
  \setcounter{secnumdepth}{-1}%
  \setcounter{tocdepth}{0}%
}

% Avoid leading empty page: first \frontmatter must not do \cleardoublepage
\newif\ifqbook@firstfrontmatter
\qbook@firstfrontmattertrue
\let\qbook@orig@frontmatter\frontmatter
\renewcommand{\frontmatter}{%
  \ifqbook@firstfrontmatter
    \global\qbook@firstfrontmatterfalse
    \@mainmatterfalse
  \else
    \qbook@orig@frontmatter
  \fi
}

\let\qbook@orig@mainmatter\mainmatter
\renewcommand{\mainmatter}{%
  \setcounter{secnumdepth}{3}%
  \setcounter{tocdepth}{3}%
  \addtocontents{toc}{\protect\setcounter{tocdepth}{3}}%
  \qbook@orig@mainmatter
}
\let\qbook@orig@subsection\subsection
\renewcommand{\subsection}{%
  \if@mainmatter\else
    \PackageWarning{qbook}{Do not use \string\subsection\space in front matter; use \string\section\space only}%
  \fi
  \qbook@orig@subsection
}
\let\qbook@orig@subsubsection\subsubsection
\renewcommand{\subsubsection}{%
  \if@mainmatter\else
    \PackageWarning{qbook}{Do not use \string\subsubsection\space in front matter; use \string\section\space only}%
  \fi
  \qbook@orig@subsubsection
}

% Section formatting, page styles (plain/empty), and parindent handling
% provided by qtex.sty. Only chapter-specific page styles remain here.

\newlength{\qbook@headruleheight@thick}
\setlength{\qbook@headruleheight@thick}{3.2pt}

\fancypagestyle{plainchapter}{%
  \fancyhf{}%
  \ifqtex@twoside
    \fancyhead[LE,RO]{\thepage}%
    \fancyhead[LO,RE]{\textls[50]{\scshape\leftmark}}%
  \else
    \fancyhead[L]{\textls[50]{\scshape\leftmark}}%
    \fancyhead[R]{\thepage}%
  \fi
  \renewcommand{\headrule}{%
    \begingroup
      \normalfont
      \setlength{\dimen0}{3em}%
      \vskip2pt
      \hrule\@height\qtex@headruleheight\@width\headwidth
      \vskip-\qtex@headruleheight
      \hbox to\headwidth{\hfill\vrule\@height\qbook@headruleheight@thick\@width\dimen0}%
      \vskip-0.3\baselineskip
    \endgroup
  }%
  \renewcommand{\headrulewidth}{0pt}%
}
\fancypagestyle{chapter}{%
  \fancyhf{}%
  \ifqtex@twoside
    \fancyhead[LE,RO]{\thepage}%
    \fancyhead[LO,RE]{\textls[50]{\scshape\leftmark}}%
  \else
    \fancyhead[L]{\textls[50]{\scshape\leftmark}}%
    \fancyhead[R]{\thepage}%
  \fi
  \renewcommand{\headrule}{%
    \begingroup
      \normalfont
      \setlength{\dimen0}{0pt}%
      \settowidth{\dimen0}{\Large\textls[50]{\scshape\ifqtex@italic\itshape\else\bfseries\fi\ \MakeUppercase{\@chapapp}~\qbook@chapterlabel}}%
      \vskip2pt
      \hrule\@height\qtex@headruleheight\@width\headwidth
      \vskip-\qtex@headruleheight
      \hbox to\headwidth{\hfill\vrule\@height\qbook@headruleheight@thick\@width\dimen0}%
      \hbox to\headwidth{\hfill\Large\textls[50]{\scshape\ifqtex@italic\itshape\else\bfseries\fi \MakeUppercase{\@chapapp}~\qbook@chapterlabel}}%
      \vskip-0.3\baselineskip
    \endgroup
  }%
  \renewcommand{\headrulewidth}{0pt}%
}

% ------------------------------------------------------------------------------
% Chapter and appendix headings
% ------------------------------------------------------------------------------
\def\@makechapterhead#1{%
  \vspace*{2\baselineskip}%
  {\noindent\Huge\ifqtex@italic\itshape\else\bfseries\fi
    \if@mainmatter
      \thechapter.\ %
    \else
      \ifqbook@inappendix
        \qbook@chapterletter.\ %
      \fi
    \fi
    #1\par}%
  \vspace{1.5\baselineskip}%
  \ifqtex@parindent \everypar{\noindent \everypar{}}\fi
}
\def\@makeschapterhead#1{%
  \vspace*{2\baselineskip}%
  {\noindent\Huge\ifqtex@italic\itshape\else\bfseries\fi #1\par}%
  \vspace{1.5\baselineskip}%
  \ifqtex@parindent \everypar{\noindent \everypar{}}\fi
}

\newif\ifqbook@inappendix
\qbook@inappendixfalse
\newif\ifqbook@numberedchapter
\newcommand{\qbook@chapterletter}{}
\def\qbook@chapterlabel{\ifqbook@inappendix \qbook@chapterletter \else \thechapter \fi}

\newcounter{qbook@appendixtoc@flag}
\let\qbook@orig@backmatter\backmatter
\renewcommand{\backmatter}{%
  \qbook@orig@backmatter
  \global\qbook@inappendixtrue
  \setcounter{chapter}{0}%
  \setcounter{section}{0}%
  \gdef\@chapapp{\appendixname}%
  \gdef\thechapter{\@Alph\c@chapter}%
  \gdef\thesection{\thechapter.\@arabic\c@section}%
  \gdef\thesubsection{\thesection.\@arabic\c@subsection}%
  \gdef\thesubsubsection{\thesubsection.\@arabic\c@subsubsection}%
  \gdef\theparagraph{\thesubsubsection.\@arabic\c@paragraph}%
  \gdef\thesubparagraph{\theparagraph.\@arabic\c@subparagraph}%
  \setcounter{secnumdepth}{3}%
  \setcounter{qbook@appendixtoc@flag}{0}%
}
\let\qbook@orig@appendix\appendix
\renewcommand{\appendix}{%
  \qbook@orig@appendix
  \global\qbook@inappendixtrue
}

\pretocmd{\@chapter}{%
  \if@mainmatter
    \qbook@numberedchaptertrue
    \thispagestyle{chapter}%
  \else
    \ifqbook@inappendix
      \qbook@numberedchaptertrue
      \refstepcounter{chapter}%
      \xdef\qbook@chapterletter{\@Alph\c@chapter}%
      \global\advance\c@qbook@appendixtoc@flag\@ne
      \thispagestyle{chapter}%
    \else
      \qbook@numberedchapterfalse
      \thispagestyle{plainchapter}%
    \fi
  \fi
  \pagestyle{plain}%
}{}{}

\AtBeginDocument{%
  \pretocmd{\@schapter}{\thispagestyle{plainchapter}}{}{}%
  \apptocmd{\@schapter}{%
    \qbook@numberedchapterfalse
    \chaptermark{##1}%
    \pagestyle{plain}%
  }{}{}%
}

\patchcmd{\tableofcontents}{\@starttoc{toc}}{\chaptermark{Contents}\thispagestyle{plainchapter}\@starttoc{toc}}{}{}
% MakeUppercase suppression for running heads now in qtex.sty.
\AtBeginDocument{%
  \patchcmd{\listoffigures}{\chapter*{\listfigurename}}{\chapter*{\listfigurename}\thispagestyle{plainchapter}}{}{}%
  \patchcmd{\listoftables}{\chapter*{\listtablename}}{\chapter*{\listtablename}\thispagestyle{plainchapter}}{}{}%
  \let\qbook@orig@listoffigures\listoffigures
  \renewcommand{\listoffigures}{%
    \let\qbook@saved@MakeUppercase\MakeUppercase
    \let\MakeUppercase\@firstofone
    \qbook@orig@listoffigures
    \let\MakeUppercase\qbook@saved@MakeUppercase
  }%
  \let\qbook@orig@listoftables\listoftables
  \renewcommand{\listoftables}{%
    \let\qbook@saved@MakeUppercase\MakeUppercase
    \let\MakeUppercase\@firstofone
    \qbook@orig@listoftables
    \let\MakeUppercase\qbook@saved@MakeUppercase
  }%
  \@ifundefined{listofalgorithms}{}{%
    \let\qbook@orig@listofalgorithms\listofalgorithms
    \renewcommand{\listofalgorithms}{%
      \let\qbook@saved@MakeUppercase\MakeUppercase
      \let\MakeUppercase\@firstofone
      \qbook@orig@listofalgorithms
      \let\MakeUppercase\qbook@saved@MakeUppercase
    }%
  }%
}

\def\qbook@toc@name{toc}%
\def\qbook@level@chapter{chapter}%
\def\qbook@wrap@addcontentsline{%
  \let\qbook@orig@addcontentsline\addcontentsline
  \def\addcontentsline##1##2##3{%
    \edef\qbook@toc@arg{##1}%
    \edef\qbook@level@arg{##2}%
    \ifx\qbook@toc@arg\qbook@toc@name
      \ifx\qbook@level@arg\qbook@level@chapter
        \ifnum\c@qbook@appendixtoc@flag>\z@
          \global\advance\c@qbook@appendixtoc@flag\m@ne
          \qbook@orig@addcontentsline{##1}{##2}{\protect\numberline{\thechapter}##3}%
        \else
          \qbook@orig@addcontentsline{##1}{##2}{##3}%
        \fi
      \else
        \qbook@orig@addcontentsline{##1}{##2}{##3}%
      \fi
    \else
      \qbook@orig@addcontentsline{##1}{##2}{##3}%
    \fi
  }%
}
\AtBeginDocument{\qbook@wrap@addcontentsline}

\patchcmd{\thebibliography}{\bibsection}{\bibsection\addcontentsline{toc}{chapter}{\bibname}}{}{}

\renewcommand{\chaptermark}[1]{%
  \ifqbook@numberedchapter
    \markboth{\qbook@chapterlabel. #1}{}%
  \else
    \markboth{#1}{}%
  \fi
}
\renewcommand{\sectionmark}[1]{%
  \if@mainmatter
    \markboth{\ifnum\c@secnumdepth>\z@\thesection\ \fi#1}{}%
  \else
    \ifqbook@inappendix
      \markboth{\ifnum\c@secnumdepth>\z@\thesection\ \fi#1}{}%
    \fi
  \fi
}
\renewcommand{\subsectionmark}[1]{}

% ------------------------------------------------------------------------------
% Front lists (check LOF/LOT/LOA and acronyms via qtex)
% ------------------------------------------------------------------------------
\newif\ifqtex@haslof
\newif\ifqtex@haslot
\newif\ifqtex@hasloa
\newcommand{\qbook@checklof}{%
  \qtex@hasloffalse
  \begingroup
    \makeatletter
    \let\addvspace\@gobble
    \def\contentsline##1##2##3{%
      \global\qtex@hasloftrue
      \@ifnextchar\bgroup{\@gobble}{}%
    }%
    \IfFileExists{\jobname.lof}{\input{\jobname.lof}}{}%
  \endgroup
}
\newcommand{\qbook@checklot}{%
  \qtex@haslotfalse
  \begingroup
    \makeatletter
    \let\addvspace\@gobble
    \def\contentsline##1##2##3{%
      \global\qtex@haslottrue
      \@ifnextchar\bgroup{\@gobble}{}%
    }%
    \IfFileExists{\jobname.lot}{\input{\jobname.lot}}{}%
  \endgroup
}
\newcommand{\qbook@checkloa}{%
  \qtex@hasloafalse
  \begingroup
    \makeatletter
    \let\addvspace\@gobble
    \def\contentsline##1##2##3{%
      \global\qtex@hasloatrue
      \@ifnextchar\bgroup{\@gobble}{}%
    }%
    \IfFileExists{\jobname.loa}{\input{\jobname.loa}}{}%
  \endgroup
}

\newcommand{\frontlists}{%
  \tableofcontents
  \cleardoublepage
  \qbook@checklof
  \ifqtex@haslof
    \listoffigures
    \addcontentsline{toc}{chapter}{List of Figures}%
    \cleardoublepage
  \fi
  \qbook@checklot
  \ifqtex@haslot
    \listoftables
    \addcontentsline{toc}{chapter}{List of Tables}%
    \cleardoublepage
  \fi
  \qbook@checkloa
  \ifqtex@hasloa
    \listofalgorithms
    \addcontentsline{toc}{chapter}{List of Algorithms}%
    \cleardoublepage
  \fi
  \ifqtex@hasacronyms
    \printglossary[type=\acronymtype]
    \cleardoublepage
  \fi
}

% ------------------------------------------------------------------------------
% Title page, copyright, dedication, maketitle
% ------------------------------------------------------------------------------
\newcommand{\qbook@copyrightpage}{%
  \clearpage
  \thispagestyle{empty}%
  \qtex@resolvelicense
  \vfill
  \begin{center}
    \ \vfill
    Copyright\ \textcopyright\ \ifstrempty{\qtex@licenseyear}{\number\year}{\qtex@licenseyear}\ %
    \ifstrempty{\qtex@copyrightholder}{\qtex@author}{\qtex@copyrightholder}\par
    \vspace{1ex}
    This work is licensed under the \qtex@lic@name.\\{\ttfamily SPDX-License-Identifier: \qtex@licenseid}\\
    Full text: \url{\qtex@lic@url}
  \end{center}
  \cleardoublepage
}

% Output on current page (no \begin{titlepage} so no leading \newpage → no empty p.1)
% Generic book-style titlepage: title, author, optional extra line (degree),
% affiliation/publisher (university), and date. No thesis/dissertation wording.
\newcommand{\maketitlepage}{%
  \thispagestyle{empty}%
  \begin{center}
    \vspace*{3ex}
    {\Huge\bfseries \qtex@title\par}
    \vspace{3\baselineskip}
    {\LARGE \qtex@author\par}
    \ifstrempty{\qtex@degree}{}{%
      \vspace{2\baselineskip}%
      {\Large \qtex@degree\par}%
    }%
    \vfill
    {\Large \qtex@university\par}
    \vspace{2ex}
    {\Large \qtex@date\par}
  \end{center}
  \newpage
}

\newcommand{\dedication}[1]{%
  \chapter[Dedication]{}\chaptermark{Dedication}%
  \ \hfill\parbox{0.5\textwidth}{\begin{flushright}\slshape
  #1%
  \end{flushright}}\hspace{2.4em}%
}

\renewcommand{\maketitle}[1]{%
  \maketitlepage
  \ifqtex@license
    \qbook@copyrightpage
  \else
    \cleardoublepage
  \fi
  \begingroup
    \chapter{Abstract}%
    #1%
    \ifqtex@haskeywords
      \par\vspace{1\baselineskip}\noindent\textbf{Keywords:}\ \qtex@keywords\par
    \fi
  \endgroup
  \cleardoublepage
  \frontlists
}

% ------------------------------------------------------------------------------
% Bibliography
% ------------------------------------------------------------------------------
\newcommand{\bib}[1]{%
  \qtex@bib@selectstyle
  \ifqtex@license
    \qtex@resolvelicense
    \chapter*{License}\label{sec:license}%
    \qbook@numberedchapterfalse
    \chaptermark{License}%
    \addcontentsline{toc}{chapter}{License}%
    This work is licensed under the \qtex@lic@name.\\{\ttfamily SPDX-License-Identifier: \qtex@licenseid}\par
    \vspace{1ex}
    \edef\qtex@lic@textcs{qtex@licensetext@\qtex@licenseid}%
    \expandafter\@ifundefined\expandafter{\qtex@lic@textcs}{%
      The full license text is available at: \url{\qtex@lic@url}\par
    }{%
      \small
      \@nameuse{\qtex@lic@textcs}%
    }%
    \vspace{2\baselineskip}%
  \fi
  \bibliography{#1}%
}

\makeatother