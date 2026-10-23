.set noreorder
.global salto_pagine
salto_pagine:
    lw    $t1, -0x5110($v0)
    lui   $t2, 0x8005
    sll   $t3, $t1, 1
    addu  $t3, $t3, $t1
    sll   $t3, $t3, 2
    subu  $t3, $t3, $t1
    sll   $t3, $t3, 3
    addu  $t2, $t2, $t3
    lw    $t2, 0x1380($t2)
    nop
    andi  $t2, $t2, 0x8
    beq   $t2, $zero, resto
    nop
    sw    $zero, -0x42f0($v0)
resto:
    lw    $v1, -0x42f0($v0)
    j     0x800832c8
    addiu $sp, $sp, -24
