# Provenienza USA: 7db60ceee82d7f7c6b61848da09789c4faa8d6dc; voce 7.
# PAL 0x80081018 legge i premuti a +72(a0); 0x80081020 applica 0x4000.
# Croce 0x4000 e START 0x8: stessa codifica, firma contesto 0x80080fdc.
# a0=pad selezionato e v0=premuti sono ipotesi statiche, da osservare in Redux.
.set noreorder
andi  $v0, $v0, 0x4008
