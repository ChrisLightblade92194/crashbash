#include <types.h>
#include <screen.h>

/* M2-L7: gestore delle schermate del motore (voce 991) e uscita dal front-end verso un livello.
   Mappa e ruoli: docs/wiki/topics/menu-e-avvio.md */

extern u32 _levelID;                       /* 0x8005a648, usato qui a 16 bit come nel gioco */
extern u16 _minigameMode;                  /* 0x8005a646: byte basso 1 Battle, 2 Tournament, 4 Adventure */
extern s16 _unk_8005a658;
extern u8 _unk_8005a660[4];
extern u8 _unk_8005a664[4];
extern u8 _unk_8005a668[4];
extern u8 _unk_8005a66c[4];
extern u8 _unk_8005a674;
extern u8 _unk_8005a79b;
extern s8 _unk_8004e0a4[];
extern u8 _cutscene_800a0858[];
extern u8 _cutscene_800a0870[];
extern u8 _cutscene_800a0888[];

#define LEVEL_ID (*(s16 *) &_levelID)
#define LEVEL_MODULE(level) (*(u16 *) &_levelTable[(level) * 6])

/*
    @brief: Chiede il cambio di schermata del motore con una dissolvenza (passo > 0 verso il nero)
    @address: 0x80092af4
*/
void Screen_Request(Screen * screen, s32 fadeStep)
{
    if (_engineScreens.next != screen)
    {
        _Fade_Start(&_engineFade, fadeStep, 0);
        _engineScreens.next = screen;
    }
}

/*
    @brief: Init del motore (intestazione 0x80078c90, campo 0): front-end, dissolvenza dal nero, primo avvio,
            prima schermata = caricamento del livello (livello 0x28 = front-end)
    @address: 0x80092bdc
*/
void Engine_Init(void)
{
    _engineScreens.current = nullptr;
    _Screen_Init(&_engineScreens, nullptr);
    _FUN_800928e8();
    _engineFade.level = 0x1000;
    _engineFade.count = 3;
    _engineFade.step = 0x100;
    _SetDispMask(1);
    _firstBoot = 1;
    Screen_Request(&_screenLoader, 0x200);
}

/*
    @brief: Update del motore (campo 1): dissolvenza e schermate
    @address: 0x80092ba0
*/
void Engine_Update(void)
{
    _Fade_Update(&_engineFade);
    _Screen_Update(&_engineScreens, &_engineFade);
}

/*
    @brief: Draw del motore (campo 2)
    @address: 0x80092b7c
*/
void Engine_Draw(void)
{
    _Screen_Draw(&_engineScreens);
}

/*
    @brief: Ogni frame della schermata di gioco: se il modo chiede l'uscita (bit 0x8000) e il conto alla
            rovescia è finito, passa alla schermata di caricamento e ferma la musica
    @address: 0x8008efd4
*/
void FrontEnd_CheckLeave(void)
{
    if (!(_gameMode & 0x8000) || _engineScreens.next) { return; }
    u16 countdown = _leaveCountdown;
    if (countdown)
    {
        countdown--;
        _leaveCountdown = countdown;
        if (countdown) { return; }
    }
    Screen_Request(&_screenLoader, 0x200);
    if (!(_gameMode & 0x200)) { _FUN_8002c284(-1); }
}

/*
    @brief: Exit della schermata di gioco: sceglie il livello successivo secondo il modo e accoda la schermata
            di caricamento (o un filmato prima di essa). Modo 0x8008: il livello in _nextLevel
    @address: 0x8008ece4
*/
void GameScreen_NextLevel(void)
{
    if (!(_gameMode & 0x8000)) { return; }
    _unk_8005a664[0] = _unk_8005a660[0];
    _unk_8005a664[1] = _unk_8005a660[1];
    _unk_8005a664[2] = _unk_8005a660[2];
    _unk_8005a664[3] = _unk_8005a660[3];
    _unk_8005a66c[0] = _unk_8005a668[0];
    _unk_8005a66c[1] = _unk_8005a668[1];
    _unk_8005a66c[2] = _unk_8005a668[2];
    _unk_8005a66c[3] = _unk_8005a668[3];
    if (_minigameMode & 0x20) { _FUN_800793e8(); }
    u16 mode = _gameMode;
    void * cutscene;
    if ((mode & 0x8008) == 0x8008)
    {
        u16 level = *(u16 *) &_nextLevel;
        LEVEL_ID = level;
        cutscene = _FUN_800951d0((s16) level);
        if (!cutscene) { goto loader; }
        goto play;
    }
    s16 level = LEVEL_ID;
    u16 module = LEVEL_MODULE(level);
    if (module == 0x101) { return; }
    if (module == 0x102)
    {
        if (level == 43) { LEVEL_ID = 40; }
        else if (mode == 0x8002) { LEVEL_ID = _FUN_8008ef70(); }
        else { LEVEL_ID = *(u16 *) &_nextLevel; }
        goto loader;
    }
    if (mode & 0x200)
    {
        _engineScreens.next = &_screenGame;
        return;
    }
    if (level == 31)
    {
        if (!_unk_8005a79b || !(mode & 1))
        {
            LEVEL_ID = _FUN_8008ef70();
            return;
        }
        if (_unk_8005a658 == 3)
        {
            LEVEL_ID = 32;
            cutscene = _cutscene_800a0888;
        }
        else if (_unk_8005a658 == 1)
        {
            LEVEL_ID = 37;
            cutscene = _cutscene_800a0858;
        }
        else
        {
            LEVEL_ID = 37;
            cutscene = _cutscene_800a0870;
        }
        goto play;
    }
    if (level == 32)
    {
        LEVEL_ID = 37;
        cutscene = (_unk_8004e0a4[_unk_8005a674] == 1) ? _cutscene_800a0858 : _cutscene_800a0870;
        goto play;
    }
    u8 type = *(u8 *) &_minigameMode;
    if (type == 1) { LEVEL_ID = 41; }
    else if (type == 2) { LEVEL_ID = (_gameMode & 1) ? _FUN_8008ff94() : 42; }
    else { LEVEL_ID = _FUN_8008ef70(); }
loader:
    _engineScreens.next = &_screenLoader;
    return;
play:
    _FUN_80094d88(cutscene, &_screenLoader);
}
