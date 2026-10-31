# M3-V3 (Task B3): tabelle dell'area dei vertici per skin_vertici_settore (skin/skinVerticiSettore.s).
# Sede: EXE, blocco InvSquareRoot (0x8003d7cc-0x8003d850, 132 byte, riserva di V3 provata nel Task 0.5).
# vertici.inc (generato da tools/build.py da skin/pacchetto.json e dal DAT originale): skin_vertici_k
# (120 byte) e skin_vertici_base (5 mezze parole); SKIN_PODIO_VERTICI serve a skin_anteprima_coda (Task B4).
.set noreorder

.include "skin/vertici.inc"
.global SKIN_PODIO_VERTICI
