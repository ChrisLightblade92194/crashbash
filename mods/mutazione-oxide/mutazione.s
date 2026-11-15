# Mutazione di controllo della correzione di Oxide (M3-L28): stessi byte di r1-fixed/boss/oxide.s, ma senza l'ultimo
# salto: il 31 in Battle torna nel ramo del finale (warp room). Con i byte esclusi dallo scenario, run deve dare 0.
# M3-L28: GameScreen_NextLevel (0x8008ece4, voce 991), ramo dei livelli 31 e 32 riscritto sul posto, da 0x8008ee18
# a 0x8008ee30 (7 istruzioni). Oxide (31) in Battle passa alla scelta per tipo di partita (0x8008ef00: Battle → 41,
# CHOOSE LEVEL) invece del ramo del finale (warp room, o filmato e Secret Warp Room). Fuori dalla Battle e per il 32
# tutto resta come nell'originale. L'originale ricaricava s0 = 0x8005a614 a 0x8008ee30, ma s0 vale già così da
# 0x8008ecf0; v1 è libero (riletto a 0x8008eeb8 e a 0x8008ef00). Il delay slot dell'ultimo salto è l'istruzione
# originale a 0x8008ee34 (lbu v0, 391(s0)), sul percorso del 31 fuori dalla Battle come prima.
# Studio: docs/evidence/m3-l27/LEGGIMI.md, «Perché Oxide va alla warp room».
# I salti condizionati verso indirizzi del motore sono scritti come .word (l'assemblatore rifiuta il bersaglio
# assoluto): spostamento = (bersaglio - (indirizzo + 4)) / 4, come i salti originali (beq a0, v0, 0x8008eeac a
# 0x8008ee24 vale 0x10820021).
.set noreorder
.set noat

    addiu $v0, $zero, 32
    .word 0x10820023                   # 0x8008ee1c beq a0, v0, 0x8008eeac: livello 32, come l'originale
    lbu   $v1, 50($s0)                 # byte basso di _minigameMode (0x8005a646)
    addiu $v0, $zero, 31
    .word 0x14820035                   # 0x8008ee28 bne a0, v0, 0x8008ef00: altri livelli, scelta per tipo di partita
    addiu $v1, $v1, -1
    nop                                # mutazione: al posto di beq v1, zero, 0x8008ef00 (31 in Battle → 41)
