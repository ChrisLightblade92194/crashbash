# PAL-P2c1: port con fixture PAL, voce R1 45, EXE, sede assegnata 0x8003de2c. Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0.
# Provenienza: r1-fixed/skin/skinVerticiPodio.s, riferimento 418a3f8.
# Prove: docs/evidence/pal-r1/p2c1/innesti.json, sedi.json e funzioni.json.
# Attivato in P2c1; compilazione e percorso modificato da verificare dalla regia.
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
    jal   0x80017998
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
    sw    $t3, 0x7f68($t1)            # DAT_80056998 di prima
    lw    $s2, 24($sp)
    lw    $s3, 20($sp)
    lw    $s4, 16($sp)
    jr    $ra
    addiu $sp, $sp, 32
