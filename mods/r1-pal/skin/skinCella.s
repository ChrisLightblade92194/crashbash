# PAL-P2c1: port con fixture PAL, voce R1 38, EXE, sede assegnata 0x800348e8. Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0.
# Provenienza: r1-fixed/skin/skinCella.s, riferimento 418a3f8.
# Prove: docs/evidence/pal-r1/p2c1/innesti.json, sedi.json e funzioni.json.
# Attivato in P2c1; compilazione e percorso modificato da verificare dalla regia.
# Ricognizione regia VRAM6400/6500: coordinate PAL960/401. L'include contiene solo
# PAL_CELLA_X/PAL_CELLA_Y misurate sulla VRAM PAL; non emette dati del gioco.
.set noreorder
.set noat
.include "skin/celle-geometria-pal.inc"

.global skin_cella
skin_cella:
    addiu $sp, $sp, -32
    sw    $ra, 28($sp)
    sw    $a1, 24($sp)                # colore: il pixel è la metà bassa della parola
    andi  $t0, $a0, 15
    addiu $t0, $t0, PAL_CELLA_X
    sh    $t0, 16($sp)                # x = base PAL + cella
    srl   $t1, $a0, 4
    addiu $t2, $zero, PAL_CELLA_Y
    subu  $t2, $t2, $t1
    sh    $t2, 18($sp)                # y = base PAL - riga
    addiu $t3, $zero, 1
    sh    $t3, 20($sp)                # 1 × 1
    sh    $t3, 22($sp)
    addiu $a0, $sp, 16
    jal   0x80033e6c                  # LoadImage
    addiu $a1, $sp, 24
    jal   0x80033bc0                  # DrawSync(0)
    move  $a0, $zero
    lw    $ra, 28($sp)
    nop
    jr    $ra
    addiu $sp, $sp, 32
