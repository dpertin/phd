
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

$(OBJS):
		cd $(CHPTDIR); make

# clean temporary files
clean: 
	latexmk -c
	cd $(CHPTDIR); make clean

# clean temporary files + PDF output
mrproper: 
	latexmk -C

