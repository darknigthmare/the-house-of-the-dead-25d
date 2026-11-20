"""Prépare la version navigateur avec le moteur web déjà fourni dans le dépôt."""
from pathlib import Path
from shutil import copy2
import re
import sys

from assembler import ROOT, main as assembler


def main():
    runtime = ROOT.parents[3] / "build" / "web"
    if not (runtime / "index.wasm").is_file():
        sys.exit("Le moteur web est dans build/web. Exécutez ce script depuis une copie complète du dépôt.")
    assembler()
    source_pack = ROOT / "HOTD_Anthologie.pck"
    site = ROOT / "site"
    site.mkdir(exist_ok=True)
    for path in runtime.glob("index.*"):
        if path.suffix not in {".pck", ".html"}:
            copy2(path, site / path.name)
    copy2(source_pack, site / "index.pck")
    page = (runtime / "index.html").read_text(encoding="utf-8")
    page = re.sub(r'"index.pck":\d+', f'"index.pck":{source_pack.stat().st_size}', page)
    page = page.replace("The House of the Dead 2.5D", "Dossier Curien")
    page = page.replace("Original fan-made 2.5D rail-shooter remake project.", "Dossier Curien, anthologie de combat de la saga.")
    (site / "index.html").write_text(page, encoding="utf-8")
    print("La version navigateur est prête. Lancez python3 Jouer.py ou ouvrez Jouer-Windows.cmd.")


if __name__ == "__main__":
    main()
