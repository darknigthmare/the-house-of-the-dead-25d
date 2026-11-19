# Dossier Curien — distribution motion pour Godot 4.6.3

Cette distribution native autonome ouvre directement le Dossier Curien. Elle contient les 24 combattants, 26 récits, 18 arènes et les 30 dessins motion du lot du 19 novembre 2026, avec la calibration finale du blocage de Linda. Les dessins supplémentaires ne constituent pas encore une animation complète de toute la saga.

Le paquet est construit et testé avec **Godot 4.6.3**, depuis les sources locales. La distribution historique pour Godot 4.7 dans `../jeu/` et la version web restent séparées. Ce paquet n’est pas un export web et ne valide pas l’ancienne distribution avec un autre moteur.

## Assembler et lancer

Installer Python 3.8 ou plus récent et Godot 4.6.3. Depuis la racine du dépôt, exécuter ces deux commandes ; `godot` doit désigner l’exécutable **4.6.3** installé :

```sh
python3 docs/dossier_curien/saga/jeu_motion_compat46/assembler.py --output /tmp/HOTD_Motion_Compat46.pck
godot --main-pack /tmp/HOTD_Motion_Compat46.pck
```

`/tmp` est un exemple de dossier temporaire sous Linux/macOS. Choisir un dossier existant adapté à son système et reporter le même chemin dans les deux commandes. Prévoir au moins **290 Mo libres** dans ce dossier. L’option `--output` place le fichier temporaire et le paquet final à cet endroit ; les fragments restent dans le dépôt. Sans cette option, le paquet est créé à côté de l’assembleur.

Sous Windows, ouvrir PowerShell à la racine du dépôt et utiliser le chemin de son installation Godot dans la deuxième commande :

```powershell
py -3 docs/dossier_curien/saga/jeu_motion_compat46/assembler.py --output "$env:TEMP\HOTD_Motion_Compat46.pck"
& "C:\Godot\Godot_v4.6.3-stable_win64.exe" --main-pack "$env:TEMP\HOTD_Motion_Compat46.pck"
```

Ces commandes Windows sont fournies comme instructions de lancement ; le contrôle effectif du paquet a été réalisé sous Linux.

L’assembleur vérifie la taille et le SHA-256 de chaque fragment, puis ceux du paquet complet. Un paquet déjà identique est reconnu. Un autre fichier présent au chemin demandé est préservé : choisir alors un autre chemin. Un fragment absent ou corrompu interrompt l’opération sans créer de paquet final et le temporaire est supprimé.

## Identification du paquet

| Propriété | Valeur |
|---|---|
| Nom reconstruit | `HOTD_Motion_Compat46.pck` |
| Taille exacte | 289 338 520 octets |
| Fragments bruts | 81 : 80 de 3 600 000 octets, puis 1 de 1 338 520 octets |
| SHA-256 du paquet | `918e8331c03696d9b13ce77d50764c14bf24c0e895610c541f454d430529863d` |
| Moteur vérifié | `4.6.3.stable.official.7d41c59c4` |

Le manifeste `fragments.json` contient les empreintes individuelles. Le contrôle du PCK monté a réussi **956 vérifications**, le test motion **65 vérifications**, et la scène principale a démarré sans erreur pendant **30 frames en mode headless**. Ces contrôles ne constituent pas une revue interactive du rendu natif. Les rapports se trouvent dans [`../production/motion_2026-11-19/`](../production/motion_2026-11-19/).
