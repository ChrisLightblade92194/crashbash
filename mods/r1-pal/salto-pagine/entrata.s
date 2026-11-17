# Provenienza USA: 7db60ceee82d7f7c6b61848da09789c4faa8d6dc; voce 6.
# NextPage PAL: firma univoca di 32 byte, 0x800832bc -> 0x8008469c.
# Il delay slot ripete il lui originale; il resto e' eseguito dalla voce 5.
# Valori dei registri nel percorso reale: ipotesi, mai osservati in Redux.
.set noreorder
j     salto_pagine
lui   $v0, 0x800a
