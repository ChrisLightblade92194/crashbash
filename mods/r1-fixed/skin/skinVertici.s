# M3-V3 (Task B3): colori dei vertici in partita (§5 della specifica dello swatch e dei vertici).
# Sede: EXE, blocco CD_vol (0x8003f004-0x8003f08c, 136 byte, riserva di V3 provata nel Task 0.5).
# - skin_vertici_carica(buffer, voce): continua skin_carica (skin/skinCarica.s) con gli stessi argomenti.
#   Con K > 0 settori per la famiglia nel posto (skin_vertici_settore), legge sopra la tabella dei colori
#   del .mdl nel buffer i K settori dell'area dei vertici di SKIN.BIN; poi passa al callback originale
#   FUN_80012840. Il .mdl sta nel buffer dopo il .tex, al primo settore intero (Task 0.2); la tabella
#   è a .mdl + 0x20 + [.mdl + 0x20]. Tentativi illimitati (skin_tentativi = 0 in partita, come il .tex).
.set noreorder
.set noat

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
    j     0x80012840                  # callback originale
    addiu $sp, $sp, 40
