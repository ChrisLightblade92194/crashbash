# PAL-P2b2 voce 55, provenienza 418a3f8561774df5de192848cefb12ee736d50b0.
# Provenienza r1-fixed 418a3f8; prove singole in docs/evidence/pal-r1/p2b2/boss.json.
# Sede EXE 0x80049e20, 21 istruzioni = 84 byte, fine esclusa 0x80049e74.
# hook58 arriva con s0=0x800527f0, v1=umani evidenziati (1..4), ra=0x800b54ec.
# Nessuno stack aggiunto. Fuori gesto si riproduce il load originale in gesti_menu.
.set noreorder
.set noat

.global gesti_tasti
gesti_tasti:
    lui   $t0, 0x8006
    lhu   $t1, -0x3bde($t0)            # minigioco 0x8005c422
    lhu   $t2, -0x3be0($t0)            # modo 0x8005c420
    andi  $t1, $t1, 0xff
    xori  $t1, $t1, 1                  # Battle: byte basso 1, provato in P1c
    bne   $t1, $zero, gesti_menu
    andi  $t2, $t2, 0x8000
    bne   $t2, $zero, gesti_fine       # avvio gia' richiesto
    lw    $t3, 0x44($s0)               # tenuti: 0x80052834
    lui   $t4, 0x800a
    lw    $t4, -0x267c($t4)            # front.next 0x8009d984
    andi  $t3, $t3, 1                  # SELECT
    beq   $t3, $zero, gesti_menu
    lw    $t5, 0x48($s0)               # premuti: 0x80052838
    bne   $t4, $zero, gesti_menu
    andi  $t6, $t5, 0x0008             # START
    lui   $t9, %hi(gesti_suono)
    bne   $t6, $zero, casuale_genera   # casuale_scrivi torna tramite t9
    addiu $t9, $t9, %lo(gesti_suono)
    j     gesti_boss
    sltiu $t6, $v1, 3                  # boss ammessi con 1 o 2 umani
