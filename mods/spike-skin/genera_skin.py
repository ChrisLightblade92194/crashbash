#!/usr/bin/env python3
"""Spike di M2-L10: genera i .bin della skin di Crash (Crate Crush) dai TIM prodotti da texture_psx.

Uso:
    python -I genera_skin.py <data.tex originale> <cartella dei TIM>

La cartella dei TIM contiene crash_0.tim, crash_1.tim, crash_4.tim e crash_13.tim, prodotti con
`texture_psx.py importa` (vedi LEGGIMI.md). Lo script controlla la tex originale (voce 989 del DAT),
le dimensioni di ogni TIM e gli indirizzi della buildList, poi scrive skin/clutKK.bin (16 colori, completati con 0x0000) e
skin/imgKK.bin (pixel a 4 bpp). Nessun file viene scritto se un controllo fallisce; la cartella skin/
(ignorata da Git) si sostituisce intera solo dopo aver scritto tutti i file in una cartella temporanea.
"""

import hashlib
import os
import re
import shutil
import struct
import sys
import tempfile
from pathlib import Path

CARTELLA = Path(__file__).resolve().parent
sys.path.insert(0, str(CARTELLA.parents[2] / "tools"))
import texture_psx  # noqa: E402

TEX_SHA256 = "b8f743ba02c9a81cf6934aacc60a54882d09f344fd0723f58aed4ad5c3bcc912"
IMMAGINI = (0, 1, 4, 13)
BASE = 0x80000000                       # indirizzo della sezione tex989 in disc.json


class ErroreSkin(Exception):
    """Ingresso non valido: nessun file scritto."""


def layout(tex: bytes) -> tuple[list[int], list[tuple[int, int, int]]]:
    """Offset dei colori di ogni CLUT e (offset dei pixel, larghezza in parole, altezza) di ogni immagine."""
    immagini, clut = struct.unpack_from("<HH", tex, 8)
    p = 0x10 + struct.unpack_from("<I", tex, 0x10)[0]
    cluts = []
    for _ in range(clut):
        colori = struct.unpack_from("<I", tex, p)[0]
        cluts.append(p + 4)
        p += 4 + 2 * colori
    p = 0xC + struct.unpack_from("<I", tex, 0xC)[0]
    pixel = []
    for _ in range(immagini):
        w, h = struct.unpack_from("<HH", tex, p)
        pixel.append((p + 0x14, w, h))
        p += 0x14 + 2 * w * h
    return cluts, pixel


def righe_attese(cluts, pixel) -> list[tuple[int, str]]:
    attese = []
    for k in IMMAGINI:
        attese.append((BASE + cluts[k], f"skin/clut{k:02d}.bin"))
        attese.append((BASE + pixel[k][0], f"skin/img{k:02d}.bin"))
    return sorted(attese)


def righe_buildlist() -> list[tuple[int, str]]:
    """Tutte le righe della buildList che nominano tex989: ognuna deve avere la forma attesa, con noreload."""
    righe = []
    for numero, riga in enumerate((CARTELLA / "buildList.txt").read_text(encoding="utf-8").splitlines(), start=1):
        if riga.lstrip().startswith("//") or "tex989" not in riga:
            continue
        m = re.fullmatch(r"\s*ntsc_u noreload,\s*tex989,\s*(0x[0-9a-fA-F]+),\s*0x0,\s*(\S+)\s*", riga)
        if not m:
            raise ErroreSkin(f"buildList.txt, riga {numero}: riga tex989 non valida")
        righe.append((int(m.group(1), 16), m.group(2)))
    return sorted(righe)


def pubblica(uscite: dict[str, bytes]) -> Path:
    """Scrive i file in una cartella temporanea e la sostituisce a skin/; in caso di errore skin/ resta com'era."""
    destinazione = CARTELLA / "skin"
    nuova = Path(tempfile.mkdtemp(prefix="skin-nuova-", dir=CARTELLA))
    vecchia = CARTELLA / f"skin-vecchia-{os.getpid()}"
    try:
        for nome, dati in uscite.items():
            (nuova / nome).write_bytes(dati)
        if destinazione.exists():
            os.replace(destinazione, vecchia)
        try:
            os.replace(nuova, destinazione)
        except OSError:
            if vecchia.exists():
                os.replace(vecchia, destinazione)
            raise
    finally:
        shutil.rmtree(nuova, ignore_errors=True)
    shutil.rmtree(vecchia, ignore_errors=True)
    return destinazione


def prepara(tex: bytes, cartella_tim: Path) -> dict[str, bytes]:
    if hashlib.sha256(tex).hexdigest() != TEX_SHA256:
        raise ErroreSkin("la tex non è la voce 989 del DAT (models/chars/crate/crash/data.tex): SHA-256 diverso")
    cluts, pixel = layout(tex)
    if righe_buildlist() != righe_attese(cluts, pixel):
        raise ErroreSkin("le righe tex989 di buildList.txt non corrispondono agli offset della tex")
    uscite = {}
    for k in IMMAGINI:
        tim = texture_psx.leggi_tim((cartella_tim / f"crash_{k}.tim").read_bytes())
        _, w, h = pixel[k]
        if tim.bpp != 4 or tim.clut is None or not 1 <= len(tim.clut.colori) <= 16:
            raise ErroreSkin(f"crash_{k}.tim: serve un TIM a 4 bpp con una CLUT da 1-16 colori")
        if tim.larghezza_pixel != 4 * w or tim.altezza != h or len(tim.dati) != 2 * w * h:
            raise ErroreSkin(f"crash_{k}.tim: dimensioni {tim.larghezza_pixel}x{tim.altezza} invece di {4 * w}x{h}")
        # importa --palette-nuova scrive solo i colori usati: gli indici liberi restano 0x0000
        colori = tim.clut.colori + [0] * (16 - len(tim.clut.colori))
        uscite[f"clut{k:02d}.bin"] = struct.pack("<16H", *colori)
        uscite[f"img{k:02d}.bin"] = tim.dati
    return uscite


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        print("uso: genera_skin.py <data.tex originale> <cartella dei TIM>", file=sys.stderr)
        return 1
    try:
        uscite = prepara(Path(argv[0]).read_bytes(), Path(argv[1]))
        destinazione = pubblica(uscite)
    except (ErroreSkin, texture_psx.ErroreTexture) as exc:
        print(f"errore: {exc}", file=sys.stderr)
        return 2
    except OSError as exc:
        print(f"errore di file: {exc.filename or exc}", file=sys.stderr)
        return 2
    print(f"scritti {len(uscite)} file in {destinazione}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
