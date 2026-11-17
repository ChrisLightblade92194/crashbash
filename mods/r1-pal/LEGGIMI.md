# R1 PAL - P2c1 attivato, da verificare dalla regia

Port SCES-02834 con 49 voci: 1-23 e 36-61. Le voci 24-35 e gli asset personalizzati
restano P3. Il manifesto cumulativo è `docs/evidence/pal-r1/p2a/patch.json`.
P2a, P2b1, P2b2 e intro 3-4 sono stati verificati dalla regia; P2c1 aggiunge
25 voci skin e ricollega ripeti 8, casuale 54 e boss 56 a `skin_scelta`,
`0x80048598`. Le altre 21 voci precedenti restano identiche byte per byte.

Gli hash delle 25 voci nuove e delle 3 voci ricollegate sono attesi dalle
codifiche MIPS, non misurati su nuovi compilati. Codex non ha eseguito build,
pytest o emulatori. I vecchi compilati 8/54/56 devono essere rigenerati.
Sedi, traduzioni, dimensioni, prove, limiti e piano del banco sono in
`docs/evidence/pal-r1/p2c1/`; i rapporti dei lotti precedenti restano nelle
rispettive cartelle di evidenza.

Provenienza USA: `7db60ceee82d7f7c6b61848da09789c4faa8d6dc` per P2a/P2b1,
`785bec466601d937b5306357409bee0fcc6ec4de` per ripeti RC3,
`418a3f8561774df5de192848cefb12ee736d50b0` per P2b2/P2c1.
Nessun include USA è usato nella build PAL. La configurazione di toolchain
e le sezioni di `disc.json` restano quelle già assegnate.

```powershell
& $py -I tools/build.py --mod r1-pal --regione pal --gioco crashbash-pal
```

La build genera un pacchetto di prova neutro a partire dai 96 TEX originali
PAL e lo scrive in BASHY. senza estendere il DAT. Dettagli e segnaposto P3
sono in `skin/LEGGIMI.md`. `Makefile` e `overlay.ld` vengono rigenerati dal
mod-builder. `tools/redux/sonda_pal_r1.py:leggi_patch` confronta tutte le 49 voci
col manifesto prima delle prove.

Le voci 60/61 sono inseparabili. Per iniezioni da savestate, gli overlay
incompatibili non vanno scritti insieme: menu 1083, Ballistix 1085 e Crate 1089
occupano la stessa finestra. La nuova sonda delle skin usa EXE, motore e
menu 1083; non certifica le altre patch degli overlay o il DAT di P3.

ISO, CUE e SBI omonimi per il banco vanno in una cartella esterna al
repository. Usare soltanto savestate con `-sbi` e gli hash documentati.
La scritta del controllo 50 dipende dalla lingua nel codice originale;
le 25 voci skin non leggono né disegnano testo, ma le lingue diverse
dall'inglese restano da coprire nei percorsi modificati.
