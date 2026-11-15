#include <types.h>

/* R17-3b: pagine e menu del motore, voce 991 NTSC-U.
   Gli accessi volatili conservano larghezza e ordine anche attorno alle chiamate
   originali. Le tabelle restano nella RAM del gioco; nessuna copia nel mod. */
extern volatile u32 _gameFlags;
extern volatile u16 _gameMode;
extern volatile u16 _minigameMode;
extern volatile s16 _levelID;
extern volatile u8 _levelTable[];
extern volatile u8 _controllers[];
extern volatile u8 _playerMetadata[];
extern volatile u8 _unk_8005a6e0[];
extern volatile s32 _nextLevel;

extern volatile s32 _pagineVolumeMusica;       /* 0x8005a604 */
extern volatile s32 _pagineVolumeEffetti;      /* 0x8005a608 */
extern volatile s32 _pagineStereo;             /* 0x8005a60c */
extern volatile s8 _pagineVibrazione[];        /* 0x8005a610 */
extern volatile u32 _pagineCheat;              /* 0x8005a618 */
extern volatile u32 _pagineAttesa;             /* 0x8005a628 */
extern volatile u8 _unk_8005a63a;               /* 0x8005a63a */
extern volatile u32 _pagineRipristino;         /* 0x8005a67c */
extern volatile u8 _pagineBlocco;              /* 0x8005a688 */
extern volatile u8 _pagineTentativi[];         /* 0x8005a6bf */
extern volatile u8 _pagineCompletati[];        /* 0x8005a6f8 */
extern volatile s32 _paginePadAttivo;          /* 0x80051604 */
extern volatile s32 _pagineRiepilogo;          /* 0x8009ae3c */
extern volatile s32 _pagineSottomenu;          /* 0x8009aee8 */
extern volatile s32 _pagineVoce;              /* 0x8009aeec */
extern volatile s32 _paginePad;               /* 0x8009aef0 */
extern volatile s32 _pagineUltimoPad;         /* 0x8009aef4 */
extern volatile s32 _pagineRientro;           /* 0x8009af00 */
extern volatile u16 _pagineModi[];           /* 0x8009af38 */
extern volatile u16 _pagineAperte;            /* 0x8009bd00 */
extern volatile u32 _pagineCorrente;          /* 0x8009bd0c */
extern volatile u32 _pagineLista;             /* 0x8009bd10 */
extern volatile u32 _pagineIndice;            /* 0x8009bd14 */
extern volatile s16 _paginePosizione;         /* 0x8009bd18 */
extern volatile u16 _pagineOpzioneStereo;     /* 0x8009bd1c */

extern void _FUN_800222bc(void);
extern void _FUN_800222dc(void);
extern void _FUN_80022660(s32, s32, s32, s32, s32, s32);
extern void _FUN_80028018(s32, s32);
extern void _FUN_80028158(void);
extern void _FUN_8002ac18(void);
extern void _FUN_8002ac40(void);
extern void _FUN_8002c0e0(s32);
extern void _FUN_8002c11c(void);
extern s32 _FUN_8007ee2c(s32);
extern s32 _FUN_8007efc0(s32, s32);
extern s32 _FUN_8007f1a8(s32, s32);
extern void _FUN_80080fbc(void);
extern void _FUN_80081470(s32);
extern void _FUN_80082d90(s32);
extern void _FUN_800831c4(s32);
extern void _FUN_80083244(void);
extern s32 _NextPage(void);
extern void _FUN_80083334(s32, s32, s32);
extern void _FUN_8008f068(void);
extern void _FUN_80095a04(s32);
extern void _FUN_80095bec(s32, u32);

#define MODULO() (*(volatile u16 *)(_levelTable + (s32)_levelID * 6))
#define PAD(p, campo) (*(volatile u32 *)(_controllers + (u32)(p) * 0x58u + (campo)))
#define PREMUTI() PAD(_paginePad, 0x48)
#define SUONO(id) _FUN_80022660((id), 0, 0, 0x1000, 0x1e00, 0)

