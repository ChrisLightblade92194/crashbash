# M3-V2 (Task 4): scrittura in VRAM del .tex crate sulle immagini del podio («Esiti di V1», S1).
# Sede: EXE, blocco PAD_init + InitPAD + StartPAD (0x8004b9c8-0x8004bb18, 336 byte, riserva provata in V1).
# skin_scrivi(personaggio 1-8): il buffer 0x800a4800 contiene il .tex crate del personaggio (formato in
# tools/skin_tex.py). Per ogni immagine j, in ordine, l'immagine del podio k = skin_coppie[inizio + j]: pixel
# con LoadImage sul RECT della voce k della tabella del record 199 (lw di 0x800555f4, 56 byte per voce,
# RECT a +0x18), CLUT dell'immagine (indice +0x0c >> 1, limitato all'ultima) con LoadImage sulla riga
# dell'ID della CLUT della voce (+0x26: x = (id & 0x3f) × 16, y = id >> 6), poi DrawSync(0); k = 255
# (immagine che il podio non usa) si salta.
.set noreorder
.set noat

.equ BUFFER, 0x800a4800

.global skin_scrivi
skin_scrivi:
    addiu $sp, $sp, -48
    sw    $ra, 44($sp)
    sw    $s0, 40($sp)
    sw    $s1, 36($sp)
    sw    $s2, 32($sp)
    sw    $s3, 28($sp)
    lui   $t0, %hi(skin_coppie_inizio - 1)
    addiu $t0, $t0, %lo(skin_coppie_inizio - 1)
    addu  $t0, $t0, $a0
    lbu   $s1, 0($t0)                 # prima coppia del personaggio
    lbu   $s2, 1($t0)                 # prima coppia del successivo
    lui   $s0, %hi(BUFFER)
    addiu $s0, $s0, %lo(BUFFER)
    lw    $t1, 12($s0)                # offset delle immagini (da +0x0c)
    nop
    addu  $s3, $s0, $t1
    addiu $s3, $s3, 12                # prima immagine
skin_scrivi_coppia:
    beq   $s1, $s2, skin_scrivi_fine
    lui   $t2, %hi(skin_coppie)
    addu  $t2, $t2, $s1
    lbu   $t2, %lo(skin_coppie)($t2)  # immagine del podio
    addiu $t9, $zero, 255
    beq   $t2, $t9, skin_scrivi_avanza    # immagine che il podio non usa
    lui   $t3, 0x8005
    lw    $t3, 0x55f4($t3)            # tabella delle immagini del podio (record 199 + 0x18)
    sll   $t4, $t2, 3
    subu  $t4, $t4, $t2
    sll   $t4, $t4, 3                 # 56 × immagine
    addu  $t3, $t3, $t4
    sw    $t3, 24($sp)
    addiu $a0, $t3, 0x18              # RECT dei pixel
    jal   0x8002f014                  # LoadImage
    addiu $a1, $s3, 0x14              # pixel dopo l'intestazione da 0x14 byte
    lhu   $t4, 0x0c($s3)
    lhu   $t5, 10($s0)                # numero di CLUT
    lw    $t6, 16($s0)                # offset delle CLUT (da +0x10)
    srl   $t4, $t4, 1                 # indice della CLUT
    sltu  $t7, $t4, $t5
    bne   $t7, $zero, skin_scrivi_clut
    addu  $t6, $t6, $s0
    addiu $t4, $t5, -1                # limitato all'ultima
skin_scrivi_clut:
    addiu $t6, $t6, 0x10
skin_scrivi_cerca:
    lw    $t7, 0($t6)                 # colori della CLUT
    beq   $t4, $zero, skin_scrivi_trovata
    sll   $t8, $t7, 1
    addiu $t4, $t4, -1
    addu  $t6, $t6, $t8
    b     skin_scrivi_cerca
    addiu $t6, $t6, 4
skin_scrivi_trovata:
    lw    $t3, 24($sp)
    sh    $t7, 20($sp)                # larghezza = colori
    lhu   $t5, 0x26($t3)              # ID della CLUT
    addiu $t8, $zero, 1
    sh    $t8, 22($sp)
    andi  $t8, $t5, 0x3f
    sll   $t8, $t8, 4
    sh    $t8, 16($sp)
    srl   $t8, $t5, 6
    sh    $t8, 18($sp)
    addiu $a0, $sp, 16
    jal   0x8002f014                  # LoadImage
    addiu $a1, $t6, 4
    jal   0x8002ed68                  # DrawSync(0): RECT e dati restano validi fino alla fine
    move  $a0, $zero
skin_scrivi_avanza:
    lhu   $t1, 0($s3)                 # parole per riga
    lhu   $t2, 2($s3)                 # righe
    addiu $s1, $s1, 1
    mult  $t1, $t2
    mflo  $t1
    sll   $t1, $t1, 1
    addu  $s3, $s3, $t1
    b     skin_scrivi_coppia
    addiu $s3, $s3, 0x14
skin_scrivi_fine:
    lw    $ra, 44($sp)
    lw    $s3, 28($sp)
    lw    $s2, 32($sp)
    lw    $s1, 36($sp)
    lw    $s0, 40($sp)
    jr    $ra
    addiu $sp, $sp, 48
