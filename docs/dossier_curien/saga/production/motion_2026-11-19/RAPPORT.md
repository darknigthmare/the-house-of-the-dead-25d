# Dossier Curien — poses de combat et reprise des appuis

**Bilan du 19 novembre 2026.** Cette vague intègre **30 PNG actifs, soit 35 895 640 octets**, pour six identités graphiques. Elle ferme **22 lacunes de poses nommées** dans l’inventaire minimal : **299 → 277**. Elle complète Linda et Rogan, ajoute des appuis et des récupérations à Stick et Rikiya, et reporte le dessin corrigé de Zobio et Zobiko sur leurs poses actives.

Le [manifeste motion](../../../../../data/assets/dossier_curien_motion.json) décrit les ressources réellement chargées. Le fichier [MANQUANTS.json](MANQUANTS.json) fait foi pour les lacunes résolues et restantes. Ces chiffres décrivent des dessins individuels et leur intégration ; ils ne mesurent pas la complétude de cycles animés fluides.

## 1. Périmètre livré et décompte

| Origine des fichiers actifs | PNG | Définition |
|---|---:|---|
| Générés pendant cette vague | 24 | Nouvelles poses et corrections dessinées, retenues après examen. |
| Retrouvés localement | 4 | Deux poses de Rogan et deux de Linda produites auparavant, désormais enregistrées et intégrées. |
| Gardes EX corrigées réutilisées | 2 | Gardes existantes de Zobio et Zobiko réemployées dans le jeu de poses cohérent. |
| **Total du dossier motion** | **30** | **35 895 640 octets ; 30 empreintes SHA-256 distinctes dans ce dossier.** |

La réutilisation des deux gardes ne constitue pas deux nouvelles générations. De même, les corrections des poses EX existantes ne deviennent pas de nouveaux types d’action ou de nouveaux personnages.

| Combattant | PNG actifs de cette vague | Contenu | Lacunes minimales fermées |
|---|---:|---|---:|
| Linda Rotta | 8 | Montée et descente de saut, blocage, projection, victoire, provocation, finisher, recharge. | 8 |
| Thomas Rogan | 2 | Montée de saut et accroupissement. | 2 |
| Zobio | 7 | Garde corrigée, préparation, contact, réaction, récupération et deux appuis de marche. | 3 |
| Zobiko | 7 | Garde corrigée, préparation, contact, réaction, récupération et deux appuis de marche. | 3 |
| Stick Breitling | 3 | Deux appuis de marche et récupération après attaque. | 3 |
| Rikiya Busujima | 3 | Deux appuis de marche et récupération après attaque. | 3 |
| **Total** | **30** | | **22** |

Le périmètre de jeu conserve **24 combattants jouables, 26 parcours narratifs, 18 arènes, 29 épreuves d’archives et 40 fiches de bestiaire**. Cette vague complète la présentation et les poses de combattants existants. Les fiches de bestiaire ne sont pas comptées comme autant de combattants jouables supplémentaires.

## 2. Cohérence des poses et corrections retenues

### Linda et Rogan

Les huit poses de Linda ferment les huit cases encore ouvertes dans son minimum de production. La recharge garde le pistolet dans la main droite et présente le chargeur avec la main gauche. La projection utilise une saisie lisible sans dessiner l’adversaire dans le PNG. La provocation, la victoire et la visée basse du finisher sont des dessins distincts. Le bandage du bras gauche, le holster de la cuisse droite, les gants et les chaussures sont conservés dans ce jeu de poses.

Les deux poses retrouvées de Rogan sont intégrées avec leurs propres repères. La hauteur apparente d’un accroupissement ne sert pas à agrandir artificiellement tout le personnage : la calibration utilise une hauteur anatomique équivalente debout, ajustée au dessin natif. Les repères retenus sont consignés dans [calibration.json](calibration.json), avec les limites de contrôle.

Les PNG restent dans leur résolution native. Les pivots, sorties de canon et autres ancrages sont des données séparées. Le repère de canon final de `linda_block` est **[679, 444]**, en pixels du PNG natif. Cette correction de données est prise en compte dans la reconstruction du paquet ; un ancien paquet ou son ancienne empreinte ne constitue pas la preuve de cette version.

### Appuis de Stick et Rikiya

Chaque personnage reçoit deux contacts opposés : jambe proche droite devant pour `walk1`, puis jambe éloignée gauche devant pour `walk2`. Les poses de récupération montrent la rétraction de leur attaque avant le retour à la garde. Elles ne sont ni des copies de la garde ni des réactions à un coup reçu.

Deux essais de `rikiya_walk2` ont été rejetés parce qu’ils conservaient la même jambe en avant. La version retenue reconstruit la direction des cuisses depuis les hanches et rend l’alternance lisible. Deux contacts donnent des appuis utilisables ; les passages de jambes et les raccords restent nécessaires pour obtenir une marche fluide.

