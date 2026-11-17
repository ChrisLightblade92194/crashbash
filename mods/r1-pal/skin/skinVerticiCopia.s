# PAL-P2c1: port con fixture PAL, voce R1 46, EXE, sede assegnata 0x8003f424. Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0.
# Provenienza: r1-fixed/skin/skinVerticiCopia.s, riferimento 418a3f8.
# Prove: docs/evidence/pal-r1/p2c1/innesti.json, sedi.json e funzioni.json.
# Attivato in P2c1; compilazione e percorso modificato da verificare dalla regia.
# Buffer provati dalla ricognizione della regia: ricognizione.json; inglese,1P,primo ingresso.
# 0x800a4800 solo Character Select, azzerare dopo lettura; 0x800a8000 libero fino al frame9000.
# Rientro,2P,altre lingue e scritture fra campioni restano fuori dalla prova.
# Podio PAL: ModelType[204], record 0x80056bac; MDL+0x0c, immagini+0x18.
.set noreorder
.set noat

.global skin_vertici_copia
skin_vertici_copia:
    lui   $t7, 0x8005
    lw    $v0, 0x6bb8($t7)            # .mdl del podio
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
    lw    $v1, 0x7f68($t7)            # DAT_80056998
    ori   $t1, $t7, 0x6bac            # ModelType[204]
    sw    $t1, 0x7f68($t7)
    jr    $ra
    addu  $s2, $v0, $t2               # mesh del personaggio
