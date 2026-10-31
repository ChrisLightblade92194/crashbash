# M3-V3 (Task A5, review del lotto A): colore di una cella swatch del podio con una variante, per skin_celle
# (skin/skinCelle.s). Sede: EXE, blocco SsVabOpenHeadSticky + SsVabFakeHead (0x80043aac-0x80043b14, 104 byte,
# riserva provata in V3-0).
# skin_texel: chiamata con convenzione propria, senza stack: $s2 = personaggio 1-8, $t3 = texel dell'immagine
# swatch del .tex crate che legge la faccia corrispondente (byte << 1 | nibble alto, skin/celle.inc).
# Legge l'indice dai pixel dell'immagine swatch del .tex della variante nel buffer 0x800a4800
# (BUFFER + skin_swatch_pixel[$s2 − 1]) e ritorna in $a1 il colore della palette swatch
# (BUFFER + skin_swatch[$s2 − 1] + 2 × indice), lo stesso che la faccia ha in partita anche quando la
# variante cambia i pixel. Usa solo $t0-$t6: $a0 resta.
.set noreorder
.set noat

.equ BUFFER, 0x800a4800

.global skin_texel
skin_texel:
    sll   $t0, $s2, 1
    lui   $t1, %hi(skin_swatch - 2)
    addu  $t1, $t1, $t0
    lhu   $t2, %lo(skin_swatch - 2)($t1)        # offset della palette swatch
    lui   $t1, %hi(skin_swatch_pixel - 2)
    addu  $t1, $t1, $t0
    lhu   $t4, %lo(skin_swatch_pixel - 2)($t1)  # offset dei pixel dell'immagine swatch
    srl   $t5, $t3, 1
    addu  $t4, $t4, $t5
    lui   $t6, %hi(BUFFER)
    addu  $t4, $t4, $t6
    lbu   $t4, %lo(BUFFER)($t4)                 # due texel
    andi  $t5, $t3, 1
    sll   $t5, $t5, 2
    srlv  $t4, $t4, $t5
    andi  $t4, $t4, 15                          # indice nella palette swatch
    sll   $t4, $t4, 1
    addu  $t4, $t4, $t2
    addu  $t4, $t4, $t6
    jr    $ra
    lhu   $a1, %lo(BUFFER)($t4)
