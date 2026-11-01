# M3-L23: modulo 722, 0x800b7638 (aggiornamento, icone delle arene), originale andi a0, a0, 0x2000
# sostituito da jal sblocco_a0; il delay slot (addu v1, v1, s2) resta.
.set noreorder
jal   sblocco_a0
