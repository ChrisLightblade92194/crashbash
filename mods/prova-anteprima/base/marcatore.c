/*
    Marcatore della Release 1 (M3-L5): l'EXE dell'ISO patchata contiene questa stringa nella sede di
    B-001 (DrawSyncCallback, 0x8002ec70, mai chiamata). Serve allo scheletro del mod: build, patch e
    regressione girano su una modifica reale dell'EXE che non cambia il gioco. Le voci della R1
    aggiungono le loro righe a buildList.txt.
*/
const char r1_marcatore[] = "crashbash-online r1";
