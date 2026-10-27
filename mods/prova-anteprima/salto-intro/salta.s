.set noreorder
.global salto
salto:
    lui   $t0, 0x8005
    lw    $t1, 0x137c($t0)
    lui   $t0, 0x800a
    andi  $t1, $t1, 0x8
    beq   $t1, $zero, vai
    nop
    addiu $t1, $zero, 4
    sw    $t1, -0x1a5c($t0)
    addiu $t1, $zero, 1
    sw    $t1, -0x1a58($t0)
    lui   $t0, 0x800b
    sw    $zero, -0x13a8($t0)
vai:
    j     0x8008e5bc
    nop
