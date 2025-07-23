#!/bin/bash

# Setup automatico Makefile per repository LEAP
# Esegui dalla root del repository

set -e

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Setup automatico Makefile LEAP${NC}"
echo ""

# Verifica di essere nella directory corretta
if [ ! -d "interventi" ]; then
    echo -e "${RED}❌ Errore: esegui questo script dalla root del repository${NC}"
    echo -e "${YELLOW}La directory corrente dovrebbe contenere 'interventi/'${NC}"
    exit 1
fi

# Crea directory templates se non existe
echo -e "${BLUE}📁 Creando directory templates...${NC}"
mkdir -p templates

# Salva il Makefile per strumenti come template
echo -e "${BLUE}📝 Salvando template Makefile strumenti...${NC}"
cat > templates/Makefile.instrument << 'EOF'
# Makefile per singolo strumento MB
# Da copiare in ogni directory mb-xxxx-xx

# Trova tutti i file .tex nella directory corrente
TEX_FILES := $(wildcard LEAP*.tex)
PDF_FILES := $(TEX_FILES:.tex=.pdf)
AUX_FILES := $(TEX_FILES:.tex=.aux)
LOG_FILES := $(TEX_FILES:.tex=.log)
OUT_FILES := $(TEX_FILES:.tex=.out)

# Strumento corrente (dal nome directory)
INSTRUMENT := $(notdir $(CURDIR))

