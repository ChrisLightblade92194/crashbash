# M3-L24: scelta casuale del minigioco e dell'arena. Sede: EXE, MemCardClose + MemCardReadData (0x80039c04-0x80039ce4,
# 224 byte, mai chiamate). Arriva da casuale_croce (casuale.s) con t9 = ra del chiamante.
# Tabella delle arene di CHOOSE LEVEL 0x800ba324 (modulo 722): 7 famiglie (puntatore, numero = 4), arene da 16 byte
# (tipo, livello, modello, valore). Sbloccata, come il predicato di CHOOSE LEVEL con L23 (0x800b7c68 e i tre controlli
# in linea): sblocco_sessione, oppure il bit 0x2000 di 0x8005a618, oppure tipo 1, oppure tipo 2 con
# 0x8005a6f8[livello] o 0x8005a77c[livello] diversi da zero.
# Prima il minigioco, uniforme fra le famiglie con almeno un'arena sbloccata, poi l'arena, uniforme fra le sue sbloccate.
.set noreorder
.set noat

.global casuale_genera
casuale_genera:
    lui   $t0, %hi(sblocco_sessione)
    lw    $t0, %lo(sblocco_sessione)($t0)
    lui   $t1, 0x8006
    lw    $t1, -0x59e8($t1)            # 0x8005a618
    addu  $t5, $zero, $zero            # arene sbloccate: bit 4 * famiglia + arena
    andi  $t1, $t1, 0x2000
    or    $t8, $t0, $t1                # diverso da zero: tutte sbloccate
    lui   $t6, 0x800c
    addiu $t6, $t6, -0x5cdc            # tabella delle arene (0x800ba324)
    addu  $t4, $zero, $zero            # bit dell'arena corrente
casuale_famiglia:
    lw    $t2, 0($t6)                  # prima arena della famiglia
    lw    $t3, 4($t6)                  # numero di arene
    addiu $t6, $t6, 8
casuale_arena:
    beq   $t3, $zero, casuale_famiglia_dopo
    lw    $a0, 0($t2)                  # tipo
    lw    $a1, 4($t2)                  # livello
    bne   $t8, $zero, casuale_si
    addiu $v0, $a0, -1
    beq   $v0, $zero, casuale_si       # tipo 1: sempre sbloccata
    addiu $v0, $a0, -2
    bne   $v0, $zero, casuale_no       # né 1 né 2: bloccata
    lui   $v1, 0x8006
    addu  $v1, $v1, $a1
    lbu   $v0, -0x5908($v1)            # 0x8005a6f8[livello]
    lbu   $a2, -0x5884($v1)            # 0x8005a77c[livello]
    nop
    or    $v0, $v0, $a2
    beq   $v0, $zero, casuale_no
casuale_si:
    addiu $v0, $zero, 1
    sllv  $v0, $v0, $t4
    or    $t5, $t5, $v0
casuale_no:
    addiu $t3, $t3, -1
    addiu $t2, $t2, 16
    b     casuale_arena
    addiu $t4, $t4, 1
casuale_famiglia_dopo:
    xori  $v0, $t4, 28                 # 7 famiglie da 4 arene
    bne   $v0, $zero, casuale_famiglia
    addu  $t0, $zero, $zero            # maschera delle famiglie (azzerata a ogni giro, usata dopo l'ultimo)

    addu  $t1, $zero, $zero            # famiglia
    addu  $t2, $t5, $zero
casuale_famiglie:
    andi  $v0, $t2, 0xf
    sltu  $v0, $zero, $v0              # 1 se la famiglia ha arene sbloccate
    sllv  $v0, $v0, $t1
    or    $t0, $t0, $v0
    srl   $t2, $t2, 4
    bne   $t2, $zero, casuale_famiglie
    addiu $t1, $t1, 1
    jal   casuale_bit                  # minigioco
    nop
    addu  $t6, $v0, $zero              # famiglia (0x8005a64a)
    sll   $v0, $t6, 2
    srlv  $t0, $t5, $v0
    jal   casuale_bit                  # arena della famiglia
    andi  $t0, $t0, 0xf
    j     casuale_personaggi
    addu  $t7, $v0, $zero              # arena (0x8005a64b)
