# Dossier Curien — personnages, costumes et stages, lot 5

**20 nouveaux PNG natifs, onze fiches de galerie et trois arènes** sont intégrés aux sources depuis `6da249f2c2cc9a988e31230dae1f805e3d7e1daf`. La [PR 2](https://github.com/darknigthmare/the-house-of-the-dead-25d/pull/2) a été fusionnée avant ce travail ; ce lot utilise une nouvelle branche `feat/dossier-curien-lot5`, destinée à une PR de continuation vers `main`. Aucune fusion n’est demandée.

## Résultat

| Mesure | Avant le lot 5 | Après intégration |
| --- | ---: | ---: |
| Fiches de galerie | 78 | **89** |
| Arènes sélectionnables | 26 | **29** |
| PNG Dossier Curien | 394 | **414** |
| Blobs Git PNG distincts | 392 | **412** |
| Combattants jouables | 24 | **24** |
| Parcours narratifs | 26 | **26** |
| Entrées Archives | 29 | **29** |
| Costumes alternatifs sélectionnables | 2 | **2** |
| Minimum suivi de poses manquantes | 277 | **277** |
| Masters historiques non récupérés | 204 | **204** |

La galerie comprend 40 fiches historiques et 49 fiches issues des cinq lots (9 + 12 + 8 + 9 + 11). Les onze nouvelles fiches sont statiques. Les trois arènes ont chacune leurs plans de fond, intermédiaire et avant-plan.

## Personnages, formes et équipements

| Sujet | Livraison | Réserve conservée |
| --- | --- | --- |
| Dan — prologue de HOTD III | Une base entière avec radio, uniforme et arme | Patronyme Taylor non confirmé par une source primaire consultée ; identifiant historique conservé. |
| Yukio créature | Une base avec ses deux couteaux | Adaptation volontairement non graphique ; forme humaine encore manquante. |
| Hangedman — Scarlet Dawn | Une base distincte de l’apparence HOTD 1 | Origine du rendu réhébergé non certifiée ; ailes et petits détails adaptés. |
| Lisa et G — Typing 2 | Deux équipements avec console, pile et clavier-fusil propres aux captures | QA ouverte sur les détails de corps entier ; Daniel Typing 2 reste manquant. |
| Stick — Zombie Revenge | Costume sombre et armure rouge | Apparence de l’armure visible ; son statut mécanique reste ouvert. |
| Linda — Zombie Revenge | Robe blanche et cuir noir | QA ouverte sur jambes, pieds ou semelles peu documentés. |
| Rikiya — Zombie Revenge | Costume/chapeau et cuir noir | QA ouverte sur les pieds du cuir ; costume/chapeau corrigé pour garder le pied entier. |

Les [reçus personnages](CHARACTERS.md) et [costumes](COSTUMES.md) conservent prompts, références, dimensions, empreintes et limites. Onze images n’ajoutent pas onze personnes uniques. Dan et Yukio sont deux identités nouvellement représentées dans la galerie ; Hangedman est un redesign et huit fiches sont des variantes d’équipement ou de tenue.

## Trois arènes supplémentaires

| Index | Arène | Référence et portion couverte |
| ---: | --- | --- |
| 26 | Place d’A Prelude | HOTD2 classique : place composée à partir de la rue initiale et de Judgment ; port exact des captures non établi. |
| 27 | Hôpital — Ballistic Trauma | Overkill PS3 : salle commune au troisième étage ; autres salles et Screamer non couverts. |
| 28 | Usine chimique — Zombie Revenge | Salle de Chemical Plant, Area 4 ; Dreamcast selon l’auteur de la vidéo, détails fins interprétés depuis les storyboards. |

Les fonds sont RGB opaques, les six plans de parallaxe RGBA. Les contrôles du centre et de la bande de combat donnent un alpha maximal de **1/255**. Huit plans mesurent 1672 × 941 ; l’avant-plan de l’usine mesure 1673 × 940. Les tailles natives sont conservées et le moteur applique son rectangle habituel. Voir le [rapport de production des stages](../stages_2026-11-20_lot5/RAPPORT.md).

## Listing poursuivi

Le [listing personnages et tenues](PERSONNAGES_TENUES.md) conserve **62 tâches et 35 rencontres de boss par édition**. **42 tâches ont au moins une base issue des cinq lots ; 20 n’en ont pas encore.** Les trois familles de tenues Zombie Revenge, la famille Typing 2 et Yukio restent partielles. Cette mesure ne signifie pas 42 personnages terminés.

Le redesign Hangedman SD représente désormais une rencontre de galerie supplémentaire. Les 35 rencontres se répartissent en 14 bases d’identité jouables à revoir par édition, 16 représentations statiques en galerie, quatre comparaisons EX/HOTD4 ouvertes et une Mother mutée sans base dédiée.

Le [listing des stages](STAGES_MANQUANTS.md) passe à **63 lignes** après ajout d’Edward Street et de Cassandra. Les 9 Areas du longplay Zombie Revenge remplacent la précédente présentation en 7 familles ; les IDs historiques sont conservés. Les titres Areas 2/3/4 sont visibles dans les captures. Cassandra est associée par la séquence et le chapitrage de l’auteur ; aucun titre en jeu retenu ne la certifie directement.

Au total, le listing distingue 22 lieux avec arène dédiée, huit adaptations partielles, 26 absences et sept besoins de référence. Les trois lieux livrés ne ferment pas leurs chapitres ou variantes voisins. La revue de référence reste explicitement ouverte sur 14 des 49 fiches issues des cinq lots, dont cinq nouvelles.

## Intégration et contrôles

La cinquième collection rejoint le chargeur de galerie, les builders et les validateurs. Les collisions d’ID, mauvaises racines et faux statuts jouables sont refusés. Les arènes 26–28 apparaissent sur la page 6 du sélecteur, à la suite du dôme d’Hermit.

Le [delta de livraison](DELTA_LIVRAISON.md) vérifie les 20 PNG, leurs octets natifs, les 62 IDs et les cinq manifestes historiques. La [validation intégrée](VALIDATION.md) consigne les tests du moteur et des catalogues. La procédure de publication prévoit de vérifier la CI distante sur le commit effectivement publié et de reporter le résultat dans la PR.

Les 21 appels de ce lot ont produit 20 sorties retenues et un premier Rikiya rejeté pour cadrage. Les 394 PNG historiques sont conservés. Aucun nouveau PCK ni export web n’est produit. Les 277 manques minimum de poses suivis et les 204 masters historiques non récupérés restent ouverts ; aucune session manuelle de jeu ni reproduction canonique 1:1 n’est revendiquée.
