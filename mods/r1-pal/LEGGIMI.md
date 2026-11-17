# R1 PAL — P2a/P2b1 chiusi, P2b2 predisposto

Port parziale SCES-02834: 22 scritture, 1472 byte verificati dalla regia. P2a resta composto
da cinque compilati per 88 byte, con gli stessi hash. P2b1 aggiunge le voci
5-9 per 472 byte: pagine e ripeti, chiusi dalla regia il 2026-11-17
(rapporto `docs/evidence/pal-r1/p2b1/LEGGIMI.md`). P2b2 aggiunge le voci
47-58 per 912 byte. La regia ha verificato build riproducibile (`8268a045…`),
22 compilati conformi al manifesto e `verifica_iso` con exit 0. Codex non ha
eseguito la build; i compilati sono presenti e i loro hash sono stati riletti.
Le correzioni degli oracoli dopo la review richiedono nuovi test e prove dinamiche.
Le copie provengono da `r1-fixed` al commit
`7db60ceee82d7f7c6b61848da09789c4faa8d6dc`, salvo `ripeti/ripeti.s` dalla RC3
`785bec466601d937b5306357409bee0fcc6ec4de`. Le dodici voci P2b2 provengono
da `418a3f8561774df5de192848cefb12ee736d50b0` (L28). Nessun include USA.

| Voce | Sezione PAL | Intervallo RAM, fine esclusiva | Byte |
| ---: | --- | --- | ---: |
| 1 | exe | `0x80033ac8–0x80033adc` | 20 |
| 2 | ball, DAT 1085 | `0x800bb76c–0x800bb778` | 12 |
| 5 | exe | `0x8003f2e0–0x8003f324` | 68 |
| 6 | engine, DAT 1348 | `0x8008469c–0x800846a4` | 8 |
| 7 | engine, DAT 1348 | `0x80081020–0x80081024` | 4 |
| 8 | exe | `0x800362dc–0x8003645c` | 384 |
| 9 | engine, DAT 1348 | `0x8008f768–0x8008f770` | 8 |
| 47 | exe | `0x80049d54–0x80049e20` | 204 |
| 48 | ovl1083 | `0x800b8e78–0x800b8e7c` | 4 |
| 49 | ovl1083 | `0x800b89c4–0x800b89c8` | 4 |
| 50 | ovl1083 | `0x800b8a94–0x800b8a98` | 4 |
| 51 | ovl1083 | `0x800b8fd4–0x800b8fd8` | 4 |
| 52 | exe | `0x80049e74–0x80049eb0` | 60 |
| 53 | exe | `0x80049edc–0x80049fbc` | 224 |
| 54 | exe | `0x8004a188–0x8004a228` | 160 |
| 55 | exe | `0x80049e20–0x80049e74` | 84 |
| 56 | exe | `0x80037f18–0x80037f90` | 120 |
| 57 | exe | `0x8003646c–0x80036494` | 40 |
| 58 | ovl1083 | `0x800b54e4–0x800b54e8` | 4 |
| 59 | engine, DAT 1348 | `0x8008f4f0–0x8008f50c` | 28 |
| 60 | ovl1089 | `0x800bf0d4–0x800bf0d8` | 4 |
| 61 | ovl1089 | `0x800bf148–0x800bf160` | 24 |

Le voci 60 e 61 sono inseparabili. Nessuna delle 22 patch introduce una
costante temporale. I timer PAL circostanti restano quelli originali.

Build dalla radice del repository, con il Python del venv della toolchain:

```powershell
& $py -I tools/build.py --mod r1-pal --regione pal --gioco crashbash-pal
```

`Makefile` e `overlay.ld` sono rigenerati dal mod-builder; le copie locali
ignorate da Git sono rigenerate durante la build delle 22 voci. La build
non richiede modifiche a `config.json`, `disc.json` o agli strumenti USA.

Prove degli indirizzi e limiti: `docs/evidence/pal-r1/p2a/LEGGIMI.md` nella
radice principale. `p2a/patch.json` e' ora il manifesto cumulativo con la
provenienza per voce. La regia ha confrontato gli hash attesi dalle codifiche
MIPS con tutti i binari effettivi; la sonda `tools/redux/sonda_pal_r1.py`
ripete il controllo prima del banco.

Il marcatore riserva i primi 20 byte di DrawSyncCallback. P2b/P2c devono
rispettare questo intervallo: la coda candidata comincia a `0x80033adc`.
Per avviare l'ISO costruita, l'orchestratore copia ISO, CUE e SBI omonimo
in una cartella esterna al repository. Le prove predisposte per 5-9 iniettano
in RAM da savestate SBI; non certificano avvio a freddo o letture DAT.

Le voci intro 3-4 sono sospese: la PAL ha le callback nel modulo menu 1083
e passa poi alla scelta della lingua. P2b2 aggiunge gli innesti 48-51 e 58
nel modulo 1083; nessuna voce P2c e' attivata. `ripeti_skin_inattive` e' un alias della
parola skin nello snapshot RC3 azzerato: P2c dovra' collegare la vera variabile
`skin_scelta`. Dettagli, mappa e prove in `docs/evidence/pal-r1/p2b1/`.

Per P2b2, `p2b2_skin_inattive` a `0x8004a224` e' una parola aggiunta alla
voce 54, nella sede assegnata; casuale e boss la azzerano. P2c dovra'
sostituire entrambi gli accessi con la vera variabile PAL. I dieci sorgenti
precedenti e le rispettive registrazioni del manifesto restano invariati.
Sedi, prove per ogni assoluto, mutazioni e piano entro 45 minuti sono in
`docs/evidence/pal-r1/p2b2/`. La scritta del controllo 50 dipende dalla lingua
nel codice originale: la corsa `sblocco-it` richiede indice lingua 3 e un
giudizio visivo delle schermate. Il solo oracolo non certifica il testo disegnato.
