.set noreorder
# Mutazione di controllo di B-006 (M3-L26): la correzione senza lo store della soglia.
# B-006 (M3-L26), parte 2 di 2. Il colpo subito in Crate Crush (0x800bfd2c, modulo 728, azione 13 tramite la
# cella 0x8009dd08) alza a 0x0200 la soglia del danno u16[M+0x46] quando vale 0, come fa il motore per una cassa.
# Il motore (0x8008402c) scarta durante +0x44/+0x48 i colpi di classe (M+0x3e & 0x0300) non superiore alla
# soglia; a 0x800840dc la soglia prende la classe del colpo ammesso, 0 per un colpo fisico: senza la correzione
# una cassa ferisce durante lo stordimento e il lampeggio. Le soglie 0x0100-0x0300 restano invariate.
# Sede: 0x800bfdf8-0x800bfe10 ricalcolava a0 = M, che a0 contiene già su tutti i percorsi che entrano
# (0x800bfdf0, 0x800bfdf4, 0x800bfdf8 e da 0x800bfdec); v0 e v1 calcolati lì vengono riscritti prima di essere
# letti. t0 contiene la soglia letta a 0x800bfd84 (b006/soglia.s).
# sltiu t1, t0, 1         1 se la soglia vale 0
.word 0x2d090001
# sll   t1, t1, 9         0x0200 oppure 0
.word 0x00094a40
# or    t0, t0, t1
.word 0x01094025
# nop                     (corretto: sh t0, 70(a0))
.word 0x00000000
# nop
.word 0x00000000
# nop
.word 0x00000000
