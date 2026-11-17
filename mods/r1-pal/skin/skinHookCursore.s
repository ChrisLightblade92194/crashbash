# PAL-P2c1: port con fixture PAL, voce R1 22, DAT1083, sede assegnata 0x800b7be8. Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0.
# Provenienza: r1-fixed/skin/skinHookCursore.s, riferimento 418a3f8.
# Prove: docs/evidence/pal-r1/p2c1/innesti.json, sedi.json e funzioni.json.
# Attivato in P2c1; compilazione e percorso modificato da verificare dalla regia.
# Contratto PAL: Sostituisce lw a0,4(s4); delay andi v0,v0,7; wrapper ripristina a0/v0.
.set noreorder
jal   skin_cursore
