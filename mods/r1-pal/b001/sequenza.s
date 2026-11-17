# Provenienza: mods/r1-fixed/b001/sequenza.s, game 7db60ceee82d7f7c6b61848da09789c4faa8d6dc.
# PAL voce 1085: 0x800bb76c-0x800bb778. Sostituisce la selezione dalla tabella.
# 0x800bb764 carica v0 da 0x800c087c; 0x800bb734 limita il contatore a 18.
# Innesto 2 P1c: v0=8 e 9, v1=0x800c05fc. andi restituisce motori 0 e 1.
# 0x800bb778 chiama 0x800bc694, che indicizza quattro record da 28 byte.
# Il ritardo della chiamata resta andi a0,a0,0xffff. Nessun timer modificato.
.set noreorder
.word 0x30440003
.word 0x00000000
.word 0x00000000
