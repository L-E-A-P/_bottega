# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**LEAP Bottega** is a LaTeX-based document management system for **LEAP - Laboratorio Elettroacustico Permanente** (Roma). It produces PDF documentation for conservation/restoration interventions on musical instruments (currently the Mario Bertoncini collection). All content is in Italian.

## Build & Compile

Requires `pdflatex` (install via MacTeX on macOS). The compile script must be run from inside `src/`:

```bash
cd src
./compile.sh            # Interactive menu - select file to compile
./compile.sh --all      # Compile all .tex files
./compile.sh --clean    # Remove LaTeX temp files
./compile.sh --stats    # Show repository statistics
```

To compile a single `.tex` file manually (two passes needed for QR codes and references):

```bash
cd src/interventi/mb/mb-1980-01-grande-spirale/LEAP170725BR0001
pdflatex -interaction=nonstopmode LEAP170725BR0001.tex
pdflatex -interaction=nonstopmode LEAP170725BR0001.tex
```

## Architecture

### Directory Structure (`src/`)

- **`stili/`** - Custom LaTeX style packages (`.sty`) and their example files (`es-*.tex`)
- **`interventi/`** - All instrument data, organized by collection owner (e.g., `mb/` for Mario Bertoncini)
- **`templates/`** - Document templates (currently `template-report.tex` using a `leap-report` style)

### Three Document Types (defined in `stili/`)

Each instrument intervention produces three document types, each with its own `.sty`:

1. **`intervento.sty`** - Intervention report sheet. Uses `\impostaStrumento{8 args}` for instrument data and `\impostaIntervento{6 args}` for intervention data. Main command: `\creaIntervento`. Uses `article` documentclass.

2. **`note.sty`** - Workshop notes (grid-paper notebook pages for handwritten notes). Uses `\impostaNote{5 args}`. Main command: `\creaNote`. Uses `article` documentclass. Features a 0.5cm grid background on every page.

3. **`fascicolo.sty`** - Physical folder cover (printable folder template drawn with TikZ). Uses `\impostaFascicolo{6 args}`. Main command: `\creaFascicolo`. Uses `standalone` documentclass. Requires logo path set via `\fascicolologo{}`.

All three styles share: OCR-A font (`ocr10`) for codes, AlegreyaSans body font (intervento/note), and magenta as accent color.

### Instrument Directory Convention

```
interventi/<owner>/<owner>-<year>-<seq>-<instrument-name>/
    fascicolo/
        <owner>-<year>-<seq>-<instrument-name>.tex   # Folder cover
    LEAP<DDMMYY>BR<NNNN>/                            # One dir per intervention
        LEAP<DDMMYY>BR<NNNN>.tex                     # Intervention report
        LEAP<DDMMYY>BR<NNNN>-note.tex                # Workshop notes
```

### Naming Conventions

- **Intervention codes**: `LEAP<DDMMYY>BR<NNNN>` (e.g., `LEAP170725BR0001` = July 17, 2025, intervention #0001). `BR` = Bottega Radicale.
- **Instrument codes**: `<OWNER>-<YEAR>-<SEQ>` (e.g., `MB-1980-01`)
- **Instrument folders**: `<owner>-<year>-<seq>-<instrument-name>` (e.g., `mb-1980-01-grande-spirale`)

### Registry

`interventi/LEAP-registro-interventi-br.tex` is a landscape longtable tracking all interventions with their codes, dates, instruments, and folder references.

### Style Path Resolution

`.tex` files reference `.sty` files via `TEXINPUTS` or relative paths. The compile script runs `pdflatex` from each `.tex` file's own directory. Style files in `stili/` must be findable by pdflatex (symlinked or via `TEXINPUTS`).
