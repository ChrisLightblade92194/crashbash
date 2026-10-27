# M3-V2 (Task 4): modulo 722, 0x800b6454, originale jal 0x800b5b10 (inizializzazione del giocatore a0
# all'ingresso nella Character Select, da 0x800b63f4) sostituito da jal skin_ingresso, che azzera lo stato
# delle varianti del giocatore e salta a 0x800b5b10; il delay slot (move a0, s0) resta.
.set noreorder
jal   skin_ingresso
