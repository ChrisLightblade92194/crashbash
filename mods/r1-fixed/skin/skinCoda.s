# M3-V3 (Task A5): coda dell'anteprima della variante sul podio (skin_anteprima, skin/skinAnteprima.s).
# Sede: EXE, coda libera di DrawSyncCallback (0x8002ec84-0x8002ecd0, 76 byte, dopo il marcatore; provata in L5).
# skin_anteprima_coda: continuazione di skin_anteprima nel suo stack frame, senza frame proprio. Si entra
# con «j» dopo una lettura riuscita e DrawSync(0): $s0 = personaggio 1-8 e $s1 = variante 0-5 (salvati da
# skin_anteprima nel suo frame, che resta attivo), $a0 = personaggio (delay slot), .tex crate nel buffer.
# Esegue skin_scrivi($s0), skin_celle($s0, $s1) (skin/skinCelle.s) e variante_mostrata[$s0 − 1] = $s1,
# poi «j skin_anteprima_svuota»: lì skin_anteprima azzera il buffer e ripristina $ra, $s0 e $s1.
.set noreorder
.set noat

.global skin_anteprima_coda
skin_anteprima_coda:
    jal   skin_scrivi
    move  $a0, $s0
    move  $a0, $s0
    jal   skin_celle
    move  $a1, $s1
    lui   $t0, %hi(variante_mostrata - 1)
    addu  $t0, $t0, $s0
    j     skin_anteprima_svuota
    sb    $s1, %lo(variante_mostrata - 1)($t0)
