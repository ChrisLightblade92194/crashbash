# PAL-P2b2 voce 58, provenienza 418a3f8561774df5de192848cefb12ee736d50b0.
# ovl1083 0x800b54e4: lw v0,72(s0) -> jal gesti_tasti.
# Il nop originale a 0x800b54e8 resta fuori patch; ritorno 0x800b54ec.
# Firma mascherata unica USA 0x800b41ec -> PAL 0x800b54a4, 132 byte.
# s0=0x800527f0 e v1=umani evidenziati; zero umani salta gia' all'epilogo.
.set noreorder
jal   gesti_tasti
