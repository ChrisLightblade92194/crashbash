# M3-L15 (R12) skin dei personaggi: scelta alla Character Select e caricamento dal disco.
# Sede: EXE, blocco CdReadBreak (0x8003456c-0x800346f8, mai chiamata).
# Dati sul disco: i primi settori di BASHY. (LBA 60120, riempitivo a zero mai letto dal gioco), letti con le routine del DAT
# al settore SKIN_SETTORE contato dall'inizio del DAT (LBA 236): i .tex delle skin in ordine di voce del
# .tex originale, ognuno con i settori del suo originale. tools/build.py li scrive e verifica LBA e contenuto.
# - skin_conferma: chiamata al posto dello store del personaggio nella conferma della Character Select
#   (modulo 722, 0x800b62f0); scrive anche skin_scelta[giocatore] (0 = originale, 1-5 = posto, M3-V2):
#   per un umano la variante che il podio del personaggio mostra (variante_mostrata, V-D3), per la CPU 0.
# - skin_accoda: chiamata al posto di FUN_800129d0 in Loader_QueueCharacterModels (0x80093950 e
#   0x800939ac); con il posto v > 0 del giocatore s4, il nodo della coda usa come callback l'ingresso
#   skin_carica_<v> (M3-V2): cinque ingressi da 8 byte che mettono in t7 lo scostamento del blocco del
#   posto ((v − 1) × SKIN_BLOCCO settori) e saltano a skin_carica (skin/skinCarica.s).
# - varianti.inc (generato da tools/build.py da skin/pacchetto.json): SKIN_BLOCCO e skin_varianti, un byte
#   di posti per personaggio (bit v − 1 = posto v).
# - skin_leggi(voce finta {settore, dimensione}, destinazione): lettura sincrona dal disco con gli stessi
#   argomenti di _LoadFile; sta a inizio blocco (0x8003456c) perché la regressione la osserva come
#   secondo caricatore (campo «caricatori» di modifiche.json). Riprova senza limite, salvo che
#   skin_tentativi valga n > 0 (anteprima, M3-V2: n − 1 tentativi, v0 < 0 se falliscono tutti).
.set noreorder
.set noat

.equ SKIN_SETTORE, 59884              # LBA di BASHY. (60120) - LBA del DAT (236); = «settore» di pacchetto.json
.global SKIN_SETTORE                  # usato da skin_carica (skin/skinCarica.s)

.global skin_leggi
skin_leggi:
    addiu $sp, $sp, -24
    sw    $ra, 20($sp)
    sw    $s0, 16($sp)
    sw    $s1, 12($sp)
    move  $s0, $a0
    move  $s1, $a1
skin_leggi_avvia:
    lui   $t0, %hi(skin_tentativi)
    lbu   $t1, %lo(skin_tentativi)($t0)
    nop
    beq   $t1, $zero, skin_leggi_prova    # 0: tentativi illimitati (partita, L15)
    addiu $t1, $t1, -1
    beq   $t1, $zero, skin_leggi_fine     # tentativi finiti: v0 < 0 dell'ultimo errore
    sb    $t1, %lo(skin_tentativi)($t0)
skin_leggi_prova:
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
    nop
skin_leggi_fine:
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
    lui   $t3, %hi(variante_mostrata - 1)
    addu  $t3, $t3, $v0               # v0 = personaggio 1-8
    lbu   $t3, %lo(variante_mostrata - 1)($t3)
    slt   $t2, $t0, $t2
    bne   $t2, $zero, skin_conferma_scrivi
    lui   $t5, %hi(skin_scelta)
    move  $t3, $zero                  # CPU: originale
skin_conferma_scrivi:
    addu  $t5, $t5, $t0
    jr    $ra
    sb    $t3, %lo(skin_scelta)($t5)  # umano: la variante mostrata (V-D3)

.global skin_tentativi
skin_tentativi:
    .byte 0                           # tentativi di skin_leggi + 1; 0 = illimitati (M3-V2, anteprima)
.align 2

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
    sltiu $t2, $t0, 6                 # posto 1-5
    beq   $t2, $zero, skin_accoda_fine
    sll   $t0, $t0, 3                 # 8 byte per ingresso
    lui   $t1, %hi(skin_carica_1 - 8)
    addiu $t1, $t1, %lo(skin_carica_1 - 8)
    addu  $t1, $t1, $t0
    sw    $t1, 16($v0)                # callback del nodo: ingresso del posto
skin_accoda_fine:
    jr    $ra
    nop

.include "skin/varianti.inc"         # dopo il codice: skin_leggi resta a inizio blocco
.global SKIN_BLOCCO                   # usato da skin_anteprima (skin/skinAnteprima.s)
.align 2

.global skin_carica_1
skin_carica_1:
    j     skin_carica
    move  $t7, $zero
skin_carica_2:
    j     skin_carica
    addiu $t7, $zero, SKIN_BLOCCO
skin_carica_3:
    j     skin_carica
    addiu $t7, $zero, 2 * SKIN_BLOCCO
skin_carica_4:
    j     skin_carica
    addiu $t7, $zero, 3 * SKIN_BLOCCO
skin_carica_5:
    j     skin_carica
    addiu $t7, $zero, 4 * SKIN_BLOCCO
