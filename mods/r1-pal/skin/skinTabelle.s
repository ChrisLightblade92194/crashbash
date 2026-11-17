# PAL-P2c1: port con fixture PAL, voce R1 21, EXE, sede assegnata 0x80033f2c. Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0.
# Provenienza: r1-fixed/skin/skinTabelle.s, riferimento 418a3f8.
# Prove: docs/evidence/pal-r1/p2c1/innesti.json, sedi.json e funzioni.json.
# Attivato in P2c1; compilazione e percorso modificato da verificare dalla regia.
.set noreorder

.global variante_mostrata
variante_mostrata:
    .space 8
.global podio_ultimo
podio_ultimo:
    .space 4
.include "skin/podio-pal.inc"
