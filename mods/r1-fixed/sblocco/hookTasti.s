# M3-L23: modulo 722, 0x800b74dc, originale jal 0x800b6e0c (funzione dei tasti di CHOOSE LEVEL) sostituito da
# jal sblocco_tasti, che gestisce il cerchio e poi salta alla funzione originale; il delay slot (nop) resta.
.set noreorder
jal   sblocco_tasti
