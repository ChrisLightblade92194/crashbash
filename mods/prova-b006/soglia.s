.set noreorder
# B-006 (M3-L26), parte 1 di 2. 0x800bfd84: lhu t0, 70(a0) (soglia del danno u16[M+0x46]) al posto di
# lhu v1, 88(a0), che ricaricava +0x58 già in v1 da 0x800bfd64: il numero di load della funzione non cambia.
# Fino a 0x800bfdf8 le istruzioni usano solo v0, v1 e a0 e non scrivono +0x46. Il ritardo del load è
# li v0, 25 a 0x800bfd88, che non legge t0.
.word 0x94880046
