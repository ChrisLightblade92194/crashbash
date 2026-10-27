# M3-V2 (Task 4): Character Select, giocatore non confermato (§4.2 della specifica delle varianti).
# Sede: EXE, blocco _SsVmSeKeyOn (0x8004ab78-0x8004ac28, 176 byte, riserva provata in V1).
# skin_cursore: chiamata da skin/skinHookCursore.s (modulo 722, 0x800b6114) per ogni giocatore non
# confermato, a ogni frame, con v0 = cursore nuovo 0-7 e i registri della funzione del giocatore
# (0x800b5ca8: s4 = giocatore, s5 = oggetto del podio, s6 = slot 0x800b9b44). Per un umano:
# - all'arrivo su un personaggio diverso da podio_ultimo: skin_arrivo (V-D5) e skin_podio_prepara (V-D6);
# - a ogni frame: skin_podio_posa (scala e posa come dopo la conferma);
# - L1/R1: skin_tasti.
# Restituisce a0 = indice del giocatore (istruzione sostituita) e v0 intatto e salva gli s che usa. Dopo
# l'aggancio (0x800b6118-0x800b63ec) la funzione scrive v1, a1-a3, t0-t9 e HI/LO prima di leggerli («Esiti
# di V1» e disassemblato del modulo 722): non serve salvarli.
.set noreorder
.set noat

.global skin_cursore
skin_cursore:
    addiu $sp, $sp, -32
    sw    $ra, 28($sp)
    sw    $s0, 24($sp)
    sw    $s1, 20($sp)
    sw    $v0, 16($sp)
    lw    $s0, 4($s4)                 # giocatore
    lui   $t1, 0x8006
    lbu   $t1, -22982($t1)            # giocatori umani (0x8005a63a)
    sll   $t5, $v0, 2
    slt   $t1, $s0, $t1
    beq   $t1, $zero, skin_cursore_fine   # CPU: codice originale
    addu  $t5, $t5, $v0
    sll   $t5, $t5, 3                 # 40 × cursore
    addu  $s1, $t5, $s6               # slot del cursore
    sw    $v0, 48($s4)                # cursore nuovo (il gioco lo scrive al ritorno, 0x800b611c)
    lbu   $a0, 4($s1)                 # personaggio 1-8
    lui   $t9, %hi(podio_ultimo)
    addu  $t9, $t9, $s0
    lbu   $t8, %lo(podio_ultimo)($t9)
    move  $a1, $v0
    beq   $t8, $a0, skin_cursore_posa
    sb    $a0, %lo(podio_ultimo)($t9) # personaggio mostrato (uguale se non cambia)
    jal   skin_arrivo                 # a0 personaggio, a1 cursore, a2 giocatore
    move  $a2, $s0
    jal   skin_podio_prepara          # a0 slot
    move  $a0, $s1
skin_cursore_posa:
    jal   skin_podio_posa
    nop
    jal   skin_tasti                  # s0 giocatore, s1 slot
    nop
skin_cursore_fine:
    lw    $ra, 28($sp)
    lw    $s0, 24($sp)
    lw    $s1, 20($sp)
    lw    $v0, 16($sp)
    lw    $a0, 4($s4)                 # istruzione sostituita
    jr    $ra
    addiu $sp, $sp, 32
