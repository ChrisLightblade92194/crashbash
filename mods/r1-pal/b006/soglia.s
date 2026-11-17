# Provenienza: mods/r1-fixed/b006/soglia.s, game 7db60ceee82d7f7c6b61848da09789c4faa8d6dc.
# PAL voce 1089, 0x800bf0d4: lhu t0,0x46(a0). Insieme a correzione.s.
# v1 contiene gia' M+0x58 da 0x800bf0b4; 0x800bf0d8 li v0,25 non legge t0.
# Fino a 0x800bf148 nessuna istruzione scrive t0, t1, a0 o M+0x46.
# PAL motore 0x80085368-0x800853ac conferma timer +0x44/+0x48 e soglia +0x46.
# P1c innesti 60/61: 14 coppie con stesso a0 e soglia (0 oppure 0x200).
.set noreorder
.word 0x94880046
