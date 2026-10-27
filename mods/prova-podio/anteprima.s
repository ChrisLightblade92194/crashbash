# M3-V1, prototipo usa-e-getta dell'anteprima delle varianti (spike S1-S3, mai nella R1).
# Chiamata da hookCursore.s al posto di «lw a0, 4(s4)» (modulo 722, 0x800b6114) con v0 = cursore 0-7 già
# mascherato; restituisce a0 = indice del giocatore e v0 intatto. Per un giocatore umano che preme L1 o R1
# su un personaggio non confermato, alterna il podio fra originale (voce crate del DAT) e skin del posto 1
# (BASHY.): legge il .tex crate nel buffer, scrive pixel e CLUT del podio in VRAM con le posizioni della
# tabella del record 199 (_modelTypes + 199 × 56, campo +0x18), poi rimette a zero il buffer.
.set noreorder
.set noat

.equ BUFFER, 0x800a4800             # 3 settori nella zona del motore a zero alla Character Select
.equ TABELLA_199, 0x800555f4        # _modelTypes (0x80052a54) + 199 × 56 + 0x18

.global proto_cs
proto_cs:
    addiu $sp, $sp, -72
    sw    $ra, 68($sp)
    sw    $s0, 64($sp)
    sw    $s1, 60($sp)
    sw    $s2, 56($sp)
    sw    $s3, 52($sp)
    sw    $v0, 48($sp)
    sw    $v1, 44($sp)
    sw    $a1, 40($sp)
    sw    $a2, 36($sp)
    sw    $a3, 32($sp)
    # prova-podio (M3-V1, spike A): per un umano non confermato mostra sul podio il personaggio del cursore.
    # Al cambio di personaggio fa come la conferma (0x800b6268-0x800b6398): tipo di modello 199 a +0x6c
    # dell'oggetto del podio, personaggio in 0x8005a660 + p e 0x8005a664 + p, stato di animazione da
    # 0x8005a9a0 in s4 + 52 e tabella del personaggio (slot + 0x1c) in s4 + 64; la scala (s4 + 28, s4 + 32)
    # va subito al valore finale (slot + 0x10). A ogni frame posa il modello come il ramo confermato
    # (0x800b5e6c-0x800b5f20).
    lw    $t0, 4($s4)                 # giocatore
    lui   $t1, 0x8006
    lbu   $t1, -22982($t1)            # giocatori umani (0x8005a63a)
    nop
    slt   $t1, $t0, $t1
    beqz  $t1, podio_fine
    sll   $t5, $v0, 2
    addu  $t5, $t5, $v0
    sll   $t5, $t5, 3                 # 40 × cursore
    lui   $t6, 0x800c
    addiu $t6, $t6, -25788
    addu  $t5, $t5, $t6               # slot del cursore
    lbu   $t7, 4($t5)                 # personaggio 1-8
    la    $t9, podio_ultimo
    addu  $t9, $t9, $t0
    lbu   $t8, 0($t9)
    nop
    beq   $t8, $t7, podio_posa
    lw    $t6, 8($s4)                 # oggetto del podio del giocatore
    sb    $t7, 0($t9)
    lui   $t9, 0x8006
    addu  $t9, $t9, $t0
    sb    $t7, -22944($t9)            # 0x8005a660 + p
    sb    $t7, -22940($t9)            # 0x8005a664 + p
    lw    $t7, 0x14($t5)              # tipo di modello (199)
    nop
    sll   $t8, $t7, 3
    subu  $t8, $t8, $t7
    sll   $t8, $t8, 3                 # 56 × tipo
    lui   $t9, 0x8005
    addiu $t9, $t9, 0x2a54            # _modelTypes
    addu  $t8, $t8, $t9
    sw    $t8, 0x6c($t6)
    lui   $t1, 0x8006
    addiu $t1, $t1, -22112            # stato di animazione iniziale (0x8005a9a0)
    addiu $t2, $s4, 52
    addiu $t3, $t1, 44
podio_copia:
    lw    $t4, 0($t1)
    addiu $t1, $t1, 4
    sw    $t4, 0($t2)
    bne   $t1, $t3, podio_copia
    addiu $t2, $t2, 4
    lw    $t4, 0x1c($t5)              # tabella del personaggio
    lw    $t7, 0x10($t5)              # scala finale
    sw    $t4, 64($s4)
    sw    $t7, 28($s4)
    sw    $t7, 32($s4)
    sw    $zero, 20($s4)
    sw    $zero, 24($s4)
podio_posa:
    lw    $t4, 28($s4)
    nop
    sra   $t4, $t4, 4
    sw    $t4, 32($t6)
    jal   0x80095e38
    addiu $a0, $zero, 2
    lw    $t6, 8($s4)
    lw    $t4, 32($s4)
    nop
    sra   $t4, $t4, 4
    sw    $t4, 36($t6)
    move  $a0, $zero
    move  $a1, $v0
    move  $a2, $t6
    jal   0x800251a8
    addiu $a3, $s4, 52
    lw    $t6, 8($s4)
    addiu $t7, $zero, 1
    sh    $t7, 82($t6)
