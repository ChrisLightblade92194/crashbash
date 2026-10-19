#ifndef MEMCARD_H
#define MEMCARD_H

#include <types.h>

/* M2-L12: salvataggio su memory card (EXE). Mappa del blocco e degli stati: docs/wiki/topics/salvataggi.md */

/* Immagine del blocco BASCUS-94570 (_memcardImage, 0x800655c8, 8192 byte) */
#define MC_IMAGE_SIZE 0x2000
#define MC_PROFILES 0x200          /* 4 profili da 0x194 byte, 0x800657c8 */
#define MC_PROFILE_SIZE 0x194
#define MC_PROFILE_COUNT 4
#define MC_PROFILES_END 0x850      /* fine dei profili: parola sempre a 1 (0x80065e18) */
#define MC_RESERVED 0x854          /* 8 byte a zero */
#define MC_CHECKSUM 0x85c          /* somma delle parole dei profili (0x80065e24) */

#define MC_IMAGE_U32(offset) (*(u32 *) &_memcardImage[(offset)])

/* Bit di _memcardStatus (0x800655c0) */
#define MC_STATUS_NO_FILE 0x02     /* scheda letta, nessun salvataggio */
#define MC_STATUS_LOADED 0x12      /* salvataggio letto, checksum giusta */
#define MC_STATUS_BAD_DATA 0x0a    /* lettura fallita o checksum sbagliata */
#define MC_STATUS_FILE 0x10        /* il file esiste sulla scheda */
#define MC_STATUS_SPACE 0x20       /* almeno un blocco libero */
#define MC_STATUS_ACCEPTING 0x42
#define MC_STATUS_FORMATTED 0x22
#define MC_STATUS_UNFORMATTED 0x06
#define MC_STATUS_BUSY 0x80        /* richiesta in corso */
#define MC_STATUS_ERROR 0x100

/* Valori di _memcardRequest (0x800655c4) */
#define MC_REQUEST_NONE 0
#define MC_REQUEST_SAVE 1
#define MC_REQUEST_FORMAT 2

/* Voce della directory di libmcrd (struct DIRENTRY), 40 byte */
typedef struct McDirEntry
{
    char name[20];
    s32 attr;
    s32 size;      /* +0x18 */
    struct McDirEntry * next;
    s32 head;
    char system[4];
} McDirEntry;

/* Variabili dell'EXE (symbols/variables.txt) */
extern s32 _memcardPort;              /* 0x800655b8: canale di libmcrd (0 = porta 1) */
extern s32 _memcardStatus;            /* 0x800655c0 */
extern s32 _memcardRequest;           /* 0x800655c4 */
extern u8 _memcardImage[];            /* 0x800655c8 */
extern s32 _memcardPollDelay;         /* 0x800675c8: controlli della scheda prima di eseguire una richiesta */
extern s32 _memcardState;             /* 0x800675cc: stato della macchina, 0-7 */
extern s32 _memcardFileCount;         /* 0x800675d0 */
extern McDirEntry _memcardDir[];      /* 0x800675d4, 15 voci */
extern s32 _memcardSyncCmd;           /* 0x8006782c */
extern s32 _memcardSyncResult;        /* 0x80067830 */
extern char _memcardFileName[];       /* 0x8004cdac: "BASCUS-94570" */
extern char _memcardWildcard[];       /* 0x8004cdbc: "*" */

/* Funzioni dell'EXE (symbols/functions.txt) */
void _MemCard_Update(void);
void _MemCard_PrepareSave(void);      /* 0x8002c5bc: titolo, icona e checksum dell'immagine */
s32 _MemCardSync(s32 mode, s32 * cmd, s32 * result);
s32 _MemCardExist(s32 chan);
s32 _MemCardAccept(s32 chan);
s32 _MemCardGetDirentry(s32 chan, char * name, McDirEntry * dir, s32 * files, s32 ofs, s32 max);
s32 _MemCardReadFile(s32 chan, char * name, void * adrs, s32 ofs, s32 bytes);
s32 _MemCardWriteFile(s32 chan, char * name, void * adrs, s32 ofs, s32 bytes);
s32 _MemCardCreateFile(s32 chan, char * name, s32 blocks);
s32 _MemCardFormat(s32 chan);
s32 _strcmp(const char * a, const char * b);

#endif
