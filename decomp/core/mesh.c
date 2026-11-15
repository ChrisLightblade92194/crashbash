#include <types.h>

extern volatile u8 * volatile _meshCacheNode;         /* 0x80056998 */

/*
    @brief: Prepara i colori delle primitive di una mesh, chiamata dalla cache e dalle skin sul podio.
            Gruppi di due byte terminati dal conteggio 0xff, indici u16 e primitive da 0x28 byte;
            il bit 0 del gruppo sceglie il formato e il bit 15 dell'indice la semitrasparenza.
            Conserva anche 0xff in v0 al ritorno, come il confronto conclusivo originale.
    @address: 0x80017d90
*/
u32 FUN_80017d90(volatile u8 * mesh, volatile u8 * data)
{
    volatile u16 * indices = (volatile u16 *)((u32) mesh + *(volatile u32 *)(mesh + 0x20) + 0x20);
    volatile u8 * cache = _meshCacheNode;
    volatile u8 * model = *(volatile u8 * volatile *)(cache + 0x0c);
    volatile u8 * groups = (volatile u8 *)((u32) mesh + *(volatile u32 *)(mesh + 0x14) + 0x14);
    volatile u32 * colors = (volatile u32 *)((u32) model + *(volatile u32 *)(model + 0x20) + 0x20);

    for (;;)
    {
        u32 count = groups[1];
        if (count == 0xff) { return 0xff; }
        while (count != 0)
        {
            count--;
            u32 index = *indices;
            u32 format = groups[0];
            volatile u32 * color = colors + (index & 0x1fff);
            if (format & 1)
            {
                *(volatile u32 *)(data + 4) = ((index >> 8) & 0x60) | 0xe1000000;
                u32 translucent = *indices & 0x8000;
                u32 rgb = color[0];
                u32 command = translucent ? 0x32000000 : 0x30000000;
                *(volatile u32 *)(data + 0x0c) = rgb | command;
                *(volatile u32 *)(data + 0x14) = color[1];
                *(volatile u32 *)(data + 0x1c) = color[2];
            }
            else
            {
                u32 rgb = color[0];
                u32 command = rgb | 0x34000000;
                *(volatile u32 *)(data + 4) = command;
                if (*indices & 0x8000)
                {
                    u16 mode = *(volatile u16 *)(data + 0x1a);
                    *(volatile u32 *)(data + 4) = command | 0x02000000;
                    mode &= 0xff9f;
                    *(volatile u16 *)(data + 0x1a) = mode;
                    *(volatile u16 *)(data + 0x1a) = mode | ((*indices >> 8) & 0x60);
                }
                *(volatile u32 *)(data + 0x10) = color[1];
                *(volatile u32 *)(data + 0x1c) = color[2];
            }
            data += 0x28;
            indices++;
        }
        groups += 2;
    }
}
