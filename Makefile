
# http://tex.stackexchange.com/questions/40738/how-to-properly-make-a-latex-project

# keep in mind :
# 	* "$@" corresponds to the target, 
# 	* "$<" corresponds the first dependency.

# include non-file target in .PHONY
.PHONY: these.pdf all clean mrproper

MAIN = these

PANDOC = pandoc
TEX = pdflatex
BIB = biblatex

CHPTDIR=chapters
SRCS=$(shell find $(CHPTDIR) -name '*.md')
OBJS=$(patsubst %.md,$(CHPTDIR)/%.tex,$SRCS)

all: these.pdf clean

# compute the .pdf file using latexmk
$(MAIN).pdf: $(MAIN).tex $(MAIN).fmt $(OBJS)
	latexmk  				\
		-pdf 				\
		-pdflatex="$(TEX)"  \
		-use-make $<
		# use-make useless

$(MAIN).fmt: header.tex
	$(TEX)                  \
	    -ini                \
	    -jobname="$(MAIN)"  \
	    "&$(TEX) header.tex\dump"

# compute .tex files from .md files related to chapters
$(OBJS):
		cd $(CHPTDIR); make

# clean temporary files
clean: 
	latexmk -c
	rm these.m???
	cd $(CHPTDIR); make clean

# pas très propre le rm these.m??? mais très chiant

# clean temporary files + PDF output
mrproper: 
	latexmk -C
	cd $(CHPTDIR); make clean

