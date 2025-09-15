#!/usr/bin/sh

DATE_COVER=$(date "+%d %B %Y")

SOURCE_FORMAT="markdown\
+tex_math_single_backslash\
+raw_tex\
+tex_math_dollars\
+pipe_tables\
+backtick_code_blocks\
+auto_identifiers\
+strikeout\
+yaml_metadata_block\
+implicit_figures\
+all_symbols_escapable\
+link_attributes\
+smart\
+fenced_divs\
+raw_html\
+markdown_in_html_blocks"

pandoc -s --dpi=300 --slide-level 2 --listings --shift-heading-level=0 --pdf-engine=xelatex --columns=50 -f "$SOURCE_FORMAT"   -V lang=en-US -t beamer presentation.md -o presentation.tex

sed -i -E 's/\\begin\{lstlisting\}\[language=C\]/\\begin{minted}[linenos,mathescape,breaklines,breakanywhere,texcomments,escapeinside=||]{c}/g' presentation.tex
sed -i -E 's/\\begin\{lstlisting\}\[language=\{C\+\+\}\]/\\begin{minted}[linenos,mathescape,breaklines,breakanywhere,texcomments,escapeinside=||]{cpp}/g' presentation.tex
sed -i -E 's/\\begin\{lstlisting\}\[language=Caml\]/\\begin{minted}[linenos,mathescape,breaklines,breakanywhere,texcomments]{ocaml}/g' presentation.tex
sed -i -E 's/\\end\{lstlisting\}/\\end{minted}/g' presentation.tex
xelatex -shell-escape presentation.tex
