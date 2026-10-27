# M3-V2 (Task 4): L1/R1 alla Character Select (V-D3, §4.2 della specifica delle varianti).
# Sede: EXE, blocco _SsSndSetDecres (0x8003891c-0x800389c0, 164 byte, riserva provata in V1).
# skin_tasti, con s0 = giocatore umano e s1 = slot di skin_cursore: con L1 o R1 appena premuti (0x80051380 + 88 × giocatore) su un
# personaggio non confermato con almeno un posto (skin_varianti), passa alla variante precedente (L1) o
# successiva (R1) che esiste, con giro dall'originale (0): R1 vale se premuti insieme. Poi salta a
# skin_anteprima(personaggio, variante), che torna al chiamante.
.set noreorder
.set noat

.global skin_tasti
skin_tasti:
    addiu $t0, $zero, 88
    mult  $s0, $t0
    lw    $t2, 0($s1)                 # bit 0: personaggio confermato
    lbu   $a0, 4($s1)                 # personaggio 1-8
    mflo  $t0
    lui   $t1, 0x8005
    addu  $t1, $t1, $t0
    lw    $t1, 0x1380($t1)            # tasti appena premuti del giocatore
    andi  $t2, $t2, 1
    bne   $t2, $zero, skin_tasti_fine
    andi  $t3, $t1, 0x0c00            # L1 0x400, R1 0x800
    beq   $t3, $zero, skin_tasti_fine
    lui   $t4, %hi(skin_varianti - 1)
    addu  $t4, $t4, $a0
    lbu   $t4, %lo(skin_varianti - 1)($t4)        # posti del personaggio (bit v − 1)
    lui   $t5, %hi(variante_mostrata - 1)
    addu  $t5, $t5, $a0
    beq   $t4, $zero, skin_tasti_fine
    lbu   $a1, %lo(variante_mostrata - 1)($t5)    # variante mostrata
    andi  $t3, $t1, 0x0800
    bne   $t3, $zero, skin_tasti_giro
    addiu $t6, $zero, 1               # R1: +1
    addiu $t6, $zero, 5               # L1: −1 modulo 6
skin_tasti_giro:
    addu  $a1, $a1, $t6
    sltiu $t7, $a1, 6
    bne   $t7, $zero, skin_tasti_posto
    nop
    addiu $a1, $a1, -6
skin_tasti_posto:
    beq   $a1, $zero, skin_tasti_leggi    # l'originale c'è sempre
    addiu $t7, $a1, -1
    srlv  $t7, $t4, $t7
    andi  $t7, $t7, 1
    beq   $t7, $zero, skin_tasti_giro     # posto vuoto: avanti
    nop
skin_tasti_leggi:
    j     skin_anteprima
    nop
skin_tasti_fine:
    jr    $ra
    nop
