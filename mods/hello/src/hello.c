/*
    Hello mod (M1-L3): a ogni frame sposta l'immagine di 16 pixel verso sinistra.

    La funzione di fine frame del gioco (0x800272ac) costruisce una DISPENV e la passa
    a PutDispEnv (jal a 0x80027390). L'hook dirotta quella jal su Hello_PutDispEnv, che
    aumenta di HELLO_DX la colonna di VRAM da cui parte l'area visualizzata e poi chiama
    la PutDispEnv originale: il risultato è l'intera immagine spostata a sinistra.
    Il codice vive nel corpo di DrawOTagEnv (0x8002f48c, 216 byte), funzione di libreria
    mai chiamata dal gioco (0 riferimenti nell'EXE e in CRASHBSH.DAT).
*/
#include <types.h>

typedef struct { s16 x, y, w, h; } HelloRect;
typedef struct
{
    HelloRect disp;     /* area di VRAM mostrata a schermo */
    HelloRect screen;   /* posizione sullo schermo */
    u8 isinter;
    u8 isrgb24;
    u8 pad[2];
} HelloDispEnv;

/* PutDispEnv del gioco (0x8002f598), risolta da symbols/functions.txt */
extern void _PutDispEnv(HelloDispEnv * env);

#define HELLO_DX 16

/* Frame passati dall'hook: leggibile via web server di Redux per provare che gira ogni frame. */
int hello_frames = 0;

void Hello_PutDispEnv(HelloDispEnv * env)
{
    env->disp.x += HELLO_DX;
    hello_frames++;
    _PutDispEnv(env);
}
