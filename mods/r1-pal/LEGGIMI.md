# R1 PAL — P2a e P2b1 predisposto

Port parziale SCES-02834: dieci scritture, 560 byte attesi. P2a resta composto
da cinque compilati per 88 byte, con gli stessi hash. P2b1 aggiunge le voci
5-9 per 472 byte: pagine e ripeti, ancora senza compilazione o prova dinamica.
Le copie provengono da `r1-fixed` al commit
`7db60ceee82d7f7c6b61848da09789c4faa8d6dc`, salvo `ripeti/ripeti.s` dalla RC3
`785bec466601d937b5306357409bee0fcc6ec4de`, ancora in prova. Nessun include USA.

| Voce | Sezione PAL | Intervallo RAM, fine esclusiva | Byte |
| ---: | --- | --- | ---: |
| 1 | exe | `0x80033ac8–0x80033adc` | 20 |
| 2 | ball, DAT 1085 | `0x800bb76c–0x800bb778` | 12 |
| 5 | exe | `0x8003f2e0–0x8003f324` | 68 |
| 6 | engine, DAT 1348 | `0x8008469c–0x800846a4` | 8 |
| 7 | engine, DAT 1348 | `0x80081020–0x80081024` | 4 |
| 8 | exe | `0x800362dc–0x8003645c` | 384 |
| 9 | engine, DAT 1348 | `0x8008f768–0x8008f770` | 8 |
| 59 | engine, DAT 1348 | `0x8008f4f0–0x8008f50c` | 28 |
| 60 | ovl1089 | `0x800bf0d4–0x800bf0d8` | 4 |
| 61 | ovl1089 | `0x800bf148–0x800bf160` | 24 |

Le voci 60 e 61 sono inseparabili. Nessuna delle dieci patch introduce una
costante temporale. I timer PAL circostanti restano quelli originali.

Build dalla radice del repository, con il Python del venv della toolchain:

```powershell
& $py -I tools/build.py --mod r1-pal --regione pal --gioco crashbash-pal
```

`Makefile` e `overlay.ld` sono rigenerati dal mod-builder; le copie locali
ignorate da Git sono aggiornate alle dieci voci e contengono percorsi di questo worktree. La build
non richiede modifiche a `config.json`, `disc.json` o agli strumenti USA.

Prove degli indirizzi e limiti: `docs/evidence/pal-r1/p2a/LEGGIMI.md` nella
radice principale. `p2a/patch.json` e' ora il manifesto cumulativo con la
provenienza per voce. Gli hash aggiunti per P2b1 sono **attesi** dalle codifiche
MIPS e non costituiscono un'attestazione di compilazione riuscita.
La sonda `tools/redux/sonda_pal_r1.py` li confronta con i binari effettivi.

Il marcatore riserva i primi 20 byte di DrawSyncCallback. P2b/P2c devono
rispettare questo intervallo: la coda candidata comincia a `0x80033adc`.
Per avviare l'ISO costruita, l'orchestratore copia ISO, CUE e SBI omonimo
in una cartella esterna al repository. Le prove predisposte per 5-9 iniettano
in RAM da savestate SBI; non certificano avvio a freddo o letture DAT.

Le voci intro 3-4 sono sospese: la PAL ha le callback nel modulo menu 1083
e passa poi alla scelta della lingua. Nessun innesto nuovo nel modulo 1083.
Nessuna voce P2b2 o P2c e' attivata. `ripeti_skin_inattive` e' un alias della
parola skin nello snapshot RC3 azzerato: P2c dovra' collegare la vera variabile
`skin_scelta`. Dettagli, mappa e prove in `docs/evidence/pal-r1/p2b1/`.
