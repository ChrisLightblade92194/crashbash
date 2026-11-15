#include <types.h>

typedef struct MenuLevelEntry
{
    s32 type;
    s32 level;
    u32 model;
    u32 flags;
} MenuLevelEntry;

typedef struct MenuLevelPage
{
    MenuLevelEntry * entries;
    s32 count;
} MenuLevelPage;

extern u32 _buttonsPressedP1;
extern u8 _unk_8005a614[];
extern s32 _unk_8005a640;
extern MenuLevelPage _unk_800ba324[];
extern u32 _unk_800ba744;
extern u32 _unk_800ba740;
extern u32 * _unk_8004dd70[];
extern u32 * _unk_8004ddbc[];
extern u8 _levelTable[];
extern u8 _unk_800555dc[];
extern u8 _mainPool[];
extern u32 _frameCounter;
extern u32 _frameBufferIndex;
extern s16 _trigTable[][2];
extern u32 _nextLevel;
extern u32 _memcardStatus;
extern u8 _unk_800657d0[];
extern u32 _unk_800ba160[];
extern u32 _unk_800ba660[];
extern u32 _unk_800ba154[];
extern u32 _unk_800ba158[];
extern u32 _unk_800ba15c[];

extern void _FUN_80022660(s32 id, s32 a1, s32 a2, s32 a3, s32 a4, s32 a5);
extern u8 * _FUN_80095e38(s32 index);
extern void _FUN_80017640(void);
extern void _FUN_80011d28(void * pool);
extern void _FUN_80029100(void * animation);
extern s32 _FUN_80015284(s32 current, s32 target, s32 step);
extern void _FUN_800b3a9c(void);
extern void _FUN_800b53d4(void);
extern void _FUN_800b5410(void);
extern void _FUN_800b6e0c(void);
extern s32 _FUN_800b6c04(s32 apply);

#define SAVE _unk_8005a614
#define PAGE (*(s8 *) (SAVE + 0x36))
#define ROW (*(s8 *) (SAVE + 0x37))
#define WORD(base, offset) (*(u32 *) ((base) + (offset)))
#define HALF(base, offset) (*(u16 *) ((base) + (offset)))
#define OBJECT(index) (*(u8 **) (_FUN_80095e38(index) + 0x6c))
#define SOUND(id) _FUN_80022660(id, 0, 0, 0x1000, 0x1e00, 0)
#define AVAILABLE(entry) ((WORD(SAVE, 4) & 0x2000) || (entry)->type == 1 || \
    ((entry)->type == 2 && (SAVE[0xe4 + (entry)->level] || SAVE[0x168 + (entry)->level])))

/*
    @brief: Richiamata da FUN_800b6e0c: conta gli sblocchi nuovi nei quattro salvataggi della scheda
            e, se richiesto, li importa.
    @address: 0x800b6c04
*/
s32 FUN_800b6c04(s32 apply)
{
    s32 count = 0;
    s32 page;
    for (page = 0; page < 7; page++)
    {
        MenuLevelEntry * entry = _unk_800ba324[page].entries;
        s32 row;
        for (row = 0; row < _unk_800ba324[page].count; row++, entry++)
        {
            if (entry->type == 2 && !SAVE[0xe4 + entry->level])
            {
                s32 slot;
                for (slot = 0; slot < 4; slot++)
                {
                    if (_unk_800657d0[slot * 0x194 + entry->level + 0xe4])
                    {
                        count++;
                        if (apply) { SAVE[0xe4 + entry->level] = 1; }
                        break;
                    }
                }
            }
        }
    }
    return count;
}

/*
    @brief: Richiamata da FUN_800b7458: elabora i tasti di CHOOSE LEVEL e aggiorna titolo,
            anteprima e messaggi degli sblocchi.
    @address: 0x800b6e0c
*/
void FUN_800b6e0c(void)
{
    MenuLevelEntry * entry;
    u8 * object;
    u32 * message;

    if ((_buttonsPressedP1 & 0x80) && PAGE > 0)
    {
        SOUND(0x190);
        _unk_800ba744 = 4;
        PAGE = (u8) PAGE - 1;
    }
    if ((_buttonsPressedP1 & 0x20) && PAGE < 6)
    {
        SOUND(0x190);
        _unk_800ba744 = 4;
        PAGE = (u8) PAGE + 1;
    }
    if ((_buttonsPressedP1 & 0x10) && ROW > 0)
    {
        SOUND(0x190);
        ROW = (u8) ROW - 1;
    }
    if ((_buttonsPressedP1 & 0x40) && ROW < (s32) ((u32) _unk_800ba324[PAGE].count - 1))
    {
        SOUND(0x190);
        ROW = (u8) ROW + 1;
    }
    if (_buttonsPressedP1 & 0x1000)
    {
        SOUND(0x192);
        _FUN_800b53d4();
    }
    if (_buttonsPressedP1 & 0x4000)
    {
        entry = &_unk_800ba324[PAGE].entries[ROW];
        if (AVAILABLE(entry))
        {
            SOUND(0x192);
            _FUN_800b5410();
        }
        else { SOUND(0x38d); }
    }

    entry = &_unk_800ba324[PAGE].entries[ROW];
    if (AVAILABLE(entry))
    {
        object = OBJECT(0);
        entry = &_unk_800ba324[PAGE].entries[ROW];
        WORD(object, 0x6c) = _unk_8004dd70[_unk_8005a640][entry->level];
        object = OBJECT(0);
        WORD(object, 8) = 8;
        object = OBJECT(2);
        WORD(object, 0x6c) = _unk_800ba324[PAGE].entries[ROW].model;
        object = OBJECT(2);
        HALF(object, 0x74) = _unk_800ba324[PAGE].entries[ROW].flags;
        object = OBJECT(0);
        WORD(object, 0x2a0) |= 0x8000;
        object = OBJECT(0);
        WORD(object, 0x5e8) &= 0xffff7fff;
        return;
    }

    object = OBJECT(0);
    WORD(object, 0x6c) = _unk_800ba160[_unk_8005a640];
    object = OBJECT(2);
    HALF(object, 0x74) = 0;
    object = OBJECT(0);
    WORD(object, 0x2a0) &= 0xffff7fff;
    object = OBJECT(0);
    WORD(object, 8) = 0x1c;
    object = OBJECT(0);
    WORD(object, 0x5e8) |= 0x8000;
    if (_unk_800ba324[PAGE].entries[ROW].type != 2)
    {
        object = OBJECT(0);
        WORD(object, 0x654) = 0;
        return;
    }
    if (_memcardStatus & 2)
    {
        if (_memcardStatus & 0x40)
        {
            object = OBJECT(0);
            message = _unk_800ba660;
            goto set_message;
        }
        if (_memcardStatus & 0x10)
        {
            if (_FUN_800b6c04(0))
            {
                object = OBJECT(0);
                WORD(object, 0x654) = _unk_800ba154[_unk_8005a640];
                if (_buttonsPressedP1 & 0x2000)
                {
                    SOUND(0x396);
                    _FUN_800b6c04(1);
                }
                return;
            }
            object = OBJECT(0);
            message = _unk_800ba158;
            goto set_message;
        }
    }
    object = OBJECT(0);
    message = _unk_800ba15c;
set_message:
    WORD(object, 0x654) = message[_unk_8005a640];
}

