# M3-V3 (Task A5): celle swatch del personaggio sul podio a ogni variante (§4.2 della specifica di V3).
# Sede: EXE, coda libera di SsUtKeyOff (0x8003787c-0x80037924, 168 byte, dopo R8; provata in L5).
# skin_celle(personaggio a0 1-8, variante a1 0-5): per ogni cella del personaggio in skin_celle_dati
# (skin/celle.inc, da skin_celle_inizio[a0 − 1] a skin_celle_inizio[a0]) chiama skin_cella
# (skin/skinCella.s) con il colore originale del podio (variante 0, P2) o con quello che skin_texel
# (skin/skinTexel.s) legge dal .tex crate della variante nel buffer 0x800a4800, al texel della faccia
# corrispondente del crate: lo stesso colore della partita anche se la variante cambia i pixel.
# Salva e ripristina $ra e $s0-$s2: per skin_anteprima_coda (skin/skinCoda.s), che la chiama nel frame
# di skin_anteprima, $s0 e $s1 restano il personaggio e la variante.
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
