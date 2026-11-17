# PAL-P2c1: port con fixture PAL, voce R1 36, EXE, sede assegnata 0x80033adc. Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0.
# Provenienza: r1-fixed/skin/skinCoda.s, riferimento 418a3f8.
# Prove: docs/evidence/pal-r1/p2c1/innesti.json, sedi.json e funzioni.json.
# Attivato in P2c1; compilazione e percorso modificato da verificare dalla regia.
# Buffer provati dalla ricognizione della regia: ricognizione.json; inglese,1P,primo ingresso.
# 0x800a4800 solo Character Select, azzerare dopo lettura; 0x800a8000 libero fino al frame9000.
# Rientro,2P,altre lingue e scritture fra campioni restano fuori dalla prova.
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
    ori   $a1, $a1, 0x8000            # buffer record provato dalla regia: ricognizione.json, con i limiti dichiarati
    bltz  $v0, skin_vertici_svuota    # lettura fallita: nessuna scrittura
    nop
    j     skin_vertici_coda
    nop
