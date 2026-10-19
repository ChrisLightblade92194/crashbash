#ifndef SCREEN_H
#define SCREEN_H

#include <types.h>
#include <math.h>

/* M2-L7: stati di primo livello, schermate del motore e dissolvenza (docs/wiki/topics/menu-e-avvio.md) */

typedef void (* VoidFunc)(void);

/* Stato di primo livello eseguito da StateMachine_Run (es. 0x8004e0b8: stato del motore) */
typedef struct State
{
    VoidFunc init;
    VoidFunc update;
    VoidFunc draw;
} State;

/* Intestazione di un binario caricato (motore: 0x80078c90) e descrittore di schermata (es. 0x800a00dc) */
typedef struct Screen
{
    VoidFunc init;
    VoidFunc update;
    VoidFunc draw;
    VoidFunc exit;
    u32 heapStart; /* se diverso da 0: inizio del pool dinamico per la schermata */
} Screen;

typedef enum ScreenFlags
{
    SCREEN_SKIP_EXIT   = 0x1,  /* al cambio non chiama exit della schermata corrente */
    SCREEN_SKIP_INIT   = 0x2,  /* al cambio non chiama init della nuova schermata */
    SCREEN_SKIP_DRAW   = 0x4,
    SCREEN_SKIP_UPDATE = 0x8,
    SCREEN_FLAGS_ONCE  = 0x10, /* i flag si azzerano al cambio successivo */
} ScreenFlags;

/* Gestore delle schermate (motore: 0x8009f658; schermate del front-end: 0x8009f8a4) */
typedef struct ScreenManager
{
    Screen * current;
    Screen * next;
    Screen * previous;
    u32 flags;
} ScreenManager;

/* Dissolvenza (motore: 0x8009f644): livello 0..0x1000, passo per frame, frame a fine corsa */
typedef struct Fade
{
    s32 level;
    s32 step;
    s32 count;
    s32 flags;
} Fade;

/* Voce della sequenza dell'intro (0x8009e4c0, 4 voci da 0x28 byte) */
typedef struct IntroEntry
{
    s32 type;           /* 1 = immagine a tutto schermo, 2 = animazione */
    void * image;       /* tipo 1: descrittore del file */
    void * animation;   /* tipo 2 */
    void * animation2;
    s32 music;          /* != -1: avvia la musica */
    s32 sound[4];       /* suoni all'ingresso (-1 = nessuno) */
    s32 frames;         /* durata minima in frame */
} IntroEntry;

/* Funzioni del gioco chiamate dal C di L7 (indirizzi in symbols/functions.txt; nomi provvisori _FUN_<indirizzo>) */
void _FUN_800101e0(void);                  /* ritorno al BIOS (combinazione Start+L1+R1+Quadrato) */
void _FUN_80010ae8(void * pool);
u32  _FUN_800110a8(void * data, void * pool); /* libera un blocco del pool */
void _FUN_80011bf8(void * pool, u32 start, u32 size); /* (ri)crea il pool dinamico */
s32  _FUN_80011db4(void * pool);
void _FUN_8001231c(void);
void _FUN_80012e54(void);
s32  _FUN_80012ffc(void);                  /* != 0 finché ci sono caricamenti dal disco in corso */
void * _FUN_800133fc(void * file);         /* carica un file del DAT in un blocco del pool */
void _FUN_800138a4(void);
void _FUN_80014388(void * p);
void _FUN_800155fc(void);
void _FUN_8001612c(void * animation, s32 a1);
void _FUN_80016f54(s32 animation);
void _FUN_8001888c(void);
void * _FUN_800189f4(void * image, s32 w, s32 h);
void _FUN_80018b08(void * a0, void * a1);
void _FUN_8001d604(void);
void _FUN_8001d640(s32 a0);
void _FUN_8001e984(s32 a0, s32 a1);
void * _FUN_8001fe80(void * a0, void * a1, void * a2, void * a3, s32 a4, s32 * done);
void _FUN_80021fb0(void);
void _FUN_80022070(void);
void _FUN_800220e8(void);
void _FUN_800222fc(void);
void _FUN_80022660(s32 sound, void * handle, s32 a2, s32 a3, s32 a4, s32 a5); /* avvia un suono */
void _FUN_80022838(void);
void _FUN_800237bc(void);
void _FUN_8002ac70(void);
void _FUN_8002bae8(void);
void _FUN_8002bea8(void);
void _FUN_8002c284(s32 music);             /* avvia (>= 0) o ferma (-1) la musica */
void _FUN_8002d274(void);
void _FUN_8002d4f4(s32 a0);
void _LoadImage(Rect * rect, void * p);
s32  _DrawSync(s32 mode);
s32  _MoveImage(Rect * rect, s32 x, s32 y);
void _SetDispMask(s32 mask);

