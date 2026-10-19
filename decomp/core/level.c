#include <types.h>
#include <level.h>

/* M2-L8: metriche dell'arena e gruppi di file del livello (EXE).
   Mappa e ruoli: docs/wiki/topics/caricamento-minigiochi.md */

static LevelMetrics * Level_FindMetrics(LevelMetrics * list, s32 id)
{
    while (list != nullptr)
    {
        if (list->id == id) { return list; }
        if (list->id == METRICS_END) { return nullptr; }
        list++;
    }
    return nullptr;
}

/*
    @brief: Cerca le metriche del livello nella lista (prima per livello, poi per modulo) e le copia nelle
            variabili dell'arena; sceglie la variante normale o del cristallo. Senza voce valida stampa
            l'errore fatale e prosegue
    @address: 0x800235bc
*/
void Level_SetMetrics(LevelMetrics * list)
{
    LevelMetrics * metrics;
    s32 i;

    for (i = 0; i < 11; i++) { _unk_8005aa70[i] = 0; }

    metrics = Level_FindMetrics(list, LEVEL_ID);
    if (metrics == nullptr) { metrics = Level_FindMetrics(list, LEVEL_MODULE(LEVEL_ID)); }
    if (metrics != nullptr)
    {
        _unk_8005aa10 = metrics->unk4 + 4;
        _unk_8005aa14 = metrics->unk2 + 4;
        _unk_8005aa12 = metrics->unk2 + 4;
        _unk_8005aa50 = metrics->unk6 << 10;
        _unk_8005aa54 = metrics->unk8;
        _levelSetup = metrics->setup;
        _unk_8005a614 = metrics->unk20;
        _unk_8005a5e0 = metrics->unk12;
        if (_minigameMode & MODE_CRYSTAL) { _levelVariant = LEVEL_VARIANT_CRYSTAL(LEVEL_ID); }
        else { _levelVariant = LEVEL_VARIANT(LEVEL_ID); }
        if (_unk_8005a5e0 != 0) { return; }
    }
    _printf(_metricsErrorText, LEVEL_ID, LEVEL_MODULE(LEVEL_ID));
}

/*
    @brief: Accoda i gruppi di file del DAT del livello: quelli propri (normale o cristallo, non nel
            front-end), quelli comuni al tipo di modulo e, nei minigiochi, uno per ogni giocatore
    @address: 0x80022140
*/
void Level_QueueBanks(s32 level, s32 module)
{
    s32 i;
    u32 value;
    void * list;

    if (LEVEL_ID != LEVEL_FRONTEND)
    {
        _FUN_8002bbb4();
        if (_minigameMode & MODE_CRYSTAL) { list = _levelBanks[level].crystal; }
        else { list = _levelBanks[level].normal; }
        _FUN_8002bd0c(list);
    }

    if ((u32) (LEVEL_MODULE(LEVEL_ID) - 0x101) < 2) { list = _unk_8004e9b0; }
    else if (_minigameMode & 0x1e0) { list = _unk_8004e9b8; }
    else { list = _unk_8004e9c0; }
    _FUN_8002bd0c(list);

    module -= 0x101;
    if ((u32) module < 2) { return; }
    for (i = 0; i < 4; i++)
    {
        value = _unk_8005a664[i] - 1;
        if (value < 8) { _FUN_8002bd0c(_moduleCharBanks[module][value]); }
    }
}
