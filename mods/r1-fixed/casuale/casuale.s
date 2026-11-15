# M3-L24: partita casuale. Dal 2026-11-15 (M3-L28) il gesto è SELECT tenuto più START su SELECT NUMBER OF PLAYERS
# (percorso Battle): lo smista gesti_tasti (boss/gesti.s), che salta a casuale_genera con t9 = gesti_suono. Partita
# subito: umani = numero evidenziato (0x8005a63a), CPU fino a quattro (flag 0x8005a670 già scritti dalla schermata
# nello stesso frame), minigioco, arena e personaggi di tutti casuali con Rand (0x80015590), tutti contro tutti,
# difficoltà e coppe come le lascia il menu. Minigioco e arena solo fra quelli sbloccati, o fra tutti con lo sblocco
# di sessione di L23 (sblocco_sessione). Indagine e progetto: docs/evidence/m3-l24/LEGGIMI.md.
# Sedi: EXE, blocchi della libreria libmcrd mai chiamati (docs/notes/m3-spazio.md §5):
#   - questo file: coda di MemCardOpen, da 0x80039b9c a 0x80039be0 (68 byte; da 0x80039b48 c'è boss/gesti.s, che ha
#     preso il posto di casuale_croce);
#   - genera.s: MemCardClose + MemCardReadData (0x80039c04-0x80039ce4), 224 byte;
#   - scrivi.s: MemCardWriteData (0x80039eb0-0x80039f4c), 156 byte.
# Il resto della mod non usa lo stack: ra del chiamante in t9, Rand cambia solo v0, v1, a0-a3, la funzione
# 0x800b4848 solo v0, v1, a0-a2; s0 e s1 del chiamante restano.
.set noreorder
.set noat

# Personaggi: quattro diversi fra gli 8 (tutti selezionabili in Battle), uno per giocatore, umani compresi.
# Arriva da genera.s con t6 = famiglia, t7 = arena; t5 = parola dei personaggi (giocatore 1 nel byte basso).
.global casuale_personaggi
casuale_personaggi:
    addiu $t8, $zero, 0xff             # personaggi liberi: bit 0-7 = personaggi 1-8
    addu  $t5, $zero, $zero
casuale_personaggio:
    jal   casuale_bit
    addu  $t0, $t8, $zero
    addiu $v1, $zero, 1
    sllv  $v1, $v1, $v0
    xor   $t8, $t8, $v1                # non più libero
    sll   $t5, $t5, 8
    addiu $v0, $v0, 1                  # personaggio 1-8
    or    $t5, $t5, $v0
    srl   $v0, $t5, 24
    beq   $v0, $zero, casuale_personaggio
    nop
    j     casuale_scrivi
    lui   $t0, 0x8006                  # prima istruzione di casuale_scrivi
