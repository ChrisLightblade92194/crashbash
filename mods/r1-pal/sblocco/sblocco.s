# Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0, voce 47; port PAL statico P2b2.
# 50 istruzioni singole e una parola: 204 byte, 0x80049d54..0x80049e20.
# Sede prenotata P2b1: MemCardOpen; le altre voci iniziano a 0x80049e20 e 0x80049e74.
# sblocco_v1 +160, sblocco_a0 +180, sblocco_sessione +200 (0x80049e1c).
# Prove: docs/evidence/pal-r1/p2b2/sblocco.json; nessun delta globale.
# Input 0x80052838, card slot1 0x80066da4, import 0x800b85a0, suono 0x8002233c,
# funzione tasti 0x800b87a8: riferimenti PAL decodificati e firme distinte.
# Cerchio 0x2000, stato card 0x52/0x12, suono 0x396 e suoi argomenti restano
# quelli del percorso PAL. Nessuna costante esprime frame.
# Il flag di sessione vive in RAM; non viene scritto sulla memory card.
# I valori effettivi ai PC e il percorso con/senza card restano da osservare al banco.
.set noreorder
.set noat

# Funzione dei tasti di CHOOSE LEVEL con il cerchio davanti. Il cerchio del giocatore 1 accende il flag e, alle
# stesse condizioni del gioco (dati di Crash Bash nello slot 1, nessuna lettura in corso), fa anche l'import
# originale degli sblocchi dalla card (FUN_800b6c04(1)). Suono 0x396 dell'import se qualcosa cambia.
.global sblocco_tasti
sblocco_tasti:
    lui   $t0, 0x8005
    lw    $t0, 0x2838($t0)             # tasti appena premuti, giocatore 1
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
    lw    $t1, 0x6da4($t1)             # stato della card nello slot 1 (0x80066da4)
    nop
    andi  $t2, $t1, 0x52               # bit 2 (card), 0x10 (dati di Crash Bash) e 0x40 (lettura in corso)
    xori  $t2, $t2, 0x12
    bne   $t2, $zero, sblocco_suono
    nop
    jal   0x800b85a0                   # import originale: numero di arene sbloccate dalla card
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
    jal   0x8002233c                   # suono, con gli argomenti dell'import originale
    sw    $zero, 20($sp)
sblocco_tasti_esci:
    lw    $ra, 28($sp)
    lw    $s0, 24($sp)
    addiu $sp, $sp, 32
sblocco_tasti_fine:
    j     0x800b87a8                   # funzione originale dei tasti, con ra del chiamante
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
