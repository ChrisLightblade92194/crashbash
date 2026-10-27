# M3-V2 (Task 4): modulo 722, 0x800b6114, originale lw a0, 4(s4) sostituito da jal skin_cursore (che lo
# esegue); il delay slot (andi v0, v0, 7) resta, quindi la routine riceve in v0 il cursore nuovo.
.set noreorder
jal   skin_cursore
