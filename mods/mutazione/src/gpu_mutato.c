/*
    Mutazione di prova del banco di equivalenza (M2, lotto L3, requisito R2).
    Compila decomp/core/gpu.c con _zIndexOffset sostituito da (_zIndexOffset + 2):
    l'unico uso è in AddPolyG4, `zIndex = (zIndex + _zIndexOffset) / 2`, quindi cambia
    solo l'offset di profondità: ogni quad Gouraud entra nella voce successiva dell'ordering table
    (con +1 la divisione intera annulla la mutazione quando l'offset è pari, misura di L3).
*/
#include <types.h>
#include <extern.h>
#define _zIndexOffset (_zIndexOffset + 2)
#include "../../../decomp/core/gpu.c"
