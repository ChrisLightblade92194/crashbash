# Provenienza: mods/r1-fixed/boss/oxide.s, game 7db60ceee82d7f7c6b61848da09789c4faa8d6dc.
# PAL voce 1348: 0x8008f4f0-0x8008f50c (28 byte).
# s0=0x8005c3f0 dal prologo 0x8008f3c0/3c8 e dall'innesto 59 osservato.
# _minigameMode=0x8005c422, quindi +50: indirizzi-p1c.json e lbu a 0x8008f5d8.
# Il ramo Battle a 0x8008f5d8 seleziona 41 tramite 0x8008f614/618/624.
# Il 32 conserva il ramo originale 0x8008f584. v1 viene riletto dai rami originali.
# Spostamento = (bersaglio - (PC+4))/4, ricalcolato per ciascuna istruzione:
# f4f4 -> f584: 0x23; f500 -> f5d8: 0x35; f508 -> f5d8: 0x33.
# Delay slot finale ORIGINALE, fuori patch, 0x8008f50c: lbu v0,399(s0).
# Non copiarvi il +391 USA: il campo PAL e' diverso, come prova innesti-oxide.json.
.set noreorder
.set noat
    addiu $v0, $zero, 32
    .word 0x10820023
    lbu   $v1, 50($s0)
    addiu $v0, $zero, 31
    .word 0x14820035
    addiu $v1, $v1, -1
    .word 0x10600033
