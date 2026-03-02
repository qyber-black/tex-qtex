# Makefile for tex-qtex package (build examples for testing)
# Run: make help for targets. Engine: ENGINE=lua (default) | pdf | xe.
#
# SPDX-FileCopyrightText: 2026 Frank Langbein <frank@langbein.org>
# SPDX-License-Identifier: LPPL-1.3c

QBOOK_DIR := examples/qbook
QARTICLE_DIR := examples/qarticle
QSLIDES_DIR := examples/qslides
ENGINE ?= lua
SEED ?= $(shell date +%s)
TEXINPUTS_QBOOK := .:../..:
TEXINPUTS_QARTICLE := .:../..:
TEXINPUTS_QSLIDES := .:../..:

.PHONY: all qbook qarticle qslides clean distclean wordcount check help hacker-font

all: qbook qarticle qslides

qbook: $(QBOOK_DIR)/main.pdf
qarticle: $(QARTICLE_DIR)/main.pdf
qslides: $(QSLIDES_DIR)/main.pdf

ifeq ($(ENGINE),xe)
  LATEXMK_ENGINE = -xelatex
  LATEXMK_CMD = -xelatex="xelatex -interaction=nonstopmode -file-line-error %O %S"
else
  ifeq ($(ENGINE),lua)
    LATEXMK_ENGINE = -lualatex
    LATEXMK_CMD = -lualatex="lualatex -interaction=nonstopmode -file-line-error %O %S"
  else
    LATEXMK_ENGINE = -pdf
    LATEXMK_CMD = -pdflatex="pdflatex -interaction=nonstopmode -file-line-error %O %S"
  endif
endif

LATEXMK = latexmk

$(QBOOK_DIR)/main.pdf: qbook.cls qtex.sty $(QBOOK_DIR)/main.tex $(QBOOK_DIR)/bibliography.bib $(QBOOK_DIR)/acronyms.tex
	cd $(QBOOK_DIR) && TEXINPUTS="$(TEXINPUTS_QBOOK)" $(LATEXMK) $(LATEXMK_ENGINE) $(LATEXMK_CMD) main
	-cd $(QBOOK_DIR) && makeglossaries main
	cd $(QBOOK_DIR) && TEXINPUTS="$(TEXINPUTS_QBOOK)" $(LATEXMK) $(LATEXMK_ENGINE) $(LATEXMK_CMD) main

$(QARTICLE_DIR)/main.pdf: qarticle.cls qtex.sty $(QARTICLE_DIR)/main.tex $(QARTICLE_DIR)/bibliography.bib $(QARTICLE_DIR)/acronyms.tex
	cd $(QARTICLE_DIR) && TEXINPUTS="$(TEXINPUTS_QARTICLE)" $(LATEXMK) $(LATEXMK_ENGINE) $(LATEXMK_CMD) main
	-cd $(QARTICLE_DIR) && makeglossaries main
	cd $(QARTICLE_DIR) && TEXINPUTS="$(TEXINPUTS_QARTICLE)" $(LATEXMK) $(LATEXMK_ENGINE) $(LATEXMK_CMD) main

$(QSLIDES_DIR)/main.pdf: qslides.cls qtex.sty \
  beamerthemeqyber.sty beamerinnerthemeqyber.sty \
  beamerouterthemeqyber.sty beamercolorthemeqyber.sty \
  $(QSLIDES_DIR)/main.tex
	cd $(QSLIDES_DIR) && TEXINPUTS="$(TEXINPUTS_QSLIDES)" $(LATEXMK) $(LATEXMK_ENGINE) $(LATEXMK_CMD) main

