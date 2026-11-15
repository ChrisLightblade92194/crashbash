#include <types.h>

/* Modulo 722: dati mantenuti nel modulo originale, non nel mod di prova. */
typedef struct
{
    u32 flags;
    u32 personaggio;
    s32 x, y, angolo;
    u32 modello, animazione, sequenza, suono, oggetto;
} MenuPersonaggio;

typedef struct
{
    u32 flags;
    s32 giocatore;
    u32 *podio, *cursore, *indicatore;
    u32 velocitaX, velocitaY, posizioneX, posizioneY;
    u32 tempo, frequenza, automatico, scelta;
    u32 animazione[11];
} MenuGiocatore;

extern MenuPersonaggio _menuPersonaggi[];  /* 0x800b9b44, passo 0x28 */
extern MenuGiocatore _menuGiocatori[];     /* 0x800b9fd4, passo 0x60 */
extern s32 _menuScartiCursore[][2];        /* 0x800b9c84 */
extern u32 _menuSuoniConferma[];          /* 0x800b9ca4 */
extern u32 _menuSuoniMovimento[];         /* 0x800b9cb4 */
extern u32 _menuVista[];                  /* 0x800b9f1c */
extern u8 _menuScenaCursori[];            /* 0x800b9634 */
extern u8 _menuScenaPersonaggi[];         /* 0x800b9a00 */
extern u32 _menuAnimazioneBase[];         /* 0x8005a9a0 */
extern u8 _modelTypes[];                  /* 0x80052a54, passo 0x38 */
extern s8 _trigTable[];                   /* 0x80068bd4, byte alto firmato */
extern u32 _frameBufferIndex;
extern u8 _controllers[];
extern u8 _unk_8005a63a;
extern s8 _unk_8004e0a4[];
extern s16 _unk_8005a658;
extern s16 _unk_8005a65a;
extern s16 _unk_8005a65c, _unk_8005a65e;
extern u8 _unk_8005a660[], _unk_8005a664[];
extern s8 _unk_8005a668[];
extern s32 _playersCampaign;

extern void *_FUN_80095e38(s32 scena);
extern void _FUN_80095bec(s32 scena, void *dati);
extern void _FUN_80014388(void *vista);
extern s32 _FUN_80015210(s32 valore, s32 destinazione, s32 passo);
extern s32 _FUN_80032f3c(s32 valore);
extern void _FUN_80022660(u32 suono, s32 a1, s32 a2, s32 volume, s32 a4, s32 a5);
extern void _FUN_800251a8(s32 a0, void *scena, void *oggetto, void *animazione);
extern u32 _FUN_80015590(u32 limite);
extern u32 _FUN_800b5b10(s32 giocatore);
extern void _FUN_800b64b8(void);

/* Gli undici word sono copiati senza cambiare il campo sequenza prima del suono. */
force_inline void copiaAnimazione(u32 *destinazione)
{
    s32 i;
    for (i = 0; i < 11; i++) { destinazione[i] = _menuAnimazioneBase[i]; }
}

force_inline u32 *oggettiScena(void *scena)
{
    return *(u32 **)((u8 *)scena + 0x6c);
}

/*
    @brief: Inizializza il podio, il cursore e l'animazione del giocatore a0;
            chiamata dall'ingresso nella Character Select e dal ripristino della selezione.
    @address: 0x800b5b10
*/
u32 FUN_800b5b10(s32 giocatore)
{
    void *scenaCursori = _FUN_80095e38(0);
    void *scenaPersonaggi = _FUN_80095e38(2);
    MenuGiocatore *p = &_menuGiocatori[giocatore];
    u32 *podio = (u32 *)((u8 *)oggettiScena(scenaPersonaggi) + (u32)giocatore * 0xa8);
    u32 *cursore = (u32 *)((u8 *)oggettiScena(scenaCursori) + (u32)giocatore * 0xa8);

    p->podio = podio;
    p->cursore = cursore;
    p->indicatore = (u32 *)((u8 *)oggettiScena(scenaPersonaggi) + (u32)giocatore * 0xa8 + 0x2a0);
    copiaAnimazione(p->animazione);
    p->flags = 0;
    p->giocatore = giocatore;
    p->automatico = 0;
    p->frequenza = _FUN_80015590(30) + 30;
    p->velocitaX = _FUN_80015590(0x200) - 0x100;
    p->velocitaY = _FUN_80015590(0x200) - 0x100;
    *((u8 *)podio + 0x50) = 1;
    *(s16 *)((u8 *)podio + 0x68) = -100;
    *((u8 *)podio + 0x51) = 0;
    podio[8] = 0;
    podio[9] = 0;
    podio[0] |= 0x02000000;
    p->scelta = giocatore;
    p->tempo = 0;
    if (giocatore < (s32)_unk_8005a63a) { cursore[0] |= 0x8000; }
    else { cursore[0] &= 0xffff7fff; }
    return cursore[0];
}

