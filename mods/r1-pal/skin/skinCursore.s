# PAL-P2c1: port con fixture PAL, voce R1 17, EXE, sede assegnata 0x80042020. Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0.
# Provenienza: r1-fixed/skin/skinCursore.s, riferimento 418a3f8.
# Prove: docs/evidence/pal-r1/p2c1/innesti.json, sedi.json e funzioni.json.
# Attivato in P2c1; compilazione e percorso modificato da verificare dalla regia.
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
    lbu   $t1, -15338($t1)            # giocatori umani (0x8005c416)
    sll   $t5, $v0, 2
    slt   $t1, $s0, $t1
    beq   $t1, $zero, skin_cursore_fine   # CPU: codice originale
    addu  $t5, $t5, $v0
    sll   $t5, $t5, 3                 # 40 × cursore
    addu  $s1, $t5, $s6               # slot del cursore
    sw    $v0, 48($s4)                # cursore nuovo (il gioco lo scrive al ritorno, 0x800b7bf0)
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

# Banco C6: ingresso isolato per mutazione semantica di un byte del JAL.
# Non raggiunto dal percorso corretto; esegue il comportamento originale senza effetto skin.
.global skin_cursore_sonda_originale
skin_cursore_sonda_originale:
    jr    $ra
    lw    $a0, 4($s4)