clean:
	cd $(QBOOK_DIR) && $(LATEXMK) -c main
	cd $(QARTICLE_DIR) && $(LATEXMK) -c main
	rm -f $(QBOOK_DIR)/*.aux $(QBOOK_DIR)/*.log $(QBOOK_DIR)/*.out $(QBOOK_DIR)/*.toc $(QBOOK_DIR)/*.lof $(QBOOK_DIR)/*.lot $(QBOOK_DIR)/*.loa
	rm -f $(QBOOK_DIR)/*.bbl $(QBOOK_DIR)/*.blg $(QBOOK_DIR)/*.run.xml $(QBOOK_DIR)/*.bcf
	rm -f $(QBOOK_DIR)/*.acn $(QBOOK_DIR)/*.acr $(QBOOK_DIR)/*.alg $(QBOOK_DIR)/*.glg $(QBOOK_DIR)/*.glo $(QBOOK_DIR)/*.gls $(QBOOK_DIR)/*.ist
	rm -f $(QBOOK_DIR)/*.fls $(QBOOK_DIR)/*.fdb_latexmk $(QBOOK_DIR)/*.synctex.gz
	rm -f $(QARTICLE_DIR)/*.aux $(QARTICLE_DIR)/*.log $(QARTICLE_DIR)/*.out $(QARTICLE_DIR)/*.toc $(QARTICLE_DIR)/*.lof $(QARTICLE_DIR)/*.lot $(QARTICLE_DIR)/*.loa
	rm -f $(QARTICLE_DIR)/*.bbl $(QARTICLE_DIR)/*.blg $(QARTICLE_DIR)/*.run.xml $(QARTICLE_DIR)/*.bcf
	rm -f $(QARTICLE_DIR)/*.acn $(QARTICLE_DIR)/*.acr $(QARTICLE_DIR)/*.alg $(QARTICLE_DIR)/*.glg $(QARTICLE_DIR)/*.glo $(QARTICLE_DIR)/*.gls $(QARTICLE_DIR)/*.ist
	rm -f $(QARTICLE_DIR)/*.fls $(QARTICLE_DIR)/*.fdb_latexmk $(QARTICLE_DIR)/*.synctex.gz
	rm -f $(QSLIDES_DIR)/*.aux $(QSLIDES_DIR)/*.log $(QSLIDES_DIR)/*.out $(QSLIDES_DIR)/*.toc $(QSLIDES_DIR)/*.lof $(QSLIDES_DIR)/*.lot $(QSLIDES_DIR)/*.loa
	rm -f $(QSLIDES_DIR)/*.bbl $(QSLIDES_DIR)/*.blg $(QSLIDES_DIR)/*.run.xml $(QSLIDES_DIR)/*.bcf
	rm -f $(QSLIDES_DIR)/*.acn $(QSLIDES_DIR)/*.acr $(QSLIDES_DIR)/*.alg $(QSLIDES_DIR)/*.glg $(QSLIDES_DIR)/*.glo $(QSLIDES_DIR)/*.gls $(QSLIDES_DIR)/*.ist
	rm -f $(QSLIDES_DIR)/*.fls $(QSLIDES_DIR)/*.fdb_latexmk $(QSLIDES_DIR)/*.synctex.gz

distclean: clean
	rm -f $(QBOOK_DIR)/main.pdf $(QARTICLE_DIR)/main.pdf $(QSLIDES_DIR)/main.pdf
	rm -rf fonts

OBF_OUT_DIR := fonts
SANS_SRC_REG := $(shell kpsewhich SourceSansPro-Regular.otf 2>/dev/null)
SANS_SRC_BOLD := $(shell kpsewhich SourceSansPro-Bold.otf 2>/dev/null)
SANS_SRC_ITALIC := $(shell kpsewhich SourceSansPro-RegularIt.otf 2>/dev/null)
SANS_SRC_BOLDITALIC := $(shell kpsewhich SourceSansPro-BoldIt.otf 2>/dev/null)
ifeq ($(SANS_SRC_REG),)
  SANS_SRC_REG := $(shell kpsewhich texgyreheros-regular.otf 2>/dev/null)
  SANS_SRC_BOLD := $(shell kpsewhich texgyreheros-bold.otf 2>/dev/null)
  SANS_SRC_ITALIC := $(shell kpsewhich texgyreheros-italic.otf 2>/dev/null)
  SANS_SRC_BOLDITALIC := $(shell kpsewhich texgyreheros-bolditalic.otf 2>/dev/null)
endif
SERIF_SRC_REG := $(shell kpsewhich SourceSerifPro-Regular.otf 2>/dev/null)
SERIF_SRC_BOLD := $(shell kpsewhich SourceSerifPro-Bold.otf 2>/dev/null)
SERIF_SRC_ITALIC := $(shell kpsewhich SourceSerifPro-RegularIt.otf 2>/dev/null)
SERIF_SRC_BOLDITALIC := $(shell kpsewhich SourceSerifPro-BoldIt.otf 2>/dev/null)
ifeq ($(SERIF_SRC_REG),)
  SERIF_SRC_REG := $(shell kpsewhich texgyretermes-regular.otf 2>/dev/null)
  SERIF_SRC_BOLD := $(shell kpsewhich texgyretermes-bold.otf 2>/dev/null)
  SERIF_SRC_ITALIC := $(shell kpsewhich texgyretermes-italic.otf 2>/dev/null)
  SERIF_SRC_BOLDITALIC := $(shell kpsewhich texgyretermes-bolditalic.otf 2>/dev/null)
endif
HACKER_SRC_REG := $(firstword $(shell kpsewhich Inconsolata-Regular.otf Inconsolata-Regular.ttf FiraMono-Regular.otf FiraMono-Regular.ttf 2>/dev/null))
HACKER_SRC_BOLD := $(firstword $(shell kpsewhich Inconsolata-Bold.otf Inconsolata-Bold.ttf FiraMono-Bold.otf FiraMono-Bold.ttf 2>/dev/null))

define obfuscate_font
	@if [ -n "$(1)" ]; then \
	  python3 scripts/build-hacker-font.py --output-dir "$(OBF_OUT_DIR)" --seed "$(SEED)" --font "$(1)" --output-font "$(2)"; \
	else \
	  echo "Skipping $(2) (missing source font)"; \
	fi
endef

hacker-font:
	@mkdir -p "$(OBF_OUT_DIR)"
	@echo "Generating obfuscated fonts into $(OBF_OUT_DIR) (SEED=$(SEED))"
	$(call obfuscate_font,$(SANS_SRC_REG),sans-obfuscated.otf)
	$(call obfuscate_font,$(SANS_SRC_BOLD),sans-obfuscated-Bold.otf)
	$(call obfuscate_font,$(SANS_SRC_ITALIC),sans-obfuscated-Italic.otf)
	$(call obfuscate_font,$(SANS_SRC_BOLDITALIC),sans-obfuscated-BoldItalic.otf)
	$(call obfuscate_font,$(SERIF_SRC_REG),serif-obfuscated.otf)
	$(call obfuscate_font,$(SERIF_SRC_BOLD),serif-obfuscated-Bold.otf)
	$(call obfuscate_font,$(SERIF_SRC_ITALIC),serif-obfuscated-Italic.otf)
	$(call obfuscate_font,$(SERIF_SRC_BOLDITALIC),serif-obfuscated-BoldItalic.otf)
	$(call obfuscate_font,$(HACKER_SRC_REG),hacker-obfuscated.otf)
	$(call obfuscate_font,$(HACKER_SRC_BOLD),hacker-obfuscated-Bold.otf)
	@echo "Done. Use class option 'obfuscate' with font sans, serif, or hacker (ENGINE=lua)."

TEXCOUNT = texcount -opt=../../texcount.opt -merge -nosub -total -brief -sum=1,1,1,0,0,1,1

wordcount:
	@echo "Word count (text+headers+captions+math):"; \
	for d in $(QBOOK_DIR) $(QARTICLE_DIR) $(QSLIDES_DIR); do \
	  name=$$(basename $$d); \
	  count=$$(cd $$d && $(TEXCOUNT) main.tex 2>/dev/null | grep -E '^[0-9]') || count="(texcount not found)"; \
	  printf "  %-10s %s\n" "$$name:" "$$count"; \
	done

check:
	@echo "Running REUSE lint..."; \
	if command -v reuse >/dev/null 2>&1; then reuse lint; else echo "  (reuse not installed; install from https://reuse.software to enable)"; fi

help:
	@echo "tex-qtex Makefile targets:"
	@echo "  make [all]       Build all example PDFs (default)."
	@echo "  make qbook      Build examples/qbook/main.pdf"
	@echo "  make qarticle   Build examples/qarticle/main.pdf"
	@echo "  make qslides    Build examples/qslides/main.pdf"
	@echo "  make help       Show this help."
	@echo "  make clean      Remove build artifacts (keep PDFs)."
	@echo "  make distclean  clean + remove PDFs and fonts/"
	@echo "  make hacker-font  Generate obfuscated fonts (optional SEED=n)."
	@echo "  make wordcount  Word count for both examples."
	@echo "  make check     REUSE lint (license/copyright)."
	@echo ""
	@echo "Engine: make ENGINE=lua (default) | ENGINE=pdf | ENGINE=xe"
