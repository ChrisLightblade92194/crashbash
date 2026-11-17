# Provenienza: mods/r1-fixed/b006/correzione.s, game 7db60ceee82d7f7c6b61848da09789c4faa8d6dc.
# PAL voce 1089: 0x800bf148-0x800bf160. Insieme a soglia.s.
# a0 = 0x8009ba68 + 108*s2 dal prologo 0x800bf088-0x800bf0a4.
# Tutti i percorsi conservano a0; i sei calcoli rimossi ripetevano questa base.
# PAL motore 0x80085380/84/88/8c confronta M+0x46 con (M+0x3e & 0x300).
# 0x80085418 salva la classe ammessa: zero per un colpo fisico.
# Si alza soltanto 0 a 0x200. 0x100, 0x200, 0x300 restano uguali.
# Nessun salto o costante temporale introdotto; v0 e v1 sono riscritti prima dell'uso.
.set noreorder
.word 0x2d090001                  # sltiu t1,t0,1
.word 0x00094a40                  # sll t1,t1,9
.word 0x01094025                  # or t0,t0,t1
.word 0xa4880046                  # sh t0,0x46(a0)
.word 0x00000000
.word 0x00000000
