# Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0, voce 50; PAL ovl1083, 0x800b8a94, 4 byte.
# Originale: andi v1,v1,0x2000; il delay slot (lw a2,4(v0)) resta fuori patch.
# Prove e contratto: docs/evidence/pal-r1/p2b2/sblocco.json.
# Dipendenza lingua: i descrittori PAL restano indicizzati da 0x8005c41c.
# Il controllo abilita il ramo arena sbloccata; non aggiunge stringhe. Provare anche Italiano (3).
.set noreorder
jal   sblocco_v1