/*
    @brief: Aggiorna un giocatore a0 della Character Select: cursore, conferma e podio;
            chiamata dall'aggiornamento della schermata per ciascuno dei quattro giocatori.
    @address: 0x800b5ca8
*/
void FUN_800b5ca8(MenuGiocatore *p)
{
    u32 *cursore = p->cursore;
    u32 *podio = p->podio;
    u32 *indicatore = p->indicatore;
    s32 x = (u32)_menuPersonaggi[p->scelta].x + (u32)_menuScartiCursore[p->giocatore][0];
    s32 y = (u32)_menuPersonaggi[p->scelta].y + (u32)_menuScartiCursore[p->giocatore][1];
    s32 distanzaX, distanzaY;
    u32 oscillazione;

    cursore[1] = _FUN_80015210(cursore[1], x, 0x800);
    cursore[2] = _FUN_80015210(cursore[2], y, 0x800);
    distanzaX = _FUN_80032f3c(cursore[1] - (u32)x);
    distanzaY = _FUN_80032f3c(cursore[2] - (u32)y);
    oscillazione = (s32)_trigTable[((_frameBufferIndex * p->frequenza - 0x400) & 0xfff) * 4 + 3] + 0x1a4;
    indicatore[2] = oscillazione;
    podio[2] = oscillazione;

    if (!(p->flags & 1))
    {
        if (p->giocatore < (s32)_unk_8005a63a)
        {
            if (*(u32 *)(_controllers + (u32)p->giocatore * 0x58 + 0x48) & 0x80)
            {
                _FUN_80022660(_menuSuoniMovimento[p->giocatore], 0, 0, 0x1000, 0x1e00, 0);
                p->scelta--;
            }
            if (*(u32 *)(_controllers + (u32)p->giocatore * 0x58 + 0x48) & 0x20)
            {
                _FUN_80022660(_menuSuoniMovimento[p->giocatore], 0, 0, 0x1000, 0x1e00, 0);
                p->scelta++;
            }
            if (*(u32 *)(_controllers + (u32)p->giocatore * 0x58 + 0x48) & 0x10)
            {
                _FUN_80022660(_menuSuoniMovimento[p->giocatore], 0, 0, 0x1000, 0x1e00, 0);
                p->scelta -= 4;
            }
            if (*(u32 *)(_controllers + (u32)p->giocatore * 0x58 + 0x48) & 0x40)
            {
                _FUN_80022660(_menuSuoniMovimento[p->giocatore], 0, 0, 0x1000, 0x1e00, 0);
                p->scelta += 4;
            }
        }
        p->scelta &= 7;
        if ((p->giocatore < (s32)_unk_8005a63a &&
             (*(u32 *)(_controllers + (u32)p->giocatore * 0x58 + 0x48) & 0x4000) &&
             (u32)distanzaX + (u32)distanzaY == 0) || p->automatico)
        {
            oggettiScena(_FUN_80095e38(0))[0xd20 / 4] &= 0xffff7fff;
            oggettiScena(_FUN_80095e38(0))[0xdc8 / 4] &= 0xffff7fff;
            if (!(_menuPersonaggi[p->scelta].flags & 1))
            {
                if (!p->automatico)
                {
                    _FUN_80022660(_menuPersonaggi[p->scelta].suono, 0, 0, 0x1000, 0x1e00, 0);
                }
                _menuPersonaggi[p->scelta].flags |= 1;
                p->posizioneX = 0;
                p->posizioneY = 0;
                p->velocitaX = 0;
                p->velocitaY = 0;
                p->flags |= 1;
                podio[0] |= 0x8000;
                podio[0x1b] = (u32)(_modelTypes + _menuPersonaggi[p->scelta].modello * 0x38);
                _unk_8005a664[p->giocatore] = (u8)_menuPersonaggi[p->scelta].personaggio;
                _unk_8005a660[p->giocatore] = (u8)_menuPersonaggi[p->scelta].personaggio;
                _FUN_80022660(_menuSuoniConferma[p->giocatore], 0, 0, 0x1000, 0x1e00, 0);
                copiaAnimazione(p->animazione);
                p->tempo++;
                p->animazione[3] = _menuPersonaggi[p->scelta].sequenza;
            }
            else { _FUN_80022660(0x38d, 0, 0, 0x1000, 0x1e00, 0); }
        }
    }
    else
    {
        u32 destinazione = _menuPersonaggi[p->scelta].angolo;
        u32 velocita = p->velocitaX;
        u32 posizione = p->posizioneX;
        u32 modulo, distanza;
        if (posizione != destinazione)
        {
            if ((s32)posizione < (s32)destinazione) { velocita += (s32)velocita < 0 ? 1600 : 700; }
            else { velocita -= (s32)velocita > 0 ? 1600 : 700; }
        }
        modulo = (s32)velocita < 0 ? -velocita : velocita;
        distanza = destinazione - posizione;
        if ((s32)distanza < 0) { distanza = -distanza; }
        if ((s32)modulo <= 700 && (s32)distanza <= 700) { velocita = 0; }
        p->velocitaX = velocita;
        p->posizioneX += velocita;
        podio[8] = (s32)p->posizioneX >> 4;

        velocita = p->velocitaY;
        posizione = p->posizioneY;
        if (posizione != destinazione)
        {
            if ((s32)posizione < (s32)destinazione) { velocita += (s32)velocita < 0 ? 1900 : 1000; }
            else { velocita -= (s32)velocita > 0 ? 1900 : 1000; }
        }
        modulo = (s32)velocita < 0 ? -velocita : velocita;
        distanza = destinazione - posizione;
        if ((s32)distanza < 0) { distanza = -distanza; }
        if ((s32)modulo <= 1000 && (s32)distanza <= 1000) { velocita = 0; }
        p->velocitaY = velocita;
        p->posizioneY += velocita;
        podio[9] = (s32)p->posizioneY >> 4;
        _FUN_800251a8(0, _FUN_80095e38(2), p->podio, p->animazione);
        *(u16 *)((u8 *)podio + 0x52) = 1;
        p->tempo++;
    }
}

