# M3-L10: ingresso della funzione di conferma del menu di fine partita (0x8007f1a8, voce 991): j ripeti_conferma, con nel
# delay slot la prima istruzione sostituita (addiu sp, sp, -40); la seconda (sw s1, 28(sp)) è rieseguita da ripeti_conferma.
.set noreorder
j     ripeti_conferma
addiu $sp, $sp, -40