### Zobio et Zobiko

Les gardes corrigées de l’expansion étaient déjà disponibles. Cette vague les relie aux préparations, contacts, réactions, récupérations et appuis du rendu de combat. La correction concerne l’identité graphique et la continuité du costume ; elle ne crée pas de nouvelles tenues alternatives.

Les seconds appuis ont été revus au niveau de la chaîne complète **hanche → cuisse → genou → pied**. Inverser seulement les bandages ou les sutures sur deux mollets ne suffit pas. Dans les versions retenues, la cuisse proche part vers l’arrière, la cuisse éloignée avance, et le recouvrement à leur racine change réellement. Les bandages clairsemés ou denses de Zobiko suivent leurs membres respectifs. Les sutures longue et courte de Zobio suivent également les bons tibias.

Les prompts, références effectivement utilisés, essais écartés et empreintes figurent dans [ex_production.json](ex_production.json) et [ex_walk_corrections.json](ex_walk_corrections.json).

## 3. Intégration et traçabilité

La bibliothèque motion enregistre chaque couple identité–pose avec son chemin, ses dimensions, son pivot et sa hauteur anatomique. Le rendu consulte ces poses dédiées et conserve les solutions de repli pour les actions dont le dessin manque encore. Les ressources du lot sont incluses dans le manifeste embarqué ; le contrôle du paquet vérifie leur chargement depuis le PCK monté.

La présentation sait sélectionner les dessins de saut, blocage, projection, recharge, victoire, provocation et finition lorsqu’ils sont disponibles. La provocation peut commencer au neutre au sol et s’interrompt avec un déplacement, une action ou un impact. Elle reste un geste de présentation. Les retours de blocage disposent d’un état bref distinct. Ces comportements ne valent pas validation de toutes les animations intermédiaires.

| Document | Rôle |
|---|---|
| [Manifeste motion](../../../../../data/assets/dossier_curien_motion.json) | Liste active, fichiers, empreintes et calibrations consommées par le jeu. |
| [calibration.json](calibration.json) | Origines, repères et explications de l’échelle anatomique, notamment pour les poses basses. |
| [linda_production.json](linda_production.json) | Six nouvelles poses de Linda, prompts, références, mesures et limites. |
| [zr_walk_production.json](zr_walk_production.json) | Appuis et récupérations de Stick et Rikiya ; essais de marche rejetés. |
| [ex_production.json](ex_production.json) | Poses et corrections EX de cette vague. |
| [ex_walk_corrections.json](ex_walk_corrections.json) | Reconstruction des seconds appuis EX et continuité des marques. |
| [MANQUANTS.json](MANQUANTS.json) | Inventaire minimal restant et correspondance des 22 cases résolues avec leurs chemins actifs. |

Les archives du sous-dossier [rejected](rejected/) représentent **huit chemins pour six images uniques**. Elles conservent les essais écartés et états intermédiaires sans les activer dans le rendu. Elles ne sont pas incluses dans les 30 PNG actifs ni dans les 22 lacunes fermées.

## 4. Vérifications effectivement réalisées

Les contrôles des sources ont été exécutés dans la copie de reprise avec **Godot 4.6.3**, **Node 24.22.3** et **npm 11.9.0**. Le [résumé final des suites](qa_logs/final-suite-summary.txt) consigne les commandes, leurs résultats et les journaux associés. Les contrôles ci-dessous ont terminé avec un code de sortie nul.

| Contrôle | Résultat observé | Preuve |
|---|---|---|
| Chaîne `npm test` | Réussie : 307/307 contrôles de données, 1 977 assertions d’environnement, 1 456 contrôles d’art, vérification des 49 PNG d’expansion et 10 auto-tests d’expansion, puis 30 PNG motion et 11 auto-tests motion. | [npm-test-final.txt](qa_logs/npm-test-final.txt) |
| Socle Godot | 1 335 assertions réussies. | [core-final.txt](qa_logs/core-final.txt) |
| Dossier Saga | 807 contrôles, aucun échec. | [saga-final.txt](qa_logs/saga-final.txt) |
| Expansion Saga | 124 contrôles, aucun échec. | [expansion-final.txt](qa_logs/expansion-final.txt) |
| Atelier technique | 72/72 exercices ; 229 contrôles, aucun échec. | [lab-final.txt](qa_logs/lab-final.txt) |
| Archives | 29 épreuves exercées, aucun échec. | [archives-final.txt](qa_logs/archives-final.txt) |
| Boss Rush | 74 contrôles, aucun échec. | [rush-final.txt](qa_logs/rush-final.txt) |
| Menu et K.-O. Curien | Parcours contrôlés sans échec. | [curien-menu-ko-final.txt](qa_logs/curien-menu-ko-final.txt) |
| Bibliothèque et comportements motion | 65 contrôles, aucun échec. | [motion-restored.txt](qa_logs/motion-restored.txt) |
| `git diff --check` | Aucun problème d’espacement détecté. | [Résumé final](qa_logs/final-suite-summary.txt) |

