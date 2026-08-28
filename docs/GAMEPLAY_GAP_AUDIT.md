# Audit des écarts gameplay et fidélité

## État mesuré — release publique v0.5.0, 28 août 2026

Ce document décrit l’état réel de la release publique `0.5.0`, issue du tag immuable `v0.5.0` au commit exact `6d84764745102b95e22b2462eeaa364103678c0b`. Les archives, la GitHub Release, la CI et le déploiement Vercel sont vérifiés ; cela ne constitue pas une certification de fidélité Sega.

Le jeu possède une campagne 2.5D complète au sens structurel et un contrat runtime fortement testé. Il reste une reconstruction fan-made : la réussite des tests locaux ne vaut pas certification de fidélité Sega.

## Preuves de release actuelles

| Contrôle | Résultat v0.5.0 |
|---|---:|
| cœur déterministe Godot | **975 assertions** |
| suite du dépôt | `npm test` **295/295** |
| orchestration QA complète | **313/313** |
| QA Web | **299/299** |
| vérificateur d’environnement | **1 977 assertions** |
| audit de contenu | **889 contrôles / 6 avertissements / 0 erreur** |

Ces résultats attestent la cohérence interne du tag publié. La publication est confirmée par la [release GitHub v0.5.0](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.5.0), la CI `33136431022`, les quatre archives aux sommes SHA-256 vérifiées et Vercel `dpl_BTEuXpYNMWmEYbWP2h2hNjAVGkGL`. Ils ne prouvent toutefois aucune comparaison avec une borne autorisée.

## Photographie du contenu actif

| Surface | Mesure v0.5.0 | Limite de la preuve |
|---|---:|---|
| graphe de campagne | **43 nœuds / 53 arêtes** | topologie encodée, pas géométrie arcade exacte |
| chemins complets C1–C4 | **8 / 4 / 8 / 2** | toutes les sorties encodées sont atteignables |
| apparitions ordinaires | **98 entrées / 68 à 71 par parcours complet** | densité déclarée, pas ordre, coordonnées ni variantes 2P certifiés |
| civils | **20 placements / 15 rencontrés par parcours** | couverture structurelle des sauvetages |
| rythme des combats | **34 rencontres multi-vagues** | la dernière vague commence à au moins **82 %** du budget de chaque rencontre |
| décor | **14 profils de props / 105 placements / 9 événements d’état** | couverture de remplacement, pas implantation arcade exacte |
| budgets fixes hors boss dynamiques C1–C4 | **106,5 / 97,4 / 93,1 / 40,4 s** | mesures par chapitre, hors combats de boss dynamiques |

Les quatre budgets fixes ne sont **pas** une durée murale totale de campagne et ne doivent pas être additionnés comme telle. Les boss dynamiques, transitions, performances du joueur et autres variations runtime sont exclus de ces valeurs.

Dix-neuf placements décoratifs ont été ajoutés dans les cinq scènes auparavant clairsemées. Le total actif atteint donc 105 placements ; cela améliore la densité visuelle sans certifier les positions de la borne.

## Corrections gameplay effectives

### Poursuite, mêlée et obstacles

- Les ennemis ordinaires restent contraints devant la caméra et convergent sur les axes X et Z jusqu’au contact physique.
- Une frappe de mêlée exige une ligne de vue valide avant d’infliger des dégâts. Un mur ou un prop intact ne peut plus être ignoré par le test de contact.
- Le déplacement utilise une collision balayée afin d’éviter la traversée d’un obstacle entre deux positions. Les props intacts restent des blockers jusqu’à leur changement d’état configuré.
- Le cycle répété est `approche -> anticipation -> frappe -> récupération -> réattaque` tant qu’une cible valide existe. Le nombre d’attaques ne supprime plus arbitrairement l’acteur.
- Les projectiles hostiles sont visibles, destructibles et tirables. Ceux qui ciblent le joueur corrigent progressivement leur direction vers la caméra mobile au lieu de s’y recaler instantanément ; les contraintes de visibilité et de trajet minimal restent requises avant les dégâts.
- En coop, chaque menace choisit un seul joueur vivant et conserve cette cible tant qu’elle reste valide. Un projectile visant un joueur verrouille son destinataire au lancement et se dissipe si ce joueur devient indisponible, sans redirection vers son partenaire.
- Un assaillant affecté à un civil ne peut pas se rabattre sur un joueur. Si le civil disparaît avant le tir, aucun projectile visant un joueur n’est créé ; un projectile civil déjà lancé se dissipe sans changer de cible.
- Chaque attaque de boss exige **0,90 seconde visible et continue** avant validation. Toute perte de visibilité remet le télégraphe à zéro ; le temps masqué ou le dépassement d’un cooldown ne peut pas réduire cette fenêtre.
- La mort logique retire immédiatement l’acteur de `active`. Un fondu visible reste suivi dans `retiring` jusqu’à sa libération finale, un acteur sans sprite est finalisé immédiatement, et le nettoyage de scène vide les deux ensembles.

Ces corrections ferment les défauts de lisibilité et de contact du runtime. Elles ne rendent pas exacts les placements, résistances, fenêtres d’attaque, réactions par membre ou variantes coopératives de l’arcade.

### HUD, glyphes et saisies

- Les accents français et les glyphes HUD pris en charge sont visuellement propres sur la surface locale vérifiée.
- Les ornements Unicode non sûrs sont remplacés sans supprimer les lettres accentuées normales.
- Les initiales des joueurs et les libellés de modes sont sanitizés avant affichage ou persistance afin d’écarter les caractères de contrôle et glyphes non pris en charge.

