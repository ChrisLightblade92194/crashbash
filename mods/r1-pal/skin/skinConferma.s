# PAL-P2c1: port con fixture PAL, voce R1 12, DAT1083, sede assegnata 0x800b7dc4. Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0.
# Provenienza: r1-fixed/skin/skinConferma.s, riferimento 418a3f8.
# Prove: docs/evidence/pal-r1/p2c1/innesti.json, sedi.json e funzioni.json.
# Attivato in P2c1; compilazione e percorso modificato da verificare dalla regia.
# Contratto PAL: Sostituisce sb v0,80(v1); delay slot originale lw v1,48(s4) conservato.
.set noreorder
jal   skin_conferma
