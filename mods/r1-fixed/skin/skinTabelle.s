# M3-V2 (Task 4): dati dell'anteprima delle varianti alla Character Select.
# Sede: EXE, blocco MoveImage (0x8002f0d4-0x8002f174, 160 byte, riserva provata in V1).
# - variante_mostrata[c − 1]: variante (0-5) che il podio del personaggio c mostra (§4.2 della specifica).
# - podio_ultimo[p]: personaggio (1-8) che il podio del giocatore umano p mostra prima della conferma
#   (V-D6); 0 = nessuno, azzerato all'ingresso nella schermata (skin_ingresso).
# - podio.inc (generato da tools/build.py): voce e settore del .tex crate per personaggio e coppie
#   immagine crate → immagine del podio.
.set noreorder

.global variante_mostrata
variante_mostrata:
    .space 8
.global podio_ultimo
podio_ultimo:
    .space 4
.include "skin/podio.inc"
