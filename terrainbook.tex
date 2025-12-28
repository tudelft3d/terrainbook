
\documentclass[
  fontsize=10pt, % Base font size
  twoside=true, % Use different layouts for even and odd pages (in particular, if twoside=true, the margin column will be always on the outside)
  % open=any, % If twoside=true, uncomment this to force new chapters to start on any page, not only on right (odd) pages
  secnumdepth=1, % How deep to number headings. Defaults to 1 (sections)
  %chapterprefix=true, % Uncomment to use the word "Chapter" before chapter numbers everywhere they appear
  %chapterentrydots=true, % Uncomment to output dots from the chapter name to the page number in the table of contents
  numbers=noenddot, % Comment to output dots after chapter numbers; the most common values for this option are: enddot, noenddot and auto (see the KOMAScript documentation for an in-depth explanation)
  % draft=true, % If uncommented, rulers will be added in the header and footer
  % overfullrule=true, % If uncommented, overly long lines will be marked by a black box; useful for correcting spacing problems
]{kaobook}

% Choose the language
\usepackage[english]{babel} % Load characters and hyphenation
\usepackage[english=british]{csquotes}  % English quotes

% Load packages for testing
\usepackage{blindtext}
%\usepackage{showframe} % Uncomment to show boxes around the text area, margin, header and footer
%\usepackage{showlabels} % Uncomment to output the content of \label commands to the document where they are used

% Load the bibliography package
% \usepackage{styles/kaobiblio}
% \addbibresource{book-template.bib} % Bibliography file

% Load the package for hyperreferences
\usepackage{kaorefs}

% Load mathematical packages for theorems and related environments. NOTE: choose only one between 'mdftheorems' and 'plaintheorems'.
% \usepackage{styles/mdftheorems}
%\usepackage{styles/plaintheorems}
\usepackage[framed=true]{kaotheorems}

\usepackage{float}
\newfloat{floatbox}{tb}{ext2}

% -- to fix the latex compilation and "TeX capacity exceeded, sorry"
% -- https://github.com/fmarotta/kaobook/issues/308
\usepackage[disablepatch=caption]{tocbasic}

\usepackage{pdfpages}

% \graphicspath{{images/}{./}} % Paths in which to look for images

\makeindex[columns=3, title=Index, intoc] % Make LaTeX produce the files required to compile the index

\makeglossaries % Make LaTeX produce the files required to compile the glossary

\makenomenclature % Make LaTeX produce the files required to compile the nomenclature

