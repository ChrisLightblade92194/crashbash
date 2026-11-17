# PAL-P3a: sezioni dati locali del podio; provenienza 418a3f8561774df5de192848cefb12ee736d50b0.
"""Avvia il mod-builder con tex132/mdl133 aggiunte soltanto in memoria.

Il primo argomento è il main.py della toolchain. Tutti gli altri sono inoltrati.
Non modifica la toolchain né il disc.json del gioco.
"""
import json
from pathlib import Path
import runpy
import sys


def estendi(disco, aggiunte):
    nuovi = {s["name"] for g in aggiunte for sezioni in g.values() for s in sezioni}
    if nuovi != {"tex132", "mdl133"} or nuovi & set(disco.df_by_name):
        raise ValueError("sezioni locali del podio duplicate o inattese")
    disco.read_data_container(aggiunte)


def main(argv) -> int:
    if not argv:
        print("Uso: build_podio.py <main.py della toolchain> [argomenti]")
        return 2
    sorgente = Path(argv[0]).resolve()
    sys.path.insert(0, str(sorgente.parent))
    # common.py del mod-builder legge sys.argv all'importazione: va impostato prima di importare disc.
    sys.argv = [str(sorgente), *argv[1:]]
    import disc
    originale = disc.Disc.__init__
    aggiunte = json.loads(Path(__file__).with_name("disc-podio.json").read_text(encoding="utf8"))
    if set(aggiunte) != {"pal"}:
        raise ValueError("disc-podio.json deve estendere soltanto PAL")
    def inizializza(self, versione):
        originale(self, versione)
        if versione == "pal":
            estendi(self, aggiunte["pal"])
    disc.Disc.__init__ = inizializza
    try:
        runpy.run_path(str(sorgente), run_name="__main__")
    finally:
        disc.Disc.__init__ = originale
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
