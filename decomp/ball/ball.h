#ifndef BALL_H
#define BALL_H

typedef enum BallState
{
    BALLSTATE_INIT   = 0,
    BALLSTATE_PLAY   = 1,
    BALLSTATE_LAUNCH = 6,
    BALLSTATE_AIR    = 8,
    BALLSTATE_SPAWN  = 12,
    BALLSTATE_SCORED = 17,
    BALLSTATE_DELETE = 18,
} BallState;


#define NUM_SKY_ENGINES      4
#define ENGINE_FAIL_ORDER    18             /* voci delle tabelle dei guasti di Sky Balls */
#define ENGINE_STATE_FAILING 1

/* Motore che regge un angolo della pedana di Sky Balls (0x800c1e78, passo 28), aggiornato da 0x800bd510 */
typedef struct SkyEngine
{
    s32 height;     /* abbassamento dell'angolo (negativo = giu') */
    s32 speed;
    s32 maxSpeed;
    s32 accelUp;
    s32 accelDown;
    s32 direction;
    u16 state;      /* 0 fermo, 1 guasto, 2 ripartenza, 3 assestamento */
    u16 timer;
} SkyEngine;

#endif