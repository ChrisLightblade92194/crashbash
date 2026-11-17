# Provenienza USA: 785bec466601d937b5306357409bee0fcc6ec4de; voce 8, RC3 ancora in prova.
# 76 istruzioni e 80 byte dati: 384 byte, sede PAL 0x800362dc..0x8003645c.
# Prove degli assoluti: docs/evidence/pal-r1/p2b1/indirizzi.json e p1/indirizzi-p1c.json.
# Modo/minigioco/livello, personaggi/CPU/squadre conservano gli offset nel blocco di 64 byte.
# Umani a 0x8005c416: -0x4a dalla fine 0x8005c460, prova P1c umani.
# 0x28 (front-end), 0x8008 (uscita Battle), 1 (Battle/SELECT/valida) non sono frame.
# Il chiamante e i valori effettivi dei registri restano ipotesi da osservare in Redux.
# P2c1: cattura e ripristina skin_scelta (0x80048598), voce10; prova in p2c1/port.json.
.set noreorder
.set noat

.global ripeti_hook
ripeti_hook:
    lui   $t0, 0x8006
    addiu $t0, $t0, -0x3be0            # 0x8005c420 = _gameMode (poi _minigameMode, _levelID, ...)
    lhu   $t1, 4($t0)                  # _levelID
    lhu   $t2, 0($t0)                  # _gameMode
    xori  $t1, $t1, 0x28               # solo nel front-end
    bne   $t1, $zero, ripeti_fine
    andi  $t3, $t2, 0x8000
    bne   $t3, $zero, ripeti_cattura
    lui   $t3, 0x8005
    lw    $t3, 0x2838($t3)             # tasti appena premuti, giocatore 1
    lui   $t4, 0x800a
    lw    $t6, -0x267c($t4)             # _frontEndScreens.next (0x8009d984)
    lw    $t4, -0x2680($t4)             # _frontEndScreens.current (0x8009d980)
    lui   $t5, 0x800b
    ori   $t5, $t5, 0xbdb8             # SELECT GAME TYPE
    xor   $t4, $t4, $t5
    bne   $t4, $zero, ripeti_fine
    andi  $t3, $t3, 1                  # SELECT
    beq   $t3, $zero, ripeti_fine
    lui   $t3, 0x800a
    lw    $t3, -0x28c8($t3)             # _engineScreens.next (0x8009d738)
    nop
    or    $t3, $t3, $t6                # nessun cambio di schermata in corso, né del motore né del menu
    bne   $t3, $zero, ripeti_fine
    lui   $t4, %hi(ripeti_dati)
# Riscrive la configurazione memorizzata, se c'è. Qui t0 vale ancora 0x8005c420.
    addiu $t4, $t4, %lo(ripeti_dati)
    lw    $t5, 0($t4)
    nop
    beq   $t5, $zero, ripeti_fine
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
    sh    $t6, -0x3404($t7)
    lw    $t6, 4($t4)                  # M3-L15: skin della configurazione
    lui   $t7, %hi(skin_scelta)
    sw    $t6, %lo(skin_scelta)($t7)
    lbu   $t6, 8($t4)                  # RC3: umani evidenziati della configurazione
    j     ripeti_fine
    sb    $t6, -0x4a($t0)              # 0x8005c416 (t0 = 0x8005c460)
ripeti_fine:
    j     0x8008f770                   # resto di FrontEnd_CheckLeave
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
    lhu   $t7, -0x3404($t5)            # _nextLevel (0x8009cbfc)
    lui   $t1, %hi(skin_scelta)
    sw    $t7, 0($t6)
    lw    $t1, %lo(skin_scelta)($t1)   # M3-L15: skin scelte alla Character Select
    lbu   $t3, -0x4a($t0)              # RC3: umani evidenziati, 0x8005c416 (t0 = 0x8005c460)
    sw    $t1, 4($t6)
    sb    $t3, 8($t6)
    addiu $t8, $zero, 1
    j     ripeti_fine
    sw    $t8, 0($t4)                  # configurazione valida

.balign 4
.global ripeti_dati
ripeti_dati:
    .space 80                          # valida, 16 parole di 0x8005c420, prossimo livello, skin (M3-L15), umani (RC3)
