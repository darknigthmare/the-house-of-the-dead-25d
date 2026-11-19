"""Reconstitue et vérifie le paquet Godot 4.6 depuis les fragments fournis.

Dérivé de ../jeu/assembler.py. --output place aussi le fichier temporaire
dans le dossier de destination, sans doubler la place utilisée dans le dépôt.
"""
import argparse
from hashlib import sha256
from pathlib import Path
import json
import os
import sys
import tempfile

ROOT = Path(__file__).resolve().parent


def file_hash(path):
    digest = sha256()
    with path.open("rb") as source:
        for content in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(content)
    return digest.hexdigest()


def local_name(value):
    if not isinstance(value, str) or value in ("", ".", "..") or any(c in value for c in ("/", "\\", ":")):
        raise ValueError("Nom de fichier invalide dans le manifeste.")
    return value


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, metavar="PATH", help="Chemin du .pck à reconstruire ; son dossier doit déjà exister.")
    args = parser.parse_args()
    manifest = json.loads((ROOT / "fragments.json").read_text(encoding="utf-8"))
    destination = (args.output.expanduser() if args.output is not None else ROOT / local_name(manifest["fichier"])).absolute()
    if not destination.parent.is_dir():
        raise ValueError(f"Le dossier de destination n’existe pas : {destination.parent}")
    if destination.is_symlink() or (destination.exists() and not destination.is_file()):
        raise ValueError(f"Un autre élément existe à l’emplacement {destination}.")
    if destination.is_file():
        if destination.stat().st_size == manifest["octets"] and file_hash(destination) == manifest["sha256"]:
            print(f"Paquet déjà vérifié : {destination}")
            return
        raise ValueError(f"Un autre fichier existe à l’emplacement {destination}. Choisissez un autre chemin.")
    fd, temporary = tempfile.mkstemp(prefix=".assemblage-", dir=destination.parent)
    try:
        digest = sha256()
        total = 0
        with os.fdopen(fd, "wb") as output:
            for fragment in manifest["fragments"]:
                source = ROOT / local_name(fragment["fichier"])
                content = source.read_bytes()
                if len(content) != fragment["octets"] or sha256(content).hexdigest() != fragment["sha256"]:
                    raise ValueError(f"Fragment incomplet ou endommagé : {source.name}")
                output.write(content)
                digest.update(content)
                total += len(content)
        if total != manifest["octets"] or digest.hexdigest() != manifest["sha256"]:
            raise ValueError("La taille ou l’empreinte du paquet assemblé ne correspond pas au manifeste.")
        if destination.exists() or destination.is_symlink():
            raise ValueError(f"Un fichier vient d’apparaître à l’emplacement {destination}. Il est préservé.")
        # Publication atomique sans écrasement, même si un autre processus crée
        # la destination après le contrôle précédent. Les deux chemins sont
        # dans le même dossier ; le finally retire seulement le nom temporaire.
        os.link(temporary, destination)
    finally:
        Path(temporary).unlink(missing_ok=True)
    print(f"Paquet vérifié : {destination}")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError, TypeError) as error:
        sys.exit(str(error))
