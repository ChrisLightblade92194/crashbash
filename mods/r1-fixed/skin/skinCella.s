# M3-V3 (Task A5): scrittura in VRAM di una cella swatch del podio, per skin_celle (skin/skinCelle.s).
# Sede: EXE, blocco GetDispEnv + GetODE (0x8002fa90-0x8002faf4, 100 byte, riserva provata in V3-0).
# skin_cella(posizione a0, colore a1): a0 = riga << 4 | cella di skin_celle_dati (riga = CLUT − 113).
# LoadImage del colore a 16 bit sul RECT 1 × 1 (x = 944 + cella, y = 469 − riga: CLUT 113 alla riga 469,
# 117 alla 465), poi DrawSync(0) prima di ritornare: RECT e colore stanno nel frame di questa funzione,
# che sparisce al ritorno, e LoadImage li legge quando esegue il trasferimento.
.set noreorder
.set noat

.global skin_cella
skin_cella:
    addiu $sp, $sp, -32
    sw    $ra, 28($sp)
    sw    $a1, 24($sp)                # colore: il pixel è la metà bassa della parola
    andi  $t0, $a0, 15
    addiu $t0, $t0, 944
    sh    $t0, 16($sp)                # x = 944 + cella
    srl   $t1, $a0, 4
    addiu $t2, $zero, 469
    subu  $t2, $t2, $t1
    sh    $t2, 18($sp)                # y = 469 − riga
    addiu $t3, $zero, 1
    sh    $t3, 20($sp)                # 1 × 1
    sh    $t3, 22($sp)
    addiu $a0, $sp, 16
    jal   0x8002f014                  # LoadImage
    addiu $a1, $sp, 24
    jal   0x8002ed68                  # DrawSync(0)
    move  $a0, $zero
    lw    $ra, 28($sp)
    nop
    jr    $ra
    addiu $sp, $sp, 32