/*
    @brief: Avanza nella lista delle istruzioni, chiamata dal gestore delle pagine.
            Restituisce 1 se apre una pagina, 0 se la lista e' assente o terminata.
    @address: 0x800832bc
    @note: La chiamata a 0x80095bec passa anche a1 = puntatore della pagina;
           il decompilato Ghidra omette questo argomento, letto dal destinatario.
*/
s32 NextPage(void)
{
    u32 lista = _pagineLista;
    if (lista != 0)
    {
        u32 indice = _pagineIndice;
        u32 pagina = *(volatile u32 *)(lista + (indice << 2) + 4u);
        if (pagina != 0)
        {
            _pagineIndice = indice + 2u;
            _pagineCorrente = pagina;
            _FUN_80095bec(0, pagina);
            return 1;
        }
    }
    _pagineLista = 0;
    _pagineCorrente = 0;
    return 0;
}

/*
    @brief: Aggiorna istruzioni, pausa e sottomenu audio/vibrazione/uscita;
            chiamata ogni aggiornamento dalla schermata di gioco a 0x80092ee4.
            Ritorna 1 se puo' proseguire la partita, 0 se il menu la trattiene.
    @address: 0x8007f314
    @note: Riproduce il gioco originale: croce 0x4000 per avanzare e cerchio
           0x1000 per tornare indietro. Chiama sempre _NextPage originale.
           FUN_80080fbc non legge argomenti in ingresso (verificato nel binario).
*/
s32 FUN_8007f314(void)
{
    s32 risultato = 1;
    s32 modoPagine = 7;
    s32 voci = 4;
    s32 i;
    u32 stato;

    if (_gameFlags & 0x10) { return 0; }
    if ((_gameMode & 0x8008) && MODULO() != 0x102) { return 0; }
    if (MODULO() == 0x101 || _levelID == 0x2b) { return 1; }
    if (_pagineBlocco != 0) { return 1; }

    if (_pagineRipristino != 0)
    {
        u32 attesa = _pagineAttesa;
        if (attesa != 0)
        {
            _pagineAttesa = attesa - 1u;
        }
        else
        {
            _FUN_8008f068();
            _pagineRipristino = 0;
            _gameFlags &= 0xfdffffffu;
        }
    }

    if (!(_minigameMode & 0x100))
    {
        u32 modo = _minigameMode & 0xff;
        modoPagine = 0;
        for (i = 0; i < 7; ++i)
        {
            if (modo == _pagineModi[i])
            {
                modoPagine = i;
                break;
            }
        }
    }

    stato = _gameFlags;
    if (!(stato & 0x660))
    {
        u32 cambiato = (stato & 0x1000000) ? ((stato & 1) ^ 1) : ((stato & 1) != 0);
        if (cambiato)
        {
            if (_gameFlags & 1)
            {
                _FUN_80028158();
                _FUN_8002ac40();
                SUONO(0x193);
            }
            else
            {
                _FUN_8002ac18();
            }
        }
        _gameFlags &= 0xfeffffffu;
    }
    if (_gameFlags & 1) { _gameFlags |= 0x1000000; }
    if (_gameFlags & 0x8000000) { return 0; }

    if (_minigameMode & 4) { voci = 3; }
    stato = _pagineCheat;
    if ((s32)stato < 0 && (stato & 0x10000)) { ++voci; }

    if (!(_gameFlags & 0x2007001))
    {
        u32 umani = 1;
        volatile u8 *pad = _controllers;
        volatile u8 *giocatore = _playerMetadata;
        if ((_gameFlags & 0x4000000) && !(_gameMode & 0x1000)) { goto uscita; }
        _paginePad = 0;
        _pagineUltimoPad = -1;
        if (MODULO() != 0x102) { umani = _unk_8005a63a; }
        for (i = 0; i < (s32)umani; ++i)
        {
            if ((*(volatile u32 *)(pad + 0x44) & 9) != 9 &&
                (*(volatile u32 *)(pad + 0x48) & 8) &&
                (!(*(volatile u16 *)(giocatore + 0x32) & 0xf800) ||
                 MODULO() == 0x102 || i == 0))
            {
                giocatore = _playerMetadata + 0x29c4;
                pad = _controllers + 0x2208;
                _paginePad = i;
                _pagineUltimoPad = i;
                stato = _gameFlags;
                _pagineVoce = 0;
                _gameFlags = stato | 1;
                if (MODULO() == 0x102) { _gameFlags = stato | 9; }
                _pagineAperte = 1;
                _FUN_80081470(1);
                risultato = 0;
                /* Conserva anche il caso limite umani > 100: l'originale
                   riparte da 100 con i cursori spostati, invece di uscire. */
                i = 99;
            }
            giocatore += 0x6c;
            pad += 0x58;
        }
        goto fine;
    }

    stato = _gameFlags & 0x23f8fec;
    switch (stato)
    {
    case 0:
        if (_gameFlags & 0x7000) { goto trattieni; }
        if (!_FUN_8007efc0(_paginePad, voci)) { goto trattieni; }
        stato = _gameFlags & 0xffc070d3u;
        _gameFlags = stato;
        if (_minigameMode & 4)
        {
            switch (_pagineVoce)
            {
            case 0:
                _gameFlags = stato & 0x4000010;
                _paginePad = 0;
                _pagineVoce = 0;
                _FUN_8002ac18();
                break;
            case 1:
                _FUN_80083334(_levelID, modoPagine, 0);
                _gameFlags |= 0x80;
                break;
            case 2:
                _gameFlags = stato | 0x100;
                _pagineVoce = 0;
                _pagineSottomenu = 0;
                break;
            case 3:
                _gameFlags = stato | (_levelID == 0x20 ? 4 : 0x8000);
                _pagineVoce = 1;
                break;
            }
        }
        else
        {
            switch (_pagineVoce)
            {
            case 0:
                _paginePad = 0;
                _pagineVoce = 0;
                _gameFlags &= 0x4000010;
                _FUN_8002ac18();
                break;
            case 1:
                _FUN_80083334(_levelID, modoPagine, 0);
                _gameFlags |= 0x80;
                break;
            case 2:
                _pagineVoce = 0;
                _pagineSottomenu = 0;
                _gameFlags |= 0x100;
                break;
            case 3:
                _pagineVoce = 1;
                _gameFlags |= 0x8000;
                break;
            case 4:
                _pagineVoce = 1;
                _gameFlags |= 4;
                break;
            }
        }
        SUONO(0x192);
        goto trattieni;

    case 8:
        if (!_FUN_8007efc0(_paginePad, voci - 1)) { goto trattieni; }
        switch (_pagineVoce)
        {
        case 0:
            _paginePad = 0;
            _pagineVoce = 0;
            _gameFlags &= 0x4000010;
            _FUN_8002ac18();
            break;
        case 1:
            _pagineSottomenu = 0;
            _pagineVoce = 0;
            _gameFlags |= 0x100;
            break;
        case 2:
            _pagineVoce = 1;
            _gameFlags |= 4;
            break;
        case 3:
            _pagineVoce = 0;
            _gameFlags |= 0x10000;
            break;
        }
        SUONO(0x192);
        goto trattieni;

    case 0x8000:
        if (_FUN_8007ee2c(_paginePad))
        {
            if (_pagineVoce == 0)
            {
                s32 massimo = 0;
                if (_minigameMode & 0x10)
                {
                    for (i = 0; i < 4; ++i)
                    {
                        u8 coppe = _unk_8005a6e0[i];
                        if (massimo < coppe) { massimo = coppe; }
                    }
                    if (massimo >= 2 && _pagineCompletati[_levelID] == 0)
                    {
                        _pagineTentativi[_levelID] += 1;
                        if (_pagineTentativi[_levelID] >= 4) { _pagineTentativi[_levelID] = 3; }
                    }
                }
                _gameFlags |= 0x10;
                _gameMode |= 0x8002;
            }
            else if (_pagineVoce == 1)
            {
                _pagineVoce = 0;
                _gameFlags &= 0xffff7fffu;
            }
        }
        if (PREMUTI() & 0x1000)
        {
            _pagineVoce = 0;
            _gameFlags &= 0xffff7fffu;
        }
        goto trattieni;

    case 4:
    case 0xc:
        if (_FUN_8007ee2c(_paginePad))
        {
            if (_pagineVoce == 0) { _FUN_8008f068(); }
            else if (_pagineVoce == 1)
            {
                _pagineVoce = 0;
                _gameFlags &= 0xfffffffbu;
            }
        }
        if (PREMUTI() & 0x1000)
        {
            _pagineVoce = 0;
            _gameFlags &= 0xfffffffbu;
        }
        goto trattieni;

    case 0x40:
    case 0x240:
        /* A 0x8007fc28 il livello 0x25 conserva s3=1 e salta tutto. */
        if (_levelID == 0x25) { goto fine; }
        if ((PAD(_paginePad, 0x44) & 9) == 9) { goto trattieni; }
        if (PREMUTI() & 0x4000)
        {
            if (_NextPage() != 1)
            {
                SUONO(0x191);
                _FUN_80095a04(0);
                risultato = 1;
                stato = _gameFlags;
                if (stato & 0x200)
                {
                    _gameFlags = stato & 0xffffffbfu;
                    _pagineVoce = 0;
                }
                else
                {
                    _gameFlags = (stato & 0xffffffbfu) & 0x4000010;
                    _paginePad = 0;
                    _pagineVoce = 0;
                    _FUN_8002ac18();
                    _pagineVoce = 0;
                }
                goto fine;
            }
            SUONO(0x195);
        }
        risultato = 0;
        if (PREMUTI() & 0x1000) { _FUN_80083244(); }
        goto fine;

    case 0x80:
        if ((PAD(_paginePad, 0x44) & 9) == 9) { goto trattieni; }
        if (PREMUTI() & 0x4000)
        {
            if (_NextPage() == 1)
            {
                SUONO(0x195);
            }
            else
            {
                SUONO(0x191);
                _FUN_80095a04(0);
                _pagineRientro = 1;
                _pagineVoce = 0;
                _gameFlags &= 0xffffff7fu;
            }
        }
        risultato = 0;
        if (PREMUTI() & 0x1000) { _FUN_80083244(); }
        goto fine;

    case 0x100:
    case 0x108:
        if (_pagineSottomenu == 1)
        {
            switch (_pagineVoce)
            {
            case 0:
            {
                u32 stereo = _pagineStereo != 0;
                _pagineOpzioneStereo = stereo;
                if (PREMUTI() & 0xa0)
                {
                    _pagineOpzioneStereo = stereo ^ 1;
                    SUONO(0x190);
                    if (_pagineOpzioneStereo)
                    {
                        _pagineStereo = 1;
                        _FUN_800222bc();
                    }
                    else
                    {
                        _pagineStereo = 0;
                        _FUN_800222dc();
                    }
                }
                break;
            }
            case 1:
            {
                s32 volume = _pagineVolumeMusica;
                if (volume > 0 && (PREMUTI() & 0x80)) { volume = (s32)((u32)volume - 5u); }
                if (volume < 100 && (PREMUTI() & 0x20)) { volume = (s32)((u32)volume + 5u); }
                _pagineVolumeMusica = volume;
                break;
            }
            case 2:
            {
                s32 volume = _pagineVolumeEffetti;
                if (volume > 0 && (PREMUTI() & 0x80))
                {
                    volume = (s32)((u32)volume - 5u);
                    SUONO(0x190);
                }
                if (volume < 100 && (PREMUTI() & 0x20))
                {
                    volume = (s32)((u32)volume + 5u);
                    SUONO(0x190);
                }
                _pagineVolumeEffetti = volume;
                break;
            }
            }
            if (_FUN_8007efc0(_paginePad, 3) || (PREMUTI() & 0x1000))
            {
                _pagineVoce = 0;
                _pagineSottomenu = 0;
                _FUN_8002c11c();
                SUONO(0x195);
            }
        }
        else if (_pagineSottomenu == 2)
        {
            for (i = 0; i < _unk_8005a63a; ++i)
            {
                if ((PAD(i, 0x48) & 0x8000) && (PAD(i, 0) & 8))
                {
                    _pagineVibrazione[i] = _pagineVibrazione[i] == 0;
                    _FUN_80028018(i, 10);
                    SUONO(0x195);
                }
            }
            if (_FUN_8007efc0(_paginePad, 0) || (PREMUTI() & 0x1000))
            {
                _pagineVoce = 1;
                _pagineSottomenu = 0;
                SUONO(0x195);
            }
        }
        else
        {
            if (_FUN_8007efc0(_paginePad, 2))
            {
                s32 voce = _pagineVoce;
                if (voce == 2)
                {
                    _pagineSottomenu = 0;
                    _gameFlags &= 0xfffffeffu;
                }
                else { _pagineSottomenu = (s32)((u32)voce + 1u); }
                if (_pagineVoce == 0) { _FUN_8002c0e0(0x192); }
                _pagineVoce = 0;
                SUONO(0x192);
            }
            if (PREMUTI() & 0x1000)
            {
                _pagineVoce = 0;
                _gameFlags &= 0xfffffeffu;
            }
        }
        goto trattieni;

    case 0x20000:
    case 0x20008:
        if (PREMUTI() & 8)
        {
            _pagineVoce = 0;
            _gameFlags = (_gameFlags & 0xfffdffffu) | 0x10000;
        }
        goto trattieni;

    case 0x40000:
    case 0x40008:
        if (PREMUTI() & 1)
        {
            _gameMode = 0x8008;
            _paginePad = 2;
            stato = _gameFlags;
            _nextLevel = _levelID;
            _gameFlags = stato & 0xfffbfffeu;
        }
        /* Rilegge il pad: il ramo precedente puo' averlo cambiato in 2. */
        if (PREMUTI() & 0x1008)
        {
            _pagineVoce = 2;
            _gameFlags = (_gameFlags & 0xfffbffffu) | 0x10000;
        }
        goto trattieni;

    case 0x200:
        if (!_FUN_8007f1a8(0, 3)) { goto aggiorna; }
        SUONO(0x195);
        switch (_pagineVoce)
        {
        case 1:
            _FUN_80083334(_levelID, modoPagine, 0);
            _FUN_800831c4(_paginePosizione);
            _gameFlags |= 0x40;
            goto fine;
        case 2:
            _paginePad = 0;
            _pagineVoce = 0;
            stato = (_gameFlags & 0xfffffdffu) | 0x10;
            _gameFlags = stato;
            _gameFlags = stato & 0x4000010;
            _gameMode |= 0x8002;
            _FUN_8002ac18();
            goto fine;
        case 3:
            _gameFlags &= 0xfffffdffu;
            _FUN_8008f068();
            stato = _gameFlags;
            _paginePad = 0;
            _pagineVoce = 0;
            _gameFlags = stato & 0x4000010;
            _FUN_8002ac18();
            goto fine;
        default:
            _paginePad = 0;
            stato = _gameFlags;
            _pagineVoce = 0;
            _gameFlags = stato & 0x4000010;
            _FUN_8002ac18();
            _pagineRiepilogo = 0;
            goto fine;
        }

    case 0x20:
    case 0x400:
        if (PAD(0, 0x48) & 0x10)
        {
            SUONO(0x190);
            _pagineVoce = (s32)((u32)_pagineVoce - 1u);
        }
        if (PAD(0, 0x48) & 0x40)
        {
            SUONO(0x190);
            _pagineVoce = (s32)((u32)_pagineVoce + 1u);
        }
        if (_pagineVoce < 0) { _pagineVoce = 0; }
        if (_pagineVoce >= 2) { _pagineVoce = 1; }
        if (!(PAD(0, 0x48) & 0x4008)) { goto aggiorna; }
        SUONO(0x192);
        _pagineRiepilogo = 0;
        _paginePad = 0;
        _gameFlags &= 0xffffffdeu;
        goto fine;

    case 0x2000000:
        if (_paginePadAttivo <= 0) { _pagineAttesa = 0; }
        goto aggiorna;

    default:
        _paginePad = 0;
        stato = _gameFlags;
        _pagineVoce = 0;
        _gameFlags = stato | 1;
        goto trattieni;
    }

aggiorna:
    _FUN_80080fbc();
    risultato = 1;
    goto fine;
trattieni:
    risultato = 0;
fine:
    if (_gameMode & 0x1000) { _FUN_80082d90(risultato); }
uscita:
    if (risultato == 0) { _FUN_80080fbc(); }
    return risultato;
}
