#include <types.h>

extern void * _FUN_80095e38(s32 index);
extern void _FUN_800b3a9c(void);
extern void _FUN_80022660(s32 sound, void * handle, s32 a2, s32 a3, s32 a4, s32 a5);
extern void _FUN_800b5410(void);
extern void _FUN_800b53d4(void);

extern s32 _unk_80051600;
extern u8 _unk_8005a63a;
extern u8 _unk_8005a63b;
extern u16 _minigameMode;
extern u8 _unk_8005a668[4];
extern u8 _unk_8005a670[4];
extern s32 _playersCampaign;
extern u8 _controllers[];
extern u32 _buttonsPressedP1;

/*
    @brief: Aggiorna SELECT NUMBER OF PLAYERS, i flag CPU e la configurazione cooperativa;
            chiamata dal gestore della schermata 0x800b8e3c a ogni frame.
    @address: 0x800b3f7c
*/
void FUN_800b3f7c(void)
{
    u8 * object = _FUN_80095e38(0);
    u8 * items = *(u8 **) (object + 0x6c) + 0xa8;
    s32 available;
    s32 i;

    _FUN_800b3a9c();
    *(s32 *) (items + 0x7c) = 3;
    *(s32 *) (items + 0x124) = 3;
    *(s32 *) (items + 0x1cc) = 3;
    *(s32 *) (items + 0x274) = 3;
    if (_unk_8005a63b == 2)
    {
        *(s32 *) (items + 0x8) = -0x22;
        *(s32 *) (items + 0xb0) = 0;
    }
    else
    {
        *(s32 *) (items + 0x8) = -0x40;
        *(s32 *) (items + 0xb0) = -0x1c;
    }
    if (_unk_8005a63b == 2)
    {
        *(u32 *) (items + 0x150) &= 0xffff7fff;
        *(u32 *) (items + 0x1f8) &= 0xffff7fff;
    }

    available = _unk_80051600;
    if (available >= 5) { available = 4; }
    if ((s32) _unk_8005a63b < available) { available = _unk_8005a63b; }
    for (i = 0; i < available; i++)
    {
        *(s32 *) (items + i * 0xa8 + 0x7c) = 0;
    }
    if (available < (s32) _unk_8005a63a) { _unk_8005a63a = (u8) available; }
    if (_unk_8005a63a != 0)
    {
        *(s32 *) (items + _unk_8005a63a * 0xa8 - 0x2c) = 2;
    }
    else
    {
        _unk_8005a63a = (u8) available;
    }

    if ((_buttonsPressedP1 & 0x10) && _unk_8005a63a >= 2)
    {
        _unk_8005a63a--;
        _FUN_80022660(0x190, nullptr, 0, 0x1000, 0x1e00, 0);
    }
    if ((_buttonsPressedP1 & 0x40) && (s32) _unk_8005a63a < available)
    {
        _unk_8005a63a++;
        _FUN_80022660(0x190, nullptr, 0, 0x1000, 0x1e00, 0);
    }

    if ((_minigameMode & 4) && _unk_8005a63a == 2)
    {
        _playersCampaign = 1;
        _unk_8005a668[0] = 1;
        _unk_8005a668[1] = 0;
        _unk_8005a668[2] = 3;
        _unk_8005a668[3] = _unk_8005a63a;
    }
    else
    {
        _playersCampaign = 0;
        _unk_8005a668[0] = 0xff;
        _unk_8005a668[1] = 0xff;
        _unk_8005a668[2] = 0xff;
        _unk_8005a668[3] = 0xff;
    }

    _unk_8005a670[0] = _unk_8005a63a < 1;
    _unk_8005a670[1] = _unk_8005a63a < 2;
    _unk_8005a670[2] = _unk_8005a63a < 3;
    _unk_8005a670[3] = _unk_8005a63a < 4;
    *(u16 *) (_controllers + 0x2a) = _unk_8005a670[0];
    *(u16 *) (_controllers + 0x82) = _unk_8005a670[1];
    *(u16 *) (_controllers + 0xda) = _unk_8005a670[2];
    *(u16 *) (_controllers + 0x132) = _unk_8005a670[3];
    if (_unk_8005a63a != 0)
    {
        if (_buttonsPressedP1 & 0x4000)
        {
            _FUN_80022660(0x192, nullptr, 0, 0x1000, 0x1e00, 0);
            _FUN_800b5410();
        }
        if (_buttonsPressedP1 & 0x1000)
        {
            _FUN_80022660(0x384, nullptr, 0, 0x1000, 0x1e00, 0);
            _FUN_800b53d4();
        }
    }
}
