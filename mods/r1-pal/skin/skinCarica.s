# PAL-P2c1: port con fixture PAL, voce R1 11, EXE, sede assegnata 0x80038700. Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0.
# Provenienza: r1-fixed/skin/skinCarica.s, riferimento 418a3f8.
# Prove: docs/evidence/pal-r1/p2c1/innesti.json, sedi.json e funzioni.json.
# Attivato in P2c1; compilazione e percorso modificato da verificare dalla regia.
.set noreorder
.set noat

.global skin_carica
skin_carica:
    addiu $sp, $sp, -40
    sw    $ra, 36($sp)
    sw    $s0, 32($sp)
    sw    $s1, 28($sp)
    move  $s0, $a0                    # buffer: .tex e poi .mdl
    move  $s1, $a1                    # voce di _charModelEntries
    lw    $t0, 12($a1)                # .tex: puntatore alla voce della tabella indice del DAT
    lui   $t1, 0x800a
    addiu $t1, $t1, -9264             # _charModelEntries (0x8009dbd0)
    addiu $t2, $t1, 1536              # 96 voci da 16 byte
    lui   $t3, %hi(SKIN_SETTORE)
    addiu $t3, $t3, %lo(SKIN_SETTORE)
    addu  $t3, $t3, $t7               # inizio del blocco del posto
skin_somma:                           # settore = inizio del blocco + settori dei .tex con voce minore
    lw    $t4, 12($t1)
    addiu $t1, $t1, 16
    lw    $t6, 4($t4)                 # dimensione del .tex
    sltu  $t5, $t4, $t0
    addiu $t6, $t6, 2047
    beq   $t5, $zero, skin_dopo
    srl   $t6, $t6, 11
    addu  $t3, $t3, $t6
skin_dopo:
    bne   $t1, $t2, skin_somma
    nop
    lw    $t6, 4($t0)                 # dimensione del .tex originale = della skin
    sw    $t3, 16($sp)                # voce finta: settore della skin
    sw    $t6, 20($sp)                #             dimensione
    addiu $a0, $sp, 16
    lui   $t4, %hi(skin_vertici_blocco)
    sw    $t7, %lo(skin_vertici_blocco)($t4)  # per skin_vertici_carica (M3-V3)
    jal   skin_leggi
    move  $a1, $s0
    move  $a0, $s0
    move  $a1, $s1
    lw    $ra, 36($sp)
    lw    $s1, 28($sp)
    lw    $s0, 32($sp)
    j     skin_vertici_carica         # M3-V3: colori dei vertici, poi il callback originale
    addiu $sp, $sp, 40

.global skin_vertici_blocco
skin_vertici_blocco:                  # scostamento del blocco del posto in settori (t7)
    .word 0
