# M3-L28: modulo 722, 0x800b422c (aggiornamento di SELECT NUMBER OF PLAYERS, dopo le scritture dei flag della CPU,
# con almeno un umano evidenziato), originale lw v0, 0x48(s0) (tasti premuti) sostituito da jal gesti_tasti; il delay
# slot (nop) resta. Senza gesto gesti_tasti fa il load originale e torna qui (0x800b4234): croce e triangolo
# originali. Con un gesto, o con la partita già chiesta, salta all'epilogo della schermata (0x800b429c).
.set noreorder
jal   gesti_tasti
