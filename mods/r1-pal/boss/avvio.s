# PAL-P2b2 voce 56, provenienza 418a3f8561774df5de192848cefb12ee736d50b0.
# Sede EXE 0x80037f18: 29 istruzioni + 4 byte = 120, fine esclusa 0x80037f90.
# Prove e limiti: docs/evidence/pal-r1/p2b2/boss.json. t0=0x80060000 da voce55.
# Il segnaposto p2b2_skin_inattive e' definito in casuale/scrivi.s (voce54),
# non abilita skin; P2c dovra' sostituirlo con la variabile skin_scelta provata.
.set noreorder
.set noat

.global gesti_boss
gesti_boss:
    beq   $t6, $zero, gesti_fine       # 3 o 4 umani: nessun avvio
    srl   $t5, $t5, 12                 # triangolo, cerchio, croce, quadrato
    andi  $t5, $t5, 0xf
    beq   $t5, $zero, gesti_fine
    lui   $t6, %hi(gesti_livelli)
    addiu $t6, $t6, %lo(gesti_livelli)
gesti_bit:
    andi  $t7, $t5, 1
    srl   $t5, $t5, 1
    beq   $t7, $zero, gesti_bit
    addiu $t6, $t6, 1
    lbu   $t7, -1($t6)
    lui   $t1, 0x0403
    ori   $t1, $t1, 0x0201             # personaggi 1,2,3,4 in little endian
    sw    $t1, -0x3bc4($t0)            # personaggi 0x8005c43c
    sw    $t1, -0x3bc0($t0)            # copie 0x8005c440
    addiu $t2, $zero, 1
    sh    $t2, -0x3bcc($t0)            # lato 0x8005c434
    lui   $t2, %hi(p2b2_skin_inattive)
    sw    $zero, %lo(p2b2_skin_inattive)($t2)
    lui   $t2, 0x800a
    sw    $t7, -0x3404($t2)            # prossimo livello 0x8009cbfc
    ori   $t2, $zero, 0x8008
    j     gesti_suono
    sh    $t2, -0x3be0($t0)            # modo 0x8005c420

.global gesti_menu
gesti_menu:
    lw    $v0, 0x48($s0)               # load sostituito a 0x800b54e4
    jr    $ra
    nop

.global gesti_fine
gesti_fine:
    j     0x800b5554                   # epilogo verificato, stack originale di 40 byte
    nop

gesti_livelli:
    .byte 31, 9, 4, 22                 # Oxide, Big Bad Fox, Papu Pummel, Bearminator
