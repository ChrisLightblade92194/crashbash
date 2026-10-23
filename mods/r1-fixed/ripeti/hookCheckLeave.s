# M3-L9: ingresso di FrontEnd_CheckLeave (0x8008efd4, voce 991): j ripeti_hook, con nel delay slot la prima
# istruzione sostituita (addiu sp, sp, -24); la seconda (lui v0, 0x8006) è rieseguita da ripeti_hook.
.set noreorder
j     ripeti_hook
addiu $sp, $sp, -24
