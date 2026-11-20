# Rapport de production — Zombie Revenge, EX et Linda Rotta

**Date : 19 novembre 2026.** Projet : *House of the Dead 2D*, mode annexe **Dossier Curien**.

Le lot local consolidé contient **49 PNG d’expansion** et **40 fiches de bestiaire**, pour **65 651 752 octets**. Il récupère les images restées hors du dépôt, complète les dessins de base identifiés pour les ennemis et plusieurs boss de *Zombie Revenge*, et ajoute neuf poses à la base de Linda Rotta. Le code de jeu accueille désormais **24 combattants** et **26 parcours narratifs**. Le contenu du lot reste à distinguer des animations complètes et de la couverture intégrale de la franchise.

Ce rapport accompagne le [manifeste consommé par le jeu](../../../../../data/assets/dossier_curien_expansion.json), l’[inventaire complémentaire](MANQUANTS_COMPLEMENT.json) et l’[ancien inventaire des manquants](../MANQUANTS_2026-11-19.json). La vérification d’expansion, `npm test`, les quatre suites Godot et le contrôle du paquet final ont réussi. La revue visuelle native est réussie sur les scénarios décrits dans le protocole. Le lancement web est bloqué avant le jeu par l’absence de WebGL2 dans le navigateur de contrôle ; la publication GitHub reste bloquée.

## 1. Périmètre et méthode de comptage

Le socle antérieur contient **253 PNG Dossier Curien** : 30 images classiques et 223 images Saga, accessoires et pièces inclus. Le lot ajoute un dossier d’expansion distinct. Les références, les maquettes, les variantes rejetées et les fichiers d’import Godot ne sont pas comptés comme sprites actifs.

| Mesure | Socle antérieur | Lot local consolidé |
|---|---:|---:|
| PNG classiques | 30 | 30 |
| PNG Saga | 223 | 223 |
| PNG d’expansion | 0 | 49 |
| Total de ce périmètre graphique | 253 | 302 |
| Profils de combattants dans le code | 23 | 24 |
| Parcours narratifs | 25 | 26 |
| Arènes enregistrées | 18 | 18 |
| Tenues alternatives déjà enregistrées | 2 | 2 |
| Fiches dans la nouvelle galerie | 0 | 40 |

Les **neuf Chroniques comprennent celle du manoir**. Les **26 parcours** se calculent donc comme suit : quatre parcours du manoir, un parcours principal dans chacune des huit autres Chroniques, puis quatorze récits alternatifs, soit **4 + (9 − 1) + 14 = 26**. La Chronique du manoir ne doit pas être ajoutée une seconde fois. Ces parcours sont déclarés dans [saga.gd](../../../../../src/dossier_curien/saga.gd). Les profils sont vérifiables dans [combatant.gd](../../../../../src/dossier_curien/combatant.gd).

Les **23 ressources récupérées** et les **26 nouvelles images** sont maintenant présentes dans les dossiers du projet et enregistrées dans le manifeste, notamment Warm Hedlin et Shell Hedlin. Les 49 fichiers ont passé la vérification ciblée des empreintes, tailles, dimensions, limites alpha et références. L’[inventaire JSON](MANQUANTS_COMPLEMENT.json) conserve séparément la photographie initiale à 23 entrées. Cette consolidation locale ne constitue pas une preuve de publication distante.

## 2. Contenu du lot

| Groupe | Images | Usage prévu |
|---|---:|---|
| Productions EX et Zombie Revenge récupérées | 23 | Bases individuelles et portraits de dialogue. |
| Nouveaux ennemis de Zombie Revenge | 10 | Dessins maîtres de bestiaire. |
| Nouveaux boss et organismes de Zombie Revenge | 7 | Dessins maîtres de bestiaire. |
| Poses supplémentaires de Linda | 9 | Attaque, réaction, contacts de marche et trois poses basses articulées. |
| **Total** | **49** | **40 sujets de galerie et neuf poses hors galerie.** |

### Personnages et portraits

