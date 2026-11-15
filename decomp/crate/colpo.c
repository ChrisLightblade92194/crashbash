#include <types.h>

extern volatile u8 _playerMetadata[];                /* 0x8009d52c: passo 0x6c */
extern volatile u32 _pagineCheat;                      /* 0x8005a618, simbolo di r17_pagine.txt */
extern volatile u16 _hitSounds[];                    /* 0x8009e080: quattro suoni per tipo */
extern void _FUN_800225c4(volatile u32 *);
extern s32 _FUN_80015590(s32);
extern void * _FUN_80022660(u32, void *, void *, u32, u32, u32);
extern u32 _FUN_800854c0(u32, u32);

/*
    @brief: Ingresso nell'azione 13 di Crate Crush: applica lo stordimento, libera la cassa tenuta,
            gestisce la salute e avvia suono e animazione del colpo. Chiamata dal gestore delle azioni.
            Riproduce l'originale, prima della correzione B-006; salute con segno, stati e tipo senza
            segno. FUN_800225c4 riceve in a0 il nodo a oggetto+0x94, omesso da Ghidra.
    @address: 0x800bfd2c
*/
u32 FUN_800bfd2c(u32 player)
{
    volatile u8 * metadata = (volatile u8 *)((u32) _playerMetadata + player * 0x6c);
    if (*(volatile u16 *)(metadata + 0x58) != 0x12)
    {
        *(volatile u16 *)(metadata + 0x48) = 30;
    }
    volatile u8 * physics = *(volatile u8 * volatile *)(metadata + 0x18);
    physics[0x1d] = 0;

    u32 state = *(volatile u16 *)(metadata + 0x58);
    if (state == 0x13)
    {
        *(volatile u16 *)(metadata + 0x5a) = 0;
        *(volatile u16 *)(metadata + 0x62) = 0;
    }
    else if (state == 0x19 || state == 0x1b || state == 0x1c)
    {
        *(volatile u16 *)(metadata + 0x62) = 0;
    }

    volatile u8 * crate = *(volatile u8 * volatile *)(metadata + 0x24);
    if (crate != nullptr)
    {
        *(volatile u16 *)(crate + 0x16) = *(volatile u16 *)(metadata + 0x38);
        crate = *(volatile u8 * volatile *)(metadata + 0x24);
        *(volatile u16 *)(crate + 0x1a) = 4;
        *(volatile u32 *)(metadata + 0x24) = 0;
    }
    if (*(volatile s16 *)(metadata + 0x36) <= 0 && !(_pagineCheat & 2))
    {
        *(volatile u16 *)(metadata + 0x32) = *(volatile u16 *)(metadata + 0x32) | 0x2000;
    }

    volatile u8 * object = *(volatile u8 * volatile *)(metadata + 4);
    volatile u32 * sound = *(volatile u32 * volatile *)(object + 0x94);
    if (sound != nullptr) { _FUN_800225c4(sound); }
    u32 choice = (u32) _FUN_80015590(4);
    u32 type = *(volatile u16 *)(metadata + 0x2e);
    _FUN_80022660(_hitSounds[(type << 2) + choice], nullptr, nullptr, 0x1000, 0x1e00, 0);
    return _FUN_800854c0(player, 9);
}
