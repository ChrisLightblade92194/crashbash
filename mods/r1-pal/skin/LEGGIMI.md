# Skin PAL — pacchetto vero P3a

Il tipo `skin_pal_da_delta_usa` sostituisce la fixture neutra. Il builder legge
le skin esterne USA R1 dei cinque posti e gli originali regionali autenticati.
Per ogni TEX ricava una biiezione delle celle CLUT dai campioni UV delle stesse
facce dei due MDL originali. Se la corrispondenza non è biiettiva la build fallisce.
Le celle cambiate dalla skin USA vengono applicate alle celle PAL corrispondenti;
i pixel cambiati vengono applicati alla stessa posizione. Strutture, dimensioni,
offset e indici regionali devono coincidere. Gli altri dati PAL restano originali.
In PAL1220/CLUT15 la biiezione è USA4→PAL6, USA5→PAL4, USA6→PAL5.
Questo compensa gli UV PAL1221; il confronto per posizione era insufficiente.
Le 93 TEX identiche e le dieci varianti di PAL1226/1232 restano invariate.
I pixel originali di1220 sono identici nelle due regioni. La skin cambia96byte
di pixel al posto3 (immagini2/4) e428byte al posto4 (immagini2/3/4), applicati
alle stesse posizioni; negli altri tre posti non cambia pixel.

`pacchetto.json` contiene le impronte degli originali e delle 480 skin PAL,
quelle delle skin USA di ingresso e gli offset USA misurati. `mappa.json`
associa personaggi e famiglie attraverso i record dei due motori, senza un
delta globale. I 40 JSON in `palette/` sono copie esatte delle regole R1 USA:
sono sorgenti, non texture. Il DAT e l'indice USA si estraggono in memoria
dall'ISO originale `build/bash.bin`, relativa a `game/` e dichiarata in
`../esterni.json` con SHA-256; lo stesso file dichiara l'ISO PAL originale.
Il DAT estratto viene autenticato anche con la sua impronta. I DAT delle uscite
di build non vengono letti. Le chiavi degli ingressi nel manifesto sono relative.

Le tabelle dei vertici vengono ricalcolate dai MDL PAL con l'algoritmo USA.
I 48 record del podio sono ricalcolati sul PAL133 e sul PAL132. Il builder genera
gli include `varianti-pal.inc`, `vertici-pal.inc`, `podio-pal.inc`, `mesh-pal.inc`
e `celle-pal.inc`. `celle-patch.json` autentica le dodici patch, generate soltanto
durante la build in `output/`. `../disc-podio.json` e `../build_podio.py` aggiungono
le sezioni dati PAL132/133 in memoria nel processo figlio del mod-builder:
`game/disc.json` e la toolchain non vengono modificati. Le righe sono `noreload`;
gli indirizzi convenzionali delle sezioni dati non sono sedi RAM eseguibili.

Misure sugli originali: blocco TEX 289 settori, cinque blocchi, 710 settori di
tabelle, 48 record da un settore. Totale 4511744 byte. `SKIN_VERTICI=79884`,
`SKIN_PODIO_VERTICI=80594`, relativi al DAT. Sede BASHY.: LBA78678, settore78439
dal DAT, 31752000 byte disponibili. SHA-256 atteso del pacchetto:
`9e1c20098aab24b9002048ebf383e8316e672fb46d4c485e5874edf95a583139`.
Questa è una misura della concatenazione in memoria, non di una build eseguita.
Gli asset e SKIN.BIN restano esterni/ignorati da Git. Il tipo vero supera la
guardia della release; `fixture_pal_originali` rimane disponibile soltanto per
prove locali e test ed è rifiutato da `ErroreRelease`.

Prove complete: `docs/evidence/pal-r1/p3a/`. L'oracolo indipendente per vertice
UV è riprodotto da `oracolo_uv.py`: 480 combinazioni, 438030 campioni.
La rotazione di Rilla Roo/kegs non lascia campioni non spiegati nei cinque posti.
Kong/posto4 conserva due differenze sulle facce88:119/140:119: la TEX è identica
alla USA ma gli UV leggono pixel diversi. Il vincolo di identità TEX e l'oracolo
integrale sono incompatibili su questi due campioni; la decisione della regia
è necessaria prima di chiudere quel punto. Il test indipendente li segnala.
I metadati MDL non decodificati hanno sede e differenze classificate; il loro
significato runtime resta incerto.

`buffer-pal.inc` è l'unica definizione di `BUFFER`, letta anche dalla sonda.
La regia ha confermato la sede0x800a4800 nel percorso di rientro documentato in
`p3/rientro-buffer.md`. L'azzeramento dopo ogni lettura, anche fallita, è essenziale.
Se cambia la sede,
rigenerare i compilati 11/15/40, codifiche e impronte del manifesto, audit dei
limiti e riferimenti della sonda; ripetere le relative baseline e mutazioni.
Ricontrollare capienza e durata di vita della nuova sede. La geometria del
pacchetto non dipende dall'indirizzo del buffer. Le coordinate CLUT113-117
restano x960, y401-(k-113), misurate in P2c1/ricognizione.json.

Build, pytest, prove DAT, callback, celle, rientro e giudizio visivo devono
essere eseguiti dalla regia. Gli invariati statici non certificano il runtime.