Linda dispose de sa base corrigée, avec le pistolet dans la main correspondant à la référence, puis de neuf dessins : **préparation**, **contact**, **récupération**, **recul**, **marche 1**, **marche 2**, **accroupissement**, **garde accroupie** et **contact de glissade**. Ces trois dernières images sont de vraies poses basses articulées ; leur taille en jeu conserve l’échelle anatomique du maître debout, sans écraser verticalement le personnage. Le premier essai de **marche 1**, qui répétait l’appui de marche 2, a été remplacé. La version corrigée place la jambe gauche en avant et la jambe droite portant l’étui en arrière. Son empreinte actualisée figure dans le manifeste, dans l’inventaire complémentaire et dans [NEW_ASSETS_PROVENANCE.json](NEW_ASSETS_PROVENANCE.json). Les deux contacts doivent ensuite rester cohérents pendant les transitions, avec son arme, ses vêtements et ses appuis.

Yoko et Marco Cloud sont des **portraits destinés aux dialogues**. Le cadrage volontaire de Yoko ne doit pas être interprété comme un sprite de combat en pied incomplet. Ces deux personnages ne reçoivent pas un profil de combat du seul fait de leur présence dans la galerie.

Pour EX, les bases corrigées de **Zobio** et **Zobiko** sont conservées séparément. Il reste à reporter leurs corrections de costume sur les autres poses utilisées en combat. Une nouvelle garde disponible dans le bestiaire ne remplace pas automatiquement les illustrations plus anciennes de chaque action.

### Dix-sept ennemis de base de Zombie Revenge

Les sept images récupérées couvrent **Latch, McCoy, Buddy, Bat Zombie, Hedgeros, Hedlin et Factory Worker 1**.

Les dix nouveaux dessins couvrent **Biff, Ebitan, Factory Worker 2, Frog, Hedrian, Hermonkey, Mansion Zombie 1, Mansion Zombie 2, Mecha Zombie et Mummy**.