/*
    @brief: Richiamata dal gestore delle schermate come aggiornamento di CHOOSE LEVEL:
            aggiorna le righe disponibili e le animazioni dei modelli e dei lucchetti.
    @address: 0x800b7458
*/
void FUN_800b7458(void)
{
    u8 * object;
    u8 * marker;
    MenuLevelEntry * entry;
    s32 row;
    s32 offset;
    u32 tick;
    u32 angle;
    s32 wave;
    s32 module;

    if (_unk_800ba744)
    {
        _FUN_80017640();
        _FUN_80011d28(_mainPool);
        _unk_800ba744--;
    }
    _FUN_800b3a9c();
    _FUN_80029100(_unk_800555dc + 0x10);
    _FUN_80029100(_unk_800555dc + 0x48);
    if (!_unk_800ba740) { _FUN_800b6e0c(); }

    object = OBJECT(0);
    entry = &_unk_800ba324[PAGE].entries[ROW];
    module = *(u16 *) (_levelTable + (u32) entry->level * 6);
    WORD(object, 0x45c) = _unk_8004ddbc[_unk_8005a640][module - 0x101];
    marker = OBJECT(0) + 0xa8;
    object = OBJECT(1);
    WORD(marker, 8) = _FUN_80015284(WORD(marker, 8),
        *(s16 *) (object + (s32) ROW * 0xa8 + 0x312) + 0x32, 0x800);

    for (row = 0, offset = 0; row < _unk_800ba324[PAGE].count; row++, offset += 0xa8)
    {
        object = OBJECT(1);
        WORD(object + offset, 0x2a0) |= 0x8000;
        object = OBJECT(row + 3);
        entry = &_unk_800ba324[PAGE].entries[row];
        if (AVAILABLE(entry))
        {
            WORD(object, 0x6c) = _unk_800ba324[PAGE].entries[row].model;
            tick = _frameCounter;
            HALF(object, 0x10) = 0x7d;
            HALF(object, 0x12) = 0;
            HALF(object, 0x14) = 0;
            HALF(object, 0x74) = _unk_800ba324[PAGE].entries[row].flags;
            angle = (tick * 20 + (u32) row * 0x800 - 0x400) & 0xfff;
            WORD(object, 4) = (s32) _trigTable[angle][1] >> 5;
            angle = (tick * 70 + (u32) row * 0x200 - 0x400) & 0xfff;
            WORD(object, 8) = ((s32) _trigTable[angle][1] * 5) >> 10;
        }
        else
        {
            WORD(object, 0x6c) = (u32) _unk_800555dc;
            HALF(object, 0x74) = 0x2006;
            HALF(object, 0x10) = 0;
            HALF(object, 0x12) = _frameBufferIndex * 50 + (u32) row * 0x400;
            tick = _frameCounter;
            angle = (tick * 100 + (u32) row * 0x800 - 0x400) & 0xfff;
            wave = _trigTable[angle][1];
            WORD(object, 4) = 0;
            WORD(object, 8) = 0;
            HALF(object, 0x14) = (wave * 25) >> 9;
        }
        object[0x51] = 0;
        HALF(object, 0x52) = 1;
    }

    /* L'anteprima usa il valore residuo di row dopo questo ciclo. */
    row = _unk_800ba324[PAGE].count;
    offset = (u32) row * 0xa8;
    while (row < 4)
    {
        object = OBJECT(1);
        WORD(object + offset, 0x2a0) &= 0xffff7fff;
        object = OBJECT(row + 3);
        HALF(object, 0x74) = 0;
        row++;
        offset += 0xa8;
    }
    _nextLevel = _unk_800ba324[PAGE].entries[ROW].level;
    object = OBJECT(2);
    HALF(object, 0x10) = 0x7d;
    object[0x51] = 0;
    tick = _frameCounter;
    angle = (tick * 20 + (u32) row * 0x800 - 0x400) & 0xfff;
    WORD(object, 4) = (s32) _trigTable[angle][1] >> 5;
    angle = (tick * 70 + (u32) row * 0x200 - 0x400) & 0xfff;
    HALF(object, 0x52) = 1;
    WORD(object, 8) = ((s32) _trigTable[angle][1] * 5) >> 10;
}
