# Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0, voce 51; PAL ovl1083, 0x800b8fd4, 4 byte.
# Originale: andi a0,a0,0x2000; il delay slot (addu v1,v1,s2) resta fuori patch.
# Prove e contratto: docs/evidence/pal-r1/p2b2/sblocco.json.
.set noreorder
jal   sblocco_a0
