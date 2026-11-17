# PAL-P2c1: port con fixture PAL, voce R1 37, EXE, sede assegnata 0x8003f324. Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0.
# Provenienza: r1-fixed/skin/skinCelle.s, riferimento 418a3f8.
# Prove: docs/evidence/pal-r1/p2c1/innesti.json, sedi.json e funzioni.json.
# Attivato in P2c1; compilazione e percorso modificato da verificare dalla regia.
.set noreorder
.set noat

.global skin_celle
skin_celle:
    addiu $sp, $sp, -32
    sw    $ra, 28($sp)
    sw    $s0, 24($sp)
    sw    $s1, 20($sp)
    sw    $s2, 16($sp)
    lui   $t0, %hi(skin_celle_inizio - 1)
    addiu $t0, $t0, %lo(skin_celle_inizio - 1)
    addu  $t0, $t0, $a0
    lbu   $s0, 0($t0)                 # prima cella del personaggio
    lbu   $s1, 1($t0)                 # prima cella del successivo
    beq   $a1, $zero, skin_celle_cella
    move  $s2, $zero                  # variante 0: colori originali del podio
    move  $s2, $a0                    # variante: il personaggio, per skin_texel
skin_celle_cella:
    beq   $s0, $s1, skin_celle_fine
    sll   $t0, $s0, 2
    lui   $t1, %hi(skin_celle_dati)
    addu  $t1, $t1, $t0
    addiu $t1, $t1, %lo(skin_celle_dati)
    lbu   $a0, 0($t1)                 # riga << 4 | cella
    lbu   $t3, 1($t1)                 # texel dell'immagine swatch del crate
    beq   $s2, $zero, skin_celle_scrivi
    lhu   $a1, 2($t1)                 # colore originale del podio
    jal   skin_texel                  # colore della variante in $a1; $a0 resta
    nop
skin_celle_scrivi:
    jal   skin_cella
    addiu $s0, $s0, 1
    b     skin_celle_cella
    nop
skin_celle_fine:
    lw    $ra, 28($sp)
    lw    $s2, 16($sp)
    lw    $s1, 20($sp)
    lw    $s0, 24($sp)
    jr    $ra
    addiu $sp, $sp, 32
