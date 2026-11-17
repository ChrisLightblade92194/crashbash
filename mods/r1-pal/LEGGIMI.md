# R1 PAL — P2a

Port parziale SCES-02834: cinque scritture, 88 byte in totale. Non comprende
menu, gesti dei boss, suoni o skin. Le copie provengono da `r1-fixed` al commit
`7db60ceee82d7f7c6b61848da09789c4faa8d6dc` del sottomodulo; nessun include USA.

| Voce | Sezione PAL | Intervallo RAM, fine esclusiva | Byte |
| ---: | --- | --- | ---: |
| 1 | exe | `0x80033ac8–0x80033adc` | 20 |
| 2 | ball, DAT 1085 | `0x800bb76c–0x800bb778` | 12 |
| 59 | engine, DAT 1348 | `0x8008f4f0–0x8008f50c` | 28 |
| 60 | ovl1089 | `0x800bf0d4–0x800bf0d8` | 4 |
| 61 | ovl1089 | `0x800bf148–0x800bf160` | 24 |

Le voci 60 e 61 sono inseparabili. Nessuna delle cinque patch introduce una
costante temporale. I timer PAL circostanti restano quelli originali.

Build dalla radice del repository, con il Python del venv della toolchain:

```powershell
& $py -I tools/build.py --mod r1-pal --regione pal --gioco crashbash-pal
```

`Makefile` e `overlay.ld` sono anche rigenerati dal mod-builder; i percorsi
assoluti generati appartengono a questo worktree. `.gitignore` locale permette
di consegnarli, in deroga all'esclusione generale del sottomodulo. La build
non richiede modifiche a `config.json`, `disc.json` o agli strumenti USA.

Prove degli indirizzi e limiti: `docs/evidence/pal-r1/p2a/LEGGIMI.md` nella
radice principale. `patch.json` contiene gli hash **attesi** dei cinque
compilati: non costituiscono un'attestazione di compilazione riuscita.
La sonda `tools/redux/sonda_pal_r1.py` li confronta con i binari effettivi.

Il marcatore riserva i primi 20 byte di DrawSyncCallback. P2b/P2c devono
rispettare questo intervallo: la coda candidata comincia a `0x80033adc`.
Per avviare l'ISO costruita, copiare il SBI omonimo accanto alla sua CUE
in `game/build/`. Il compito di P2a non certifica avvio a freddo o letture DAT.
