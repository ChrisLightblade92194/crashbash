# M3-L24: modulo 722, 0x800b425c (aggiornamento di SELECT NUMBER OF PLAYERS, croce), originale jal 0x800b5410
# (schermata seguente del menu) sostituito da jal casuale_croce; il delay slot (nop) resta.
.set noreorder
jal   casuale_croce
