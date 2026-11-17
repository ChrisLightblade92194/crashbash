# Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0, voce 49; PAL ovl1083, 0x800b89c4, 4 byte.
# Originale: andi v1,v1,0x2000; il delay slot (lw a2,4(v0)) resta fuori patch.
# Prove e contratto: docs/evidence/pal-r1/p2b2/sblocco.json.
.set noreorder
jal   sblocco_v1
