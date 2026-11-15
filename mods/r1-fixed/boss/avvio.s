# M3-L28: avvio di un boss dal gesto di gesti.s, ritorno ai tasti originali e uscita. Sede: EXE, MatrixNormal dopo
# l'opzione R10 (0x8003d9e0-0x8003da74, 148 byte; i primi 84 da 0x8003d98c restano all'opzione, commentata nella
# buildList), blocco provato in L5.
# Scrive quello che scriveva la sonda di L27 (docs/evidence/m3-l27/LEGGIMI.md): personaggi 1-4 (Crash al giocatore 1,
# l'unico in campo), lato 1, livello del boss e _gameMode = 0x8008. Skin originali (la Character Select non c'è stata).
.set noreorder
.set noat

# Arriva da gesti_tasti con t0 = 0x80060000, t5 = tasti premuti, t6 = 1 con 1 o 2 umani evidenziati.
.global gesti_boss
gesti_boss:
    beq   $t6, $zero, gesti_fine       # 3 o 4 umani: niente
    srl   $t5, $t5, 12                 # bit 0 triangolo, 1 cerchio, 2 croce, 3 quadrato
    andi  $t5, $t5, 0xf
    beq   $t5, $zero, gesti_fine       # nessuno dei quattro tasti
    lui   $t6, %hi(gesti_livelli)
    addiu $t6, $t6, %lo(gesti_livelli)
gesti_bit:                             # primo bit acceso, da triangolo a quadrato
    andi  $t7, $t5, 1
    srl   $t5, $t5, 1
    beq   $t7, $zero, gesti_bit
    addiu $t6, $t6, 1
    lbu   $t7, -1($t6)                 # livello del boss
    lui   $t1, 0x0403
    ori   $t1, $t1, 0x0201             # personaggi 1, 2, 3, 4
    sw    $t1, -0x59a0($t0)            # personaggi del menu (0x8005a660)
    sw    $t1, -0x599c($t0)            # e copie (0x8005a664)
    addiu $t2, $zero, 1
    sh    $t2, -0x59a8($t0)            # lato (0x8005a658)
    lui   $t2, %hi(skin_scelta)
    sw    $zero, %lo(skin_scelta)($t2) # skin originali (M3-L15)
    lui   $t2, 0x800a
    sw    $t7, -0x1a24($t2)            # livello scelto (0x8009e5dc)
    ori   $t2, $zero, 0x8008
    j     gesti_suono
    sh    $t2, -0x59bc($t0)            # _gameMode: la partita parte, come la croce su GAME OPTIONS

# Nessun gesto: il load sostituito da hookGesti.s, poi croce e triangolo originali (0x800b4234).
.global gesti_menu
gesti_menu:
    lw    $v0, 0x48($s0)
    jr    $ra
    nop

# Tasto ignorato o partita già chiesta: epilogo della schermata, senza croce né triangolo.
.global gesti_fine
gesti_fine:
    j     0x800b429c
    nop

gesti_livelli:                         # triangolo, cerchio, croce, quadrato
    .byte 31, 9, 4, 22                 # Oxide, Big Bad Fox, Papu Pummel, Bearminator
