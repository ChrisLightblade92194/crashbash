#include <types.h>
#include <controller.h>
#include <screen.h>

/* M2-L7, mod usa e getta: selezione rapida del minigioco per numero. Topic: docs/wiki/topics/menu-e-avvio.md */

extern u32 _levelID;
extern u16 _minigameMode;
extern ScreenManager _frontEndScreens;     /* 0x8009f8a4: schermate del menu */
extern Screen _menuSelectGameType;         /* 0x800b8e28, modulo 722 */
void FrontEnd_CheckLeave(void);

/* Livello da avviare: indice della tabella 0x8004ddd0 (0x0e = Ballistix). Si cambia scrivendo in RAM
   all'indirizzo del simbolo nel debug/redux.map del mod. */
s32 SelezioneRapida_livello = 0x0e;

void SelezioneRapida_CheckLeave(void)
{
    if (*(s16 *) &_levelID == 0x28 && _frontEndScreens.current == &_menuSelectGameType &&
        (_buttonsPressedP1 & BTN_SELECT) && !(_gameMode & 0x8000))
    {
        /* Come il menu alla fine delle opzioni di Battle Mode: tipo Battle, livello scelto, modo 0x8008 */
        _nextLevel = SelezioneRapida_livello;
        _minigameMode = (_minigameMode & 0xff00) | 1;
        _gameMode = 0x8008;
    }
    FrontEnd_CheckLeave();
}
