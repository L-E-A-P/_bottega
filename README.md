# Bottega Radicale

La bottega del **LEAP — Laboratorio Elettroacustico Permanente** (Roma):
costruzione e manutenzione di strumenti, restauri, progetti di ricerca.
Questo repo ha una doppia anima:

- **`web/` + `img/`** — il diario di laboratorio pubblicato sul sito:
  [leaphz.net/bottega](https://www.leaphz.net/bottega/). Un post per progetto,
  che alterna testi e gallerie fotografiche per sessione di lavoro.
- **`src/`** — il sistema LaTeX dei fascicoli d'intervento (schede di
  restauro, note di bottega, copertine): vedi `CLAUDE.md` per compilazione
  e convenzioni dei codici (`LEAP<DDMMYY>BR<NNNN>`, BR = Bottega Radicale).

## Com'è fatto un progetto sul sito

```
web/<progetto>.md                        il post (titolo, date:, testi, gallerie)
img/<progetto>/
├── <progetto>-hero.jpg                  immagine di testata (1600×800)
├── <progetto>-t.jpg                     thumbnail per la griglia (800×800)
└── <YYYY-MM-DD[-slug]>/                 una cartella per sessione di lavoro
    └── <sigla-fotografo>/
        ├── org/    originali rinominati <sessione>-NN (archivio, NON pubblicati)
        ├── edit/   versioni web watermarked ← lightbox
        ├── thumb/  miniature ← griglia
        └── raw/    non pubblicati (HEIC originali, scarti) — solo archivio
```

Il post appare in `/bottega/` ordinato per `date:` decrescente (= data
dell'ultima sessione pubblicata: un progetto "risale" quando ci si rilavora).
URL: `/bottega/web/<progetto>/`.

## Contribuire foto di una sessione

1. Crea la cartella `img/<progetto>/<YYYY-MM-DD>/<tua-sigla>/` e mettici le
   foto originali (le sigle sono in `tools/watermark/photographers.yml` del
   repo principale; se non hai una sigla, cartella `nome-cognome`).
2. Dal repo principale, la pipeline fa tutto il resto (conversioni HEIC,
   resize, watermark, rinomina):

       tools/bottega/process-session.sh _bottega/img/<progetto>/<sessione> <sigla>

3. Nel post: un heading con la data e un include per ogni cartella-sigla:

       ## 8 giugno 2024
       {% include gallery path="bottega/img/<progetto>/<sessione>/<sigla>/" %}

4. Aggiorna `date:` nel front matter del post alla data della nuova sessione.

Se non hai gli strumenti per il passo 2–4: committa solo le foto al passo 1
e segnalalo — chi cura la pubblicazione completa la pipeline.

## Regole d'oro

- `org/`, `edit/`, `thumb/` hanno **gli stessi nomi file**, sempre.
- I numeri `-NN` sono **identificatori stabili**: mai rinumerare, i buchi
  vanno bene. Per *togliere* una foto pubblicata: l'originale si sposta in
  `raw/` e si eliminano solo `edit/` e `thumb/` (mai cancellare da `org/`
  senza archiviare in `raw/`).
- Per *aggiungere* foto a una sessione già pubblicata: `organize.py --start
  <ultimo+1>` (repo principale), così le esistenti non si toccano.
- **Niente file singoli sopra i 100 MB**: GitHub li rifiuta (i video grossi
  restano in archivio locale in attesa del canale video).
- `org/`, `raw/`, `*.mov`, `*.heic` stanno in git ma NON vengono pubblicati
  (esclusi dalla build del sito nel `_config.yml` del repo principale).

Convenzioni complete e dettagli operativi in `CLAUDE.md` (sezione «Web»).
