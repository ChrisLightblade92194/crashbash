# M3-L24: scrittura della configurazione e partenza; scelta di un bit acceso con Rand. Sede: EXE, MemCardWriteData
# (0x80039eb0-0x80039f4c, 156 byte, mai chiamata).
.set noreorder
.set noat

# Arriva da casuale_personaggi (casuale.s) con t0 = 0x80060000, t5 = personaggi, t6 = famiglia, t7 = arena,
# t9 = ra del chiamante. Scrive quello che scriverebbero Character Select, CHOOSE LEVEL e GAME OPTIONS; tipo di
# battaglia, squadre, difficoltà e coppe restano come li ha lasciati il menu (tutti contro tutti nel percorso Battle).
.global casuale_scrivi
casuale_scrivi:
    sw    $t5, -0x59a0($t0)            # personaggi del menu (0x8005a660)
    sw    $t5, -0x599c($t0)            # e copie (0x8005a664), come la conferma della Character Select
    sb    $t6, -0x59b6($t0)            # famiglia (0x8005a64a)
    sb    $t7, -0x59b5($t0)            # arena (0x8005a64b)
    sll   $t1, $t6, 3
    lui   $t2, 0x800c
    addu  $t2, $t2, $t1
    lw    $t2, -0x5cdc($t2)            # prima arena della famiglia (tabella 0x800ba324)
    sll   $t1, $t7, 4
    addu  $t2, $t2, $t1
    lw    $t2, 4($t2)                  # livello dell'arena
    lui   $t1, %hi(skin_scelta)
    sw    $zero, %lo(skin_scelta)($t1) # skin originali per tutti (M3-L15; la Character Select non c'è stata)
    lui   $t1, 0x800a
    jal   0x800b4848                   # 0x8005a658 dai personaggi, come alla fine della Character Select
    sw    $t2, -0x1a24($t1)            # livello scelto (0x8009e5dc), come CHOOSE LEVEL
    ori   $t1, $zero, 0x8008
    jr    $t9
    sh    $t1, -0x59bc($t0)            # _gameMode: la partita parte, come la croce su GAME OPTIONS

# casuale_bit: t0 = maschera; v0 = indice di uno dei bit accesi scelto con Rand(numero dei bit accesi), 0 se la
# maschera è vuota. Usa t0-t4 (ra in t4).
.global casuale_bit
casuale_bit:
    addu  $t4, $ra, $zero
    addu  $t1, $t0, $zero
    addu  $a0, $zero, $zero
casuale_conta:
    andi  $v0, $t1, 1
    srl   $t1, $t1, 1
    bne   $t1, $zero, casuale_conta
    addu  $a0, $a0, $v0
    jal   0x80015590                   # Rand(n): da 0 a n - 1, 0 se n < 2
    addu  $t1, $zero, $zero            # indice del bit
casuale_cerca:
    andi  $t2, $t0, 1
    beq   $t2, $zero, casuale_avanti
    srl   $t0, $t0, 1
    beq   $v0, $zero, casuale_trovato
    nop
    addiu $v0, $v0, -1
casuale_avanti:
    bne   $t0, $zero, casuale_cerca
    addiu $t1, $t1, 1
    addu  $t1, $zero, $zero            # maschera vuota
casuale_trovato:
    jr    $t4
    addu  $v0, $t1, $zero
