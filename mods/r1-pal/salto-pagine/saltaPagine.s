# Provenienza USA: 7db60ceee82d7f7c6b61848da09789c4faa8d6dc; voce 5.
# PAL: sede SsUtKeyOff da p2b1/sedi-r1.json, 68 byte.
# Prove: p2b1/indirizzi.json, pagine_pad/pad_premuti/pagine_lista/next_page.
# v0=0x800a0000 e pad selezionato: contratto statico, ipotesi da osservare in Redux.
# Stride 88 = ((p*2+p)*4-p)*8, decodificato a 0x80080fec..0x80080ffc.
.set noreorder
.global salto_pagine
salto_pagine:
    lw    $t1, -0x68d4($v0)
    lui   $t2, 0x8005
    sll   $t3, $t1, 1
    addu  $t3, $t3, $t1
    sll   $t3, $t3, 2
    subu  $t3, $t3, $t1
    sll   $t3, $t3, 3
    addu  $t2, $t2, $t3
    lw    $t2, 0x2838($t2)
    nop
    andi  $t2, $t2, 0x8
    beq   $t2, $zero, resto
    nop
    sw    $zero, -0x5db4($v0)
resto:
    lw    $v1, -0x5db4($v0)
    j     0x800846a8
    addiu $sp, $sp, -24