Le contrat texte courant est donc propre ; il ne certifie pas la police, le logo, les icônes ni la composition graphique originaux de Sega.

### Rails, raccords et sol

- Un raccord par interpolation d’Hermite relie les poses caméra de sortie et d’entrée de deux nœuds.
- Le changement d’environnement intervient tard dans le raccord afin de masquer davantage la substitution.
- Le monde n’est toutefois pas persistant : l’environnement est encore reconstruit au passage de nœud. La continuité visuelle et spatiale exacte reste donc provisoire.
- Un solveur générique maintient les acteurs sur les sols, marches et pentes détectés. Il ne remplace pas une géométrie ni une navigation construites scène par scène depuis une référence arcade.

## État des neuf décisions de route

Les neuf décisions disposent maintenant d’une représentation dans le graphe actif, mais cinq restent non exactes ou provisoires :

| Décision | État v0.5.0 |
|---:|---|
| #2 | substitut inexact : la condition active ne reproduit pas encore l’ordre/la cible et toutes les issues observées |
| #3 | branche impact/chute présente, mais déclenchement, rail et mise en scène provisoires |
| #4 | branche impact/chute présente, mais déclenchement, rail et mise en scène provisoires |
| #6 | substitut inexact : le sort d’un civil remplace encore la condition d’interrupteur observée |
| #9 | deux portes ciblables indépendamment sont présentes, mais le raccord et la mise en scène restent provisoires |

Les décisions restantes sont des alignements structurels approximatifs. Le bilan `43 nœuds / 53 arêtes / 8/4/8/2 chemins` prouve la traversabilité des branches encodées, pas leur exactitude arcade.

## Écarts de fidélité encore ouverts

### Animation et direction

Les **38 atlas** contiennent **2 432 cellules adressables**, mais seulement **huit états sémantiques par direction**. Ce contrat ne fournit pas les clips multi-images complets nécessaires aux anticipations détaillées, attaques alternatives, impacts localisés, démembrements, transitions et morts.

- **38/38** profils droits sont miroités depuis la gauche ;
- **25/38** profils arrière-droits sont miroités depuis l’arrière-gauche ;
- trois variantes de placement ennemies restent explicitement non arcade-exactes.

Ces trois placements et les trois limites globales ci-dessus constituent les **six avertissements connus** de l’audit de contenu.

### Level design et rythme

- Le raccord Hermite réduit la coupure, mais la reconstruction du décor interdit encore toute revendication de continuité spatiale exacte.
- Le solveur de sol, marches et pentes est générique ; les hauteurs, paliers, corridors et occultations exacts restent à construire.
- Les 19 ajouts décoratifs comblent cinq scènes clairsemées, mais les 105 placements ne sont pas des relevés arcade certifiés.
- Les 34 rencontres multi-vagues et leur dernière vague à partir de 82 % garantissent un rythme interne tardif ; elles ne certifient ni la cadence, ni les formations, ni les timings de la borne.
- Les budgets fixes par chapitre excluent les boss dynamiques et ne constituent pas un chronométrage de partie complète.

### Routes et contenu

- Remplacer les conditions de substitution des décisions #2 et #6 reste prioritaire.
- Les décisions #3, #4 et #9 doivent encore recevoir leurs déclencheurs, rails, caméras et raccords exacts.
- Les trois variantes de placement provisoires doivent être comparées à une référence autorisée avant de devenir des placements arcade revendiqués.

## Frontière de certification Sega

`LICENSED_ASSETS_ROOT` et `REFERENCE_BUILD_ROOT` ne sont pas disponibles pour cet audit. Il manque donc à la fois les masters licenciés et un build Sega autorisé, identifiable par révision et réglages opérateur.

Ne peuvent pas être certifiés dans cet état :

- coordonnées, rails, rotations, pauses, FOV, raccords et surfaces exacts ;
- ordre des vagues, variantes deux joueurs, résistances, hit zones et fenêtres de dégâts ;
- identités et délais des civils, objets cachés, règles de score, continues et fins ;
- modèles, animations, textures, dialogues, voix, musiques, sons, polices, logos et crédits originaux.

Les enregistrements publics peuvent aider à observer la composition et la topologie, mais ne fournissent ni mesures certifiables ni ressources licenciées.

## Verdict et priorités

La release v0.5.0 est structurellement complète, jouable, publiée et fortement vérifiée. Les corrections de combat, collision, projectile, HUD, raccord Hermite, sol générique, densité décorative et rythme multi-vagues sont effectives. Le niveau de preuve de fidélité reste toutefois celui d’une adaptation fan-made interne.

Priorités restantes :

1. remplacer les substituts #2/#6 et finaliser les mises en scène provisoires #3/#4/#9 ;
2. construire la continuité environnementale et les surfaces praticables scène par scène ;
3. remplacer les vues miroitées et les huit états sémantiques par des clips directionnels détaillés ;
4. vérifier les trois variantes de placement avec une référence autorisée ;
5. fournir `LICENSED_ASSETS_ROOT` et `REFERENCE_BUILD_ROOT`, identifier la révision et les réglages, puis refaire les mesures avant toute revendication Sega exacte.

> **Verdict : release publique v0.5.0 vérifiée, mais non certifiée fidèle à l’arcade Sega.**
