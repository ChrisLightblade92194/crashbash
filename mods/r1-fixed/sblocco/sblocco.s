# M3-L23: il cerchio su CHOOSE LEVEL sblocca per la sessione tutte le arene di Battle.
# Sede: EXE, blocco MemCardOpen con la coda (0x80039a7c-0x80039be0, 356 byte, mai chiamata: prova di L5 con il
# blocco pieno di break). Il flag resta in RAM fino allo spegnimento e non va sulla memory card.
# Agganci nel modulo 722 (front-end), docs/evidence/m3-l23/LEGGIMI.md:
#   - 0x800b74dc: la chiamata della funzione dei tasti di CHOOSE LEVEL (jal 0x800b6e0c) diventa jal sblocco_tasti;
#   - 0x800b7028 e 0x800b70f8 (funzione dei tasti, andi v1, v1, 0x2000) e 0x800b7638 (aggiornamento delle icone,
#     andi a0, a0, 0x2000): il controllo del bit 0x2000 di 0x8005a618 diventa jal sblocco_v1 o jal sblocco_a0, che
#     rieseguono l'andi e aggiungono il flag di sessione. Le due funzioni salvano ra nel prologo; i delay slot
#     originali restano e non toccano il registro controllato. Il quarto controllo (FUN_800b7c68, 0x800b7c94) sta
#     in una funzione foglia senza chiamanti e resta originale.
.set noreorder
.set noat

# Funzione dei tasti di CHOOSE LEVEL con il cerchio davanti. Il cerchio del giocatore 1 accende il flag e, alle
# stesse condizioni del gioco (dati di Crash Bash nello slot 1, nessuna lettura in corso), fa anche l'import
# originale degli sblocchi dalla card (FUN_800b6c04(1)). Suono 0x396 dell'import se qualcosa cambia.
.global sblocco_tasti
sblocco_tasti:
    lui   $t0, 0x8005
    lw    $t0, 0x1380($t0)             # tasti appena premuti, giocatore 1
    nop
    andi  $t0, $t0, 0x2000             # cerchio
    beq   $t0, $zero, sblocco_tasti_fine
    nop
    addiu $sp, $sp, -32
    sw    $ra, 28($sp)
    sw    $s0, 24($sp)
    lui   $t1, %hi(sblocco_sessione)
    lw    $t2, %lo(sblocco_sessione)($t1)
    addu  $s0, $zero, $zero            # s0 != 0 se il cerchio ha cambiato qualcosa
    bne   $t2, $zero, sblocco_card
    addiu $t2, $zero, 1
    sw    $t2, %lo(sblocco_sessione)($t1)
    addiu $s0, $zero, 1
sblocco_card:
    lui   $t1, 0x8006
    lw    $t1, 0x55c0($t1)             # stato della card nello slot 1 (0x800655c0)
    nop
    andi  $t2, $t1, 0x52               # bit 2 (card), 0x10 (dati di Crash Bash) e 0x40 (lettura in corso)
    xori  $t2, $t2, 0x12
    bne   $t2, $zero, sblocco_suono
    nop
    jal   0x800b6c04                   # import originale: numero di arene sbloccate dalla card
    addiu $a0, $zero, 1
    or    $s0, $s0, $v0
sblocco_suono:
    beq   $s0, $zero, sblocco_tasti_esci
    addiu $a0, $zero, 0x396
    addu  $a1, $zero, $zero
    addu  $a2, $zero, $zero
    addiu $a3, $zero, 0x1000
    addiu $t0, $zero, 0x1e00
    sw    $t0, 16($sp)
    jal   0x80022660                   # suono, con gli argomenti dell'import originale
    sw    $zero, 20($sp)
sblocco_tasti_esci:
    lw    $ra, 28($sp)
    lw    $s0, 24($sp)
    addiu $sp, $sp, 32
sblocco_tasti_fine:
    j     0x800b6e0c                   # funzione originale dei tasti, con ra del chiamante
    nop

# Controlli del bit 0x2000: usano solo il registro controllato e at.
.global sblocco_v1
sblocco_v1:
    lui   $at, %hi(sblocco_sessione)
    lw    $at, %lo(sblocco_sessione)($at)
    andi  $v1, $v1, 0x2000
    jr    $ra
    or    $v1, $v1, $at

.global sblocco_a0
sblocco_a0:
    lui   $at, %hi(sblocco_sessione)
    lw    $at, %lo(sblocco_sessione)($at)
    andi  $a0, $a0, 0x2000
    jr    $ra
    or    $a0, $a0, $at

.balign 4
.global sblocco_sessione
sblocco_sessione:
    .word 0                            # 1 dopo il cerchio su CHOOSE LEVEL (letto anche da L24)