podio_fine:
    lw    $v0, 48($sp)                # cursore
    lw    $t0, 4($s4)                 # giocatore
    lui   $t1, 0x8006
    lbu   $t1, -22982($t1)            # giocatori umani (0x8005a63a)
    nop
    slt   $t1, $t0, $t1
    beqz  $t1, proto_fine
    addiu $t2, $zero, 88
    mult  $t0, $t2
    mflo  $t2
    lui   $t3, 0x8005
    addu  $t3, $t3, $t2
    lw    $t3, 0x1380($t3)            # tasti appena premuti del giocatore
    nop
    andi  $t3, $t3, 0x0c00            # L1 0x400, R1 0x800
    beqz  $t3, proto_fine
    sll   $t5, $v0, 2
    addu  $t5, $t5, $v0
    sll   $t5, $t5, 3                 # 40 × cursore
    lui   $t6, 0x800c
    addiu $t6, $t6, -25788            # slot della Character Select (0x800b9b44)
    addu  $t5, $t5, $t6
    lw    $t6, 0($t5)
    nop
    andi  $t6, $t6, 1                 # personaggio già confermato
    bnez  $t6, proto_fine
    lbu   $s0, 4($t5)                 # personaggio 1-8
    la    $s1, proto_mostrata
    addu  $s1, $s1, $s0
    lbu   $s2, 0($s1)
    nop
    xori  $s2, $s2, 1                 # prototipo: solo originale e posto 1
    addiu $t7, $s0, -1
    bnez  $s2, proto_skin
    sll   $t8, $t7, 3
    la    $t9, proto_voci_crate
    sll   $t8, $t7, 1
    addu  $t9, $t9, $t8
    lhu   $t9, 0($t9)
    lui   $a0, 0x8005
    sll   $t9, $t9, 3
    addiu $a0, $a0, -7920             # tabella dell'indice del DAT (0x8004e110)
    b     proto_leggi
    addu  $a0, $a0, $t9
proto_skin:
    la    $a0, proto_finte
    addu  $a0, $a0, $t8
proto_leggi:
    lui   $a1, %hi(BUFFER)
    jal   skin_leggi
    addiu $a1, $a1, %lo(BUFFER)
    jal   0x8002ed68                  # DrawSync(0)
    move  $a0, $zero
    la    $s3, proto_coppie
    addiu $t7, $s0, -1
    sll   $t7, $t7, 2
    addu  $s3, $s3, $t7
    lw    $s3, 0($s3)                 # elenco delle coppie del personaggio
    nop
    lw    $t0, 0($s3)
    addiu $s3, $s3, 4
    sw    $t0, 24($sp)                # coppie restanti
proto_coppia:
    lw    $t0, 24($sp)
    nop
    beqz  $t0, proto_svuota
    addiu $t0, $t0, -1
    sw    $t0, 24($sp)
    lhu   $t1, 0($s3)                 # immagine del podio
    lui   $t2, %hi(TABELLA_199)
    lw    $t2, %lo(TABELLA_199)($t2)
    sll   $t3, $t1, 3
    subu  $t3, $t3, $t1
    sll   $t3, $t3, 3                 # 56 × immagine
    addu  $t2, $t2, $t3
    sw    $t2, 28($sp)                # voce della tabella
    lw    $a1, 4($s3)                 # offset dei pixel
    lui   $t4, %hi(BUFFER)
    addiu $t4, $t4, %lo(BUFFER)
    addu  $a1, $a1, $t4
    jal   0x8002f014                  # LoadImage(RECT dei pixel, pixel)
    addiu $a0, $t2, 0x18
    jal   0x8002ed68
    move  $a0, $zero
    lw    $t2, 28($sp)
    nop
    lhu   $t5, 0x26($t2)              # ID della CLUT
    nop
    andi  $t6, $t5, 0x3f
    sll   $t6, $t6, 4
    sh    $t6, 16($sp)                # x
    srl   $t6, $t5, 6
    sh    $t6, 18($sp)                # y
    lhu   $t6, 2($s3)
    nop
    sh    $t6, 20($sp)                # colori
    addiu $t6, $zero, 1
    sh    $t6, 22($sp)
    lw    $a1, 8($s3)                 # offset dei colori
    lui   $t4, %hi(BUFFER)
    addiu $t4, $t4, %lo(BUFFER)
    addu  $a1, $a1, $t4
    jal   0x8002f014                  # LoadImage(RECT della CLUT, colori)
    addiu $a0, $sp, 16
    jal   0x8002ed68
    move  $a0, $zero
    b     proto_coppia
    addiu $s3, $s3, 12
proto_svuota:
    lui   $t0, %hi(BUFFER)
    addiu $t0, $t0, %lo(BUFFER)
    addiu $t1, $t0, 0x1800
proto_azzera:
    sw    $zero, 0($t0)
    addiu $t0, $t0, 4
    bne   $t0, $t1, proto_azzera
    nop
    sb    $s2, 0($s1)                 # variante mostrata
proto_fine:
    lw    $ra, 68($sp)
    lw    $s0, 64($sp)
    lw    $s1, 60($sp)
    lw    $s2, 56($sp)
    lw    $s3, 52($sp)
    lw    $v0, 48($sp)
    lw    $v1, 44($sp)
    lw    $a1, 40($sp)
    lw    $a2, 36($sp)
    lw    $a3, 32($sp)
    lw    $a0, 4($s4)                 # istruzione sostituita
    jr    $ra
    addiu $sp, $sp, 72

.global proto_mostrata
proto_mostrata:
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0
podio_ultimo:
    .byte 0, 0, 0, 0
.align 2
