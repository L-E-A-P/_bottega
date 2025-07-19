# Setup LaTeX con Font OCR-A e AlegreyaSans

Guida completa per l'installazione e l'uso del sistema di documentazione LEAP con font OCR-A e AlegreyaSans.

## Prerequisiti

- **MacTeX 2025** installato
- **Terminale** per i comandi di installazione
- **Editor LaTeX** (TeXShop, VS Code, etc.)

## Installazione Font OCR-A

### 1. Download e preparazione
```bash
cd ~/Downloads
curl -O https://mirrors.ctan.org/fonts/ocr-a.zip
unzip ocr-a.zip
cd ocr-a
```

### 2. Correzione bug nei file METAFONT
```bash
# Correggi il riferimento nei file .mf
sed -i '' 's/input ocra/input ocr-a/' ocr10.mf
sed -i '' 's/input ocra/input ocr-a/' ocr12.mf
sed -i '' 's/input ocra/input ocr-a/' ocr16.mf
```

### 3. Verifica correzioni
```bash
tail -1 ocr10.mf ocr12.mf ocr16.mf
# Dovrebbe mostrare "input ocr-a;" per tutti e tre
```

### 4. Installazione nel sistema
```bash
# Trova la directory TEXMFLOCAL
kpsewhich -var-value=TEXMFLOCAL

# Installa i file (sostituisci il percorso se diverso)
cd ~/Downloads
sudo mkdir -p $(kpsewhich -var-value=TEXMFLOCAL)/fonts/source
sudo mv ocr-a $(kpsewhich -var-value=TEXMFLOCAL)/fonts/source/
sudo mktexlsr
```

### 5. Test installazione
```bash
# Crea file di test
cat > test-ocr.tex << 'EOF'
\font\ocrten=ocr10
\ocrten
ABCDEFGHIJKLMNOPQRSTUVWXYZ
0123456789
\bye
EOF

# Compila con Plain TeX
pdftex test-ocr.tex
```

## Verifica AlegreyaSans

AlegreyaSans dovrebbe essere già incluso in MacTeX 2025. Verifica con:

```bash
# Test rapido
cat > test-alegreya.tex << 'EOF'
\documentclass{article}
\usepackage{AlegreyaSans}
\renewcommand{\familydefault}{\sfdefault}
\begin{document}
Questo è un test di AlegreyaSans.
\end{document}
EOF

pdflatex test-alegreya.tex
```

## Uso nei Documenti

### Template base

```latex
\documentclass[a4paper,12pt]{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage[italian]{babel}
\usepackage{AlegreyaSans}

% Attiva AlegreyaSans come font di default
\renewcommand{\familydefault}{\sfdefault}

\usepackage{tikz}
\usetikzlibrary{calc}
\usepackage[left=3cm, right=2cm, top=0.7cm, bottom=0.7cm]{geometry}
\usepackage{qrcode}
\usepackage[hidelinks]{hyperref}

% Font OCR-A a comando
\newfont{\ocrfontsmall}{ocr10 at 8pt}
\newfont{\ocrfontnormal}{ocr10}
\newfont{\ocrfontlarge}{ocr10 at 14pt}
\newfont{\ocrfonthuge}{ocr10 at 18pt}

% Comandi semplici per usare OCR-A
\newcommand{\ocr}[1]{{\ocrfontnormal #1}}
\newcommand{\ocrsmall}[1]{{\ocrfontsmall #1}}
\newcommand{\ocrlarge}[1]{{\ocrfontlarge #1}}
\newcommand{\ocrhuge}[1]{{\ocrfonthuge #1}}

% Comando per il codice identificativo verticale
\newcommand{\codiceverticale}[1]{%
    \begin{tikzpicture}[remember picture, overlay]
        \node[rotate=90, anchor=south] at ($(current page.west) + (3cm, 0cm)$) {%
            {\font\tempocr=ocr10 at 81pt \tempocr #1}%
        };
    \end{tikzpicture}%
}

\begin{document}
\thispagestyle{empty}

% Codice identificativo del documento
\codiceverticale{LEAP190725BR0001}

% Il tuo contenuto qui
Testo in AlegreyaSans con codici \ocr{OCR-A} integrati.

\end{document}
```

### Comandi disponibili

#### Font OCR-A
- `\ocr{TESTO}` - OCR-A dimensione normale
- `\ocrsmall{testo}` - OCR-A piccolo
- `\ocrlarge{TESTO}` - OCR-A grande
- `\ocrhuge{TESTO}` - OCR-A molto grande

#### Codice verticale
- `\codiceverticale{CODICE}` - Codice identificativo sul margine sinistro

#### QR Code cliccabili
```latex
\href{https://esempio.com}{
    \qrcode[height=3cm]{https://esempio.com}
}
```

## Compilazione

### Comando standard
```bash
pdflatex nome-documento.tex
```

### In caso di problemi
1. **Errore font OCR-A**: Verifica installazione con test Plain TeX
2. **TeXShop non compila**: Usa terminale con `pdflatex`
3. **QR code mancanti**: Ricompila due volte per generare i QR code

### Workflow consigliato
```bash
# Prima compilazione (genera QR code)
pdflatex documento.tex

# Seconda compilazione (inserisce QR code)
pdflatex documento.tex

# Visualizza risultato
open documento.pdf
```

## Risoluzione Problemi

### Font OCR-A non trovato
```bash
# Verifica installazione
find /opt/local/share/texmf-local -name "*ocr*" -type f

# Se vuoto, ripeti installazione
```

### AlegreyaSans non attivo
```bash
# Verifica pacchetto
kpsewhich AlegreyaSans.sty

# Se non trovato
tlmgr install alegreya
```

### QR code non funzionano
```bash
# Verifica pacchetto qrcode
kpsewhich qrcode.sty

# Se necessario
tlmgr install qrcode
```

## Convenzioni di Naming

### Codici identificativi
- **Formato**: `LEAP + GGMMAA + TIPO + NUMERO`
- **Esempio**: `LEAP190725BR0001`
  - `LEAP` = Laboratorio
  - `190725` = 19 Luglio 2025
  - `BR` = Bottega/Restauro
  - `0001` = Numero progressivo

### File LaTeX
- **Formato**: `LEAP190725BR0001.tex`
- **Corrispondenza**: Nome file = Codice identificativo

## Template Disponibili

1. **report_restauro.tex** - Report completo di restauro
2. **LEAP190725BR000X.tex** - Interventi di bottega
3. **documento_intestato.tex** - Documento base con intestazione

## Note Tecniche

- **OCR-A**: Font ottimizzato per maiuscolo e numeri
- **AlegreyaSans**: Font principale per leggibilità
- **QR Code**: Generati automaticamente, cliccabili nei PDF
- **Codici verticali**: Posizionati a 3cm dal bordo sinistro
- **Compatibilità**: Testato su macOS con MacTeX 2025

## Supporto

Per problemi tecnici, verificare:
1. Versione MacTeX (2025)
2. Installazione corretta OCR-A
3. Uso di `pdflatex` (non `pdftex`)
4. Pacchetti LaTeX aggiornati

---

**Versione**: 1.0  
**Data**: 20 Luglio 2025  
**Autore**: LEAP - Laboratorio Elettroacustico Permanente
