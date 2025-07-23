# Makefile principale per compilazione report LEAP
# Root directory: bottega/

# Trova tutte le directory degli strumenti
INSTRUMENT_DIRS := $(shell find interventi -name "mb-*" -type d)

# Trova tutti i file .tex
TEX_FILES := $(shell find interventi -name "*.tex")
PDF_FILES := $(TEX_FILES:.tex=.pdf)

# Colori per output
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
BLUE=\033[0;34m
NC=\033[0m # No Color

.PHONY: all clean help step step-all list

# Target principale: compila tutto con cleanup
all:
	@echo "$(BLUE)🔧 Compilazione completa di tutti i report LEAP$(NC)"
	@for dir in $(INSTRUMENT_DIRS); do \
		if [ -f "$$dir/Makefile" ]; then \
			echo "$(YELLOW)📁 Compilando $$dir$(NC)"; \
			$(MAKE) -C $$dir || exit 1; \
		else \
			echo "$(RED)⚠️  Makefile mancante in $$dir$(NC)"; \
		fi; \
	done
	@echo "$(GREEN)✅ Compilazione completata!$(NC)"

# Target step: compila tutto senza cleanup
step-all:
	@echo "$(BLUE)🔧 Compilazione step di tutti i report LEAP$(NC)"
	@for dir in $(INSTRUMENT_DIRS); do \
		if [ -f "$$dir/Makefile" ]; then \
			echo "$(YELLOW)📁 Compilando (step) $$dir$(NC)"; \
			$(MAKE) -C $$dir step || exit 1; \
		else \
			echo "$(RED)⚠️  Makefile mancante in $$dir$(NC)"; \
		fi; \
	done
	@echo "$(GREEN)✅ Compilazione step completata!$(NC)"

# Pulizia globale
clean:
	@echo "$(YELLOW)🧹 Pulizia file intermedi...$(NC)"
	@for dir in $(INSTRUMENT_DIRS); do \
		if [ -f "$$dir/Makefile" ]; then \
			echo "$(YELLOW)🧹 Pulendo $$dir$(NC)"; \
			$(MAKE) -C $$dir clean; \
		fi; \
	done
	@echo "$(GREEN)✅ Pulizia completata!$(NC)"

# Lista tutti i report disponibili
list:
	@echo "$(BLUE)📋 Report disponibili:$(NC)"
	@for dir in $(INSTRUMENT_DIRS); do \
		instrument=$$(basename $$dir); \
		tex_files=$$(find $$dir -name "*.tex" | wc -l | tr -d ' '); \
		pdf_files=$$(find $$dir -name "*.pdf" | wc -l | tr -d ' '); \
		echo "$(YELLOW)  📁 $$instrument$(NC) - TEX: $$tex_files, PDF: $$pdf_files"; \
		find $$dir -name "LEAP*.tex" -exec basename {} \; | sed 's/^/    📄 /'; \
	done

# Compila singolo strumento (uso: make instrument INST=mb-1990-01)
instrument:
	@if [ -z "$(INST)" ]; then \
		echo "$(RED)❌ Errore: specifica INST=mb-xxxx-xx$(NC)"; \
		echo "$(YELLOW)Esempio: make instrument INST=mb-1990-01$(NC)"; \
		exit 1; \
	fi
	@dir="interventi/mb/$(INST)"; \
	if [ -d "$$dir" ]; then \
		echo "$(BLUE)🔧 Compilando strumento $(INST)$(NC)"; \
		$(MAKE) -C "$$dir" || exit 1; \
		echo "$(GREEN)✅ $(INST) compilato!$(NC)"; \
	else \
		echo "$(RED)❌ Directory $$dir non trovata$(NC)"; \
		exit 1; \
	fi

# Statistiche
stats:
	@echo "$(BLUE)📊 Statistiche repository:$(NC)"
	@total_instruments=$$(find interventi -name "mb-*" -type d | wc -l | tr -d ' '); \
	total_tex=$$(find interventi -name "*.tex" | wc -l | tr -d ' '); \
	total_pdf=$$(find interventi -name "*.pdf" | wc -l | tr -d ' '); \
	echo "$(YELLOW)  🎼 Strumenti totali: $$total_instruments$(NC)"; \
	echo "$(YELLOW)  📄 File TEX: $$total_tex$(NC)"; \
	echo "$(YELLOW)  📋 File PDF: $$total_pdf$(NC)"

# Help
help:
	@echo "$(BLUE)🚀 Makefile LEAP - Sistema di compilazione report$(NC)"
	@echo ""
	@echo "$(YELLOW)Target disponibili:$(NC)"
	@echo "  $(GREEN)make$(NC)              - Compila tutti i report (con cleanup)"
	@echo "  $(GREEN)make step-all$(NC)     - Compila tutti i report (senza cleanup)"
	@echo "  $(GREEN)make clean$(NC)        - Pulisce tutti i file intermedi"
	@echo "  $(GREEN)make list$(NC)         - Lista tutti i report disponibili"
	@echo "  $(GREEN)make stats$(NC)        - Mostra statistiche repository"
	@echo ""
	@echo "$(YELLOW)Target per singoli strumenti:$(NC)"
	@echo "  $(GREEN)make instrument INST=mb-1990-01$(NC) - Compila singolo strumento"
	@echo ""
	@echo "$(YELLOW)Esempi:$(NC)"
	@echo "  make                    # Compila tutto"
	@echo "  make instrument INST=mb-1990-01"
	@echo "  make clean              # Pulisce tutto"

# Default target
.DEFAULT_GOAL := all
