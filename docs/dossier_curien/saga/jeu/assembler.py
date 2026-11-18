"""Reconstitue le paquet de jeu depuis les fragments fournis avec le dépôt."""
from hashlib import sha256
from pathlib import Path
import json
import os
import sys
import tempfile

ROOT = Path(__file__).resolve().parent


def main():
    manifest = json.loads((ROOT / "fragments.json").read_text(encoding="utf-8"))
    destination = ROOT / manifest["fichier"]
    if destination.is_file():
        if sha256(destination.read_bytes()).hexdigest() == manifest["sha256"]:
            print(f"Paquet déjà vérifié : {destination}")
            return
        raise ValueError(f"Un autre fichier existe à l’emplacement {destination}.")
    fd, temporary = tempfile.mkstemp(prefix=".assemblage-", dir=ROOT)
    try:
        digest = sha256()
        with os.fdopen(fd, "wb") as output:
            for fragment in manifest["fragments"]:
                source = ROOT / fragment["fichier"]
                content = source.read_bytes()
                if len(content) != fragment["octets"] or sha256(content).hexdigest() != fragment["sha256"]:
                    raise ValueError(f"Fragment incomplet ou endommagé : {source.name}")
                output.write(content)
                digest.update(content)
        if digest.hexdigest() != manifest["sha256"]:
            raise ValueError("L’empreinte du paquet assemblé ne correspond pas au manifeste.")
        os.replace(temporary, destination)
    finally:
        Path(temporary).unlink(missing_ok=True)
    print(f"Paquet vérifié : {destination}")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError) as error:
        sys.exit(str(error))
