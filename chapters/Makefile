
# http://tex.stackexchange.com/questions/40738/how-to-properly-make-a-latex-project

# keep in mind :
# 	* "$@" corresponds to the target, 
# 	* "$<" corresponds the first dependency.

# include non-file target in .PHONY
.PHONY: all mrproper

TEXS := $(patsubst %.md,%.tex,$(wildcard *.md))

PANDOC = pandoc

all: $(TEXS) bidouille

# convert .md files into .tex files using pandoc
%.tex:%.md
	$(PANDOC) 							\
		-R								\
		--smart							\
		--biblatex						\
		--bibliography=these.bib		\
		-o $@ $<

# bidouille is used to manage LaTeX comments...
bidouille: $(TEXS)
	sed -i -- 's/^\\%/%/g' *.tex

# remove all pandoc outputs
clean: 
	rm $(TEXS)

# remove all pandoc outputs then build them again
rebuild: clean all
