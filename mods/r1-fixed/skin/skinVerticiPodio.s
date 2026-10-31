# M3-V3 (Task B4): colori dei vertici sul podio (§5.3 della specifica dello swatch e dei vertici).
# Sede: EXE, blocco SsSepSetVol (0x80038504-0x80038584, 128 byte, riserva di V3 provata nel Task 0.5).
# - skin_vertici_podio(personaggio a0): skin_vertici_copia scrive il record di 0x800a8000 nella tabella dei
#   colori del .mdl 199 e mette ModelType[199] in DAT_80056998; poi nuova preparazione dei colori (Task 0.3):
#   FUN_80017d90(mesh, dati) per ogni nodo {successivo, dati} delle liste della cache C della mesh (parola 0
#   della mesh; 0 = niente da rifare), parità p con testa a C + 8 + 40p: un nodo per ogni oggetto del podio
#   che mostra il personaggio. Infine rimette il valore precedente di DAT_80056998.
#   FUN_80017d90 è una foglia che usa solo a, t e v: la cache e il nodo restano in $s2-$s4.
.set noreorder
.set noat

.global skin_vertici_podio
skin_vertici_podio:
    addiu $sp, $sp, -32
    sw    $ra, 28($sp)
    sw    $s2, 24($sp)
    sw    $s3, 20($sp)
    jal   skin_vertici_copia          # $s2 = mesh, $v1 = DAT_80056998 di prima
    sw    $s4, 16($sp)
    lw    $t0, 0($s2)                 # cache C
    sw    $v1, 12($sp)
    beq   $t0, $zero, skin_vertici_preparati
    move  $t3, $v1
    addiu $s3, $t0, 8                 # testa della lista della parità 0
skin_vertici_lista:
    lw    $s4, 0($s3)
skin_vertici_nodo:
    nop
    beq   $s4, $zero, skin_vertici_parita
    lw    $a1, 4($s4)                 # dati del nodo
    jal   0x80017d90
    move  $a0, $s2
    b     skin_vertici_nodo
    lw    $s4, 0($s4)                 # nodo successivo
skin_vertici_parita:
    lw    $t0, 0($s2)
    addiu $s3, $s3, 40
    addiu $t0, $t0, 88                # dopo la testa della parità 1
    bne   $s3, $t0, skin_vertici_lista
    lw    $t3, 12($sp)
skin_vertici_preparati:
    lui   $t1, 0x8005
    lw    $ra, 28($sp)
    sw    $t3, 0x6998($t1)            # DAT_80056998 di prima
    lw    $s2, 24($sp)
    lw    $s3, 20($sp)
    lw    $s4, 16($sp)
    jr    $ra
    addiu $sp, $sp, 32
