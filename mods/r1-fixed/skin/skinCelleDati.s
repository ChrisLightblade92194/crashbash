# M3-V3 (Task A5): tabelle delle celle swatch del podio per skin_celle (skin/skinCelle.s).
# Sede: EXE, coda libera di DrawOTagEnv + GetDrawEnv (0x8002f4c4-0x8002f598, 212 byte, dopo R7; provata in L5).
# celle.inc (generato da tools/build.py dal DAT originale): skin_celle_dati (4 byte per cella, 48 celle)
# e skin_celle_inizio (9 byte). skin_swatch sta in skin/podio.inc: con questi 201 byte non entra qui.
.set noreorder

.include "skin/celle.inc"
