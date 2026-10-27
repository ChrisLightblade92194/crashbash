# M3-L15: maschera della conferma della Character Select (modulo 722, 0x800b615c): croce (0x4000) o tasto
# della skin (SKIN_TASTO di skin.s, oggi il quadrato 0x8000). Originale: andi v0, v0, 0x4000.
.set noreorder
andi  $v0, $v0, 0xc000
