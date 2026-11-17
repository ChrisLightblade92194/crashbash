# PAL-P2b2 voce 57, provenienza 418a3f8561774df5de192848cefb12ee736d50b0.
# Sede EXE 0x8003646c: 10 istruzioni = 40 byte, fine esclusa 0x80036494.
# Parametri decodificati da PAL 0x800b54f4..0x800b5510, funzione 0x8002233c.
# Lo stack e' quello del menu: argomenti 5 e 6 a sp+16/+20; ra originale a sp+32.
# Nessun nuovo frame, ra impostato all'epilogo che ripristina ra/s1/s0 e sp.
.set noreorder
.set noat

.global gesti_suono
gesti_suono:
    addiu $a0, $zero, 0x192
    addu  $a1, $zero, $zero
    addu  $a2, $zero, $zero
    addiu $a3, $zero, 0x1000
    addiu $v0, $zero, 0x1e00
    sw    $v0, 16($sp)
    sw    $zero, 20($sp)
    lui   $ra, 0x800b
    j     0x8002233c
    ori   $ra, $ra, 0x5554
