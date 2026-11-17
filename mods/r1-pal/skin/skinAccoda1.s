# PAL-P2c1: port con fixture PAL, voce R1 13, DAT1348, sede assegnata 0x80092c74. Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0.
# Provenienza: r1-fixed/skin/skinAccoda1.s, riferimento 418a3f8.
# Prove: docs/evidence/pal-r1/p2c1/innesti.json, sedi.json e funzioni.json.
# Attivato in P2c1; compilazione e percorso modificato da verificare dalla regia.
# Contratto PAL: Sostituisce jal 0x80012828; delay addu a1,s5,zero; s4=giocatore, a0=entry.
.set noreorder
jal   skin_accoda