# Colori per output
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
BLUE=\033[0;34m
NC=\033[0m # No Color

.PHONY: all clean step help list

# Target principale: compila tutto e pulisce file intermedi
all: $(PDF_FILES) clean-temp
	@echo "$(GREEN)✅ $(INSTRUMENT): Compilazione completata!$(NC)"

# Target step: compila una volta senza cleanup
step: step-compile
	@echo "$(GREEN)✅ $(INSTRUMENT): Compilazione step completata!$(NC)"

# Compila tutti i PDF (doppia compilazione per QR code)
$(PDF_FILES): %.pdf: %.tex
	@echo "$(BLUE)🔧 Compilando $< (prima passata)...$(NC)"
	@pdflatex -interaction=nonstopmode $< > /dev/null 2>&1 || \
		(echo "$(RED)❌ Errore nella prima compilazione di $<$(NC)" && \
		 echo "$(YELLOW)📋 Log disponibile in $*.log$(NC)" && exit 1)
	@echo "$(BLUE)🔧 Compilando $< (seconda passata per QR code)...$(NC)"
	@pdflatex -interaction=nonstopmode $< > /dev/null 2>&1 || \
		(echo "$(RED)❌ Errore nella seconda compilazione di $<$(NC)" && \
		 echo "$(YELLOW)📋 Log disponibile in $*.log$(NC)" && exit 1)
	@echo "$(GREEN)✅ $@ generato$(NC)"

# Compilazione step (una sola volta)
step-compile:
	@for tex in $(TEX_FILES); do \
		echo "$(BLUE)🔧 Compilando $$tex (step)...$(NC)"; \
		pdflatex -interaction=nonstopmode $$tex > /dev/null 2>&1 || \
			(echo "$(RED)❌ Errore nella compilazione di $$tex$(NC)" && \
			 echo "$(YELLOW)📋 Log disponibile in $${tex%.tex}.log$(NC)" && exit 1); \
		echo "$(GREEN)✅ $${tex%.tex}.pdf generato$(NC)"; \
	done

# Pulizia file temporanei (mantiene PDF)
clean-temp:
	@if [ -n "$(AUX_FILES)" ]; then \
		echo "$(YELLOW)🧹 Eliminando file temporanei...$(NC)"; \
		rm -f $(AUX_FILES) $(LOG_FILES) $(OUT_FILES); \
	fi

# Pulizia completa (inclusi PDF)
clean: clean-temp
	@if [ -n "$(PDF_FILES)" ]; then \
		echo "$(YELLOW)🧹 Eliminando PDF...$(NC)"; \
		rm -f $(PDF_FILES); \
	fi
	@echo "$(GREEN)✅ $(INSTRUMENT): Pulizia completata!$(NC)"

# Lista file nel progetto
list:
	@echo "$(BLUE)📋 Contenuto $(INSTRUMENT):$(NC)"
	@if [ -n "$(TEX_FILES)" ]; then \
		echo "$(YELLOW)  📄 File TEX:$(NC)"; \
		for tex in $(TEX_FILES); do echo "    $$tex"; done; \
	fi
	@if [ -n "$(PDF_FILES)" ]; then \
		echo "$(YELLOW)  📋 File PDF:$(NC)"; \
		for pdf in $(PDF_FILES); do \
			if [ -f "$$pdf" ]; then \
				size=$$(ls -lh "$$pdf" | awk '{print $$5}'); \
				echo "    $$pdf ($$size)"; \
			else \
				echo "    $$pdf $(RED)[mancante]$(NC)"; \
			fi; \
		done; \
	fi

# Forza ricompilazione
force: clean all

# Debug: mostra log dell'ultimo errore
debug:
	@echo "$(BLUE)🐛 Debug $(INSTRUMENT):$(NC)"
	@for log in $(LOG_FILES); do \
		if [ -f "$$log" ]; then \
			echo "$(YELLOW)📋 Contenuto $$log:$(NC)"; \
			tail -20 "$$log"; \
			echo ""; \
		fi; \
	done

# Apri PDF compilati
open:
	@for pdf in $(PDF_FILES); do \
		if [ -f "$$pdf" ]; then \
			echo "$(BLUE)📖 Aprendo $$pdf$(NC)"; \
			open "$$pdf"; \
		else \
			echo "$(RED)❌ $$pdf non trovato$(NC)"; \
		fi; \
	done

# Verifica dipendenze
check:
	@echo "$(BLUE)🔍 Verifica dipendenze $(INSTRUMENT):$(NC)"
	@command -v pdflatex >/dev/null 2>&1 || \
		(echo "$(RED)❌ pdflatex non trovato$(NC)" && exit 1)
	@echo "$(GREEN)✅ pdflatex disponibile$(NC)"
	@kpsewhich qrcode.sty >/dev/null 2>&1 || \
		echo "$(YELLOW)⚠️  pacchetto qrcode potrebbe mancare$(NC)"
	@kpsewhich AlegreyaSans.sty >/dev/null 2>&1 || \
		echo "$(YELLOW)⚠️  pacchetto AlegreyaSans potrebbe mancare$(NC)"

# Info strumento
info:
	@echo "$(BLUE)ℹ️  Informazioni $(INSTRUMENT):$(NC)"
	@echo "$(YELLOW)  📁 Directory: $(CURDIR)$(NC)"
	@echo "$(YELLOW)  🎼 Strumento: $(INSTRUMENT)$(NC)"
	@echo "$(YELLOW)  📄 File TEX: $(words $(TEX_FILES))$(NC)"
	@echo "$(YELLOW)  📋 File PDF: $(words $(PDF_FILES))$(NC)"

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

# Default target: compila tutto
.DEFAULT_GOAL := all
EOF

# Salva il Makefile principale come template
echo -e "${BLUE}📝 Salvando template Makefile principale...${NC}"
cat > templates/Makefile.root << 'EOF'
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
EOF

# Trova tutte le directory degli strumenti
INSTRUMENT_DIRS=$(find interventi -name "mb-*" -type d)

# Copia Makefile in ogni directory strumento
echo -e "${BLUE}📂 Creando Makefile per strumenti...${NC}"
for dir in $INSTRUMENT_DIRS; do
    instrument=$(basename "$dir")
    if [ ! -f "$dir/Makefile" ]; then
        echo -e "${YELLOW}  📝 Creando Makefile per $instrument${NC}"
        cp templates/Makefile.instrument "$dir/Makefile"
    else
        echo -e "${GREEN}  ✅ Makefile già presente per $instrument${NC}"
    fi
done

# Crea Makefile principale se non esiste
if [ ! -f "Makefile" ]; then
    echo -e "${BLUE}📝 Creando Makefile principale...${NC}"
    cp templates/Makefile.root Makefile
else
    echo -e "${GREEN}✅ Makefile principale già presente${NC}"
fi

# Crea .gitignore se non esiste
if [ ! -f .gitignore ]; then
    echo -e "${BLUE}📝 Creando .gitignore...${NC}"
    cat > .gitignore << 'EOF'
# File temporanei LaTeX
*.aux
*.log
*.out
*.synctex.gz
*.fdb_latexmk
*.fls

# File di backup
*~
*.bak

# Directory temporanee
.DS_Store
.vscode/
*.tmp

# File di sistema macOS
.DS_Store
EOF
fi

# Verifica dipendenze
echo -e "${BLUE}🔍 Verifica dipendenze LaTeX...${NC}"
if command -v pdflatex >/dev/null 2>&1; then
    echo -e "${GREEN}✅ pdflatex disponibile${NC}"
else
    echo -e "${RED}❌ pdflatex non trovato - installa MacTeX${NC}"
fi

if kpsewhich qrcode.sty >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Pacchetto qrcode disponibile${NC}"
else
    echo -e "${YELLOW}⚠️  Pacchetto qrcode potrebbe mancare${NC}"
fi

if kpsewhich AlegreyaSans.sty >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Pacchetto AlegreyaSans disponibile${NC}"
else
    echo -e "${YELLOW}⚠️  Pacchetto AlegreyaSans potrebbe mancare${NC}"
fi

# Statistiche finali
TOTAL_INSTRUMENTS=$(find interventi -name "mb-*" -type d | wc -l | tr -d ' ')
TOTAL_TEX=$(find interventi -name "*.tex" | wc -l | tr -d ' ')

echo ""
echo -e "${GREEN}🎉 Setup completato!${NC}"
echo -e "${BLUE}📊 Repository configurato con:${NC}"
echo -e "${YELLOW}  🎼 Strumenti: $TOTAL_INSTRUMENTS${NC}"
echo -e "${YELLOW}  📄 File TEX: $TOTAL_TEX${NC}"
echo ""
echo -e "${BLUE}🚀 Comandi disponibili:${NC}"
echo -e "${GREEN}  make${NC}              - Compila tutti i report"
echo -e "${GREEN}  make step-all${NC}     - Compila tutti (senza cleanup)"
echo -e "${GREEN}  make list${NC}         - Lista tutti i report"
echo -e "${GREEN}  make help${NC}         - Mostra aiuto completo"
echo ""
echo -e "${YELLOW}💡 Per compilare un singolo strumento:${NC}"
echo -e "${GREEN}  cd interventi/mb/mb-1990-01 && make${NC}"
