# PAL-P2c1: port con fixture PAL, voce R1 23, DAT1083, sede assegnata 0x800b7f28. Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0.
# Provenienza: r1-fixed/skin/skinHookIngresso.s, riferimento 418a3f8.
# Prove: docs/evidence/pal-r1/p2c1/innesti.json, sedi.json e funzioni.json.
# Attivato in P2c1; compilazione e percorso modificato da verificare dalla regia.
# Contratto PAL: Sostituisce jal 0x800b75e4; delay addu a0,s0,zero; wrapper tail jump alla init.
.set noreorder
jal   skin_ingresso
