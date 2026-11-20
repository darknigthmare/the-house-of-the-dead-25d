"""Produit les archives locales de l'expansion, sans publication distante."""

import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import zipfile


ROOT = Path(__file__).resolve().parents[1]
ANNEX = ROOT / "docs/dossier_curien/saga/production/expansion_2026-11-19"
GAME = ROOT / "docs/dossier_curien/saga/jeu"
DEFAULT_BASE = "1586e4c9aee3fe4b20214303e1d098cff24cde5d"


def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT, text=True).strip()


def digest(path):
    result = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            result.update(chunk)
    return result.hexdigest()


def archive(destination, files):
    with zipfile.ZipFile(destination, "w", zipfile.ZIP_DEFLATED, compresslevel=6) as output:
        for source, name in sorted(files, key=lambda item: item[1]):
            output.write(source, name)
    with zipfile.ZipFile(destination) as check:
        broken = check.testzip()
        if broken:
            raise ValueError(f"Entrée ZIP endommagée : {broken}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=ROOT / "dist/dossier-curien-2026-11-19")
    parser.add_argument("--base-commit", default=DEFAULT_BASE)
    args = parser.parse_args()
    if git("status", "--porcelain"):
        raise ValueError("Enregistrez les modifications dans un commit avant de produire le reçu.")
    commit = git("rev-parse", "HEAD")
    branch = git("branch", "--show-current")
    base_commit = git("rev-parse", "--verify", args.base_commit + "^{commit}")
    subprocess.run(["git", "merge-base", "--is-ancestor", base_commit, commit], cwd=ROOT, check=True)
    catalogue = json.loads((ROOT / "data/assets/dossier_curien_expansion.json").read_text())
    fragments = json.loads((GAME / "fragments.json").read_text())
    for entry in catalogue["assets"]:
        if digest(ROOT / entry["path"]) != entry["sha256"]:
            raise ValueError(f"Ressource modifiée : {entry['path']}")
    subprocess.run([sys.executable, str(GAME / "preparer_web.py")], cwd=GAME, check=True)
    if digest(GAME / "site/index.pck") != fragments["sha256"]:
        raise ValueError("Le paquet web diffère du manifeste des fragments.")

    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    native = output / "HOTD_Anthologie_2026-11-19.pck"
    shutil.copy2(GAME / fragments["fichier"], native)
    temporary = tempfile.TemporaryDirectory(prefix="hotd-web-stage-", dir=output)
    stage = Path(temporary.name) / "HOTD_Anthologie_Linda_EX_2026-11-19_web"
    stage.mkdir()
    (stage / "site").mkdir()
    web_names = {p.name for p in (ROOT / "build/web").glob("index.*") if p.is_file() and p.suffix not in {".html", ".pck"}}
    web_names.update(("index.html", "index.pck"))
    for filename in sorted(web_names):
        shutil.copy2(GAME / "site" / filename, stage / "site" / filename)
    for filename in ("Jouer.py", "Jouer-Windows.cmd"):
        shutil.copy2(GAME / filename, stage / filename)
    for filename in ("VISUAL_QA.json", "PACK_QA.json", "CAPTURE_PROTOCOL.md", "MANQUANTS_COMPLEMENT.json", "RAPPORT.md"):
        shutil.copy2(ANNEX / filename, stage / filename)
    for directory in ("qa_native", "qa_web", "qa_logs"):
        shutil.copytree(ANNEX / directory, stage / directory)
    (stage / "LIRE_MOI.md").write_text(f"""# Dossier Curien — Linda, Zombie Revenge et EX

Version du 19 novembre 2026. Commit local : `{commit}`.

## Lancer le jeu

1. Extraire tout le ZIP, en conservant le dossier `site/`.
2. Sous Windows : ouvrir **Jouer-Windows.cmd**. Le lanceur utilise Python si disponible, sinon PowerShell.
3. Sous Linux ou macOS : ouvrir un terminal ici et lancer `python3 Jouer.py`.
4. Garder la fenêtre du lanceur ouverte. Le jeu utilise une adresse locale du navigateur.

Cette archive contient déjà le moteur web et le paquet : aucun assemblage ni installation de Godot n'est nécessaire pour ce lancement. Ne pas ouvrir `site/index.html` par double-clic ; utiliser le lanceur. Le navigateur doit prendre en charge **WebGL2**.

Pour la version native, utiliser **Godot 4.7.1** avec le PCK distribué séparément :

```sh
godot --main-pack HOTD_Anthologie_2026-11-19.pck
```

Le fichier `site/index.pck` contient le même paquet et peut aussi être lancé avec Godot 4.7.1.

## Découvrir les ajouts

- **Bestiaire & personnages** : 40 fiches, filtres Tous / Zombie Revenge / Loving Deads EX.
- **Zombie Revenge → Linda Rotta → Jouer Linda** dans le bestiaire : choix de l'adversaire et de l'arène.
- **Chroniques de la saga → Zombie Revenge → Histoire → Linda Rotta** : parcours du simulateur AMS.
- Le jeu comporte 24 combattants, 26 parcours et 18 arènes.

## Commandes de Linda

Flèches : marcher, sauter, s'accroupir. Maintenir arrière : garder. J : léger. K : lourd. L : tir debout. Bas + L : glissade armée. U : projection. R : recharger. Échap : pause.

Le pistolet contient huit cartouches. Le tir debout et la glissade consomment chacun une cartouche. Le tir debout passe au-dessus d'une cible accroupie ; la glissade peut la toucher. Dans Entraînement → Pause → Atelier technique, la cadence image par image utilise N pour avancer.

## État vérifié et limites

Le paquet natif a passé 673 contrôles, avec 49 textures chargées et aucun échec. Les suites du jeu et la revue native des scénarios décrits dans VISUAL_QA.json ont réussi. Huit captures et les journaux sont inclus. CAPTURE_PROTOCOL.md distingue les cinq captures sur les sources des trois captures sur le PCK final. Les liens du rapport vers le code ou les archives de production se consultent depuis le dépôt complet ou les sources graphiques fournies séparément.

L'essai du navigateur partagé a été bloqué **avant le jeu**, car WebGL2 y est indisponible. Le lancement web de cette révision reste donc à confirmer sur un navigateur compatible. Le chemin PowerShell de Windows n'a pas été exécuté sous Linux, et l'audio n'a pas été contrôlé par écoute.

Les 49 PNG d'expansion comprennent 23 images récupérées et 26 nouvelles images. Linda possède dix dessins ; les autres sujets de bestiaire restent des illustrations de production. Aucune animation complète ou fidélité 1:1 intégrale n'est revendiquée. L'inventaire de production conserve 299 poses minimales manquantes et 204 masters historiques indisponibles.

Cette livraison est locale. La publication GitHub vers la PR n° 2 attend une autorisation explicite après rejet du contrôle automatique.
""", encoding="utf-8")
    web_zip = output / (stage.name + ".zip")
    archive(web_zip, [(p, stage.name + "/" + p.relative_to(stage).as_posix()) for p in stage.rglob("*") if p.is_file()])
    art_paths = {ROOT / entry["path"] for entry in catalogue["assets"]}
    art_paths.add(ROOT / "data/assets/dossier_curien_expansion.json")
    for directory in (ANNEX, ROOT / "docs/dossier_curien/saga/production/recovered_2026-11-19", ROOT / "docs/dossier_curien/sources_art/references-2026-11-19", ROOT / "docs/dossier_curien/sources_art/recovered-2026-11-19"):
        art_paths.update(p for p in directory.rglob("*") if p.is_file())
    art_zip = output / "HOTD_Expansion_Sources_Linda_EX_2026-11-19.zip"
    archive(art_zip, [(p, p.relative_to(ROOT).as_posix()) for p in art_paths])
    with zipfile.ZipFile(art_zip) as check:
        for entry in catalogue["assets"]:
            if hashlib.sha256(check.read(entry["path"])).hexdigest() != entry["sha256"]:
                raise ValueError(f"PNG incorrect dans le ZIP : {entry['path']}")
    with zipfile.ZipFile(web_zip) as check:
        if hashlib.sha256(check.read(stage.name + "/site/index.pck")).hexdigest() != fragments["sha256"]:
            raise ValueError("PCK incorrect dans le ZIP web.")
    temporary.cleanup()

    bundle = output / "HOTD_Changes_2026-11-19.bundle"
    with tempfile.TemporaryDirectory(prefix="hotd-bundle-stage-", dir=output) as bundle_stage:
        candidate = Path(bundle_stage) / bundle.name
        subprocess.run(["git", "bundle", "create", str(candidate), base_commit + ".." + branch], cwd=ROOT, check=True)
        candidate.replace(bundle)
    verification = subprocess.run(["git", "bundle", "verify", str(bundle)], cwd=ROOT, check=True, capture_output=True, text=True)
    changed_png = [p for p in git("diff", "--name-only", "--diff-filter=A", base_commit, commit, "--", "assets/dossier_curien").splitlines() if p.endswith(".png")]
    receipt = {
        "date": "2026-11-19", "repository": "darknigthmare/the-house-of-the-dead-25d", "branch": branch,
        "local_commit": commit, "base_remote_commit": base_commit, "remote_published": False,
        "publication_status": "blocked_by_automatic_review_pending_explicit_authorization",
        "expansion_assets": catalogue["summary"]["assets"], "gallery_entries": catalogue["summary"]["gallery_entries"],
        "unpublished_dossier_png_added": len(changed_png), "unpublished_png_paths": changed_png,
        "pack_sha256": fragments["sha256"], "pack_bytes": fragments["octets"], "fragment_count": len(fragments["fragments"]),
        "web_gameplay_validated": False, "web_blocker": "WebGL2 unavailable in the shared Chromium",
        "archive_crc_checks": "passed", "asset_hash_checks": "49/49 passed", "web_pack_hash_matches": True,
        "bundle_verified": True, "bundle_verification": verification.stdout + verification.stderr,
        "files": [{"filename": p.name, "bytes": p.stat().st_size, "sha256": digest(p)} for p in (native, web_zip, art_zip, bundle)],
    }
    (output / "LIVRAISON.json").write_text(json.dumps(receipt, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"local_commit": commit, "unpublished_png": len(changed_png), "files": receipt["files"]}, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
