#include <types.h>
#include <screen.h>

/* M2-L7: sequenza dell'intro (scritta SCEA, loghi Universal, Eurocom, Crash Bash) nel motore, voce 991.
   La schermata 0x800b9524 del modulo del front-end chiama queste funzioni dai puntatori 0x8009e58c-0x8009e598. */

extern u8 _unk_8009e498[];
extern u8 _unk_80051640[];
extern u8 _unk_8009e560[];
extern u8 _unk_8009e580[];
extern u32 _unk_80058b64;
extern Rect * _pFrameBuffer;

/*
    @brief: Init dell'intro: prima voce, nessun timer, sfondo e suoni pronti; segna il primo avvio
    @address: 0x8008eb8c
*/
void Intro_Init(void)
{
    _introIndex = 0;
    _introTimer = 0;
    _introAnimBusy = 0;
    _introAnim = 0;
    _FUN_8001e984(0x20, 0x80);
    _introDelayedSound = -1;
    _introSoundDelay = 0;
    _FUN_8001d640(0x200);
    _FUN_80014388(_unk_80051640);
    _firstBoot = 1;
}

static void Intro_PlaySounds(IntroEntry * entry, s32 delay)
{
    _FUN_80022660(entry->sound[0], &_introSoundHandles[0], 0, 0x1000, 0x1e00, 0);
    _FUN_80022660(entry->sound[1], &_introSoundHandles[1], 0, 0x1000, 0x1e00, 0);
    _FUN_80022660(entry->sound[2], &_introSoundHandles[2], 0, 0x1000, 0x1e00, 0);
    _introSoundDelay = delay;
    _introDelayedSound = entry->sound[3];
}

/*
    @brief: Update dell'intro: a fine timer mostra la voce successiva; dopo la quarta torna alla schermata
            di caricamento senza init (flag 0x12), che prosegue verso il menu
    @address: 0x8008e5bc
*/
void Intro_Update(void)
{
    _frameCounter++;
    if ((_buttonsHeldP1 & 0x8c08) == 0x8c08) { _FUN_800101e0(); }
    _FUN_800220e8();
    if (_introSoundDelay)
    {
        _introSoundDelay--;
        if (!_introSoundDelay)
        {
            _FUN_80022660(_introDelayedSound, &_introSoundHandles[3], 0, 0x1000, 0x1e00, 0);
        }
    }
    if (_introAnimBusy) { return; }
    if (_introAnim)
    {
        _FUN_80016f54(_introAnim);
        _introAnim = 0;
    }
    if (_introIndex == 1 && _introTimer == _introEntries[0].frames) { _FUN_8002d4f4(0); }
    if (_introTimer < 0) { return; }
    _introTimer--;
    if (_introTimer > 0) { return; }
    if (_FUN_80012ffc())
    {
        _introTimer = 1;
        return;
    }
    if (_introIndex >= 4)
    {
        _engineScreens.flags = SCREEN_SKIP_INIT | SCREEN_FLAGS_ONCE;
        _engineScreens.next = &_screenLoader;
        _introTimer = -1;
        return;
    }
    IntroEntry * entry = &_introEntries[_introIndex];
    if (entry->type == 1)
    {
        _introTimer = entry->frames;
        void * file = _FUN_800133fc(entry->image);
        void * image = _FUN_800189f4(file, _pFrameBuffer[0].w, _pFrameBuffer[0].h);
        _FUN_800110a8(file, _mainPool);
        _LoadImage(&_pFrameBuffer[0], image);
        _LoadImage(&_pFrameBuffer[1], image);
        _DrawSync(0);
        _FUN_800110a8(image, _mainPool);
        entry = &_introEntries[_introIndex];
        if (entry->sound[0] != -1) { Intro_PlaySounds(entry, 6); }
    }
    else if (entry->type == 2)
    {
        _introTimer = entry->frames;
        _FUN_80095258(entry->animation);
        _unk_80058b64 = 0x10000;
        entry = &_introEntries[_introIndex];
        _endFrameMode = 2;
        _introAnimHandle = _FUN_8001fe80(entry->animation, entry->animation2, _unk_8009e560, _unk_8009e580, 4, &_introAnimBusy);
        entry = &_introEntries[_introIndex];
        if (entry->sound[0] != -1) { Intro_PlaySounds(entry, 0x16); }
        entry = &_introEntries[_introIndex];
        if (entry->music != -1) { _FUN_8002c284(entry->music); }
        if (_introAnim) { _FUN_80016f54(_introAnim); }
        _introAnim = (s32) _introEntries[_introIndex].animation;
    }
    _introIndex++;
    entry = &_introEntries[_introIndex];
    if (entry->type == 2) { _FUN_8001612c(entry->animation, 0); }
}

/*
    @brief: Draw dell'intro
    @address: 0x8008eb3c
*/
void Intro_Draw(void)
{
    _FUN_80018b08(_unk_8009e498, _unk_80051640);
    if (_introAnim) { _FUN_8009440c(); }
    _FUN_80022070();
}

/*
    @brief: Exit dell'intro: ferma l'animazione e copia il framebuffer visibile nell'altro
    @address: 0x8008eac8
*/
void Intro_Exit(void)
{
    if (_introAnim) { _FUN_80016f54(_introAnim); }
    _FUN_80021fb0();
    _FUN_8001d604();
    u32 i = _frameBufferIndex;
    _MoveImage(&_pFrameBuffer[i & 1], _pFrameBuffer[(i + 1) & 1].x, _pFrameBuffer[(i + 1) & 1].y);
}
