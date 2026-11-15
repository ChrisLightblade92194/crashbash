# M3-L28: gesti su SELECT NUMBER OF PLAYERS (percorso Battle), con SELECT tenuto:
#   - START: partita casuale (M3-L24, casuale_genera), con qualsiasi numero di umani evidenziati;
#   - croce, cerchio, quadrato, triangolo: Papu Pummel, Big Bad Fox, Bearminator, Oxide (gesti_boss, avvio.s), solo
#     con 1 o 2 umani evidenziati; con 3 o 4 il tasto non fa niente.
# Esito della sonda e progetto: docs/evidence/m3-l27/LEGGIMI.md e docs/evidence/m3-l28/LEGGIMI.md.
# Sede: EXE, coda di MemCardOpen (0x80039b48-0x80039b9c, 84 byte; prima il gesto della croce di L24, casuale_croce),
# blocco di libmcrd mai chiamato, provato in L24 (prova-sedi-l24). Il seguito in avvio.s (MatrixNormal).
# Arriva da hookGesti.s (jal a 0x800b422c) con s0 = 0x80051338 (pad del giocatore 1 come lo leggono i menu) e
# v1 = umani evidenziati (1-4). Non usa lo stack; ra resta quella del jal fino all'uscita (gesti_menu) o alla fine.
.set noreorder
.set noat

.global gesti_tasti
gesti_tasti:
    lui   $t0, 0x8006
    lhu   $t1, -0x59ba($t0)            # _minigameMode (0x8005a646), byte basso 1 = Battle
    lhu   $t2, -0x59bc($t0)            # _gameMode (0x8005a644)
    andi  $t1, $t1, 0xff
    xori  $t1, $t1, 1
    bne   $t1, $zero, gesti_menu       # fuori dalla Battle: tasti originali
    andi  $t2, $t2, 0x8000
    bne   $t2, $zero, gesti_fine       # partita già chiesta: né croce né triangolo mentre si carica
    lw    $t3, 0x44($s0)               # tasti tenuti (0x8005137c)
    lui   $t4, 0x800a
    lw    $t4, -0x758($t4)             # _frontEndScreens.next (0x8009f8a8): cambio di schermata in corso
    andi  $t3, $t3, 1                  # SELECT
    beq   $t3, $zero, gesti_menu
    lw    $t5, 0x48($s0)               # tasti premuti (0x80051380)
    bne   $t4, $zero, gesti_menu
    andi  $t6, $t5, 0x0008             # START
    lui   $t9, %hi(gesti_suono)
    bne   $t6, $zero, casuale_genera   # partita casuale; casuale_scrivi torna in t9
    addiu $t9, $t9, %lo(gesti_suono)
    j     gesti_boss
    sltiu $t6, $v1, 3                  # 1 se gli umani evidenziati sono 1 o 2
