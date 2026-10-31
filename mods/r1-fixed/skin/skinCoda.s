# M3-V3 (Task A5): coda dell'anteprima della variante sul podio (skin_anteprima, skin/skinAnteprima.s).
# Sede: EXE, coda libera di DrawSyncCallback (0x8002ec84-0x8002ecd0, 76 byte, dopo il marcatore; provata in L5).
# skin_anteprima_coda: continuazione di skin_anteprima nel suo stack frame, senza frame proprio. Si entra
# con «j» dopo una lettura riuscita e DrawSync(0): $s0 = personaggio 1-8 e $s1 = variante 0-5 (salvati da
# skin_anteprima nel suo frame, che resta attivo), .tex crate nel buffer.
# M3-V3 (Task B4): prima di ogni scrittura legge il record del podio (SKIN_PODIO_VERTICI + 8 × $s1 + $s0 − 1)
# nel settore libero 0x800a8000 con al massimo 3 tentativi (skin_tentativi = 4), voce finta nel frame di
# skin_anteprima. Se la lettura fallisce salta a skin_vertici_svuota senza scrivere texture, celle, tabella
# e variante_mostrata; altrimenti a skin_vertici_coda (skin/skinVerticiCoda.s), che esegue skin_scrivi,
# skin_celle, skin_vertici_podio e variante_mostrata[$s0 − 1] = $s1. Entrambe tornano a skin_anteprima_svuota.
.set noreorder
.set noat

.global skin_anteprima_coda
skin_anteprima_coda:
    lui   $t0, %hi(SKIN_PODIO_VERTICI - 1)
    addiu $t0, $t0, %lo(SKIN_PODIO_VERTICI - 1)
    sll   $t1, $s1, 3
    addu  $t0, $t0, $t1
    addu  $t0, $t0, $s0               # settore del record
    addiu $t1, $zero, 2048
    sw    $t0, 16($sp)                # voce finta {settore, dimensione}
    sw    $t1, 20($sp)
    addiu $t0, $zero, 4
    lui   $t1, %hi(skin_tentativi)
    sb    $t0, %lo(skin_tentativi)($t1)
    addiu $a0, $sp, 16
    lui   $a1, 0x800a
    jal   skin_leggi
    ori   $a1, $a1, 0x8000            # settore libero del record (Task 0.3)
    bltz  $v0, skin_vertici_svuota    # lettura fallita: nessuna scrittura
    nop
    j     skin_vertici_coda
    nop
