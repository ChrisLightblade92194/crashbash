# M3-L24: partita casuale. SELECT tenuto più la croce su SELECT NUMBER OF PLAYERS (percorso Battle) avvia subito
# una partita: umani = numero evidenziato (0x8005a63a), CPU fino a quattro (flag 0x8005a670 già scritti dalla
# schermata nello stesso frame), minigioco, arena e personaggi di tutti casuali con Rand (0x80015590), tutti contro
# tutti, difficoltà e coppe come le lascia il menu. Minigioco e arena solo fra quelli sbloccati, o fra tutti con lo
# sblocco di sessione di L23 (sblocco_sessione). Indagine e progetto: docs/evidence/m3-l24/LEGGIMI.md.
# Sedi: EXE, blocchi della libreria libmcrd mai chiamati (docs/notes/m3-spazio.md §5):
#   - questo file: coda di MemCardOpen (0x80039b48-0x80039be0, dopo il codice di L23), 152 byte;
#   - genera.s: MemCardClose + MemCardReadData (0x80039c04-0x80039ce4), 224 byte;
#   - scrivi.s: MemCardWriteData (0x80039eb0-0x80039f4c), 156 byte.
# Aggancio nel modulo 722 (hookCroce.s): 0x800b425c, jal 0x800b5410 (la croce passa alla schermata seguente)
# diventa jal casuale_croce. Il resto della mod non usa lo stack: ra del chiamante in t9, Rand cambia solo v0, v1,
# a0-a3, la funzione 0x800b4848 solo v0, v1, a0-a2; s0 e s1 del chiamante restano.
.set noreorder
.set noat

# Croce su SELECT NUMBER OF PLAYERS (il suono 0x192 l'ha già fatto la schermata). Fuori dalla Battle, senza SELECT
# tenuto o con un cambio di schermata del menu in corso: croce originale. Dopo il gesto (_gameMode con 0x8000) la
# croce non fa più niente, così il menu non avanza mentre la partita si carica.
.global casuale_croce
casuale_croce:
    lui   $t0, 0x8006
    lhu   $t1, -0x59ba($t0)            # _minigameMode (0x8005a646), byte basso 1 = Battle
    lhu   $t2, -0x59bc($t0)            # _gameMode (0x8005a644)
    lui   $t3, 0x8005
    lw    $t3, 0x137c($t3)             # tasti tenuti, giocatore 1
    lui   $t4, 0x800a
    lw    $t4, -0x758($t4)             # _frontEndScreens.next (0x8009f8a8)
    andi  $t1, $t1, 0xff
    xori  $t1, $t1, 1
    bne   $t1, $zero, casuale_menu
    andi  $t2, $t2, 0x8000
    bne   $t2, $zero, casuale_esci
    andi  $t3, $t3, 1                  # SELECT
    beq   $t3, $zero, casuale_menu
    addu  $t9, $ra, $zero              # ra del chiamante, per tutta la mod
    bne   $t4, $zero, casuale_menu
    nop
    j     casuale_genera
    nop
casuale_menu:
    j     0x800b5410                   # croce originale: schermata seguente, con ra del chiamante
    nop
casuale_esci:
    jr    $ra
    nop

# Personaggi: quattro diversi fra gli 8 (tutti selezionabili in Battle), uno per giocatore, umani compresi.
# Arriva da genera.s con t6 = famiglia, t7 = arena; t5 = parola dei personaggi (giocatore 1 nel byte basso).
.global casuale_personaggi
casuale_personaggi:
    addiu $t8, $zero, 0xff             # personaggi liberi: bit 0-7 = personaggi 1-8
    addu  $t5, $zero, $zero
casuale_personaggio:
    jal   casuale_bit
    addu  $t0, $t8, $zero
    addiu $v1, $zero, 1
    sllv  $v1, $v1, $v0
    xor   $t8, $t8, $v1                # non più libero
    sll   $t5, $t5, 8
    addiu $v0, $v0, 1                  # personaggio 1-8
    or    $t5, $t5, $v0
    srl   $v0, $t5, 24
    beq   $v0, $zero, casuale_personaggio
    nop
    j     casuale_scrivi
    lui   $t0, 0x8006                  # prima istruzione di casuale_scrivi
