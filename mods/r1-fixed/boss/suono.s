# M3-L28: suono della conferma (0x192, come la croce del menu) e uscita dalla schermata dopo un gesto di gesti.s
# (boss o partita casuale). Sede: EXE, coda del blocco di L9 (LoadImage2 + StoreImage2, da 0x80031614 a 0x8003165c,
# 72 byte liberi), provato in L5.
# La funzione del suono (0x80022660) torna direttamente all'epilogo di SELECT NUMBER OF PLAYERS (0x800b429c): ra
# preparato qui, argomenti come la chiamata originale a 0x800b4240-0x800b4258 (lo stack è quello della schermata).
.set noreorder
.set noat

.global gesti_suono
gesti_suono:
    addiu $a0, $zero, 0x192
    addu  $a1, $zero, $zero
    addu  $a2, $zero, $zero
    addiu $a3, $zero, 0x1000
    addiu $v0, $zero, 0x1e00
    sw    $v0, 16($sp)
    sw    $zero, 20($sp)
    lui   $ra, 0x800b
    j     0x80022660
    ori   $ra, $ra, 0x429c
