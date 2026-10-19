#include <types.h>
#include <screen.h>

/* M2-L7, mod usa e getta: salta l'intro. Il resto dell'avvio (init della schermata dell'intro nel modulo del
   front-end: caricamenti e musica) resta invariato. Topic: docs/wiki/topics/menu-e-avvio.md */

void _Intro_Init(void);

void SaltaIntro_Init(void)
{
    _Intro_Init();
    /* Nessuna voce da mostrare: al primo update Intro_Update torna alla schermata di caricamento (flag 0x12),
       che prosegue verso il menu come dopo la quarta voce. */
    _introIndex = 4;
}
