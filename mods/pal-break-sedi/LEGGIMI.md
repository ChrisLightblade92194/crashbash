# Prova di tutte le sedi PAL

Generare dalla radice con `python -I tools/genera_pal_break_sedi.py`:
una sola build contiene tutte le 40 sedi generabili di `sedi.json` (37 della consegna di Codex più le tre risolte dalla regia; 6280 byte di BREAK).
Ogni sorgente `break_<id-USA>.s` contiene soltanto BREAK per la capacità
documentata, con provenienza. `--sede <id-USA>` limita a una sede;
`--escludi <id-USA>` è ripetibile per rimuovere le sedi già colpite.

Nessuna sede è ancora verificata dinamicamente. Le due sedi Decres hanno
capacità nominali di 164 byte e una prova statica distinta dallo studio;
le altre capacità sono lunghezze di firme. Non usare questo mod per giocare.

`avvio` usa una ISO con i BREAK già nell'EXE e reset a freddo.
Gli altri percorsi caricano il savestate originale in pausa, poi scrivono
tutti i BREAK in RAM con rilettura e flush della cache prima del primo frame.
Tutte le sedi sono nell'EXE residente, non negli overlay. La sonda verifica
CUE/ISO, tutti i byte e l'hash del savestate dichiarato nell'input.

Il monitor `pal_sede` accetta più intervalli e registra per ciascuno
armamento, prima sovrapposizione e primo ingresso su BREAK. Un arresto
CPU viene attribuito da PC o da EPC (+4 se Cause.BD), con ExcCode 9 e
rilettura del BREAK per la conferma. Dopo un arresto, rigenerare senza
la sede colpita, ricostruire e ripetere soltanto quel percorso; conservare
il risultato precedente e rispettare il budget complessivo di 90 minuti.

Exit: 0 percorso completato e tutte le sedi armate senza eventi; 1 sede
eseguita/sovrapposta; 2 errore o copertura non probante. Le sovrascritture
sono campionate ai VSync e possono sfuggire fra due campioni.

Input, savestate, taratura PNG, comandi e limiti sono nel rapporto
`docs/evidence/pal-r1/p1/LEGGIMI.md`. Output e immagini restano esterni
al repository. Nessuna compilazione o corsa Redux eseguita in P1a.
