#include <types.h>
#include <gpu.h>
#include <screen.h>

/* M2-L7: stati di primo livello e gestore delle schermate (EXE). Mappa e ruoli: docs/wiki/topics/menu-e-avvio.md */

#define POOL_END 0x801ff000

/*
    @brief: Crea il pool dopo l'EXE, carica il motore (voce 991 del DAT) a 0x80078c90 ed esegue i suoi stati
    @address: 0x80010158
    @note: non agganciata né verificata dal banco: eccezione in docs/notes/m2-eccezioni-decomp.md (M2-L7)
*/
void Boot_LoadEngine(void)
{
    _endFrameMode = 2;
    _FUN_80011bf8(_mainPool, (u32) &_engineHeader, POOL_END - (u32) &_engineHeader);
    _FUN_80012e90();
    _FUN_80013ca4();
    _FUN_800138a4();
    _LoadFile(_engineFile, &_engineHeader);
    _pOverlayHeader = &_engineHeader;
    _StateMachine_Run(&_stateEngine);
}

/*
    @brief: Esegue gli stati di primo livello: init una volta, poi update e draw finché _currentState non cambia
    @address: 0x800270f0
    @params:
        @state: primo stato (main lo chiama con lo stato del motore 0x8004e0b8)
*/
void StateMachine_Run(State * state)
{
    while (state)
    {
        _currentState = state;
        state->init();
        while (_currentState == state)
        {
            state->update();
            state->draw();
        }
        state = _currentState;
    }
}

/*
    @brief: Init dello stato del motore: pool dal fondo del binario caricato, poi init del binario
    @address: 0x80010410
*/
void EngineState_Init(void)
{
    u32 heapStart = _pOverlayHeader->heapStart;
    if (heapStart)
    {
        _FUN_80011bf8(_mainPool, heapStart, POOL_END - heapStart);
        _FUN_80012e54();
    }
    _FUN_800222fc();
    _FUN_800237bc();
    _pOverlayHeader->init();
}

/*
    @brief: Update dello stato del motore: servizi di sistema, poi update del binario caricato
    @address: 0x80010394
*/
void EngineState_Update(void)
{
    _FUN_8001231c();
    _FUN_800138a4();
    _FUN_800155fc();
    _FUN_80022838();
    _FUN_8002bea8();
    if (!(_frameBufferIndex & 1)) { _FUN_8002d274(); }
    _pOverlayHeader->update();
}

/*
    @brief: Inizializza un gestore di schermate con la schermata corrente
    @address: 0x8001e934
*/
void Screen_Init(ScreenManager * manager, Screen * screen)
{
    manager->current = screen;
    manager->next = nullptr;
    manager->previous = nullptr;
    manager->flags = 0;
}

/*
    @brief: Avvia una dissolvenza (passo > 0 verso il nero, < 0 dal nero)
    @address: 0x8001e588
*/
void Fade_Start(Fade * fade, s32 step, s32 flags)
{
    fade->step = step;
    fade->flags = flags;
    fade->count = 0;
}

/*
    @brief: Avanza la dissolvenza; a fine corsa conta i frame e, verso lo 0, la ferma dopo 3
    @address: 0x8001e598
    @return: livello della dissolvenza (0..0x1000)
*/
s32 Fade_Update(Fade * fade)
{
    s32 step = fade->step;
    if (step)
    {
        s32 level = fade->level + step;
        fade->level = level;
        if (step > 0)
        {
            if (level >= 0x1000)
            {
                fade->level = 0x1000;
                fade->count++;
            }
        }
        else if (level <= 0)
        {
            fade->level = 0;
            fade->count++;
            if (fade->count >= 3) { fade->step = 0; }
        }
    }
    return fade->level;
}

/*
    @brief: Cambia schermata quando la dissolvenza è finita (exit, init, pool) ed esegue l'update della corrente
    @address: 0x8001e610
*/
void Screen_Update(ScreenManager * manager, Fade * fade)
{
    if (manager->next && fade && (!fade->step || fade->count >= 3))
    {
        Screen * current = manager->current;
        if (current)
        {
            if (!(manager->flags & SCREEN_SKIP_EXIT) && current->exit) { current->exit(); }
            if (fade && fade->step && fade->count >= 3)
            {
                _FUN_8001888c();
                while (_FUN_80011db4(_mainPool)) { }
                _FUN_80010ae8(_mainPool);
            }
        }
        Screen * next = manager->next;
        current = manager->current;
        manager->next = nullptr;
        manager->current = next;
        manager->previous = current;
        if (next->heapStart)
        {
            _FUN_8002ac70();
            while (_FUN_80012ffc())
            {
                _FUN_8001231c();
                _FUN_80010ae8(_mainPool);
                _FUN_8002bae8();
            }
            u32 heapStart = manager->current->heapStart;
            _FUN_80011bf8(_mainPool, heapStart, POOL_END - heapStart);
            _FUN_80012e54();
        }
        _gameMode &= 0xfffe;
        u32 flags = manager->flags;
        if (!(flags & SCREEN_SKIP_INIT))
        {
            if (flags & SCREEN_FLAGS_ONCE) { manager->flags = 0; }
            if (manager->current->init) { manager->current->init(); }
        }
        else if (flags & SCREEN_FLAGS_ONCE) { manager->flags = 0; }
    }
    if (manager->current && !(manager->flags & SCREEN_SKIP_UPDATE) && manager->current->update)
    {
        manager->current->update();
    }
}

/*
    @brief: Esegue il draw della schermata corrente
    @address: 0x8001e898
*/
void Screen_Draw(ScreenManager * manager)
{
    if (manager && manager->current && manager->current->draw && !(manager->flags & SCREEN_SKIP_DRAW))
    {
        manager->current->draw();
    }
}

/*
    @brief: Esegue l'exit della schermata corrente
    @address: 0x8001e854
*/
void Screen_Exit(ScreenManager * manager)
{
    if (manager && manager->current && manager->current->exit) { manager->current->exit(); }
}

/*
    @brief: Esegue di nuovo l'init della schermata corrente
    @address: 0x8001e8f0
*/
void Screen_CallInit(ScreenManager * manager)
{
    if (manager && manager->current && manager->current->init) { manager->current->init(); }
}
