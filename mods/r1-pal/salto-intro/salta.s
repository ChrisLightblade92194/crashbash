# Provenienza USA: 7db60ceee82d7f7c6b61848da09789c4faa8d6dc; voce 3.
# PAL: sede DrawOTagEnv da p2b1/sedi-r1.json (0x800342e4, 56 byte su 268).
# Osservazione a freddo del 2026-11-17 (p2b1/LEGGIMI.md): START tenuto (bit 3 di 0x80052834)
# porta indice 0x800bc810 a 4, timer 0x800bc814 a 1 e la terza 0x800be02c a 0, poi
# l'aggiornamento originale 0x800b6c54 passa al menu della lingua.
# Ordine diverso dalla USA, stesse scritture: vai sta a +0x10, cosi' la mutazione della voce 4
# (xor 0x10 sul puntatore) entra in vai e salta il controllo di START senza registri indefiniti.
.set noreorder
.global salto
salto:
    lui   $t0, 0x8005
    lw    $t1, 0x2834($t0)
    b     corpo
    lui   $t0, 0x800c
vai:
    j     0x800b6c54
    nop
corpo:
    andi  $t1, $t1, 0x8
    beq   $t1, $zero, vai
    addiu $t1, $zero, 4
    sw    $t1, -0x37f0($t0)
    addiu $t1, $zero, 1
    sw    $t1, -0x37ec($t0)
    j     0x800b6c54
    sw    $zero, -0x1fd4($t0)
