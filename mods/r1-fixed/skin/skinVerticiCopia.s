# M3-V3 (Task B4): colori del record del podio nella tabella dei colori del .mdl 199, per skin_vertici_podio.
# Sede: EXE, blocco SsSepPause + PushCallbackFunc + PullCallbackFunc (0x800392b0-0x8003932c, 124 byte, riserva di
# V3 provata nel Task 0.5).
# - skin_vertici_copia(personaggio a0): scrive le n voci del record in 0x800a8000 (mezza parola n, poi voci da
#   8 byte: indice a 16 bit, 2 byte a zero, colore a 4 byte da scostamento 6, copiato a mezze parole) nella
#   tabella del .mdl del podio (ModelType[199] + 0x0c, tabella a .mdl + 0x20 + [.mdl + 0x20]). Poi mette
#   ModelType[199] (0x800555dc) in DAT_80056998 per la nuova preparazione (Task 0.3). Uscita: $s2 = mesh del
#   personaggio (.mdl + skin_vertici_mesh[a0 − 1]), $v1 = valore precedente di DAT_80056998. Senza stack:
#   usa t, v e $s2, che skin_vertici_podio salva.
.set noreorder
.set noat

.global skin_vertici_copia
skin_vertici_copia:
    lui   $t7, 0x8005
    lw    $v0, 0x55e8($t7)            # .mdl del podio
    lui   $t1, 0x800a
    ori   $t1, $t1, 0x8000            # record
    lw    $t2, 0x20($v0)
    lhu   $t3, 0($t1)                 # n
    addu  $t2, $t2, $v0
    addiu $t2, $t2, 0x20              # tabella dei colori
skin_vertici_voce:
    lhu   $t4, 2($t1)                 # indice
    lhu   $t5, 6($t1)                 # colore
    lhu   $t6, 8($t1)
    beq   $t3, $zero, skin_vertici_copiati
    sll   $t4, $t4, 2
    addu  $t4, $t4, $t2
    sh    $t5, 0($t4)
    sh    $t6, 2($t4)
    addiu $t1, $t1, 8
    b     skin_vertici_voce
    addiu $t3, $t3, -1
skin_vertici_copiati:
    sll   $t1, $a0, 1
    lui   $t2, %hi(skin_vertici_mesh - 2)
    addu  $t2, $t2, $t1
    lhu   $t2, %lo(skin_vertici_mesh - 2)($t2)
    lw    $v1, 0x6998($t7)            # DAT_80056998
    ori   $t1, $t7, 0x55dc            # ModelType[199]
    sw    $t1, 0x6998($t7)
    jr    $ra
    addu  $s2, $v0, $t2               # mesh del personaggio
