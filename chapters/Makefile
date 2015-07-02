
# http://tex.stackexchange.com/questions/40738/how-to-properly-make-a-latex-project

# keep in mind :
# 	* "$@" corresponds to the target, 
# 	* "$<" corresponds the first dependency.

# include non-file target in .PHONY
.PHONY: all mrproper

TEXS := $(patsubst %.md,%.tex,$(wildcard *.md))

PANDOC = pandoc

all: $(TEXS)

%.tex:%.md
	$(PANDOC) 							\
		--biblatex						\
		--bibliography=these.bib 	\
		-o $@ $<

# remove all TEX outputs
clean: 
	rm $(TEXS)

# remove all TEX outputs then build them again
rebuild: clean all
