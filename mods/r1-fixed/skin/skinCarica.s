# M3-V2: callback del nodo della coda dei modelli con la variante del giocatore (§4.1 della specifica delle
# varianti). Sede: EXE, blocco _spu_Fr_ (0x8003fc58-0x8003fd00, 168 byte, riserva provata in V1).
# - skin_carica(buffer, voce), con t7 = scostamento del blocco del posto in settori, messo da uno dei
#   cinque ingressi skin_carica_<v> di skin/skin.s: il buffer contiene .tex e .mdl originali; legge sopra
#   il .tex i settori della skin dal blocco del posto (stessa dimensione dell'originale), poi passa al
#   callback originale FUN_80012840. Nel blocco i .tex sono in ordine di voce, ognuno con i settori del
#   suo originale.
.set noreorder
.set noat

.global skin_carica
skin_carica:
    addiu $sp, $sp, -40
    sw    $ra, 36($sp)
    sw    $s0, 32($sp)
    sw    $s1, 28($sp)
    move  $s0, $a0                    # buffer: .tex e poi .mdl
    move  $s1, $a1                    # voce di _charModelEntries
    lw    $t0, 12($a1)                # .tex: puntatore alla voce della tabella indice del DAT
    lui   $t1, 0x800a
    addiu $t1, $t1, -1516             # _charModelEntries (0x8009fa14)
    addiu $t2, $t1, 1536              # 96 voci da 16 byte
    lui   $t3, %hi(SKIN_SETTORE)
    addiu $t3, $t3, %lo(SKIN_SETTORE)
    addu  $t3, $t3, $t7               # inizio del blocco del posto
skin_somma:                           # settore = inizio del blocco + settori dei .tex con voce minore
    lw    $t4, 12($t1)
    addiu $t1, $t1, 16
    lw    $t6, 4($t4)                 # dimensione del .tex
    sltu  $t5, $t4, $t0
    addiu $t6, $t6, 2047
    beq   $t5, $zero, skin_dopo
    srl   $t6, $t6, 11
    addu  $t3, $t3, $t6
skin_dopo:
    bne   $t1, $t2, skin_somma
    nop
    lw    $t6, 4($t0)                 # dimensione del .tex originale = della skin
    sw    $t3, 16($sp)                # voce finta: settore della skin
    sw    $t6, 20($sp)                #             dimensione
    addiu $a0, $sp, 16
    jal   skin_leggi
    move  $a1, $s0
    move  $a0, $s0
    move  $a1, $s1
    lw    $ra, 36($sp)
    lw    $s1, 28($sp)
    lw    $s0, 32($sp)
    j     0x80012840                  # callback originale
    addiu $sp, $sp, 40
