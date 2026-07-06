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

## Web (bottega sul sito)

Le pagine del sito vivono in `web/` (collezione Jekyll `bottega` del repo
principale, layout `project`; griglia in `/bottega/` ordinata per `date:`
decrescente, URL dei post: `/bottega/web/<slug>/`). Un post per progetto,
stesso slug della cartella immagini.

Immagini in `img/<progetto>/<YYYY-MM-DD[-slug]>/<sigla>/{org,edit,thumb}/`
(convenzione LEAP, stessi nomi file nelle tre cartelle; in `org/` l'estensione
originale, in `edit/thumb` sempre `.jpg`) più:

- `img/<progetto>/<progetto>-hero.jpg` (1600×800) e `<progetto>-t.jpg`
  (800×800): hero e thumbnail del post (`tools/bottega/make-hero.py` del
  repo principale, sorgente consigliata: la foto in `org/`).
- `raw/` dentro una cartella-sigla: originali non processati (es. HEIC
  pre-conversione). In git come archivio, MAI pubblicati.
- `org/`, `raw/`, `*.mov`, `*.heic` sono esclusi dal sito via `exclude:`
  nel `_config.yml` del repo principale (servono pattern a livello file,
  es. `**/org/**`: le collezioni confrontano l'exclude coi percorsi dei file).

Pipeline per sessione (dal repo principale):

    tools/bottega/process-session.sh _bottega/img/<progetto>/<sessione> <sigla>

(converte HEIC con originali in `raw/`, organizza `org/edit/thumb`, elimina i
loose, watermarka `edit/`). `date:` del post = ultima sessione pubblicata.
Sessioni nel post in ordine cronologico; un include gallery per
cartella-sigla (il match `thumb/` non è ricorsivo). Le sessioni solo-video
restano in archivio finché non esiste un canale di pubblicazione video.

Nota: GitHub rifiuta file singoli > 100 MB (limite rigido, GH001). I video
oltre soglia NON si committano: si aggiungono a `.gitignore` con nota e
restano nell'archivio locale in attesa del canale YouTube.

### Modificare gallerie già pubblicate

- **Sfinimento** (togliere foto): metodo *demote, non delete* —
  `tools/bottega/cull.sh <session-dir> <sigla> NN [NN ...]` (repo
  principale): sposta `org/NN` in `raw/`, elimina solo `edit/` e `thumb/`.
  Reversibile con `tools/bottega/restore.sh` (stessi argomenti): rigenera
  edit+thumb+watermark dal file in `raw/`, con lo stesso numero.
- **Mai rinumerare**: i `-NN` sono identificatori stabili, i buchi sono ok;
  rinumerare cambierebbe URL già pubblicati.
- **Aggiungere foto a sessione esistente**: `organize.py ... --start
  <ultimo+1>`, poi watermark: le foto esistenti non si toccano.
- **Nuova sessione a progetto esistente**: `process-session.sh` + heading e
  include nel post + aggiornare `date:` (il progetto risale in griglia).
- Raggruppare più modifiche in un solo giro commit→push→bump: una build
  copre tutto. Dopo il deploy la cache CDN può servire le foto tolte per
  ~10 minuti (max-age 600): non è un errore.