/*
    @brief: Prepara vista, scene e quattro giocatori all'ingresso nella Character Select;
            chiamata dall'inizializzazione della schermata del modulo 722.
    @address: 0x800b63f4
*/
void FUN_800b63f4(void)
{
    void *scena;
    s32 i;
    _FUN_80014388(_menuVista);
    _menuVista[2] = 0x400;
    _menuVista[6] = 400;
    scena = _FUN_80095e38(0);
    _FUN_80095bec(0, _menuScenaCursori);
    _FUN_80095bec(2, _menuScenaPersonaggi);
    for (i = 0; i < 4; i++) { _FUN_800b5b10(i); }
    for (i = 0; i < 8; i++)
    {
        _menuPersonaggi[i].flags = 0;
        _menuPersonaggi[i].oggetto = (u32)((u8 *)oggettiScena(scena) + 0x7e0 + i * 0xa8);
    }
    _FUN_800b64b8();
}

/*
    @brief: Calcola le maschere dei personaggi scelti alla fine della Character Select;
            chiamata dalla conferma della schermata e dall'avvio della partita casuale.
    @address: 0x800b4848
*/
s32 FUN_800b4848(void)
{
    s32 valore;
    if (_playersCampaign == 1)
    {
        valore = (s8)((u8)_unk_8004e0a4[_unk_8005a660[_unk_8005a65c]] |
                      (u8)_unk_8004e0a4[_unk_8005a660[_unk_8005a668[_unk_8005a65c]]]);
        _unk_8005a658 = valore;
        valore = (s8)((u8)_unk_8004e0a4[_unk_8005a660[_unk_8005a65e]] |
                      (u8)_unk_8004e0a4[_unk_8005a660[_unk_8005a668[_unk_8005a65e]]]);
        _unk_8005a65a = valore;
    }
    else
    {
        valore = _unk_8004e0a4[_unk_8005a660[_unk_8005a65c]];
        _unk_8005a658 = valore;
    }
    return valore;
}
