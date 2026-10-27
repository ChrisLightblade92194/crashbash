# M3-V2 (Task 4): podio acceso prima della conferma (V-D6, «Spike A» negli «Esiti di V1» del piano).
# Sede: EXE, blocco SetGraphQueue (0x8002ebbc-0x8002ec60, 164 byte, riserva provata in V1).
# Chiamate da skin_cursore con i registri della funzione del giocatore (0x800b5ca8): s4 = giocatore,
# s5 = oggetto del podio, s6 = slot. Non scrivono la scelta del personaggio del gioco (0x8005a660/664).
# - skin_podio_prepara(slot): come la conferma (0x800b6268-0x800b63c8) senza flag, suono e scelta: tipo di
#   modello dello slot nell'oggetto (+0x6c), stato di animazione iniziale (0x8005a9a0, 44 byte) in s4 + 52,
#   tabella del personaggio (slot + 0x1c) in s4 + 64, velocità e scala a 0: il modello cresce come dopo la croce.
# - skin_podio_posa: esegue il ramo dei confermati (0x800b5dc0-0x800b5f34: scala verso slot + 0x10, posa
#   con 0x80095e38 e 0x800251a8) con una cornice uguale a quella della funzione, che il ramo chiude a
#   0x800b63cc tornando al chiamante con gli s ripristinati; il ramo conta i frame in s4 + 36, che qui si
#   scala prima di un'unità.
.set noreorder
.set noat

.global skin_podio_prepara
skin_podio_prepara:
    lw    $t7, 0x14($a0)              # tipo di modello (199)
    lw    $t6, 8($s4)                 # oggetto del podio
    sll   $t8, $t7, 3
    subu  $t8, $t8, $t7
    sll   $t8, $t8, 3                 # 56 × tipo
    lui   $t9, 0x8005
    addiu $t9, $t9, 0x2a54            # _modelTypes
    addu  $t8, $t8, $t9
    sw    $t8, 0x6c($t6)
    lui   $t1, 0x8006
    addiu $t1, $t1, -22112            # stato di animazione iniziale (0x8005a9a0)
    addiu $t2, $s4, 52
    addiu $t3, $t1, 44
skin_podio_copia:
    lw    $t4, 0($t1)
    addiu $t1, $t1, 4
    sw    $t4, 0($t2)
    bne   $t1, $t3, skin_podio_copia
    addiu $t2, $t2, 4
    lw    $t4, 0x1c($a0)              # tabella del personaggio
    sw    $zero, 20($s4)
    sw    $zero, 24($s4)
    sw    $zero, 28($s4)
    sw    $zero, 32($s4)
    jr    $ra
    sw    $t4, 64($s4)

.global skin_podio_posa
skin_podio_posa:
    lw    $t0, 36($s4)
    addiu $sp, $sp, -56               # cornice di 0x800b5ca8: s0-s6 a 24-48, ra a 52
    sw    $s0, 24($sp)
    sw    $s1, 28($sp)
    sw    $s2, 32($sp)
    sw    $s3, 36($sp)
    sw    $s4, 40($sp)
    sw    $s5, 44($sp)
    sw    $s6, 48($sp)
    addiu $t0, $t0, -1                # il ramo aggiunge 1
    sw    $t0, 36($s4)
    j     0x800b5dc0
    sw    $ra, 52($sp)
