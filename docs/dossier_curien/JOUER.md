# Jouer à Dossier Curien — Anthologie de combat

Depuis le jeu complet, choisissez **Dossier Curien** dans le menu d’arcade. Dans la version autonome, le menu du mode combat apparaît au démarrage.

## Nouveaux visuels du 19 novembre 2026 — depuis les sources

La branche de la PR ajoute quatre poses de marche pour Kate et sa tenue de soirée, douze poses de combat pour Rogan, G et Magician, trois accessoires indépendants à Venise et une dix-huitième arène, **Rue dévastée de Despair**, avec trois plans peints.

Pour jouer ces ajouts, ouvrez `project.godot` dans **Godot 4.7.1**, laissez les ressources s’importer, puis lancez le projet. Depuis la racine du dépôt, la commande équivalente est :

```sh
godot --path .
```

Choisissez **Dossier Curien → Duel local**, puis les deux combattants. La quatrième page des arènes contient **Rue dévastée de Despair**. Les tenues de Kate se règlent depuis **Tenues de Kate et Ryan** à la sélection ; les deux appuis de marche suivent la tenue choisie.

Les paquets PCK, les fragments, le navigateur préparé et la bible PDF présents ci-dessous restent ceux du **volume IV**. Ils n’ont pas été réexportés pour ce lot ; les nouveaux visuels sont disponibles dans les sources de la PR.

[Lire le bilan de production, la traçabilité des images et les éléments restant à produire](saga/production/REPRISE_2026-11-19.md).

## Paquet du volume IV depuis ce dépôt

Téléchargez la branche de la PR ou récupérez le dossier [saga/jeu](saga/jeu) avec tous ses fragments. Dans ce dossier, utilisez Python 3.8 ou plus récent pour assembler le paquet. Le script vérifie chaque fragment et l’empreinte SHA-256 du jeu complet. Si la version précédente de l’anthologie est déjà assemblée, sa mise à jour est automatique après vérification de son empreinte. Lancez ensuite le paquet avec Godot 4.7.1.

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

## De Pandore à l’Arche • Volume IV

Dans **Chroniques de la saga → The House of the Dead 4 → Histoire**, choisissez **Kate Green** pour retrouver James et affronter The World au parvis de Goldman. Choisissez **The World** pour jouer les trois actes du côté de la créature. Dans **Scarlet Dawn**, Ryan rejoint Kate face à Moon, dans les ruines du domaine Scarecrow. Moon a également son propre parcours en trois combats, avec une introduction, un rival, un dernier duel et un épilogue illustrés.

**The World** fait passer deux salves de glace à hauteur de buste avec L. La première touche ralentit la marche, le second passage oblige à tenir sa défense. Bas + L déclenche sa hache à courte portée. **Moon** propage sa frappe au ras du sol avec L. Sautez lorsque son bras redescend. Bas + L déclenche une attraction à moyenne distance, avec une zone libre près du corps. Dans les finales de Kate et Ryan, le scanner AMS suit le noyau de The World ou l’œil de Moon pendant leurs changements de pose. Après une victoire décisive par K.-O., appuyez sur I pour lancer leur finition si vous jouez le boss.

**Boss Rush AMS → De Pandore à l’Arche** enchaîne Justice, The World et Moon. Une halte entre les adversaires permet de conserver son avantage au chronomètre, de se soigner ou de recharger.

À la sélection du combattant, **Tenues de Kate et Ryan** permet d’essayer les vêtements portés au manoir de Scarlet Dawn. **Entraînement → Pause → Atelier technique** donne accès à trois exercices pour chacun des 23 combattants. Activez le journal des impacts pour lire le tic et les dégâts de chaque touche. En mode image par image, une pression sur N, la touche point ou le stick droit avance d’un tic. L’atelier mémorise les exercices réussis par combattant.

![Kate contre The World, Ryan contre Moon, avec leurs points faibles](saga/Duels_World_Moon.jpg)

[Voir les deux confrontations en mouvement](saga/Duels_World_Moon.mp4)

## Un premier duel dans les épisodes II et III

Ouvrez **Chroniques de la saga → The House of the Dead III → Histoire → Lisa Rogan**. Passez l’introduction pour entrer au poste de sécurité. Le deuxième duel oppose Lisa à Death. En finale, Daniel retrouve Lisa dans la chambre d’incubation face à Wheel of Fate. Dans le dossier de II, James retrouve Emperor sur le toit de Goldman. Le briefing du dernier acte et la pause proposent le scanner de point faible pour ces deux combats.

