# PAL-P2c1: port con fixture PAL, voce R1 44, EXE, sede assegnata 0x8003dd34. Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0.
# Provenienza: r1-fixed/skin/skinVerticiCoda.s, riferimento 418a3f8.
# Prove: docs/evidence/pal-r1/p2c1/innesti.json, sedi.json e funzioni.json.
# Attivato in P2c1; compilazione e percorso modificato da verificare dalla regia.
# Buffer provati dalla ricognizione della regia: ricognizione.json; inglese,1P,primo ingresso.
# 0x800a4800 solo Character Select, azzerare dopo lettura; 0x800a8000 libero fino al frame9000.
# Rientro,2P,altre lingue e scritture fra campioni restano fuori dalla prova.
.set noreorder
.set noat

.global skin_vertici_coda
skin_vertici_coda:
    jal   skin_scrivi
    move  $a0, $s0
    move  $a0, $s0
    jal   skin_celle
    move  $a1, $s1
    jal   skin_vertici_podio
    move  $a0, $s0
    lui   $t0, %hi(variante_mostrata - 1)
    addu  $t0, $t0, $s0
    sb    $s1, %lo(variante_mostrata - 1)($t0)
.global skin_vertici_svuota
skin_vertici_svuota:
    lui   $t1, %hi(skin_tentativi)
    sb    $zero, %lo(skin_tentativi)($t1)
    lui   $t0, 0x800a
    ori   $t0, $t0, 0x8000
    addiu $t1, $t0, 2048
skin_vertici_azzera:
    addiu $t0, $t0, 4
    bne   $t0, $t1, skin_vertici_azzera
    sw    $zero, -4($t0)
    j     skin_anteprima_svuota
    nop

.global skin_vertici_mesh
skin_vertici_mesh:
    .include "skin/mesh-pal.inc"    # Otto offset u16 misurati sul MDL PAL133: dati-pal.json
    .if (. - skin_vertici_mesh) != 16
    .error "mesh-pal.inc deve emettere esattamente 16 byte"
    .endif
