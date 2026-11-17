# Skin PAL - codice P2c1 e pacchetto di prova

Le 25 voci 10-23 e 36-46 sono attive nella buildList, con provenienza
`418a3f8561774df5de192848cefb12ee736d50b0`. Le sedi restano quelle assegnate
in `docs/evidence/pal-r1/p2b1/sedi-r1.json`. La compilazione e le prove del
codice modificato spettano alla regia: gli hash nel manifesto sono attesi
dalle codifiche MIPS, non misurati su nuovi compilati.

Gli include PAL sono completi. `podio-pal.inc` contiene le otto voci crate,
gli scostamenti nel blocco e 67 coppie di immagini misurate sui TEX PAL.
`mesh-pal.inc` contiene otto scostamenti riconosciuti per geometria, facce,
UV e colori del MDL PAL133. Le prove sono in `p2c1/dati-pal.json`.

`pacchetto.json` richiede al builder una fixture neutra: cinque copie dei
96 TEX originali PAL, in ordine di voce e arrotondati al settore. Un blocco
occupa 289 settori. Seguono 48 record del podio con conteggio zero; la fixture
non altera colori di vertici e presuppone il podio originale. `K=0` in tutte
le famiglie. Non si mescolano questa fixture e asset personalizzati.

La sede è BASHY., LBA 78678, settore 78439 relativo al DAT. I record del podio
cominciano al settore 79884 relativo al DAT. Nessun record è aggiunto alla
tabella originale: 1349 è l'identificatore virtuale nei manifesti e nelle
sonde. Il builder costruisce SKIN.BIN solo durante la build, dagli originali
dell'utente; nessun asset è versionato. La prova dinamica del DAT resta P3.

`celle-pal.inc` riserva 48 record a zero e nove indici di inizio a zero:
nessuna cella viene aggiornata. è un segnaposto valido finché P3 non porta
le patch 24-35 per separare le celle condivise del podio. Il codice delle
voci 37-40 rimane attivo e può essere verificato con contratti sintetici
dichiarati; tali prove non certificano le celle finali di P3.

La ricognizione della regia autorizza il buffer `0x800a4800..0x800a6000`
solo alla Character Select, con azzeramento dopo ogni lettura: il motore lo
usa dal frame 6750. Il buffer `0x800a8000..0x800a8800` resta zero nei campioni
6010-9000. CLUT 113-117: x=960, y=401-(k-113). Prova e limiti in
`p2c1/ricognizione.json`: una corsa inglese, 1P, primo ingresso, campioni ogni
10 frame; rientro, 2P e altre lingue non coperti. Il layout delle 67 immagini
usate è corroborato da RAM/VRAM in `p2c1/strutture-runtime.json`.

Le voci 10, 17, 20 hanno un ingresso isolato di 8 byte per le mutazioni del banco.
Il percorso corretto non lo chiama; il JAL alterato può così eseguire il
comportamento originale senza corrompere lo stack. Le estensioni non hanno
riferimenti diretti trovati in EXE/DAT (`p2c1/sedi-estensioni.json`).

Nessuna voce legge o disegna testo. Il -1 della voce 18 compensa un incremento
del ramo originale; non è una durata da convertire da 60 a 50 Hz. I contatori
3/4 riguardano tentativi CD. Fonte completa degli indirizzi, contratti dei
registri e delay slot: `p2c1/innesti.json`, `funzioni.json` e `port.json`.
