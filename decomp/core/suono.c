#include <types.h>

extern volatile s8 _soundMap[];                       /* 0x80064508: coppie di byte */
extern volatile u32 * volatile _soundFreeNodes;       /* 0x80059610 */
extern volatile u32 * volatile _soundActiveNodes;     /* 0x80059614 */
extern void _FUN_800225c4(volatile u32 *);
extern void _FUN_80027a74(void);

/*
    @brief: Accoda un effetto sonoro, chiamata dai menu e dal gioco; restituisce il nodo oppure zero.
            I parametri volume e flags arrivano sulla pila O32 a sp+0x10 e sp+0x14 dell'ingresso.
            Un handle esistente viene fermato passando il suo nodo a FUN_800225c4 (a0 implicito
            nel decompilato Ghidra). Con il bit 0x8000 chiama FUN_80027a74, senza argomenti.
    @address: 0x80022660
*/
volatile u32 * FUN_80022660(u32 sound, volatile u32 * handle, const volatile u32 * position,
                           u32 pitch, u32 volume, u32 flags)
{
    if (sound & 0x8000)
    {
        _FUN_80027a74();
        return nullptr;
    }
    if (_soundMap[(sound << 1) + 1] == -1) { return nullptr; }

    volatile u32 * node = _soundFreeNodes;
    if (node == nullptr) { return nullptr; }

    _soundFreeNodes = (volatile u32 *) node[6];
    node[6] = (u32) _soundActiveNodes;
    node[5] = 0;
    volatile u32 * previous = _soundActiveNodes;
    if (previous != nullptr) { previous[5] = (u32) node; }
    node[0] = 0;
    node[10] = 0xffffffff;
    node[11] = 0xffffffff;

    node[5] = 0;
    node[6] = (u32) _soundActiveNodes;
    _soundActiveNodes = node;
    node[13] = sound;
    node[8] = pitch;
    node[9] = volume;
    node[7] = flags;
    node[10] = 0xffffffff;

    if (handle != nullptr)
    {
        volatile u32 * old = (volatile u32 *) *handle;
        if (old != nullptr) { _FUN_800225c4(old); }
        *handle = (u32) node;
        node[0] = (u32) handle;
        node[4] = (u32) position;
    }
    else if (position != nullptr)
    {
        /* L'originale legge tutte e tre le parole prima di scrivere la copia. */
        u32 x = position[0];
        u32 y = position[1];
        u32 z = position[2];
        node[1] = x;
        node[2] = y;
        node[3] = z;
        node[4] = (u32) &node[1];
    }
    else { node[4] = 0; }
    return node;
}
