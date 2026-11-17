# Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0; voce 54, L28.
# PAL-P2b2, sede 0x8004a188..0x8004a228; 156 byte codice + 4 dati.
# Prove: docs/evidence/pal-r1/p2b2/casuale.json e p1/indirizzi-p1c.json.
# Campi PAL provati in P1c; famiglia/arena a c426/c427 dal predicato PAL.
# Rand PAL 0x8001519c: chiamata univoca a b76c8 e corpo decodificato.
# 0x800b5b00: firma univoca della funzione USA b4848, conserva t0-t9.
# P2c1: azzera skin_scelta PAL (0x80048598), prova p2c1/port.json.
# Nessun testo letto o disegnato; nessuna costante contata in frame.
# Contratto dinamico ancora da osservare: non verificato senza Redux.
.set noreorder
.set noat

# Arriva da casuale_personaggi (casuale.s) con t0 = 0x80060000, t5 = personaggi, t6 = famiglia, t7 = arena,
# t9 = gesti_suono (M3-L28; prima ra del chiamante). Scrive quello che scriverebbero Character Select, CHOOSE LEVEL e GAME OPTIONS; tipo di
# battaglia, squadre, difficoltà e coppe restano come li ha lasciati il menu (tutti contro tutti nel percorso Battle).
.global casuale_scrivi
casuale_scrivi:
    sw    $t5, -0x3bc4($t0)            # personaggi del menu (0x8005c43c)
    sw    $t5, -0x3bc0($t0)            # e copie (0x8005c440), come la conferma della Character Select
    sb    $t6, -0x3bda($t0)            # famiglia (0x8005c426)
    sb    $t7, -0x3bd9($t0)            # arena (0x8005c427)
    sll   $t1, $t6, 3
    lui   $t2, 0x800c
    addu  $t2, $t2, $t1
    lw    $t2, -0x2af0($t2)            # prima arena della famiglia (tabella 0x800bd510)
    sll   $t1, $t7, 4
    addu  $t2, $t2, $t1
    lw    $t2, 4($t2)                  # livello dell'arena
    lui   $t1, %hi(skin_scelta)
    sw    $zero, %lo(skin_scelta)($t1) # skin originali per tutti (M3-L15; la Character Select non c'è stata)
    lui   $t1, 0x800a
    jal   0x800b5b00                   # 0x8005c434 dai personaggi, come alla fine della Character Select
    sw    $t2, -0x3404($t1)            # livello scelto (0x8009cbfc), come CHOOSE LEVEL
    ori   $t1, $zero, 0x8008
    jr    $t9
    sh    $t1, -0x3be0($t0)            # _gameMode: la partita parte, come la croce su GAME OPTIONS

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
    jal   0x8001519c                   # Rand(n): da 0 a n - 1, 0 se n < 2
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

.balign 4
    .space 4  # riserva conservata per mantenere dimensione e sede della voce54
