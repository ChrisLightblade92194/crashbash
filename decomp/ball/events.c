#include <types.h>
#include <player.h>
#include <entity.h>
#include <extern.h>
#include <screen.h>
#include <level.h>
#include <minigame.h>
#include "ball.h"
#include "ball_extern.h"

#define BALL_SPAWN_DELAY     30
#define BALL_LIST_MAX        9
#define FLAGS_OUT_OF_GAME    0xfa00

/*
    @brief: Guasto del motore di Sky Balls (M2-L13): mette il motore nello stato 1 (l'angolo della pedana
            scende) per 60-89 aggiornamenti e suona il guasto. L'unica chiamata e' Ball_UpdateEvents.
    @address: 0x800bd43c
    @params:
        @engine: indice 0-3 del motore, dalle tabelle _Ball_failOrderSolo/_Ball_failOrderCoop
*/
void SkyBalls_FailEngine(u32 engine)
{
    s16 timer = _FUN_80015590(30);
    SkyEngine * pEngine = &_Ball_skyEngines[engine & 0xffff];
    pEngine->timer = timer + 60;
    pEngine->state = ENGINE_STATE_FAILING;
    pEngine->accelDown = 0xa0;
    pEngine->maxSpeed = 0x300;
    pEngine->speed = 0;
    pEngine->accelUp = 0;
    pEngine->direction = -1;
    _FUN_80022660(0x5c9, _Ball_engineSoundHandle, 0, 0x1000, 0x1e00, 0);
    _FUN_80022660(_Ball_engineSounds[_FUN_80015590(4)], nullptr, 0, 0x1000, 0x1e00, 0);
}

/*
    @brief: Eventi a tempo delle quattro arene di Ballistix (M2-L13), una volta per aggiornamento fuori
            da pausa e fine partita: in N. Ballism il rilancio quando nessun giocatore ha il campo +0x58;
            in Crashball un oggetto casuale (1 su 15); in tutte le arene una palla nuova ogni 30
            aggiornamenti finche' le palle in gioco sono meno di 1 + _Ball_spawnCounter / 300 (al massimo
            4 in Beach Ball, 5 altrove; 0 se l'oggetto _Ball_unk_800c1b2c ha il campo +0x1a); nella sfida
            del cristallo di Beach Ball un evento sul giocatore scelto dalle tabelle; in Sky Balls il guasto
            di un motore scelto dalle stesse tabelle ogni 270-510 aggiornamenti. Le tabelle contengono
            solo i giocatori/motori 1-3 (2-3 in co-op): il motore 0 non si guasta mai (bug B-001).
    @address: 0x800bc0d8
*/
void Ball_UpdateEvents(void)
{
    if (_gameMode & 0x801) { return; }

    u32 frozen = false;
    if (_Ball_unk_800c1b2c) { frozen = *(u16 *)((u8 *) _Ball_unk_800c1b2c + 0x1a) != 0; }

    if ((LEVEL_ID == LEVELID_N_BALLISM) && (_unk_8009e25c == 0))
    {
        if (_Ball_unk_800c1f0a != 0) { _Ball_unk_800c1f0a--; }
        else
        {
            s32 active = 0;
            for (s32 i = 0; i < NUM_PLAYERS; i++)
            {
                if (*(u16 *)((u8 *) &_playerMetadata[i] + 0x58)) { active++; }
            }
            if (active == 0)
            {
                _FUN_800bd770();
                _Ball_unk_800c1f0a = _FUN_80015590(90) + 30;
            }
        }
    }

    if ((LEVEL_ID == LEVELID_CRASHBALL) && (_FUN_80015590(15) == 0))
    {
        s32 x = _FUN_80015590(0x1800) - 0xc00;
        s32 y = -(_FUN_80015590(0x200) + 0x80);
        s32 z = _FUN_80015590(0x800) + 0x1000;
        _FUN_80022a3c(x, y, z, 0x1504, 17);
    }

    if (_Ball_spawnTimer != 0) { _Ball_spawnTimer--; }
    else
    {
        _Ball_spawnCounter++;
        s32 maxBalls = (u16) (_Ball_spawnCounter / 300) + 1;
        if (LEVEL_ID == LEVELID_BEACH_BALL)
        {
            if (maxBalls > 4) { maxBalls = 4; }
        }
        else if (maxBalls > 5) { maxBalls = 5; }
        if (frozen) { maxBalls = 0; }
        _Ball_ballCount = 0;
        for (EntityLinkedList * p = _pBallLinkedList; p; p = p->next) { _Ball_ballCount++; }
        if ((s32) _Ball_ballCount < maxBalls)
        {
            s32 balls = 0;
            for (EntityLinkedList * p = _pBallLinkedList; p; p = p->next) { balls++; }
            if (balls < BALL_LIST_MAX)
            {
                EntityLinkedList * pBall = _FUN_80022a3c(0x1000, 0x1000, 0x1000, 0x1501, 17);
                if ((pBall) && (pBall->pEntityObject) && (pBall->pEntity))
                {
                    *(u16 *)((u8 *) pBall->pEntity + 0x1a) = 0;
                }
            }
            _Ball_spawnTimer = BALL_SPAWN_DELAY;
        }
    }
    _Ball_defaultChallengeQuality = _Ball_qualityByBallCount[_Ball_ballCount];

    if ((LEVEL_ID == LEVELID_BEACH_BALL) && (_minigameMode & MODE_CRYSTAL))
    {
        if (_Ball_crystalTimer != 0) { _Ball_crystalTimer--; }
        else
        {
            _Ball_crystalIndex++;
            if (_Ball_crystalIndex >= ENGINE_FAIL_ORDER) { _Ball_crystalIndex = 0; }
            u16 * order = (_playersCampaign != SOLO) ? _Ball_failOrderCoop : _Ball_failOrderSolo;
            u32 player = order[_Ball_crystalIndex];
            if ((_playerMetadata[player].flags & FLAGS_OUT_OF_GAME) == 0)
            {
                _FUN_80022a3c(player, 0, 0, 0x1509, 17);
            }
            _Ball_crystalTimer = _FUN_80015590(6) * 30 + 90;
        }
    }

    if (LEVEL_ID == LEVELID_SKY_BALLS)
    {
        if (_Ball_unk_800c1f0c != 0) { _Ball_unk_800c1f0c--; }
        if (_Ball_engineFailTimer != 0) { _Ball_engineFailTimer--; }
        else
        {
            _Ball_engineFailIndex++;
            if (_Ball_engineFailIndex >= ENGINE_FAIL_ORDER) { _Ball_engineFailIndex = 0; }
            u16 * order = (_playersCampaign != SOLO) ? _Ball_failOrderCoop : _Ball_failOrderSolo;
            SkyBalls_FailEngine(order[_Ball_engineFailIndex]);
            _Ball_engineFailTimer = _FUN_80015590(9) * 30 + 270;
        }
    }
}
