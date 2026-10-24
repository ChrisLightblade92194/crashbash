# M3-L10 (R10), OPZIONALE e fuori dalla R1 (decisione del proprietario, 2026-10-24): SELECT sulla cerimonia di fine
# partita Battle vale la croce. Non è nella buildList attiva: per inserirlo togliere i due «//» delle righe
# «opzione R10» di buildList.txt (vedi opzioni/rivincita-select/LEGGIMI.md).
# Sede: EXE, subito dopo i dati di L9 (ripeti_dati termina a 0x800315f8), 84 byte fino a 0x8003164c nel blocco
# LoadImage2 + StoreImage2 (0x80031484-0x8003165c).
.set noreorder
.set noat

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
