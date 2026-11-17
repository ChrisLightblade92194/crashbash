# Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0, voce 48; PAL ovl1083, 0x800b8e78, 4 byte.
# Originale: jal 0x800b87a8; il delay slot (nop) resta fuori patch.
# Prove e contratto: docs/evidence/pal-r1/p2b2/sblocco.json.
.set noreorder
jal   sblocco_tasti
