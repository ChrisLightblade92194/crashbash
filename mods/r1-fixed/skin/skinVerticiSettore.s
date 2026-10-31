# M3-V3 (Task B3): settori dei vertici di una famiglia nell'area del posto, per skin_vertici_carica.
# Sede: EXE, blocco _spu_pitch2note (0x8004a31c-0x8004a3a4, 136 byte, riserva di V3 provata nel Task 0.5).
# - skin_vertici_settore(t0 posto − 1, a1 voce di _charModelEntries) → v0 = K, v1 = settore relativo a
#   SKIN_SETTORE: skin_vertici_base[posto − 1] più i K delle famiglie del posto con voce .tex minore di
#   quella di a1, come skin_somma (skin/skinCarica.s). Foglia: usa solo t, v; a0 e a1 restano.
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
    addiu $t2, $t2, -1516             # _charModelEntries (0x8009fa14)
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
