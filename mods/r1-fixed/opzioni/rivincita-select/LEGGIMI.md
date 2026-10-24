# Opzione R10: SELECT sulla cerimonia di fine partita Battle

**Non è nella Release 1.** Il proprietario ha deciso il 2026-10-24 di tenerla solo come possibilità documentata: nell'originale la croce (o START) sulla cerimonia di fine partita rilancia già la stessa partita, e SELECT non faceva niente. Questa opzione fa valere SELECT come la croce (solo giocatore 1, solo Battle).

## Come inserirla
1. In `buildList.txt` togliere i due `//` delle righe «opzione R10» (codice a `0x800315f8` nell'EXE, hook all'ingresso di `0x8007f1a8` nella voce 991).
2. Aggiungere `{"voce": 991, "inizio": "0x6518", "fine": "0x6520"}` agli `intervalli_dat` di `avvio-freddo-partita` in `tools/regressione_base.json` e la voce `rivincita-freddo` (atteso 1) in `tools/regressione_r1.json`; la voce è già in `tools/regressione_opzioni.json`.
3. Riprovare: `python -I tools/redux/sonda_rivincita.py --mod game/mods/r1-fixed` (exit 0, senza `--mod` exit 1), `python -I tools/equiv.py run tools/equiv_scenari/rivincita-select-r1.json` (exit 1) e gli altri `rivincita-*-r1` (exit 0), poi la release e le suite sull'ISO (`topics/build-e-release.md`).

Misure, progetto e prove: `docs/evidence/m3-l10/progetto.md` e `LEGGIMI.md`. Provata l'ultima volta con l'ISO di release `r1-fixed-m3-l10` (SHA-256 `2cea22c4…`, repository `723591c`, sottomodulo `d658fac`): suite R1 8/8 e di base 16/16 exit 0.
