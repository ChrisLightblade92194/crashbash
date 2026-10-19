#ifndef MODEL_H
#define MODEL_H

#include <types.h>
#include <math.h>

typedef struct VertexEncoding
{
    u8 flag;
    u8 vertexCount;
} VertexEncoding;

/* M2-L10: tipi di modello (record da 56 byte) e modelli dei personaggi.
   Strutture e misure: docs/wiki/topics/personaggi-e-texture.md */

#define MODEL_TYPE_SHARED 28                /* record 28: copia di mdl e tex del record _unk_800a00d0[_unk_8005a640] */
#define CHAR_MODEL_ENTRIES 96               /* 12 famiglie di minigiochi x 8 personaggi */
#define CHAR_VALUE_MAX 8                    /* valori dei personaggi in _unk_8005a664: 1-8 */

/* Immagine di un modello caricata in VRAM: tabella [ModelType.textures], 56 byte per immagine */
typedef struct ModelTexture
{
    u8 unk0[0x18];
    Rect rect;     /* +0x18: posizione in VRAM (x e larghezza in parole da 16 bit) */
    u16 unk20;
    u16 unk22;
    u16 tpage;     /* +0x24 */
    u16 clut;      /* +0x26: x = (clut & 0x3f) * 16, y = clut >> 6 */
    u8 uv[8];      /* +0x28: UV dei quattro angoli */
    u8 unk30[8];
} ModelTexture;

/* Record di un tipo di modello (0x80052a54, 283 record; il record 0 è vuoto) */
typedef struct ModelType
{
    void * mdlFile;                /* voce del DAT del .mdl (tabella indice 0x8004e110) */
    void * texFile;                /* voce del DAT del .tex */
    u32 unk8;
    void * mdl;                    /* +0x0c: .mdl in RAM dopo il caricamento */
    u32 unk10;
    u32 unk14;
    ModelTexture * textures;       /* +0x18: immagini in VRAM dopo il caricamento */
    u8 unk1C[0x18];
    void * arena;                  /* +0x34: parametro dell'arena scritto da _FUN_800129d0 */
} ModelType;

/* Voce della lista dei modelli dei personaggi (motore: 0x8009fa14, 16 byte) */
typedef struct CharModelEntry
{
    void * files;                  /* descrittore dei file da caricare */
    ModelType * type;
    void * mdlFile;
    void * texFile;
} CharModelEntry;

/* Tabelle valore del personaggio -> record del modello (motore: 0x8009d6e8) */
typedef struct CharModelTables
{
    u32 unk0;
    u16 * primary;                 /* indice = valore 1-8 */
    u16 * secondary;               /* secondo modello per personaggio, oppure nullptr */
} CharModelTables;

/* Funzioni dell'EXE */
void _FUN_800129d0(CharModelEntry * entry, void * arena);  /* accoda il caricamento del modello */

/* Variabili dell'EXE */
extern ModelType _modelTypes[];             /* 0x80052a54 */
extern u8 * _arenaVariants;                 /* 0x8005a5e8: record da 32 byte, indice _levelVariant */

/* Variabili del motore */
extern CharModelTables _charModelTables;    /* 0x8009d6e8 */
extern CharModelEntry _charModelEntries[];  /* 0x8009fa14 */
extern u16 _unk_800a00d0[];                 /* record da copiare nel record 28, indice _unk_8005a640 */

#endif
