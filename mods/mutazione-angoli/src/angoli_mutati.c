#include <types.h>
#include <math.h>
#include <extern.h>

// Copia di SubtractAngles (decomp/core/math.c, originale a 0x800154a0) con una costante cambiata.
s32 SubtractAngles(s32 x, s32 y)
{
    s32 res = ANG_MOD(y - x);
    if (res > ANG_180) { return res - ANG_360; }
    return res + 1; // mutazione: l'originale restituisce res
}
