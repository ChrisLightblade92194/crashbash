# Provenienza USA: 418a3f8561774df5de192848cefb12ee736d50b0; voce 52, L28.
# PAL-P2b2, sede 0x80049e74..0x80049eb0; 60 byte.
# Prove: docs/evidence/pal-r1/p2b2/casuale.json e p1/indirizzi-p1c.json.
# Quattro personaggi distinti 1..8; bit e indici non sono temporizzazioni.
# Nessun testo letto o disegnato; nessuna costante contata in frame.
# Contratto dinamico ancora da osservare: non verificato senza Redux.
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
