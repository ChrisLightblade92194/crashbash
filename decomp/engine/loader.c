#include <types.h>
#include <screen.h>
#include <level.h>
#include <model.h>

/* M2-L8: schermata di caricamento del livello (_screenLoader 0x800a00dc) e caricamento del modulo.
   Mappa e ruoli: docs/wiki/topics/caricamento-minigiochi.md */

#define HEAP_LEVEL_START 0x800d7144         /* pool prima del caricamento del modulo */
#define HEAP_END 0x801ff000

/*
    @brief: Carica i file del modulo del livello corrente: quello del secondo slot (se c'è) e il modulo,
            solo se diverso dall'ultimo caricato. Restituisce la fine del modulo in memoria
    @address: 0x8009317c
*/
u8 * Level_LoadModule(void)
{
    void * file;

    file = _slot2Tables[_unk_8005a640][LEVEL_MODULE(LEVEL_ID) - 0x101];
    if (file != nullptr) { _LoadFile(file, _slot2LoadAddr); }

    file = _moduleFiles[LEVEL_MODULE(LEVEL_ID) - 0x101];
    if (file != _lastModule)
    {
        _LoadFile(file, _moduleLoadAddr);
        _lastModule = file;
    }
    return _moduleLoadAddr + ((u32 *) file)[1];
}

/*
    @brief: Init del caricamento: attende il disco, ricrea il pool, carica il modulo, legge le metriche e
            prepara la scena; al primo avvio sul front-end passa subito all'intro
    @address: 0x800936c4
*/
void Loader_Init(void)
{
    u32 end;
    u32 * setup;

    _FUN_8002ac70();
    while (_FUN_80012ffc())
    {
        _FUN_8001231c();
        _FUN_80010ae8(_mainPool);
        _FUN_8002bae8();
    }
    _FUN_80011bf8(_mainPool, HEAP_LEVEL_START, HEAP_END - HEAP_LEVEL_START);
    _FUN_80012e54();

    end = ((u32) Level_LoadModule() + 7) & ~7;
    _FUN_80011bf8(_mainPool, end, HEAP_END - end);
    _FUN_80012e54();

    _Level_SetMetrics(_levelMetricsList);
    setup = _levelSetup;
    if (setup == nullptr) { setup = _levelSetupDefault; }
    _FUN_800274fc(setup);
    _FUN_800276a4((_unk_800637a8 == 0) ? _unk_8005b72c : _unk_8005b744);
    _unk_8005a674 = 0;
    _unk_8005a675 = 0;
    _FUN_80028774(setup[6], setup[7], setup[8], setup[9]);
    _FUN_80017164(&setup[3]);
    _FUN_800170d4();
    _FUN_800222fc();
    _FUN_8001d5d0();

    _loaderState = 0;
    if ((LEVEL_ID == LEVEL_FRONTEND) && _firstBoot)
    {
        _engineScreens.flags = SCREEN_FLAGS_ONCE | SCREEN_SKIP_UPDATE | SCREEN_SKIP_DRAW | SCREEN_SKIP_EXIT;
        _engineScreens.next = &_screenIntro;
    }
}

static void * Loader_Cutscene(void)
{
    if (_unk_8005a650 < 0) { return nullptr; }
    return &_modelTypes[_unk_8005a650];
}

/*
    @brief: Accoda il caricamento dei modelli dei personaggi scelti (M2-L10): per ogni giocatore con valore
            1-8 in _unk_8005a664 prende il record del modello dalle tabelle del modulo e accoda ogni voce
            della lista _charModelEntries che punta a quel record; copia nel record 28 i file del record
            _unk_800a00d0[_unk_8005a640]
    @address: 0x80093854
*/
void Loader_QueueCharacterModels(void)
{
    s32 player;
    s32 i;
    u32 value;
    void * arena;
    ModelType * shared;
    ModelType * type;

    arena = *(void **) &_arenaVariants[_levelVariant * 32 + 4];
    shared = &_modelTypes[_unk_800a00d0[_unk_8005a640]];
    _modelTypes[MODEL_TYPE_SHARED].mdlFile = shared->mdlFile;
    _modelTypes[MODEL_TYPE_SHARED].texFile = shared->texFile;

    for (player = 0; player < 4; player++)
    {
        value = _unk_8005a664[player];
        if (value - 1 >= CHAR_VALUE_MAX) { continue; }

        type = &_modelTypes[_charModelTables.primary[value]];
        for (i = 0; i < CHAR_MODEL_ENTRIES; i++)
        {
            if (_charModelEntries[i].type == type) { _FUN_800129d0(&_charModelEntries[i], arena); }
        }

        if (_charModelTables.secondary == nullptr) { continue; }
        type = &_modelTypes[_charModelTables.secondary[value]];
        for (i = 0; i < CHAR_MODEL_ENTRIES; i++)
        {
            if (_charModelEntries[i].type == type) { _FUN_800129d0(&_charModelEntries[i], arena); }
        }
    }
}