Les flèches déplacent J1. J donne un coup léger, K un lourd, L le spécial, U une projection et R recharge. Maintenez arrière pour garder. Après une victoire décisive par K.-O., I déclenche la finition. Échap ouvre la pause et donne accès à la liste des coups.

Pour essayer la frappe en pleine manche, ouvrez **Archives et variantes → The Typing of the Dead → Lancer l’épreuve**. Tab ouvre le terminal. Recopiez le mot et validez par Entrée. La touche View et la croix directionnelle en donnent une adaptation pour manette.

Parmi les 29 épreuves figurent **The Typing of the Dead US Edition**, la réédition PC de 2005 et **Typing Lariat** sur Windows. US Edition demande des appels en anglais. La réédition de 2005 accorde une seconde par mot. Lariat prolonge l’ouverture pour tenter une projection.

**Archives et variantes → House of the Dead: Reawakened → Lancer l’épreuve** ouvre *Les trois ouvertures*. Le volet gauche, la porte de face puis le volet droit s’ouvrent à tour de rôle. Pendant que le signal est actif, appuyez sur Tab ou View, ou touchez votre adversaire. Réussir les trois dans l’ordre donne 12 PV de dégâts supplémentaires et interrompt l’adversaire. Une ouverture manquée oblige à recommencer la série.

[Voir les trois ouvertures validées en jeu](saga/Reawakened_en_jeu.webp)

## Boss Rush AMS

Au menu principal, ouvrez **Boss Rush AMS → Les gardiens d’EFI**, puis choisissez votre combattant. Une seule manche contre Death vous sépare de Wheel of Fate. La vie et les cartouches restantes sont conservées entre les deux combats. Une halte permet de récupérer 18 PV pour cinq secondes au classement, ou de remplir le chargeur pour trois secondes. Le meilleur temps est conservé par circuit et combattant sur le même appareil. Le lanceur réutilise le port local 28716 pour retrouver les records dans le même navigateur. Si ce port est occupé, il signale que la nouvelle adresse aura ses propres records. Le circuit Anthologie enchaîne huit gardiens.

**Pour essayer les quatre recrues**, ouvrez Histoire dans le dossier de *II* pour Gary et Emperor, ou dans celui de *III* pour Daniel et Wheel. Au sol, maintenez bas en lançant le spécial d’Emperor ou de Daniel pour obtenir la variante. Gary recule avant le tir et peut donner un coup de coude avec J. L’anneau de Wheel passe à l’aller et au retour.

![Quatre duels dans les arènes du volume III](saga/Quatre_duels_volume_III.webp)

[Voir Gary et Emperor en mouvement dans le moteur](saga/Echange_Gary_Emperor.mp4)

## Documents

- [Bible intégrale, volumes I à IV, 83 pages](saga/HOTD_Anthologie_Bible_integrale.pdf)
- [Volume IV — De Pandore à l’Arche](saga/HOTD_Bible_IV_De_Pandore_a_l_Arche.pdf) et [texte de production](saga/VOLUME_IV.md)
- [Boss et points faibles](saga/REFERENCES_COMBATTANTS_IV.md), [arènes et parallaxe](saga/SOURCES_ARENES_IV.md) et [tenues et cycles de marche](saga/TENUES_ET_MARCHE_IV.md)
- [Volume III — Les gardiens](saga/HOTD_Bible_III_Les_gardiens.pdf) et [texte de production](saga/VOLUME_III.md)
- [Volume II — Anthologie de combat](saga/HOTD_Anthologie_Bible_Saga.pdf)
- [Volume I — Le dossier du manoir](HOTD_Dossier_Curien_Bible.pdf)
- [Sources des combattants du volume III](saga/VAGUE_III_REFERENCES.md) et [sources des quatre arènes](saga/SOURCES_ARENES_III.md)
- [Registre des ressources peintes de l’anthologie](saga/CATALOGUE_VISUEL_SAGA.json)
- [Sources et périmètre des jeux](saga/SOURCES_ET_CORPUS.md)
- [Paquet historique du seul manoir](Dossier_Curien.pck)
