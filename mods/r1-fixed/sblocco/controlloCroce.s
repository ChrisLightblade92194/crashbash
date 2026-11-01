# M3-L23: modulo 722, 0x800b7028 (funzione dei tasti, arena evidenziata alla croce), originale
# andi v1, v1, 0x2000 sostituito da jal sblocco_v1; il delay slot (lw a2, 4(v0)) resta.
.set noreorder
jal   sblocco_v1
