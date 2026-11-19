# Expansion Zombie Revenge / EX — 19 novembre 2026

Cette annexe suit la récupération des productions locales, les nouveaux dessins et l’intégration de Linda Rotta au **Dossier Curien** de *House of the Dead 2D*.

Le lot local consolidé comprend **49 PNG d’expansion** : 23 images récupérées et 26 nouvelles images — 10 ennemis, 7 visuels de boss et 9 poses supplémentaires de Linda. Les 49 fichiers sont présents dans le projet et inscrits dans le manifeste, pour **65 651 752 octets**. La galerie compte **40 sujets** dans ses métadonnées, les neuf poses supplémentaires étant masquées dans la liste des personnages.

Ces comptes désignent des images et des fiches. Le code contient **24 profils de combattants**, **26 parcours narratifs** et **18 arènes**. Les neuf Chroniques comprennent le manoir : quatre parcours du manoir, huit autres parcours principaux et quatorze récits alternatifs donnent bien **4 + 8 + 14 = 26**. Les illustrations du bestiaire ne deviennent pas automatiquement des combattants ou des ennemis animés.

## Documents

| Document | Usage |
|---|---|
| [RAPPORT.md](RAPPORT.md) | Bilan français, périmètre, contenu du lot, limites et prochaine production. |
| [MANQUANTS_COMPLEMENT.json](MANQUANTS_COMPLEMENT.json) | Inventaire détaillé : fichiers produits, état d’intégration au relevé, poses absentes et contrôles de fidélité restants. |
| [Manifeste d’expansion](../../../../../data/assets/dossier_curien_expansion.json) | Catalogue effectivement lu par le jeu ; il fait autorité pour les ressources intégrées. |
| [Inventaire antérieur](../MANQUANTS_2026-11-19.json) | Périmètre initial des 23 combattants et deux tenues, conservé pour la traçabilité. |
| [Récupération locale](../recovered_2026-11-19/RECOVERY_INVENTORY.json) | Empreintes, références et originaux archivés. |
| [Contrôle alpha](../recovered_2026-11-19/ALPHA_FRAMING_QA.json) | Limites de transparence et cadrage des 23 images récupérées. |
| [PACK_QA.json](PACK_QA.json) | Contrôle du paquet final : 673 vérifications, 49 textures chargées, 40 fiches et aucun échec. |
| [CAPTURE_PROTOCOL.md](CAPTURE_PROTOCOL.md) | Huit captures natives, scénarios observés et blocage WebGL2 du navigateur de contrôle. |
| [VISUAL_QA.json](VISUAL_QA.json) | Résultats natifs/web, empreintes des captures et journaux archivés. |
| [PR_DESCRIPTION.md](PR_DESCRIPTION.md) | Description prête pour la PR n° 2, conservée localement. |

## État de cette annexe

Le manifeste est **consolidé à 49 PNG et 40 fiches**. Linda dispose de **dix dessins**, dont trois vraies poses basses. Le périmètre Dossier Curien atteint **302 PNG** et le minimum ciblé de poses encore absentes descend à **299**. `npm test`, les quatre suites Godot et le contrôle du paquet final ont réussi. Le paquet a passé **673 vérifications**, dont le chargement de ses **49 textures** et de ses **40 fiches**. La revue native est réussie pour les sélections, les tirs, les appuis, les poses basses et la reprise de l’atelier. Le lancement web reste bloqué par WebGL2 indisponible dans le navigateur partagé ; aucune jouabilité web n’est revendiquée. Le JSON conserve les relevés antérieurs pour la traçabilité. Les 27 fragments reconstruisent le paquet final de 95 935 632 octets.

La publication GitHub du lot est **bloquée par le contrôle automatique** signalé par la coordination. Aucune mise à jour distante n’est confirmée dans cette annexe. Les fichiers restent disponibles dans la copie locale du projet.

## Vérification ciblée

Commande exécutée avec succès sur les fichiers et le manifeste consolidés :

```bash
npm run qa:curien-expansion
```

Le vérificateur contrôle les images, leurs empreintes, leurs dimensions, l’alpha, la sécurité des chemins, les références, les catégories de galerie et la présence d’une seule entrée par PNG. Il ne certifie ni la fidélité 1:1 au jeu d’origine ni la fluidité des animations.
