# PAL-P2c1: port con fixture PAL, voce R1 18, EXE, sede assegnata 0x80033a14. Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0.
# Provenienza: r1-fixed/skin/skinPodio.s, riferimento 418a3f8.
# Prove: docs/evidence/pal-r1/p2c1/innesti.json, sedi.json e funzioni.json.
# Attivato in P2c1; compilazione e percorso modificato da verificare dalla regia.
.set noreorder
.set noat

.global skin_podio_prepara
skin_podio_prepara:
    lw    $t7, 0x14($a0)              # tipo di modello (204)
    lw    $t6, 8($s4)                 # oggetto del podio
    sll   $t8, $t7, 3
    subu  $t8, $t8, $t7
    sll   $t8, $t8, 3                 # 56 × tipo
    lui   $t9, 0x8005
    addiu $t9, $t9, 0x3f0c            # _modelTypes
    addu  $t8, $t8, $t9
    sw    $t8, 0x6c($t6)
    lui   $t1, 0x8006
    addiu $t1, $t1, -14460            # stato di animazione iniziale (0x8005c784)
    addiu $t2, $s4, 52
    addiu $t3, $t1, 44
skin_podio_copia:
    lw    $t4, 0($t1)
    addiu $t1, $t1, 4
    sw    $t4, 0($t2)
    bne   $t1, $t3, skin_podio_copia
    addiu $t2, $t2, 4
    lw    $t4, 0x1c($a0)              # tabella del personaggio
    sw    $zero, 20($s4)
    sw    $zero, 24($s4)
    sw    $zero, 28($s4)
    sw    $zero, 32($s4)
    jr    $ra
    sw    $t4, 64($s4)

.global skin_podio_posa
skin_podio_posa:
    lw    $t0, 36($s4)
    addiu $sp, $sp, -56               # cornice di 0x800b777c: s0-s6 a 24-48, ra a 52
    sw    $s0, 24($sp)
    sw    $s1, 28($sp)
    sw    $s2, 32($sp)
    sw    $s3, 36($sp)
    sw    $s4, 40($sp)
    sw    $s5, 44($sp)
    sw    $s6, 48($sp)
    addiu $t0, $t0, -1                # il ramo aggiunge 1
    sw    $t0, 36($s4)
    j     0x800b7894
    sw    $ra, 52($sp)