%-- new box environments
\definecolor{redish}{HTML}{F7E0E0}
\definecolor{blueish}{HTML}{DDECF1}
\definecolor{greenish}{HTML}{E6E6E6}
\newmdenv[
  style=kaoboxstyle,
  backgroundcolor=redish,
  frametitlebackgroundcolor=redish,
]{kaobox-practice}
\newmdenv[
  style=kaoboxstyle,
  backgroundcolor=blueish,
  frametitlebackgroundcolor=blueish,
]{kaobox-toread}
\newmdenv[
  style=kaoboxstyle,
  backgroundcolor=greenish,
  frametitlebackgroundcolor=greenish,
]{kaobox-info}
\newcommand{\youtube}[2][0pt]{%
  \marginnote[#1]{
    \begin{kaobox}[
      backgroundcolor=blueish,
      frametitlebackgroundcolor=blueish
    ]
    \center{\faYoutube\ \href{https://#2}{#2}}
    \end{kaobox}
  }
  \vspace{1cm}
}

%----------------------------------------
% HL
%----------------------------------------

% \usepackage[backend=biber,natbib=true,maxcitenames=2,maxbibnames=10,giveninits=true,isbn=false,doi=false,url=false,defernumbers=true,style=numeric,sorting=ydnt]{biblatex} 
\usepackage[backend=bibtex,natbib=true,style=authoryear,citestyle=authoryear,maxcitenames=2,maxbibnames=10,giveninits=true,isbn=false,doi=false,dashed=false]{biblatex}
\bibliography{refs/tb} % Bibliography file
%-- remove the In:
\renewbibmacro{in:}{}
%-- remove the "" before/after the title of the paper
\DeclareFieldFormat[article, inbook, incollection, inproceedings, misc, thesis, unpublished]{title}{#1}



% Command to print a citation in the margins
\newcommand{\sidecitet}[1]{% The optional parameter is the 
%vertical shift; 
%the mandatory one is the citation key
  \citet{#1}% With this we print the marker in the text and add the item to the 
  %bibliography at the end \margincitation
  \marginnote{\citeauthor*{#1} (\citeyear{#1}), \citetitle{#1}\\}% 
  %Create a marginnote for each item
}

\newcommand{\sidecitep}[1]{% The optional parameter is the 
%vertical shift; 
%the mandatory one is the citation key
  \citep{#1}% With this we print the marker in the text and add the item to the 
  %bibliography at the end \margincitation
  \marginnote{\citeauthor*{#1} (\citeyear{#1}), \citetitle{#1}\\}% 
  %Create a marginnote for each item
}

\renewcommand{\ie}{ie}
\renewcommand{\eg}{eg}



\setcounter{margintocdepth}{1}
\setcounter{tocdepth}{1}
\setcounter{secnumdepth}{3}

\usepackage{subcaption}
\usepackage{fontawesome}
\usepackage{gensymb}
\usepackage{xurl}
\usepackage{hyperref}
\hypersetup{breaklinks=true}
\usepackage{siunitx}



%----------------------------------------------------------------------------------------

\begin{document}

%----------------------------------------------------------------------------------------
% BOOK INFORMATION
%----------------------------------------------------------------------------------------


\title{Computational modelling of terrains}
\author{Hugo Ledoux \hspace{10mm} Ken Arroyo Ohori\\ Ravi Peters \hspace{17mm} Maarten Pronk}
\date{\texttt{v2025.1}}

% \publishers{\includegraphics[width=\linewidth]{front-back/imhof.png}}

%----------------------------------------------------------------------------------------

\frontmatter % Denotes the start of the pre-document content, uses roman numerals

%----------------------------------------------------------------------------------------
% OPENING PAGE
%----------------------------------------------------------------------------------------

%\makeatletter
%\extratitle{
% % In the title page, the title is vspaced by 9.5\baselineskip
% \vspace*{9\baselineskip}
% \vspace*{\parskip}
% \begin{center}
%   % In the title page, \huge is set after the komafont for title
%   \usekomafont{title}\huge\@title
% \end{center}
%}
%\makeatother

%----------------------------------------------------------------------------------------
% COPYRIGHT PAGE
%----------------------------------------------------------------------------------------

\includepdf{cover/cover_front.pdf}
\cleardoublepage


\input{front-back/pre}



%----------------------------------------------------------------------------------------
% OUTPUT TITLE PAGE AND PREVIOUS
%----------------------------------------------------------------------------------------

\maketitle

%----------------------------------------------------------------------------------------
% PREFACE
%----------------------------------------------------------------------------------------

\input{front-back/preface.tex}

%----------------------------------------------------------------------------------------
% TABLE OF CONTENTS & LIST OF FIGURES/TABLES
%----------------------------------------------------------------------------------------

\begingroup % Local scope for the following commands

% Define the style for the TOC, LOF, and LOT
%\setstretch{1} % Uncomment to modify line spacing in the ToC
%\hypersetup{linkcolor=blue} % Uncomment to set the colour of links in the ToC
\setlength{\textheight}{23cm} % Manually adjust the height of the ToC pages

% Turn on compatibility mode for the etoc package
\etocstandarddisplaystyle % "toc display" as if etoc was not loaded
\etocstandardlines % "toc lines as if etoc was not loaded

\tableofcontents % Output the table of contents

% \listoffigures % Output the list of figures

% Comment both of the following lines to have the LOF and the LOT on different pages
% \let\cleardoublepage\bigskip
% \let\clearpage\bigskip

% \listoftables % Output the list of tables

\endgroup

%----------------------------------------------------------------------------------------
% MAIN BODY
%----------------------------------------------------------------------------------------

\mainmatter 
\setchapterstyle{kao} % Choose the default chapter heading style

\include{whatisterrain/whatisterrain} %- 01
\include{acquisition/acquisition}     %- 02
\include{gdem/gdem}                   %- 03
\include{dtvd/dtvd}                   %- 04
\include{interpol/interpol}           %- 05
\include{kriging/kriging}             %- 06
\include{conversion/conversion}       %- 07
\include{topofeatures/topofeatures}   %- 08
\include{visibility/visibility}       %- 09
\include{runoff/runoff}               %- 10
\include{pcprocessing/pcprocessing}   %- 11
\include{massive/massive}             %- 12
\include{spatialextent/spatialextent} %- 13
\include{bathymetry/bathymetry}       %- 14
%----------------------------------------------------------------------------------------

\pagelayout{wide} % No margins
\addpart{Appendices}
\pagelayout{margin} % Restore margins
\appendix
\include{appendices/pcformats/pcformats} %- A
\include{appendices/ahn/ahn}             %- B
\include{appendices/normalplane/normalplane} %- C
\include{appendices/equations/equations} %- D

\backmatter % Denotes the end of the main document content
\setchapterstyle{plain} % Output plain chapters from this point onwards

%----------------------------------------------------------------------------------------
% BIBLIOGRAPHY
%----------------------------------------------------------------------------------------

% The bibliography needs to be compiled with biber using your LaTeX editor, or on the command line with 'biber main' from the template directory

% \defbibnote{bibnote}{Here are the references in citation order.\par\bigskip} % Prepend this text to the bibliography
\printbibliography[heading=bibintoc, title=Bibliography] % Add the bibliography heading to the ToC, set the title of the bibliography and output the bibliography note

%----------------------------------------------------------------------------------------
% INDEX
%----------------------------------------------------------------------------------------

% The index needs to be compiled on the command line with 'makeindex main' from the template directory

\printindex % Output the index

%----------------------------------------------------------------------------------------
% BACK COVER
%----------------------------------------------------------------------------------------

% If you have a PDF/image file that you want to use as a back cover, uncomment the following lines

\clearpage
\thispagestyle{empty}
\null%
\clearpage
\includepdf{cover/cover_back.pdf}

%----------------------------------------------------------------------------------------

\end{document}
