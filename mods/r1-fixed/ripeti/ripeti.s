# M3-L9 (R9) SELECT su SELECT GAME TYPE ripete l'ultima partita Battle; M3-L10 (R10) SELECT sulla cerimonia di fine partita vale la croce.
# Sede: EXE, blocco LoadImage2 + StoreImage2 (0x80031484-0x8003165c, mai chiamate).
# Hook: ingresso di FrontEnd_CheckLeave (0x8008efd4, voce 991), chiamata a ogni frame della schermata di gioco.
#   - nel front-end (_levelID 0x28), se il modo chiede l'uscita (bit 0x8000) con 0x8008 e tipo Battle, copia il
#     blocco di configurazione 0x8005a644-0x8005a684 e il prossimo livello (0x8009e5dc) in ripeti_dati;
#   - nel front-end, se il modo non chiede l'uscita, su SELECT GAME TYPE e senza cambio di schermata in corso
#     (_engineScreens.next e _frontEndScreens.next nulli), SELECT riscrive il blocco (che porta il modo a 0x8008)
#     e il prossimo livello se la configurazione è valida.
.set noreorder
.set noat

.global ripeti_hook
ripeti_hook:
    lui   $t0, 0x8006
    addiu $t0, $t0, -0x59bc            # 0x8005a644 = _gameMode (poi _minigameMode, _levelID, ...)
    lhu   $t1, 4($t0)                  # _levelID
    lhu   $t2, 0($t0)                  # _gameMode
    xori  $t1, $t1, 0x28               # solo nel front-end
    bne   $t1, $zero, ripeti_fine
    andi  $t3, $t2, 0x8000
    bne   $t3, $zero, ripeti_cattura
    lui   $t3, 0x8005
    lw    $t3, 0x1380($t3)             # tasti appena premuti, giocatore 1
    lui   $t4, 0x800a
    lw    $t6, -0x758($t4)             # _frontEndScreens.next (0x8009f8a8)
    lw    $t4, -0x75c($t4)             # _frontEndScreens.current (0x8009f8a4)
    lui   $t5, 0x800b
    ori   $t5, $t5, 0x8e28             # SELECT GAME TYPE
    xor   $t4, $t4, $t5
    bne   $t4, $zero, ripeti_fine
    andi  $t3, $t3, 1                  # SELECT
    beq   $t3, $zero, ripeti_fine
    lui   $t3, 0x800a
    lw    $t3, -0x9a4($t3)             # _engineScreens.next (0x8009f65c)
    nop
    or    $t3, $t3, $t6                # nessun cambio di schermata in corso, né del motore né del menu
    bne   $t3, $zero, ripeti_fine
    addu  $t9, $ra, $zero
    jal   ripeti_ripristina
    nop
    addu  $ra, $t9, $zero
ripeti_fine:
    j     0x8008efdc                   # resto di FrontEnd_CheckLeave
    lui   $v0, 0x8006                  # istruzione sostituita dal j

ripeti_cattura:
    lhu   $t3, 2($t0)                  # _minigameMode
    andi  $t1, $t2, 0x8008
    xori  $t1, $t1, 0x8008
    bne   $t1, $zero, ripeti_fine
    andi  $t3, $t3, 0xff
    addiu $t3, $t3, -1                 # solo Battle (1)
    bne   $t3, $zero, ripeti_fine
    lui   $t4, %hi(ripeti_dati)
    addiu $t4, $t4, %lo(ripeti_dati)
    addiu $t5, $t0, 64
    addiu $t6, $t4, 4
ripeti_copia:
    lw    $t7, 0($t0)
    addiu $t0, $t0, 4
    sw    $t7, 0($t6)
    addiu $t6, $t6, 4
    bne   $t0, $t5, ripeti_copia
    nop
    lui   $t5, 0x800a
    lhu   $t7, -0x1a24($t5)            # _nextLevel (0x8009e5dc)
    addiu $t8, $zero, 1
    sw    $t7, 0($t6)
    j     ripeti_fine
    sw    $t8, 0($t4)                  # configurazione valida

.global ripeti_conferma
ripeti_conferma:
    # M3-L10 (R10): ingresso della funzione del motore che legge la conferma del menu di fine partita (0x8007f1a8,
    # voce 991, ritorna i tasti premuti & 0x4008: croce o START). In una partita Battle, sulla cerimonia di fine
    # partita (_gameMode 0x801 e flag 0x200 di 0x8005a624) SELECT del giocatore 1 vale come la croce: si aggiunge il bit
    # della croce alla parola dei tasti appena premuti (0x80051380) prima che la funzione la legga.
    lui   $t0, 0x8006
    addiu $t0, $t0, -0x59bc            # 0x8005a644 = _gameMode
    lhu   $t2, 0($t0)
    lhu   $t3, 2($t0)                  # _minigameMode
    lw    $t4, -0x20($t0)              # flag di 0x8005a624
    xori  $t1, $t2, 0x801
    bne   $t1, $zero, ripeti_conferma_fine
    andi  $t4, $t4, 0x200
    beq   $t4, $zero, ripeti_conferma_fine
    andi  $t3, $t3, 0xff
    addiu $t3, $t3, -1                 # solo Battle (1)
    bne   $t3, $zero, ripeti_conferma_fine
    lui   $t3, 0x8005
    lw    $t4, 0x1380($t3)             # tasti appena premuti, giocatore 1
    nop
    andi  $t5, $t4, 1                  # SELECT
    beq   $t5, $zero, ripeti_conferma_fine
    ori   $t4, $t4, 0x4000             # croce
    sw    $t4, 0x1380($t3)
ripeti_conferma_fine:
    j     0x8007f1b0                   # resto della funzione
    sw    $s1, 28($sp)                 # seconda istruzione sostituita

# Riscrive la configurazione memorizzata; v0 = 1 se l'ha fatto, 0 se non c'è. Foglia: usa t0, t4-t7.
.global ripeti_ripristina
ripeti_ripristina:
    lui   $t4, %hi(ripeti_dati)
    addiu $t4, $t4, %lo(ripeti_dati)
    lw    $t5, 0($t4)
    nop
    beq   $t5, $zero, ripeti_nulla
    addu  $v0, $zero, $zero
    lui   $t0, 0x8006
    addiu $t0, $t0, -0x59bc
    addiu $t5, $t0, 64
    addiu $t4, $t4, 4
ripeti_ripr:
    lw    $t6, 0($t4)
    addiu $t4, $t4, 4
    sw    $t6, 0($t0)
    addiu $t0, $t0, 4
    bne   $t0, $t5, ripeti_ripr
    nop
    lw    $t6, 0($t4)
    lui   $t7, 0x800a
    sh    $t6, -0x1a24($t7)
    addiu $v0, $zero, 1
ripeti_nulla:
    jr    $ra
    nop

.balign 4
.global ripeti_dati
ripeti_dati:
    .space 72                          # valida, 16 parole di 0x8005a644, prossimo livello
