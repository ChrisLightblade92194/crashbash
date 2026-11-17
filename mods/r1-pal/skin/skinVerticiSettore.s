# PAL-P2c1: port con fixture PAL, voce R1 42, EXE, sede assegnata 0x8003e984. Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0.
# Provenienza: r1-fixed/skin/skinVerticiSettore.s, riferimento 418a3f8.
# Prove: docs/evidence/pal-r1/p2c1/innesti.json, sedi.json e funzioni.json.
# Attivato in P2c1; compilazione e percorso modificato da verificare dalla regia.
.set noreorder
.set noat

.global skin_vertici_settore
skin_vertici_settore:
    lui   $t9, %hi(skin_vertici_k)
    sll   $t1, $t0, 3
    sll   $t3, $t0, 4
    addu  $t1, $t1, $t3
    addu  $t1, $t1, $t9               # riga del posto: 24 × (posto − 1), più %lo nella lettura
    sll   $t3, $t0, 1
    lui   $t4, %hi(skin_vertici_base)
    addu  $t4, $t4, $t3
    lhu   $v1, %lo(skin_vertici_base)($t4)
    lui   $t2, 0x800a
    addiu $t2, $t2, -9264             # _charModelEntries (0x8009dbd0)
    lw    $t5, 12($a1)                # .tex della famiglia
    move  $v0, $zero
    addiu $t6, $t2, 1520              # dall'ultima delle 96 voci da 16 byte
skin_vertici_somma:
    subu  $t7, $t6, $t2
    srl   $t8, $t7, 3
    andi  $t8, $t8, 6                 # 2 × (j & 3)
    srl   $t7, $t7, 6                 # j >> 2
    addu  $t7, $t7, $t1
    lbu   $t7, %lo(skin_vertici_k)($t7)
    lw    $t0, 12($t6)
    srlv  $t7, $t7, $t8
    andi  $t7, $t7, 3                 # K della famiglia j
    sltu  $t0, $t0, $t5
    bne   $t6, $a1, skin_vertici_altra
    subu  $t0, $zero, $t0             # maschera: voce .tex minore
    move  $v0, $t7                    # K della famiglia di a1
skin_vertici_altra:
    and   $t0, $t0, $t7
    addu  $v1, $v1, $t0
    bne   $t6, $t2, skin_vertici_somma
    addiu $t6, $t6, -16
    jr    $ra
    nop
