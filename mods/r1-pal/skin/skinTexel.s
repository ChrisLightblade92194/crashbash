# PAL-P2c1: port con fixture PAL, voce R1 40, EXE, sede assegnata 0x80044764. Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0.
# Provenienza: r1-fixed/skin/skinTexel.s, riferimento 418a3f8.
# Prove: docs/evidence/pal-r1/p2c1/innesti.json, sedi.json e funzioni.json.
# Attivato in P2c1; compilazione e percorso modificato da verificare dalla regia.
# Buffer provati dalla ricognizione della regia: ricognizione.json; inglese,1P,primo ingresso.
# 0x800a4800 solo Character Select, azzerare dopo lettura; 0x800a8000 libero fino al frame9000.
# Rientro,2P,altre lingue e scritture fra campioni restano fuori dalla prova.
.set noreorder
.set noat

.include "skin/buffer-pal.inc"

.global skin_texel
skin_texel:
    sll   $t0, $s2, 1
    lui   $t1, %hi(skin_swatch - 2)
    addu  $t1, $t1, $t0
    lhu   $t2, %lo(skin_swatch - 2)($t1)        # offset della palette swatch
    lui   $t1, %hi(skin_swatch_pixel - 2)
    addu  $t1, $t1, $t0
    lhu   $t4, %lo(skin_swatch_pixel - 2)($t1)  # offset dei pixel dell'immagine swatch
    srl   $t5, $t3, 1
    addu  $t4, $t4, $t5
    lui   $t6, %hi(BUFFER)
    addu  $t4, $t4, $t6
    lbu   $t4, %lo(BUFFER)($t4)                 # due texel
    andi  $t5, $t3, 1
    sll   $t5, $t5, 2
    srlv  $t4, $t4, $t5
    andi  $t4, $t4, 15                          # indice nella palette swatch
    sll   $t4, $t4, 1
    addu  $t4, $t4, $t2
    addu  $t4, $t4, $t6
    jr    $ra
    lhu   $a1, %lo(BUFFER)($t4)
