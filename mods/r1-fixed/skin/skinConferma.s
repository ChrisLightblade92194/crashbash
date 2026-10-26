# M3-L15: store del personaggio confermato (modulo 722, 0x800b62f0, originale sb v0, 80(v1)) sostituito da
# jal skin_conferma, che lo esegue e scrive il flag della skin; il delay slot (lw v1, 48(s4)) resta.
.set noreorder
jal   skin_conferma
