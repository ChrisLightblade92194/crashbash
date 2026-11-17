# PAL-P2c1: port con fixture PAL, voce R1 15, EXE, sede assegnata 0x80048f30. Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0.
# Provenienza: r1-fixed/skin/skinScrivi.s, riferimento 418a3f8.
# Prove: docs/evidence/pal-r1/p2c1/innesti.json, sedi.json e funzioni.json.
# Attivato in P2c1; compilazione e percorso modificato da verificare dalla regia.
# Buffer provati dalla ricognizione della regia: ricognizione.json; inglese,1P,primo ingresso.
# 0x800a4800 solo Character Select, azzerare dopo lettura; 0x800a8000 libero fino al frame9000.
# Rientro,2P,altre lingue e scritture fra campioni restano fuori dalla prova.
# Podio PAL: ModelType[204], record 0x80056bac; MDL+0x0c, immagini+0x18.
# Layout runtime provato per le 67 coppie usate: strutture-runtime.json;
# record56byte, RECT+0x18 e CLUT+0x26, RAM6450 contro VRAM6400/6500.
# Puntatore ModelType204 statico; valore runtime del campo fuori dal dump.
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
    lw    $t3, 0x6bc4($t3)            # tabella delle immagini del podio (record 204 + 0x18)
    sll   $t4, $t2, 3
    subu  $t4, $t4, $t2
    sll   $t4, $t4, 3                 # 56 × immagine
    addu  $t3, $t3, $t4
    sw    $t3, 24($sp)
    addiu $a0, $t3, 0x18              # RECT dei pixel
    jal   0x80033e6c                  # LoadImage
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
    jal   0x80033e6c                  # LoadImage
    addiu $a1, $t6, 4
    jal   0x80033bc0                  # DrawSync(0): RECT e dati restano validi fino alla fine
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
