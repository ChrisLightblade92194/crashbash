# M3-L15 (R12) skin dei personaggi: scelta alla Character Select e caricamento dal disco.
# Sede: EXE, blocco CdReadBreak (0x8003456c-0x800346f8, mai chiamata).
# Dati sul disco: i primi settori di BASHY. (LBA 60120, riempitivo a zero mai letto dal gioco), letti con le routine del DAT
# al settore SKIN_SETTORE contato dall'inizio del DAT (LBA 236): i .tex delle skin in ordine di voce del
# .tex originale, ognuno con i settori del suo originale. tools/build.py li scrive e verifica LBA e contenuto.
# - skin_conferma: chiamata al posto dello store del personaggio nella conferma della Character Select
#   (modulo 722, 0x800b62f0); scrive anche skin_scelta[giocatore] = 1 se un giocatore umano ha confermato
#   con SKIN_TASTO, altrimenti 0 (CPU comprese).
# - skin_accoda: chiamata al posto di FUN_800129d0 in Loader_QueueCharacterModels (0x80093950 e
#   0x800939ac); con la skin del giocatore s4 scelta, il nodo della coda usa skin_carica come callback.
# - skin_carica(buffer, voce): il buffer contiene .tex e .mdl originali; legge sopra il .tex i settori
#   della skin (stessa dimensione), poi passa al callback originale FUN_80012840.
# - skin_leggi(voce finta {settore, dimensione}, destinazione): lettura sincrona dal disco con gli stessi
#   argomenti di _LoadFile; sta a inizio blocco (0x8003456c) perché la regressione la osserva come
#   secondo caricatore (campo «caricatori» di modifiche.json).
.set noreorder
.set noat

.equ SKIN_TASTO, 0x8000               # quadrato (provvisorio: decisione del proprietario in M3.md)
.equ SKIN_SETTORE, 59884              # LBA di BASHY. (60120) - LBA del DAT (236); = «settore» di pacchetto.json

.global skin_leggi
skin_leggi:
    addiu $sp, $sp, -24
    sw    $ra, 20($sp)
    sw    $s0, 16($sp)
    sw    $s1, 12($sp)
    move  $s0, $a0
    move  $s1, $a1
skin_leggi_avvia:
    lw    $a3, 4($s0)                 # dimensione in byte → settori
    move  $a0, $s0
    addiu $a3, $a3, 2047
    srl   $a3, $a3, 11
    move  $a1, $zero
    jal   0x80027790                  # avvia la lettura (voce, scostamento, destinazione, settori)
    move  $a2, $s1
    bltz  $v0, skin_leggi_avvia
    nop
skin_leggi_attendi:
    jal   0x80027944                  # stato della lettura: >0 in corso, 0 finita, <0 errore
    nop
    bgtz  $v0, skin_leggi_attendi
    nop
    bltz  $v0, skin_leggi_avvia
    lw    $ra, 20($sp)
    lw    $s1, 12($sp)
    lw    $s0, 16($sp)
    jr    $ra
    addiu $sp, $sp, 24

.global skin_scelta
skin_scelta:
    .space 4                          # un byte per giocatore

.global skin_conferma
skin_conferma:
    lw    $t0, 4($s4)                 # indice del giocatore
    lui   $t1, 0x8006
    addiu $t1, $t1, -23020            # 0x8005a614
    addu  $t1, $t1, $t0
    sb    $v0, 80($t1)                # istruzione sostituita: personaggio in 0x8005a664[giocatore]
    lui   $t2, 0x8006
    lbu   $t2, -22982($t2)            # giocatori umani (0x8005a63a)
    addiu $t3, $zero, 88
    mult  $t0, $t3
    mflo  $t3                         # 88 * giocatore
    lui   $t4, 0x8005
    addu  $t4, $t4, $t3
    lw    $t4, 0x1380($t4)            # tasti appena premuti del giocatore
    slt   $t2, $t0, $t2               # giocatore umano
    andi  $t4, $t4, SKIN_TASTO
    sltu  $t4, $zero, $t4
    and   $t4, $t4, $t2
    lui   $t5, %hi(skin_scelta)
    addu  $t5, $t5, $t0
    jr    $ra
    sb    $t4, %lo(skin_scelta)($t5)

.global skin_accoda
skin_accoda:
    addiu $sp, $sp, -8
    sw    $ra, 4($sp)
    jal   0x800129d0                  # accoda il modello (a0 voce, a1 arena); v0 = nodo, 0 se la coda è piena
    nop
    lui   $t0, %hi(skin_scelta)
    addu  $t0, $t0, $s4               # s4 = giocatore nel ciclo di Loader_QueueCharacterModels
    lbu   $t0, %lo(skin_scelta)($t0)
    lw    $ra, 4($sp)
    beq   $t0, $zero, skin_accoda_fine
    addiu $sp, $sp, 8
    beq   $v0, $zero, skin_accoda_fine
    lui   $t1, %hi(skin_carica)
    addiu $t1, $t1, %lo(skin_carica)
    sw    $t1, 16($v0)                # callback del nodo
skin_accoda_fine:
    jr    $ra
    nop

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
    li    $t3, SKIN_SETTORE
skin_somma:                           # settore = fine del DAT + settori dei .tex con voce minore
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
