
\citet{} -> #citet(<Kumler94>)
\citep{} -> #citep(<Kumler94>)

\kaobox-practice -> box-practice(title)[text]

\begin{figure*} -> #figure (without wideblock)
all subfigures in latex: convert to my special type #subfigure

\marginnote{} -> #notefigure

if only one letter is bold/emph then you can't use ** only on the letter you need to do this:
\textbf{d}igital -> #strong[d]igital

The cross-ref in Typst already add Figure and Table, so if they are written in Latex (eg Figure~\ref{}) then you should not write the "Figure" in Typst

Don't forget that figure/table caption can also contain citet and those should also be converted

Make sure of the type of the figures included: if not included then check in the ./figs/ folder to add the extension

$\mathcal{V}$ -> $cal(V)$ 
$\mathbb{R}^2$ -> $bb(R)^2$

\includegraphics[page=1,width=\linewidth]{figs/dimgis} -> #image("figs/dimgis.pdf", width: 100%, page: 1)

$\tau_{big}$ -> $tau_"big"$
