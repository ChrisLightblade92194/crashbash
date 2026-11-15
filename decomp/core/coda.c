#include <types.h>

/* R17-3a: coda dei modelli e letture CD dell'EXE. Le parole dei record
   restano volatili per conservare l'ordine delle scritture e delle riletture. */

typedef struct DatFile
{
    u32 sector;
    u32 size;
} DatFile;

extern volatile DatFile _datFiles[];                  /* 0x8004e110 */
extern u8 _mainPool[];                               /* 0x8004e0f0 */
extern const char _modelQueueError[];                 /* 0x8004c83c */
extern volatile u32 * volatile _modelLoadFree;        /* 0x80050f3c */
extern volatile u32 * volatile _modelLoadHead;        /* 0x80050634 */
extern volatile u32 * volatile _modelLoadTail;        /* 0x80050638 */
extern volatile s32 _cdReadStatus;                    /* 0x800637b4 */
extern volatile u32 _cdSectorBase;                    /* 0x800637b8 */
extern volatile u8 _cdResult[];                      /* 0x8006ea08 */
extern volatile u8 _cdPosition[];                    /* 0x8006ea10 */

extern s32 _printf(const char *, ...);
extern u32 _FUN_80012840(u32, volatile u32 *);
extern u32 _FUN_80011828(u32, u32);
extern void _FUN_80011498(u32, u32, void *);
extern void _FUN_80016e5c(u32, u32);
extern u32 _FUN_80016234(u32, u32);
extern s32 _CdReadSync(s32, void *);
extern s32 _CdControl(u32, const volatile void *, volatile void *);
extern void _CdIntToPos(u32, volatile void *);
extern s32 _CdRead(u32, void *, u32);
extern void _FUN_80034aec(void);

/*
    @brief: Accoda un gruppo di modello nella lista dei caricamenti, dopo averne impostato l'arena;
            chiamata dal caricatore dei personaggi e dalle skin. Restituisce il nodo lasciato in v0.
            Anche senza nodi stampa l'errore e prosegue con le scritture all'indirizzo zero.
    @address: 0x800129d0
*/
__attribute__((optimize("no-delete-null-pointer-checks")))
volatile u32 * FUN_800129d0(volatile u32 * entry, u32 arena)
{
    u32 first = *(volatile u32 *) entry[0];
    *(volatile u32 *)(entry[1] + 0x34) = arena;
    volatile DatFile * file = (volatile DatFile *)((u32) _datFiles + (first << 3));
    volatile u32 * node = _modelLoadFree;
    u32 size = ((volatile u32 *) entry[0])[2];

    if (node != nullptr)
    {
        volatile u32 * next = (volatile u32 *) node[7];
        node[7] = 0;
        node[8] = (u32) _modelLoadTail;
        volatile u32 * tail = _modelLoadTail;
        _modelLoadFree = next;
        if (tail != nullptr) { tail[7] = (u32) node; }
        else { _modelLoadHead = node; }
        _modelLoadTail = node;
    }
    if (node == nullptr) { _printf(_modelQueueError); }

    node[0] = (u32) file;
    node[1] = 0;
    node[3] = 1;
    node[2] = size;
    node[4] = (u32) _FUN_80012840;
    node[5] = (u32) entry;
    node[6] = 0;
    return node;
}

/*
    @brief: Callback della coda dei modelli, richiamato anche dalle skin: separa i file a ritroso,
            carica prima le texture e poi il modello. La ricerca fallita conserva lo scostamento
            -1 settore (0xfffff800 byte); il ritorno e' quello dell'ultima chiamata originale.
    @address: 0x80012840
*/
u32 FUN_80012840(u32 buffer, volatile u32 * entry)
{
    volatile u32 * group = (volatile u32 *) entry[0];
    u32 first = group[0];
    u32 count = group[1];
    volatile DatFile * base = (volatile DatFile *)((u32) _datFiles + (first << 3));

    if (count != 0)
    {
        count--;
        volatile DatFile * file = (volatile DatFile *)((u32) _datFiles + ((first + count) << 3));
        while (count != 0)
        {
            count--;
            u32 split = _FUN_80011828(buffer, (file->sector - base->sector) << 11);
            u32 size = file->size;
            file--;
            _FUN_80011498(split, size, _mainPool);
        }
    }

    /* Il gruppo e l'arena vengono riletti dopo le chiamate che separano i file. */
    group = (volatile u32 *) entry[0];
    u32 arena = entry[1];
    volatile DatFile * target = (volatile DatFile *) entry[3];
    count = group[1] - 1;
    volatile DatFile * file = (volatile DatFile *)((u32) _datFiles + (group[0] << 3));
    u32 firstSector = file->sector;
    u32 offset = 0xffffffff;
    if (count != 0xffffffff)
    {
        do
        {
            count--;
            if (file == target)
            {
                offset = file->sector - firstSector;
                break;
            }
            file++;
        } while (count != 0xffffffff);
    }
    _FUN_80016e5c(buffer + (offset << 11), arena);

    count = group[1] - 1;
    file = (volatile DatFile *)((u32) _datFiles + (group[0] << 3));
    target = (volatile DatFile *) entry[2];
    firstSector = file->sector;
    offset = 0xffffffff;
    if (count != 0xffffffff)
    {
        do
        {
            count--;
            if (file == target)
            {
                offset = file->sector - firstSector;
                break;
            }
            file++;
        } while (count != 0xffffffff);
    }
    return _FUN_80016234(buffer + (offset << 11), arena);
}

/*
    @brief: Avvia una lettura CD per il caricatore e le skin, oppure restituisce -1 se occupato
            o se Setloc/CdRead falliscono. Interroga e conclude anche un'eventuale lettura precedente.
    @address: 0x80027790
*/
s32 FUN_80027790(volatile DatFile * file, u32 offset, void * destination, u32 sectors)
{
    if (_cdReadStatus > 0)
    {
        _cdReadStatus = _CdReadSync(1, nullptr);
        if (_cdReadStatus == 0)
        {
            _CdControl(1, nullptr, _cdResult);
            _FUN_80034aec();
        }
    }
    if (_cdReadStatus > 0) { return -1; }

    _CdIntToPos(file->sector + offset + _cdSectorBase, _cdPosition);
    if (_CdControl(2, _cdPosition, nullptr) == 0) { return -1; }
    if (_CdRead(sectors, destination, 0x80) == 0) { return -1; }

    _cdReadStatus = 1;
    _cdReadStatus = _CdReadSync(1, nullptr);
    if (_cdReadStatus == 0)
    {
        _CdControl(1, nullptr, _cdResult);
        _FUN_80034aec();
    }
    return _cdReadStatus;
}

/*
    @brief: Interroga la lettura CD per il caricatore e le skin; aggiorna lo stato solo se positivo,
            e alla conclusione richiede lo stato del disco e richiama la routine finale di libcd.
    @address: 0x80027944
*/
s32 FUN_80027944(void)
{
    if (_cdReadStatus > 0)
    {
        _cdReadStatus = _CdReadSync(1, nullptr);
        if (_cdReadStatus == 0)
        {
            _CdControl(1, nullptr, _cdResult);
            _FUN_80034aec();
        }
    }
    return _cdReadStatus;
}
