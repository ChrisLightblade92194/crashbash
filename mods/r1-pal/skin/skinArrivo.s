# PAL-P2c1: port con fixture PAL, voce R1 20, EXE, sede assegnata 0x8003a7b8. Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0.
# Provenienza: r1-fixed/skin/skinArrivo.s, riferimento 418a3f8.
# Prove: docs/evidence/pal-r1/p2c1/innesti.json, sedi.json e funzioni.json.
# Attivato in P2c1; compilazione e percorso modificato da verificare dalla regia.
.set noreorder
.set noat

.global skin_arrivo
skin_arrivo:
    lui   $t0, 0x8006
    lbu   $t0, -15338($t0)            # giocatori umani (0x8005c416)
    lui   $t1, 0x800c
    addiu $t1, $t1, -11904            # giocatori (0x800bd180, 96 byte)
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
    j     0x800b75e4
    sb    $zero, %lo(skin_scelta)($t0)

# Banco C6: ingresso isolato per mutazione semantica di un byte del JAL.
# Non raggiunto dal percorso corretto; esegue il comportamento originale senza effetto skin.
.global skin_ingresso_sonda_originale
skin_ingresso_sonda_originale:
    j     0x800b75e4
    nop
