# PAL-P2c1: port con fixture PAL, voce R1 16, EXE, sede assegnata 0x800365f8. Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0.
# Provenienza: r1-fixed/skin/skinAnteprima.s, riferimento 418a3f8.
# Prove: docs/evidence/pal-r1/p2c1/innesti.json, sedi.json e funzioni.json.
# Attivato in P2c1; compilazione e percorso modificato da verificare dalla regia.
# Buffer provati dalla ricognizione della regia: ricognizione.json; inglese,1P,primo ingresso.
# 0x800a4800 solo Character Select, azzerare dopo lettura; 0x800a8000 libero fino al frame9000.
# Rientro,2P,altre lingue e scritture fra campioni restano fuori dalla prova.
.set noreorder
.set noat

.include "skin/buffer-pal.inc"

.global skin_anteprima
skin_anteprima:
    addiu $sp, $sp, -40
    sw    $ra, 36($sp)
    sw    $s0, 32($sp)
    sw    $s1, 28($sp)
    move  $s0, $a0
    move  $s1, $a1
    sll   $t1, $a0, 1
    lui   $t0, %hi(skin_crate - 2)
    addu  $t0, $t0, $t1
    lhu   $t2, %lo(skin_crate - 2)($t0)           # voce del .tex crate
    lui   $a0, 0x8005
    sll   $t2, $t2, 3
    addiu $a0, $a0, -5532             # tabella dell'indice del DAT (0x8004ea64)
    beq   $a1, $zero, skin_anteprima_leggi
    addu  $a0, $a0, $t2               # variante 0: la voce originale
    lui   $t0, %hi(skin_crate_settore - 2)
    addu  $t0, $t0, $t1
    lhu   $t3, %lo(skin_crate_settore - 2)($t0)   # settore del .tex crate nel blocco
    addiu $t4, $a1, -1
    lui   $t5, %hi(SKIN_BLOCCO)
    addiu $t5, $t5, %lo(SKIN_BLOCCO)
    mult  $t4, $t5
    lw    $t6, 4($a0)                 # dimensione: la stessa dell'originale
    lui   $t7, %hi(SKIN_SETTORE)
    addiu $t7, $t7, %lo(SKIN_SETTORE)
    addu  $t3, $t3, $t7
    mflo  $t4
    addu  $t3, $t3, $t4
    sw    $t3, 16($sp)                # voce finta {settore, dimensione}
    sw    $t6, 20($sp)
    addiu $a0, $sp, 16
skin_anteprima_leggi:
    addiu $t0, $zero, 4
    lui   $t1, %hi(skin_tentativi)
    sb    $t0, %lo(skin_tentativi)($t1)
    lui   $a1, %hi(BUFFER)
    jal   skin_leggi
    addiu $a1, $a1, %lo(BUFFER)
    lui   $t1, %hi(skin_tentativi)
    bltz  $v0, skin_anteprima_svuota  # lettura fallita
    sb    $zero, %lo(skin_tentativi)($t1)
    jal   0x80033bc0                  # DrawSync(0): la GPU non disegna con le texture da cambiare
    move  $a0, $zero
    j     skin_anteprima_coda         # M3-V3: skin_scrivi, skin_celle e variante_mostrata (skin/skinCoda.s)
    move  $a0, $s0
    # M3-V3: le tre istruzioni seguenti non si eseguono più (le fa skin_anteprima_coda); restano per
    # non spostare il resto del blocco.
    lui   $t0, %hi(variante_mostrata - 1)
    addu  $t0, $t0, $s0
    sb    $s1, %lo(variante_mostrata - 1)($t0)
.global skin_anteprima_svuota             # ritorno di skin_anteprima_coda
skin_anteprima_svuota:
    lui   $t0, %hi(BUFFER)
    addiu $t0, $t0, %lo(BUFFER)
    addiu $t1, $t0, 0x1800
skin_anteprima_azzera:
    sw    $zero, 0($t0)
    addiu $t0, $t0, 4
    bne   $t0, $t1, skin_anteprima_azzera
    nop
    lw    $ra, 36($sp)
    lw    $s1, 28($sp)
    lw    $s0, 32($sp)
    jr    $ra
    addiu $sp, $sp, 40