Ces compteurs ne sont pas additionnés en un score global : les suites ont des périmètres différents et certains contrôles se recoupent. Les avertissements existants sur la couverture du contenu restent visibles dans le journal de `npm test`.

Une attente du smoke Saga a été ajustée pour accepter la pose dédiée `_throw` de Linda comme un contact **sans tir**. Le contrôle des autres utilisateurs d’armes et de la pose du spécial de tir reste présent. Cet ajustement de test ne modifie pas le comportement du jeu ; le [diagnostic initial](qa_logs/saga-before-throw-expectation-fix.txt) est conservé.

### Revue visuelle de cette vague

Cinq projections statiques ont été examinées **hors moteur** pour vérifier les proportions, les ancrages proposés et la lecture des appuis : [Linda](qa_projection/linda.jpg), [Rogan](qa_projection/rogan.jpg), [Zobio](qa_projection/zobio.jpg), [Zobiko](qa_projection/zobiko.jpg) et [Stick/Rikiya](qa_projection/zombie_revenge.jpg).

Aucune capture native du rendu de cette vague et aucun parcours interactif de cette version ne sont revendiqués. Une projection permet de contrôler la géométrie préparée ; elle ne montre pas les transitions temporelles, l’affichage effectif des effets ni l’ensemble des conditions de combat dans le moteur.

### Paquet reconstruit

Le [guide du paquet compatible Godot 4.6](../../jeu_motion_compat46/README.md) indique le fichier livré et son lancement. Les résultats propres au paquet reconstruit sont dans [COMPAT_PACK_QA.json](COMPAT_PACK_QA.json) et le [rapport de démarrage du paquet](qa_logs/compat-pack-runtime.json). Ces rapports font foi pour le PCK réellement testé.

Le paquet final comporte **289 338 520 octets** et a passé **956 contrôles de ressources sans échec**, avec les **30 textures motion chargées**. Les **65 contrôles de comportements motion** passent également contre ce même PCK. La scène principale démarre pendant 30 frames en mode headless puis sort sans erreur. Son SHA-256 est `918e8331c03696d9b13ce77d50764c14bf24c0e895610c541f454d430529863d`. Le manifeste motion et les scripts embarqués correspondent aux sources finales, y compris la correction de l’émetteur de Linda. Les tests ne constituent pas une validation interactive du rendu.

## 5. Manquants restant à traiter

Le minimum suivi passe de **299 à 277 poses**, soit **22 cases fermées**. Il reste réparti ainsi dans [MANQUANTS.json](MANQUANTS.json) :

| Famille de pose | Minimum encore absent |
|---|---:|
| Blocage | 25 |
| Accroupissement | 24 |
| Garde accroupie | 25 |
| Finisher | 25 |
| Descente de saut | 25 |
| Montée de saut | 24 |
| Récupération d’attaque | 17 |
| Recharge | 11 |
| Provocation | 25 |
| Projection | 25 |
| Victoire | 25 |
| Marche, contact 1 | 13 |
| Marche, contact 2 | 13 |
| **Total** | **277** |

L’inventaire couvre 26 identités graphiques et tenues pour les 24 combattants ; les variantes de Kate et Ryan ont leurs propres entrées. Ce minimum nomme des poses de base. Il ne comprend pas toutes les images de passage, anticipations et retours nécessaires à des cycles fluides, ni les cycles futurs des ennemis et boss actuellement représentés dans le bestiaire. Fermer les huit cases de Linda ne signifie donc pas que son animation complète est achevée.

Les **204 masters historiques non retrouvés** restent un déficit de récupération distinct. Les quatre images retrouvées dans cette vague viennent d’une production locale plus récente et ne réduisent pas ce nombre.

Les comportements, attaques, collisions, points de contact, sons et effets des nouveaux ennemis de bestiaire restent à développer avant leur intégration comme rencontres jouables. L’inventaire et la réalisation des variantes de costumes, couleurs, niveaux, mini-jeux, pièces séparées et accessoires supplémentaires restent également ouverts. Les 18 arènes enregistrées ne constituent pas une reproduction de tous les niveaux de la franchise.

La fidélité **1:1 reste non certifiée**. Les références, prompts, PNG et mesures rendent les décisions vérifiables ; la validation canonique exige encore les comparaisons visuelles appropriées, et la validation des animations demande leur examen en mouvement dans le jeu.