Cela constitue **17 dessins de base dans le périmètre identifié du guide**. Ce chiffre ne signifie pas que chaque ennemi possède ses déplacements, attaques, dégâts, mort, variations ou comportements de niveau. Les références sont issues des pages 30–31 et 32–33 du [Zombie Revenge Perfect Guide](https://thehouseofthedead.fandom.com/wiki/Zombie_Revenge_Perfect_Guide), recoupées avec la [liste des zombies](https://thehouseofthedead.fandom.com/wiki/List_of_zombies_in_Zombie_Revenge).

### Treize visuels de boss, formes ou organismes de Zombie Revenge

Les six bases récupérées sont **ZED, UDS-03, Neclien, UDS-04C, UDS-05 et UDS-06B**.

Les sept nouveaux visuels sont **UDS-02, Black Magician Type 01, UDS-TP II 00, UDS-TP II 01, UDS-07 Nikelle, Warm Hedlin et Shell Hedlin**.

Ces **13 illustrations** distinguent les formes ou organismes enregistrés. Elles ne désignent pas treize nouveaux combattants jouables, ni une reconstitution complète de tous les affrontements. Les deux sujets UDS-TP II et les deux Hedlin conservent leurs fichiers propres.

La partie EX conserve cinq illustrations de boss : **Justice, The Star, The Empress, The Lovers et Temperance**. Avec les deux protagonistes, EX représente sept fiches du lot. La collection Zombie Revenge représente les trente-trois autres fiches : dix-sept ennemis, treize visuels de boss, Linda et les deux portraits.

## 3. Intégration de Linda et de la galerie

Le profil local de Linda ajoute un **pistolet à huit cartouches**, un tir debout et une **glissade armée**. Le profil dispose de ses valeurs de portée, de préparation et de récupération. Son parcours des Chroniques de Zombie Revenge comporte une introduction, un rival, une finale et un épilogue. Le code conserve les combats invités dans le cadre du simulateur du projet.

La galerie propose les filtres **Tous**, **Zombie Revenge** et **Loving Deads EX**. Une fiche d’illustration doit rester distincte d’une fiche donnant accès à un véritable profil de combattant. Les neuf fichiers de pose de Linda sont enregistrés avec `gallery:false` : ils ne doivent pas apparaître comme neuf personnages supplémentaires.

Les suites automatiques finales confirment les comportements testés de Linda et de la galerie ; le contrôle du PCK confirme également les textures, les pivots et les émetteurs chargés depuis le paquet. La revue native confirme la sélection, le départ des tirs au canon, les appuis alternés et les trois poses basses. Les captures et le périmètre exact figurent dans [CAPTURE_PROTOCOL.md](CAPTURE_PROTOCOL.md). Le navigateur de contrôle n’a pas pu démarrer le moteur faute de WebGL2.

## 4. Fidélité : contrôles encore ouverts

La fidélité 1:1 reste un objectif de production et doit être jugée visuellement. La présence d’une URL, d’un prompt ou d’un PNG ne constitue pas une certification.

| Sujet | État à conserver | Travail restant |
|---|---|---|
| Justice, Star et Empress EX | Référence visuelle à confirmer | Comparer les reconstructions aux captures exactes d’EX ; vérifier silhouette, couleurs, costume, accessoires et proportions. |
| Hedlin courant | Détails anatomiques à recouper | Lire les membres et proportions sur une référence plus définie, sans le confondre avec Warm ou Shell Hedlin. |
| Nikelle | Capture d’origine et storyboard, définition limitée | Vérifier les détails fins sur un rendu ou une capture plus nette. |
| Warm Hedlin et Shell Hedlin | Maîtres produits, référence encore limitée | Confirmer les détails de tête et de corps des deux organismes ; ne pas remplacer l’un par une variante approximative de l’autre. |
| UDS-06B | Maître retrouvé et identifié contre une capture | Retrouver le prompt original si disponible ; la provenance manquante reste signalée. |
| Zobio et Zobiko | Bases corrigées | Reporter le même dessin de référence sur les poses de combat et les transitions. |
| Tous les sujets | Adaptations dessinées | Vérifier l’identité et la continuité image par image avant toute mention « 1:1 validée ». |

Le contrôle alpha a été repris avec une **composition RGBA sur un fond opaque**, afin de ne pas confondre des couleurs stockées dans des pixels transparents avec un halo réellement visible. **UDS-04C et Neclien ne présentent pas de rognage anatomique confirmé.** Les seuils alpha 1, 16 et 128 des 23 images récupérées sont consignés dans [ALPHA_FRAMING_QA.json](../recovered_2026-11-19/ALPHA_FRAMING_QA.json). Ce contrôle technique ne valide pas leur exactitude canonique.

## 5. Manquants réels après ce lot

### Minimum de poses individuelles : 299 images encore identifiées

L’ancien inventaire listait **291 fichiers de pose absents**, pour les 23 combattants initiaux et les deux tenues de réception. Ces fichiers restent absents au relevé : les nouveaux ennemis de galerie ne les remplacent pas.

Linda conserve **8 poses minimales encore manquantes** après ses dix dessins disponibles : montée de saut, descente de saut, blocage, projection, victoire, provocation, finisher et recharge. L’accroupissement et la garde accroupie sont désormais dessinés. Le contact de glissade ajoute une action hors du minimum antérieur ; il ne réduit donc pas ce compteur une troisième fois.

Le minimum ciblé atteint donc **299 poses nommées** : **291 + 8**, soit deux de moins que le relevé précédent à 301. Ce décompte n’inclut ni toutes les images intermédiaires nécessaires à des animations fluides ni les futurs mouvements propres aux nouveaux sujets du bestiaire.

| Famille de pose | Images minimales encore absentes |
|---|---:|
| Marche : contact 1 | 17 |
| Marche : contact 2 | 17 |
| Montée de saut | 26 |
| Descente de saut | 26 |
| Accroupissement | 25 |
| Garde accroupie | 25 |
| Blocage | 26 |
| Projection | 26 |
| Victoire | 26 |
| Provocation | 26 |
| Finisher | 26 |
| Recharge | 12 |
| Récupération d’attaque | 21 |
| **Total** | **299** |

Les 26 identités graphiques de plusieurs lignes comprennent les 24 combattants et les deux tenues déjà enregistrées. Certaines actions n’appellent pas le même nombre d’images selon le personnage ; ce tableau prolonge le minimum défini dans l’inventaire antérieur.

### Animations et comportements

Les mouvements doivent encore recevoir leurs poses de passage, appuis, variations de hauteur et transitions. Deux contacts de marche ne suffisent pas à décrire un cycle fluide. Les attaques demandent la continuité entre préparation, contact et récupération ; les dégâts demandent des réactions, chutes et retours à la garde adaptés.

Les ennemis et boss nouvellement représentés nécessitent ensuite leurs comportements, attaques, collisions, points de contact, sons et effets avant une intégration comme rencontres jouables. Aucune animation complète de ces nouveaux sujets n’est revendiquée par le lot.

### Personnages et variantes à documenter

**Gil** reste une entrée de suivi : sa présence nominale est référencée dans l’[épisode The House of the Dead](https://thehouseofthedead.fandom.com/wiki/The_House_of_the_Dead_(episode)) et l’histoire de [ZED](https://thehouseofthedead.fandom.com/wiki/ZED), mais aucune apparence suffisamment vérifiée n’a été retenue pour produire son sprite.

**The World dans EX** reste à documenter visuellement et à représenter. La [fiche du personnage](https://thehouseofthedead.fandom.com/wiki/The_World) distingue sa présence dans EX ; le World de HOTD4 déjà jouable ne suffit pas à valider une représentation EX.

Les **variantes de couleurs 2P/3P de Zombie Revenge** constituent une piste documentée par la [rétrospective consultée](https://sesesega.hatenablog.jp/entry/zombierevenge). Le lot ne fournit pas leur inventaire visuel complet. Leur nombre, leur répartition par personnage et leurs détails doivent être vérifiés avant de produire les variantes ou d’annoncer une couverture complète.

Les deux tenues de réception existantes conservent leurs propres besoins de poses. Les corrections du costume original de Zobio et Zobiko ne sont pas comptées comme de nouvelles tenues alternatives.

### Décors, niveaux, accessoires et pièces séparées

Le précédent inventaire indique **zéro calque peint manquant dans les arènes actuellement enregistrées**. Ce résultat porte sur les 18 arènes du projet ; il ne signifie pas que tous les niveaux ou mini-jeux de Zombie Revenge et d’EX ont été reproduits.

Le présent lot n’ajoute pas d’arène ni de pièce détachée. Les niveaux et épreuves supplémentaires restent à documenter, avec leurs arrière-plans, plans de parallaxe, zones jouables, obstacles, interactions et règles. Les deux pièces indépendantes de Lisa et les cinq accessoires répertoriés précédemment constituent un début de production, pas un inventaire exhaustif.

### Originaux historiques indisponibles

Les **204 masters historiques** signalés dans l’ancien audit restent absents de l’environnement disponible. Aucun n’est déclaré récupéré par ce lot. Les 23 images récupérées ici appartiennent à une production locale plus récente et ne réduisent pas ce déficit historique.

Les six originaux supplémentaires issus de la récupération sont cinq variantes rejetées et une maquette de menu. Le premier essai de marche 1 de Linda a ensuite été conservé comme révision rejetée supplémentaire. Ces archives ne deviennent pas des sprites actifs et ne gonflent pas les comptes de personnages.

## 6. Suite de production priorisée

1. **Vérifier le démarrage web sur un navigateur disposant de WebGL2** : le contrôle partagé reste bloqué avant le moteur.
2. **Poursuivre les contrôles d’animation de Linda** : les appuis, les tirs, les poses basses et la sélection sont observés ; les transitions complètes et les autres mouvements restent à produire et à examiner.
3. **Résoudre les références encore faibles** : Justice/Star/Empress EX, Hedlin, Nikelle, Warm Hedlin et Shell Hedlin ; documenter Gil et The World EX.
4. **Compléter les 299 poses minimales**, puis les images intermédiaires nécessaires. Traiter chaque personnage comme un ensemble cohérent.
5. **Préparer la jouabilité des sujets de bestiaire** : mouvements, attaques, comportement, collision, audio et effets, puis rencontres et niveaux.
6. **Étendre les costumes et environnements** à partir d’un inventaire visuel vérifié, sans supposer qu’un maître isolé couvre toutes les variantes.

## 7. Validation finale et publication

La consolidation, les suites automatiques et la vérification du paquet sont terminées. Le lot contient **49 PNG**, **40 fiches de galerie**, **neuf poses masquées** et **65 651 752 octets** d’images sources enregistrées. Le paquet final a passé **673 contrôles**, sans échec.

| Contrôle | Résultat |
|---|---|
| Manifeste complet et 49 PNG présents | **Confirmé** : 49 fichiers enregistrés, 65 651 752 octets. |
| Galerie du paquet : 40 fiches et neuf poses masquées | **Confirmé** : les 40 fiches sont réellement chargées, aucune ressource manquante silencieusement écartée. |
| `npm test` final | **Réussi**, code de sortie 0. |
| Vérification d’expansion | **Réussie** : 49 PNG contrôlés et dix auto-tests réussis. |
| Suite Dossier Curien | **Réussie** : 0 échec, code de sortie 0. |
| Suite Dossier Saga | **Réussie** : 807 contrôles, 0 échec, code de sortie 0. |
| Suite Saga Expansion | **Réussie** : 124 contrôles, 0 échec, code de sortie 0. |
| Atelier technique | **Réussi** : 72/72 exercices, 229 contrôles, 0 erreur, code de sortie 0. |
| Paquet final, Godot 4.7.1 | **Réussi** : 673 contrôles, 0 échec, 49/49 textures natives et 40 fiches chargées. |
| Contrôle visuel natif | **Réussi sur les scénarios observés** : bestiaire, sélection, tirs, appuis, poses basses et reprise de l’atelier. Huit captures conservées. |
| Contrôle de la version web | **Bloqué par l’environnement avant le moteur** : WebGL2 indisponible, y compris après un rechargement. Jouabilité web non validée. |
| État de livraison | Sources, provenance, captures et 27 fragments préparés pour le commit local de livraison ; identifiant exact fourni dans le reçu accompagnant les archives. |
| Publication GitHub | **Bloquée par le contrôle automatique ; aucun push confirmé pour ce lot.** |

Le contrôle du paquet utilise ses propres ressources montées : il vérifie `res://demo.tscn`, les scripts empaquetés, chaque texture du manifeste, la galerie, les 24 combattants, les 26 parcours et les 18 arènes. Il confirme les pivots de Linda, ses émetteurs et l’échelle anatomique des poses basses. Les textures sont lues via les remappages Godot ; les PNG sources bruts ne sont pas requis dans le PCK. Aucune interface n’est instanciée par ce contrôle.

Le rapport détaillé est [PACK_QA.json](PACK_QA.json). Le journal d’exécution est [qa-final-pack.txt](qa_logs/qa-final-pack.txt). Le paquet testé est `HOTD_Anthologie_final.pck`, avec l’empreinte SHA-256 vérifiée avant exécution :

`690ebbb7f1c82cc9954ac474ff5b87e9e8a6b29f6fb714ae698ab4c71c7733a3`

La suite Curien signale un avertissement de nettoyage de trois instances ObjectDB à la sortie du processus ; elle conserve zéro échec fonctionnel et un code de sortie 0. Cette observation est conservée dans l’inventaire de validation.

Le contrôle automatique a refusé le push vers `darknigthmare/the-house-of-the-dead-25d`, branche `feat/dossier-curien-combat`, car l’autorisation explicite d’exporter le code et les ressources vers cette destination a été jugée insuffisante. Aucune autre voie de publication n’a été tentée. La PR visée est la **n° 2**. Les résultats restent locaux et sont remis sous forme d’archives téléchargeables ; une autorisation précise sera demandée pour publier ce lot concret.

Le paquet de **95 935 632 octets** est livré en un fichier et dans une archive web contenant déjà `site/`, le moteur et les lanceurs. Les **27 fragments** ont été assemblés et l’empreinte obtenue est identique à celle du paquet testé et de `site/index.pck`. Le contrôle natif et la limite web sont documentés dans [CAPTURE_PROTOCOL.md](CAPTURE_PROTOCOL.md) et [VISUAL_QA.json](VISUAL_QA.json). La version Windows du lanceur et le rendu audio n’ont pas été exécutés ou écoutés dans cet environnement Linux.