/*
    @brief: Update del caricamento: automa a stati (0x800a0158) che, a disco fermo, prepara le schermate,
            accoda e attende i file del livello e infine passa alla schermata di gioco
    @address: 0x80093be8
*/
void Loader_Update(void)
{
    u8 * source;

    if (_loaderState >= 2) { _Screen_Update(&_loaderScreens, nullptr); }
    _FUN_8002ba44();
    _FUN_80011410(_mainPool);
    if (_FUN_80012ffc() != 0) { return; }
    if (((u32 *) _mainPool)[4] != 0) { return; }

    switch (_loaderState)
    {
        case 0:
            if ((LEVEL_ID == LEVEL_FRONTEND) && !_firstBoot) { _Screen_Init(&_loaderScreens, &_loaderScreenFrontEnd); }
            else { _Screen_Init(&_loaderScreens, &_loaderScreen); }
            _Screen_Init(&_frontEndScreens, nullptr);
            _FUN_80095dbc();
            _FUN_80093588();
            _unk_8005a656 = -1;
            _unk_8005a6e0[0] = 0;
            _unk_8005a6e0[1] = 0;
            _unk_8005a6e0[2] = 0;
            _unk_8005a6e0[3] = 0;
            _loaderState = 1;
            _gameMode &= 0xfdff;
            break;

        case 1:
            _FUN_800237bc();
            _gameMode = 0;
            _gameFlags = 0;
            _FUN_80023158(_unk_8005aa50);
            _FUN_8001d640(_unk_8005aa54);
            _FUN_8001e984(32, 32);
            _Screen_CallInit(&_loaderScreens);
            _FUN_80078ca4();
            _FUN_8007a8c4();
            if ((LEVEL_ID != LEVEL_FRONTEND) || !_firstBoot) { _FUN_800229fc(LEVEL_ID); }
            if ((LEVEL_ID == LEVEL_FRONTEND) && !_firstBoot)
            {
                _FUN_8002bbb4();
                _FUN_8002bd0c(_unk_8004e998);
            }
            _Fade_Start(&_engineFade, -768, 0);
            _loaderState = 2;
            break;

        case 2:
            _FUN_8002c284(LEVEL_ID == LEVEL_FRONTEND);
            __attribute__((fallthrough)); /* prosegue nello stato 8 */
        case 8:
            Loader_QueueCharacterModels();
            _loaderState = 6;
            break;

        case 3:
            _FUN_8001def4(_unk_800a00f0, Loader_Cutscene());
            _FUN_800939fc();
            _loaderState = 4;
            break;

        case 4:
            source = *(u8 **) (_unk_80058ad0 + 16);
            _unk_8009f718[3] = source[39];
            _unk_8009f718[0] = source[36];
            _unk_8009f718[1] = source[37];
            _unk_8009f718[2] = source[38];
            _FUN_8007abc4();
            _FUN_8007a808();
            _loaderState = 7;
            break;

        case 5:
            _Level_QueueBanks(LEVEL_ID, LEVEL_MODULE(LEVEL_ID));
            _loaderState = 3;
            break;

        case 6:
            if ((LEVEL_ID != LEVEL_FRONTEND) || !_firstBoot) { _Level_QueueBanks(LEVEL_ID, LEVEL_MODULE(LEVEL_ID)); }
            _FUN_800939fc();
            _FUN_8001def4(_unk_800a00f0, Loader_Cutscene());
            _loaderState = 4;
            break;

        case 7:
            _Screen_Request(&_screenGame, 768);
            if (LEVEL_ID != LEVEL_FRONTEND) { _FUN_8002c284(-1); }
            _loaderState = 9;
            break;
    }
}

/*
    @brief: Draw del caricamento: disegna le schermate interne dallo stato 2
    @address: 0x8009407c
*/
void Loader_Draw(void)
{
    if (_loaderState >= 2) { _Screen_Draw(&_loaderScreens); }
}

/*
    @brief: Exit del caricamento: chiude le schermate interne
    @address: 0x80094058
*/
void Loader_Exit(void)
{
    _Screen_Exit(&_loaderScreens);
}
