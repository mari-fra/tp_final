# Makefile for LaTeX report compilation
# Compatible with pdflatex and biber/biblatex

# Variables
LATEX = pdflatex
BIBTEX = biber
MAIN = report
TEXFILE = $(MAIN).tex
PDFFILE = $(MAIN).pdf
OUTPUT_DIR = build
LATEX_OPTIONS = -output-directory=$(OUTPUT_DIR) -interaction=nonstopmode -file-line-error

# Default target
.PHONY: all
all: $(PDFFILE)

# Main compilation target
$(PDFFILE): $(TEXFILE) | $(OUTPUT_DIR)
	@echo "=== First pass ==="
	$(LATEX) $(LATEX_OPTIONS) $(TEXFILE)
	@echo "=== Bibliography (if exists) ==="
	@if [ -f "$(OUTPUT_DIR)/$(MAIN).bcf" ]; then \
		cd $(OUTPUT_DIR) && $(BIBTEX) $(MAIN) && cd ..; \
	fi
	@if [ -f "$(OUTPUT_DIR)/$(MAIN).aux" ] && grep -q "\\citation" "$(OUTPUT_DIR)/$(MAIN).aux" 2>/dev/null; then \
		cd $(OUTPUT_DIR) && bibtex $(MAIN) 2>/dev/null || true && cd ..; \
	fi
	@echo "=== Second pass (resolve references) ==="
	$(LATEX) $(LATEX_OPTIONS) $(TEXFILE)
	@echo "=== Third pass (final references) ==="
	$(LATEX) $(LATEX_OPTIONS) $(TEXFILE)
	@echo "=== Moving PDF to root ==="
	@cp "$(OUTPUT_DIR)/$(PDFFILE)" . 2>/dev/null || true
	@echo "=== Compilation complete: $(PDFFILE) ==="

# Create output directory
$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

# Quick compile (single pass, faster but may not resolve all references)
.PHONY: quick
quick: $(TEXFILE) | $(OUTPUT_DIR)
	@echo "=== Quick compilation (single pass) ==="
	$(LATEX) $(LATEX_OPTIONS) $(TEXFILE)
	@cp "$(OUTPUT_DIR)/$(PDFFILE)" . 2>/dev/null || echo "Compilation had errors, check $(OUTPUT_DIR)/$(MAIN).log"

# Clean auxiliary files
.PHONY: clean
clean:
	@echo "Cleaning auxiliary files..."
	rm -rf $(OUTPUT_DIR)
	rm -f *.aux *.log *.out *.toc *.bbl *.blg *.bcf *.run.xml *.synctex.gz *.fdb_latexmk *.fls *.auxlock 2>/dev/null || true
	@echo "Clean complete"

# Clean everything including PDF
.PHONY: distclean
distclean: clean
	@echo "Cleaning everything including PDF..."
	rm -f $(PDFFILE)
	@echo "Distclean complete"

# Help target
.PHONY: help
help:
	@echo "LaTeX Report Makefile"
	@echo "===================="
	@echo "Available targets:"
	@echo "  make           - Compile PDF with full passes (references, bibliography)"
	@echo "  make quick     - Quick single-pass compilation"
	@echo "  make clean     - Remove auxiliary files"
	@echo "  make distclean - Remove everything including PDF"
	@echo "  make help      - Show this help message"
	@echo ""
	@echo "Variables:"
	@echo "  MAIN          - Main tex file name (default: report)"
	@echo "  OUTPUT_DIR    - Output directory for build files (default: build)"
	@echo ""
	@echo "Usage examples:"
	@echo "  make                    # Compile report.tex"
	@echo "  make MAIN=thesis quick  # Quick compile thesis.tex"
