#ifndef BALL_EXTERN_H
#define BALL_EXTERN_H

#include <types.h>
#include <player.h>
#include <entity.h>
#include "coll.h"
#include "ball.h"

/* Variables */
extern s32 (* _Ball_Func_Ball_onCollide_World(Object * pBall, s32 ballAngle));
extern PillarObj _Ball_pillarObj[4];
extern PillarData _Ball_pillarData;
extern u16 _Ball_activeWalls;
extern s16 _Ball_playerSpeedCopy[NUM_PLAYERS];
extern s16 _Ball_defaultChallengeQuality;
extern u16 _Ball_unk_800c1f0c;
extern s32 _Ball_PLAYER_1_ID;
extern s32 _Ball_PLAYER_2_ID;
extern s32 _Ball_PLAYER_3_ID;
extern s32 _Ball_PLAYER_4_ID;

extern void * _Ball_unk_800c1b2c;
extern u16 _Ball_spawnCounter;
extern u16 _Ball_ballCount;
extern u16 _Ball_spawnTimer;
extern u16 _Ball_unk_800c1f0a;
extern s16 _Ball_qualityByBallCount[];
extern s32 _Ball_crystalTimer;
extern s32 _Ball_crystalIndex;
extern s32 _Ball_engineFailTimer;
extern s32 _Ball_engineFailIndex;
extern u16 _Ball_failOrderSolo[18];
extern u16 _Ball_failOrderCoop[18];
extern u16 _Ball_engineSounds[4];
extern u8 _Ball_engineSoundHandle[];
extern SkyEngine _Ball_skyEngines[4];
extern u16 _unk_8009e25c;

/* Functions */
s32 _FUN_80015590(s32 max);                /* numero casuale in [0, max) */
EntityLinkedList * _FUN_80022a3c(s32 a0, s32 a1, s32 a2, s32 a3, s32 a4);
void _FUN_80022660(s32 sound, void * handle, s32 a2, s32 a3, s32 a4, s32 a5);
void _FUN_800bd770(void);

#endif