# PAL-P2c1: port con fixture PAL, voce R1 41, EXE, sede assegnata 0x800473ec. Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0.
# Provenienza: r1-fixed/skin/skinVertici.s, riferimento 418a3f8.
# Prove: docs/evidence/pal-r1/p2c1/innesti.json, sedi.json e funzioni.json.
# Attivato in P2c1; compilazione e percorso modificato da verificare dalla regia.
.set noreorder
.set noat
# Contratto P3 da verificare sulle coppie PAL: MDL dopo i settori interi del
# TEX; tabella colori a MDL+0x20+[MDL+0x20], spazio sufficiente per K settori.

.global skin_vertici_carica
skin_vertici_carica:
    addiu $sp, $sp, -40
    sw    $ra, 36($sp)
    sw    $a0, 24($sp)
    sw    $a1, 28($sp)
    lui   $t0, %hi(skin_vertici_blocco)
    lw    $t0, %lo(skin_vertici_blocco)($t0)  # scostamento del blocco del posto (t7 di skin_carica)
    addiu $t1, $zero, %lo(SKIN_BLOCCO)
    divu  $zero, $t0, $t1             # istruzione nuda, senza il controllo della macro (SKIN_BLOCCO > 0)
    jal   skin_vertici_settore        # v0 = K, v1 = settore relativo a SKIN_SETTORE
    mflo  $t0                         # posto − 1
    beq   $v0, $zero, skin_vertici_fine
    lw    $t0, 12($a1)                # .tex: puntatore alla voce della tabella indice del DAT
    lui   $t1, %hi(SKIN_SETTORE)
    lw    $t0, 4($t0)                 # dimensione del .tex
    addiu $t1, $t1, %lo(SKIN_SETTORE)
    addu  $v1, $v1, $t1
    sll   $v0, $v0, 11
    sw    $v1, 16($sp)                # voce finta: settore
    sw    $v0, 20($sp)                #             K × 2048
    addiu $t0, $t0, 2047
    srl   $t0, $t0, 11
    sll   $t0, $t0, 11
    addu  $a1, $a0, $t0               # .mdl nel buffer
    lw    $t1, 0x20($a1)
    addiu $a0, $sp, 16
    addu  $a1, $a1, $t1
    jal   skin_leggi
    addiu $a1, $a1, 0x20              # tabella dei colori
skin_vertici_fine:
    lw    $a0, 24($sp)
    lw    $a1, 28($sp)
    lw    $ra, 36($sp)
    j     0x8001291c                  # callback originale
    addiu $sp, $sp, 40
