#ifndef LEVEL_H
#define LEVEL_H

#include <types.h>
#include <screen.h>

/* M2-L8: caricamento di un livello (modulo, metriche, gruppi di file del DAT).
   Mappa livello -> modulo -> minigioco -> arena: docs/wiki/topics/caricamento-minigiochi.md */

/* Riga di _levelTable (0x8004ddd0, 6 byte per livello) */
#define LEVEL_ID (*(s16 *) &_levelID)
#define LEVEL_MODULE(level) (*(u16 *) &_levelTable[(level) * 6])               /* ID del modulo, 0x101-0x10e */
#define LEVEL_VARIANT(level) (*(u16 *) &_levelTable[(level) * 6 + 2])          /* variante dell'arena nella partita normale */
#define LEVEL_VARIANT_CRYSTAL(level) (*(u16 *) &_levelTable[(level) * 6 + 4])  /* variante nella sfida del cristallo */

#define LEVEL_FRONTEND 40                   /* livello 0x28: TITLES (front-end, modulo 0x101) */
#define MODE_CRYSTAL 0x80                   /* bit di _minigameMode: sfida del cristallo */
#define METRICS_END 999                     /* ID che chiude la lista delle metriche */

/* Voce della lista delle metriche (motore: 0x80098f48), 24 byte; id = livello oppure ID del modulo */
typedef struct LevelMetrics
{
    u16 id;
    u16 unk2;      /* +4 in 0x8005aa12 e 0x8005aa14 */
    u16 unk4;      /* +4 in 0x8005aa10 */
    u16 unk6;      /* << 10 in 0x8005aa50 */
    u16 unk8;      /* in 0x8005aa54 */
    u16 pad;
    u32 unk12;     /* in 0x8005a5e0: se 0 la voce non è valida */
    u32 * setup;   /* in _levelSetup: parametri passati all'init della scena */
    u32 unk20;     /* in 0x8005a614 */
} LevelMetrics;

/* Gruppi di file del DAT da accodare per ogni livello (0x80058b88), 20 byte */
typedef struct LevelBanks
{
    u32 unk0;      /* letto da FUN_800229fc */
    u32 unk4;      /* s16 letto da FUN_800229fc */
    void * normal;
    void * crystal;
    u32 unk16;
} LevelBanks;

/* Funzioni dell'EXE (symbols/functions.txt) */
void _Level_SetMetrics(LevelMetrics * list);
void _Level_QueueBanks(s32 level, s32 module);
s32  _printf(char * format, ...);           /* 0x800322fc */
void _FUN_8002bbb4(void);                   /* svuota la coda dei file da caricare */
void _FUN_8002bd0c(void * list);            /* accoda una lista di voci del DAT (fino a 6) */
void _FUN_8002ba44(void);
void _FUN_80011410(void * pool);
void _FUN_80023158(s32 a0);
void _FUN_800229fc(s32 level);             /* legge _levelBanks[level] +0 e +4, poi chiama 0x8002c488 */
void _FUN_8001def4(void * a0, void * cutscene);
void _FUN_800274fc(u32 * setup);
void _FUN_800276a4(void * a0);
void _FUN_80028774(u32 a0, u32 a1, u32 a2, u32 a3);
void _FUN_80017164(u32 * a0);
void _FUN_800170d4(void);
void _FUN_8001d5d0(void);

/* Funzioni del motore */
void _FUN_80078ca4(void);
void _FUN_8007a808(void);
void _FUN_8007a8c4(void);
void _FUN_8007abc4(void);
void _FUN_80093588(void);
void _FUN_80093854(void);
void _FUN_800939fc(void);
void _FUN_80095dbc(void);
void _Screen_Request(Screen * screen, s32 fadeStep);

/* Variabili dell'EXE */
extern u32 _levelID;                        /* 0x8005a648, letto a 16 bit */
extern u16 _minigameMode;                   /* 0x8005a646 */
extern u32 _gameFlags;                      /* 0x8005a624 */
extern s32 _unk_8005a640;                   /* indice (0-3) delle tabelle 0x8009f954, tutte uguali */
extern s16 _unk_8005a650;                   /* filmato del livello (< 0: nessuno) */
extern s16 _unk_8005a656;
extern u8 _unk_8005a664[4];                 /* valore 1-8 per giocatore (forse il personaggio, non verificato) */
extern u8 _unk_8005a674;
extern u8 _unk_8005a675;
extern u8 _unk_8005a6e0[4];
extern u32 _unk_8005a5e0;
extern u32 * _levelSetup;                   /* 0x8005a5e4 */
extern u32 _unk_8005a614;
extern u32 _levelVariant;                   /* 0x8005a61c: variante dell'arena (record da 32 byte a [0x8005a5e8]) */
extern u16 _unk_8005aa10;
extern u16 _unk_8005aa12;
extern u16 _unk_8005aa14;
extern u32 _unk_8005aa50;
extern u32 _unk_8005aa54;
extern u32 _unk_8005aa70[11];
extern s32 _unk_800637a8;
extern u8 _unk_8005b72c[];
extern u8 _unk_8005b744[];
extern u8 _unk_80052a54[];                  /* record da 56 byte, indice _unk_8005a650 */
extern u8 * _unk_80058ad0;
extern LevelBanks _levelBanks[];            /* 0x80058b88, indice = livello */
extern void * _moduleCharBanks[][8];        /* 0x80058f0c, indice = modulo - 0x101, poi valore di _unk_8005a664 - 1 */
extern u8 _unk_8004e998[];                  /* lista accodata all'ingresso nel front-end */
extern u8 _unk_8004e9b0[];                  /* lista per i moduli 0x101 e 0x102 (front-end, warp room) */
extern u8 _unk_8004e9b8[];                  /* lista per i minigiochi con _minigameMode & 0x1e0 */
extern u8 _unk_8004e9c0[];                  /* lista per gli altri minigiochi */
extern char _metricsErrorText[];            /* 0x8004c8d0: "FATAL METRICS ERROR ..." */

/* Variabili del motore */
extern s32 _loaderState;                    /* 0x800a0158 */
extern ScreenManager _loaderScreens;        /* 0x800a015c */
extern Screen _loaderScreen;                /* 0x8009f998 */
extern Screen _loaderScreenFrontEnd;        /* 0x8009fa00: rientro nel front-end dopo il primo avvio */
extern Screen _screenIntro;                 /* 0x800b9524 */
extern ScreenManager _frontEndScreens;      /* 0x8009f8a4 */
extern void ** _slot2Tables[4];             /* 0x8009f954: file del secondo slot per modulo (tutte e 4 uguali) */
extern void * _moduleFiles[];               /* 0x8009f8e4: voce del DAT del modulo, indice = modulo - 0x101 */
extern u8 * _moduleLoadAddr;                /* 0x80098594 */
extern u8 * _slot2LoadAddr;                 /* 0x80098598 */
extern void * _lastModule;                  /* 0x8009f968: ultimo modulo caricato */
extern u32 _levelSetupDefault[];            /* 0x8009f96c */
extern LevelMetrics _levelMetricsList[];    /* 0x80098f48 */
extern u8 _unk_800a00f0[];
extern u8 _unk_8009f718[4];

#endif
