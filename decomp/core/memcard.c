#include <types.h>
#include <memcard.h>

/* M2-L12: macchina a stati della memory card (EXE).
   Mappa del blocco, stati e prove: docs/wiki/topics/salvataggi.md */

/* Azzera gli 8 byte iniziali dei 4 profili e la coda dei profili, poi ricalcola la checksum
   (stesso codice ripetuto tre volte nell'originale) */
force_inline void MemCard_ClearProfiles(void)
{
    s32 i;
    s32 k;
    u32 * word;
    u32 sum;

    for (i = 0; i < MC_PROFILE_COUNT; i++)
    {
        for (k = 0; k < 8; k++) { _memcardImage[MC_PROFILES + i * MC_PROFILE_SIZE + k] = 0; }
    }
    MC_IMAGE_U32(MC_PROFILES_END) = 1;
    for (k = 7; k >= 0; k--) { _memcardImage[MC_RESERVED + k] = 0; }
    sum = 0;
    for (word = (u32 *) &_memcardImage[MC_PROFILES]; word < (u32 *) &_memcardImage[MC_PROFILES_END]; word++)
    {
        sum += *word;
    }
    MC_IMAGE_U32(MC_CHECKSUM) = sum;
}

/*
    @brief: Avanza di un passo la lettura, il salvataggio o la formattazione della scheda quando libmcrd ha
            finito il comando precedente. All'avvio legge il blocco BASCUS-94570 in _memcardImage e ne
            verifica la checksum (0x12 = caricato, 10 = dati non validi, 2 = nessun salvataggio); a riposo
            controlla la presenza della scheda; esegue le richieste di salvataggio (1) e formattazione (2)
    @address: 0x8002c97c
*/
void MemCard_Update(void)
{
    s32 i;
    s32 free;
    s32 used;
    char * found;
    McDirEntry * entry;
    u32 * word;
    u32 sum;

    if (_MemCardSync(1, &_memcardSyncCmd, &_memcardSyncResult) == 0) { return; }

    switch (_memcardState)
    {
        case 0:
            _MemCardExist(_memcardPort);
            _memcardStatus = 0;
            _memcardState = 1;
            return;

        case 1:
            if (_memcardSyncResult == 1)
            {
                _memcardState = 0;
                _memcardStatus = 0;
                return;
            }
            if (_memcardSyncResult < 2)
            {
                if (_memcardSyncResult != 0) { return; }
            }
            else if (_memcardSyncResult >= 5) { return; }
            _MemCardAccept(_memcardPort);
            _memcardStatus = MC_STATUS_ACCEPTING;
            _memcardState = 2;
            return;

        case 2:
            MemCard_ClearProfiles();
            switch ((u32) _memcardSyncResult)
            {
                case 0:
                case 3:
                    if (_MemCardGetDirentry(_memcardPort, _memcardWildcard, _memcardDir, &_memcardFileCount, 0, 15) != 0)
                    {
                        _memcardState = 0;
                    }
                    found = nullptr;
                    entry = _memcardDir;
                    for (i = _memcardFileCount - 1; i != -1; i--, entry++)
                    {
                        if (_strcmp(_memcardFileName, entry->name) == 0)
                        {
                            found = entry->name;
                            break;
                        }
                    }
                    if (found != nullptr)
                    {
                        for (word = (u32 *) _memcardImage; word < (u32 *) &_memcardImage[MC_IMAGE_SIZE]; word++) { *word = 0; }
                        _MemCardReadFile(_memcardPort, _memcardFileName, _memcardImage, 0, MC_IMAGE_SIZE);
                        _memcardState = 7;
                        return;
                    }
                    MemCard_ClearProfiles();
                    _memcardStatus = 0;
                    if (_memcardFileCount < 15)
                    {
                        used = 0;
                        entry = _memcardDir;
                        for (i = _memcardFileCount - 1; i != -1; i--, entry++) { used += entry->size; }
                        free = 0x1e000 - used;
                    }
                    else
                    {
                        free = 0;
                    }
                    if (free >= MC_IMAGE_SIZE) { _memcardStatus |= MC_STATUS_SPACE; }
                    _memcardState = 3;
                    _memcardStatus |= MC_STATUS_NO_FILE;
                    return;

                case 1:
                    _memcardState = 0;
                    _memcardStatus = 0;
                    return;

                case 2:
                    _memcardStatus = MC_STATUS_BAD_DATA;
                    _memcardState = 3;
                    return;

                case 4:
                    _memcardStatus = MC_STATUS_UNFORMATTED;
                    _memcardState = 3;
                    return;
            }
            return;

        case 3:
            if (_memcardRequest == MC_REQUEST_NONE || _memcardPollDelay != 0)
            {
                _memcardPollDelay--;
                _MemCardExist(_memcardPort);
                _memcardState = 4;
                return;
            }
            if (_memcardRequest == MC_REQUEST_SAVE)
            {
                if ((_memcardStatus & MC_STATUS_FILE) == 0 && _MemCardCreateFile(_memcardPort, _memcardFileName, 1) != 0)
                {
                    _memcardState = 6;
                    _memcardStatus |= MC_STATUS_ERROR;
                }
                if (_memcardState == 6) { return; }
                _MemCard_PrepareSave();
                _MemCardWriteFile(_memcardPort, _memcardFileName, _memcardImage, 0, MC_IMAGE_SIZE);
                _memcardState = 5;
                return;
            }
            if (_memcardRequest != MC_REQUEST_FORMAT) { return; }
            MemCard_ClearProfiles();
            if (_MemCardFormat(_memcardPort) != 0)
            {
                _memcardState = 6;
                _memcardStatus |= MC_STATUS_ERROR;
                return;
            }
            _memcardStatus = MC_STATUS_FORMATTED;
            _memcardState = 3;
            _memcardRequest = MC_REQUEST_NONE;
            return;

        case 4:
            switch ((u32) _memcardSyncResult)
            {
                case 0:
                case 2:
                case 4:
                    _memcardState = 3;
                    return;

                case 1:
                case 3:
                    _memcardStatus = 0;
                    _memcardState = 0;
                    return;
            }
            return;

        case 5:
            if (_memcardRequest != MC_REQUEST_SAVE) { return; }
            if (_memcardSyncResult == 0)
            {
                _memcardStatus = MC_STATUS_LOADED;
                _memcardState = 3;
                _memcardRequest = MC_REQUEST_NONE;
                return;
            }
            _memcardState = 6;
            _memcardStatus |= MC_STATUS_ERROR;
            return;

        case 7:
            if (_memcardSyncResult == 0)
            {
                sum = 0;
                for (word = (u32 *) &_memcardImage[MC_PROFILES]; word < (u32 *) &_memcardImage[MC_PROFILES_END]; word++)
                {
                    sum += *word;
                }
                if (MC_IMAGE_U32(MC_CHECKSUM) == sum)
                {
                    _memcardState = 3;
                    _memcardStatus = MC_STATUS_LOADED;
                    return;
                }
            }
            _memcardStatus = MC_STATUS_BAD_DATA;
            _memcardState = 3;
            return;
    }
}
