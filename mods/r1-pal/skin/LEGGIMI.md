# Skin PAL — pacchetto vero P3a

Il tipo `skin_pal_da_delta_usa` sostituisce la fixture neutra. Il builder legge
le skin esterne USA R1 dei cinque posti e gli originali regionali autenticati.
Per ogni byte cambiato dalla skin rispetto all'originale USA, applica il byte
della skin alla base PAL. Il delta deve rientrare in CLUT e pixel PAL; sulle
intersezioni con le differenze regionali prevale la skin. Gli altri byte PAL
restano originali. Le 93 TEX identiche producono la skin USA esatta.

`pacchetto.json` contiene le impronte degli originali e delle 480 skin PAL,
quelle delle skin USA di ingresso e gli offset USA misurati. `mappa.json`
associa personaggi e famiglie attraverso i record dei due motori, senza un
delta globale. I 40 JSON in `palette/` sono copie esatte delle regole R1 USA:
sono sorgenti, non texture. Il DAT USA richiesto è quello originale dichiarato
nel descrittore, non un'uscita in `game/build/`. Il percorso assoluto è quello
concordato per questa installazione; una diversa installazione deve aggiornare
la fonte mantenendo le impronte, senza sostituirla con un DAT di build.

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
`b8be04e1cbfa39a769f590282747d0e790e5cf83ad7babbb322320ed23f7943d`.
Questa è una misura della concatenazione in memoria, non di una build eseguita.
Gli asset e SKIN.BIN restano esterni/ignorati da Git. Il tipo vero supera la
guardia della release; `fixture_pal_originali` rimane disponibile soltanto per
prove locali e test ed è rifiutato da `ErroreRelease`.

Prove complete: `docs/evidence/pal-r1/p3a/`. In particolare, le UV PAL di Rilla
Roo/kegs cambiano la cella letta su 60 facce; Kong/kegs cambia due facce.
Il confronto delle tabelle dei colori passa anche per questi MDL, ma non prova
equivalenza visiva. La regia deve giudicare le schermate previste dal piano.
I metadati MDL non decodificati hanno sede e differenze classificate; il loro
significato runtime resta incerto.

`buffer-pal.inc` è l'unica definizione assembly di `BUFFER`. Il valore attuale
è provvisorio e il rientro resta sotto osservazione della regia. Se cambia,
rigenerare i compilati 11/15/40, codifiche e impronte del manifesto, audit dei
limiti e riferimenti della sonda; ripetere le relative baseline e mutazioni.
Ricontrollare capienza e durata di vita della nuova sede. La geometria del
pacchetto non dipende dall'indirizzo del buffer. Le coordinate CLUT113-117
restano x960, y401-(k-113), misurate in P2c1/ricognizione.json.

Build, pytest, prove DAT, callback, celle, rientro e giudizio visivo devono
essere eseguiti dalla regia. Gli invariati statici non certificano il runtime.
