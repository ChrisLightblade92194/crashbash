# Mod PAL senza modifiche

Prova degli strumenti PAL-P0. L'unica riga della buildList riscrive un `nop`
sopra il `nop` originale a `0x800114a8` di `SCES_028.34` (delay slot dopo un
`jr ra`): nessun byte cambia, ma compilazione, ricostruzione dell'ISO con
mkpsxiso e correzione delle date passano dal percorso PAL vero.

Comando dalla radice del progetto:

```powershell
& 'C:\dev\crashbash-online-tools\psx-modding-toolchain\.venv\Scripts\python.exe' -I tools/build.py --mod pal-vuoto --regione pal --gioco crashbash-pal
```

L'ISO è `game/build/bash_pal_pal-vuoto.bin` e deve avere SHA-1
`253c05e9e8dbe9251f31b3512fd251390483cb59`, uguale all'originale.
