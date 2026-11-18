# Jouer à Dossier Curien — Anthologie de combat

Depuis le jeu complet, choisissez **Dossier Curien** dans le menu d’arcade. Dans la version autonome, le menu du mode combat apparaît au démarrage.

## Depuis ce dépôt

Téléchargez la branche de la PR ou récupérez le dossier [saga/jeu](saga/jeu) avec tous ses fragments. Dans ce dossier, utilisez Python 3.8 ou plus récent pour assembler le paquet. Le script vérifie chaque fragment et l’empreinte SHA-256 du jeu complet. Lancez ensuite le paquet avec Godot 4.7.1.

```sh
python3 assembler.py
godot --main-pack HOTD_Anthologie.pck
```

Sous Windows, ouvrez PowerShell dans ce même dossier. Remplacez le chemin de l’exécutable par celui de votre installation Godot.

```powershell
py -3 assembler.py
.\Godot_v4.7.1-stable_win64.exe --main-pack .\HOTD_Anthologie.pck
```

Un paquet `HOTD_Anthologie.pck` déjà téléchargé en un seul fichier se lance directement avec la deuxième commande.

## Dans le navigateur

Depuis une copie complète du dépôt, ouvrez le dossier [saga/jeu](saga/jeu) et lancez les commandes suivantes. Le lanceur ouvre une adresse locale dans votre navigateur. Gardez la fenêtre du lanceur ouverte pendant la partie.

```sh
python3 preparer_web.py
python3 Jouer.py
```

Sous Windows, après `py -3 preparer_web.py`, double-cliquez sur `Jouer-Windows.cmd`. Le ZIP de jeu livré avec la bible est déjà préparé et contient directement ces lanceurs.

## Un premier duel

Ouvrez **Chroniques de la saga → The House of the Dead III → Histoire → Lisa Rogan**. Passez l’introduction pour entrer au poste de sécurité. Le deuxième duel est celui de Death.

Les flèches déplacent J1. J donne un coup léger, K un lourd, L le spécial, U une projection et R recharge. Maintenez arrière pour garder. Après une victoire décisive par K.-O., I déclenche la finition. Échap ouvre la pause et donne accès à la liste des coups.

Pour essayer la frappe en pleine manche, ouvrez **Archives et variantes → The Typing of the Dead → Lancer l’épreuve**. Tab ouvre le terminal. Recopiez le mot et validez par Entrée. La touche View et la croix directionnelle en donnent une adaptation pour manette.

## Documents

- [Bible intégrale de 49 pages](saga/HOTD_Anthologie_Bible_integrale.pdf)
- [Volume I — Le dossier du manoir](HOTD_Dossier_Curien_Bible.pdf)
- [Bible intégrale de 49 pages](saga/HOTD_Anthologie_Bible_integrale.pdf)
- [Volume II — Anthologie de combat](saga/HOTD_Anthologie_Bible_Saga.pdf)
- [Sources et périmètre des jeux](saga/SOURCES_ET_CORPUS.md)
- [Paquet historique du seul manoir](Dossier_Curien.pck)