/* Variabili del gioco usate dal C di L7 (symbols/variables.txt) */
extern State * _currentState;              /* 0x8005b648 */
extern Screen * _pOverlayHeader;           /* 0x8004e0dc: intestazione del binario caricato (motore) */
extern u8 _mainPool[];                     /* 0x8004e0f0: pool dinamico */
extern u32 _frameBufferIndex;              /* 0x8005b690 */
extern u16 _gameMode;                      /* 0x8005a644: modo (0x8008 = partita dal livello in _nextLevel) */
extern u32 _frameCounter;                  /* 0x8004e0d8 */
extern s32 _endFrameMode;                  /* 0x8004e0e0: argomento della fine frame */
extern u32 _buttonsHeldP1;                 /* 0x8005137c */
extern u32 _buttonsPressedP1;              /* 0x80051380 */
extern s32 _firstBoot;                     /* 0x800590cc: 1 dall'avvio all'ingresso nel menu */

void _FUN_80012e90(void);
void _FUN_80013ca4(void);
void _LoadFile(void * file, void * destination);
void _StateMachine_Run(State * state);
extern u8 _engineFile[];                   /* 0x80050008: settore e dimensione della voce 991 */
extern Screen _engineHeader;               /* 0x80078c90: intestazione del motore (init, update, draw, exit, pool) */
extern State _stateEngine;                 /* 0x8004e0b8: stato di primo livello del motore */

/* Funzioni dell'EXE agganciate dal C di L7 (chiamate dal motore) */
void _Screen_Init(ScreenManager * manager, Screen * screen);
void _Fade_Start(Fade * fade, s32 step, s32 flags);
s32  _Fade_Update(Fade * fade);
void _Screen_Update(ScreenManager * manager, Fade * fade);
void _Screen_Draw(ScreenManager * manager);

/* Motore (voce 991 del DAT, 0x80078c90) */
void _FUN_800793e8(void);
s16  _FUN_8008ef70(void);                  /* livello di ritorno dalla tabella 0x8009edd4 */
s16  _FUN_8008ff94(void);
void _FUN_800928e8(void);                  /* init del front-end del motore */
void _FUN_8009440c(void);
void _FUN_80094d88(void * cutscene, Screen * then); /* filmato, poi la schermata then */
void * _FUN_800951d0(s32 level);           /* filmato prima del livello, o nullptr */
void _FUN_80095258(void * animation);

extern Fade _engineFade;                   /* 0x8009f644 */
extern ScreenManager _engineScreens;       /* 0x8009f658 */
extern Screen _screenLoader;               /* 0x800a00dc: schermata di caricamento del livello */
extern Screen _screenGame;                 /* 0x8009f720: schermata di gioco (esegue il modulo caricato, menu compreso) */
extern u32 _nextLevel;                     /* 0x8009e5dc: livello scelto dal menu (letto a 16 bit) */
extern u16 _leaveCountdown;                /* 0x8005a638 */
extern u8 _levelTable[];                   /* 0x8004ddd0: 6 byte per livello, u16 ID del modulo in testa */
extern IntroEntry _introEntries[5];        /* 0x8009e4c0: 4 voci; la quinta è solo il campo type letto dopo l'ultima, che cade nel buffer 0x8009e560 (come nell'originale) */
extern u32 _introIndex;                    /* 0x8009e5a4 */
extern s32 _introTimer;                    /* 0x8009e5a8 */
extern void * _introAnimHandle;            /* 0x8009e5ac */
extern s32 _introDelayedSound;             /* 0x8009e5b0 */
extern s32 _introSoundDelay;               /* 0x8009e5b4 */
extern s32 _introSoundHandles[4];          /* 0x8009e5b8 */
extern s32 _introAnimBusy;                 /* 0x800aec58 */
extern s32 _introAnim;                     /* 0x800aec5c */

#endif
