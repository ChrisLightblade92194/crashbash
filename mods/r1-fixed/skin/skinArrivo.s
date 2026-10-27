# M3-V2 (Task 4): arrivo del cursore (V-D5) e ingresso nella Character Select (§4.2 della specifica).
# Sede: EXE, blocco SsSepSetDecrescendo (0x80038a40-0x80038ae4, 164 byte, riserva provata in V1).
# - skin_arrivo(personaggio, cursore, giocatore): se un altro umano ha il cursore sullo stesso slot il podio
#   resta; altrimenti, se il personaggio mostra una variante, torna all'originale (skin_anteprima con 0).
# - skin_ingresso(giocatore): al posto di jal 0x800b5b10 (0x800b6454, inizializzazione dei giocatori 0-3
#   all'ingresso nella schermata): azzera podio_ultimo e skin_scelta del giocatore, poi salta a 0x800b5b10.
#   variante_mostrata resta: la schermata non ricarica le texture del podio (sonda del Task 4, casi ingresso
#   e rientro), quindi ogni podio continua a mostrare la sua variante, e l'arrivo di un umano su un
#   personaggio libero lo riporta all'originale (skin_arrivo) prima che la croce possa confermarlo.
.set noreorder
.set noat

.global skin_arrivo
skin_arrivo:
    lui   $t0, 0x8006
    lbu   $t0, -22982($t0)            # giocatori umani (0x8005a63a)
    lui   $t1, 0x800c
    addiu $t1, $t1, -24620            # giocatori (0x800b9fd4, 96 byte)
    move  $t2, $zero
skin_arrivo_altri:
    beq   $t2, $a2, skin_arrivo_dopo
    lw    $t3, 48($t1)                # cursore dell'altro giocatore
    nop
    beq   $t3, $a1, skin_arrivo_fine  # un altro umano è sul personaggio: il podio resta
    nop
skin_arrivo_dopo:
    addiu $t2, $t2, 1
    slt   $t3, $t2, $t0
    bne   $t3, $zero, skin_arrivo_altri
    addiu $t1, $t1, 96
    lui   $t5, %hi(variante_mostrata - 1)
    addu  $t5, $t5, $a0
    lbu   $t5, %lo(variante_mostrata - 1)($t5)
    nop
    beq   $t5, $zero, skin_arrivo_fine
    move  $a1, $zero
    j     skin_anteprima              # torna all'originale; ritorna al chiamante
    nop
skin_arrivo_fine:
    jr    $ra
    nop

.global skin_ingresso
skin_ingresso:
    lui   $t0, %hi(podio_ultimo)
    addu  $t0, $t0, $a0
    sb    $zero, %lo(podio_ultimo)($t0)
    lui   $t0, %hi(skin_scelta)
    addu  $t0, $t0, $a0
    j     0x800b5b10
    sb    $zero, %lo(skin_scelta)($t0)
