# Intégrer Linda Rotta et le bestiaire Zombie Revenge / Loving Deads EX

> **Description locale prête — 19 novembre 2026.** Les tests et la revue native sont terminés. L’essai web est bloqué par WebGL2 indisponible dans le navigateur partagé. La publication vers la PR n° 2 attend une autorisation explicite ; aucune mise à jour distante n’est revendiquée.

## Problème

Des productions Zombie Revenge et Loving Deads EX existaient dans l’espace de travail sans être intégrées au dépôt, au catalogue ni au paquet jouable. Le mode Zombie Revenge ne proposait pas Linda Rotta, et les nouvelles illustrations n’avaient pas de galerie permettant de distinguer un personnage jouable, un portrait et un dessin de production.

La validation des sources ne suffisait pas non plus à prouver que chaque texture était réellement présente dans la distribution : la galerie peut ignorer une ressource manquante. Cette PR ajoute donc un contrôle du contenu du PCK, en plus des contrôles des fichiers sources et du comportement de jeu.

## Changements

### Ressources et traçabilité

- Intègre **49 PNG d’expansion**, représentant **65 651 752 octets** : **23 images récupérées** et **26 nouvelles images** — dix ennemis, sept visuels de boss et neuf poses supplémentaires de Linda.
- Enregistre chaque ressource dans `data/assets/dossier_curien_expansion.json`, avec son usage, son statut de référence, ses dimensions, ses limites alpha, son empreinte SHA-256, ses sources et sa provenance. Les prompts absents ou les références encore incertaines sont signalés.
- Conserve les références et les variantes rejetées dans les archives de production, séparément des sprites actifs. Les images récupérées sont conservées sans modification de leurs pixels.
- Porte le périmètre graphique Dossier Curien de **253 à 302 PNG**. Le lot couvre les dessins de base de **17 ennemis** et **13 boss, formes ou organismes de Zombie Revenge**, ainsi que les portraits et les sept sujets EX.

### Jeu et présentation

- Ajoute **Linda Rotta** à la sélection et aux modes de combat, avec son pistolet à huit cartouches, son tir debout, sa glissade armée et son parcours Histoire de Zombie Revenge.
- Intègre **dix dessins de Linda** au total : garde, préparation, contact, récupération, recul, deux contacts de marche et **trois vraies poses basses** — accroupissement, garde accroupie et contact de glissade. Les poses basses conservent l’échelle anatomique du dessin debout. La première pose de marche a été corrigée pour alterner les appuis avec la seconde.
- Ajoute **Bestiaire & personnages**, avec les filtres Tous, Zombie Revenge et Loving Deads EX, une navigation par fiches et un accès direct au combattant Linda depuis sa fiche.
- Affiche **40 fiches de galerie** ; les neuf poses supplémentaires de Linda sont enregistrées avec `gallery:false` pour éviter les doublons dans la liste des personnages.
- Complète la construction du paquet pour embarquer le manifeste, les nouveaux scripts et les textures importées. Ajoute les vérificateurs des sources et du PCK ainsi que l’inventaire actualisé des manquants.

## Comportement obtenu

Le jeu déclare désormais **24 combattants**, **26 parcours narratifs** et **18 arènes**. Les neuf Chroniques comprennent celle du manoir : les parcours se décomposent en **quatre parcours du manoir, huit autres parcours principaux et quatorze récits alternatifs**, soit **4 + 8 + 14 = 26**.

Linda se choisit depuis les modes de combat habituels ou depuis **Chroniques de la saga → Zombie Revenge → Histoire**. Son tir debout passe au-dessus d’une cible accroupie ; sa glissade armée avance au sol et atteint cette cible, tandis qu’un saut permet de sortir de sa bande de tir. La glissade ne donne pas d’invincibilité. Les rencontres de son parcours restent des adaptations du simulateur AMS du projet.

La galerie permet de consulter les personnages, créatures et portraits avec l’état de leurs références. Seule une fiche reliée à un profil effectivement intégré propose un accès au combat. Les illustrations de boss et d’ennemis ne deviennent pas automatiquement des adversaires animés ; les bases EX corrigées de Zobio et Zobiko ne remplacent pas toutes leurs poses de duel antérieures.

## Vérifications effectuées

Les résultats ci-dessous portent sur la copie locale consolidée à 49 PNG. L’identifiant exact du commit local est indiqué dans le reçu de livraison accompagnant les archives.

| Contrôle | Résultat observé |
|---|---|
| `npm test` final | Réussi, code de sortie 0. |
| Vérificateur d’expansion | **49 PNG**, **40 fiches**, empreintes, tailles, dimensions, alpha, chemins, références et correspondance fichier/manifeste vérifiés ; **dix auto-tests** réussis. |
| Suite Dossier Curien | **0 échec**, code de sortie 0. |
| Suite Dossier Saga | **807 contrôles**, **0 échec**, code de sortie 0. |
| Suite Saga Expansion | **124 contrôles**, **0 échec**, code de sortie 0. |
| Atelier technique | **72/72 exercices**, **229 contrôles**, **0 erreur**, code de sortie 0. |
| Paquet final sous Godot 4.7.1 | **673 contrôles**, **0 échec**, code de sortie 0. Les **49/49 textures** sont chargées à leurs dimensions natives ; la galerie conserve les **40 fiches** attendues. |
| Vérification visuelle native finale | **Réussie sur les scénarios observés** : accroupissement et garde articulés, canon aligné pendant la glissade, consommation de 8 à 7 cartouches, 12 PV de dégâts et reprise immédiate de l’atelier. [Huit captures et protocole](CAPTURE_PROTOCOL.md). |
| Vérification navigateur finale | **Bloquée avant le moteur** : le Chromium partagé signale WebGL2 indisponible, y compris après un rechargement. [Preuve](qa_web/webgl2-unavailable.jpg). |

Le test du PCK monte le paquet réel et charge les textures via `ResourceLoader`, y compris les remappages d’import Godot. Il contrôle également `res://demo.tscn`, les scripts empaquetés, les profils et parcours, les pivots de Linda, ses émetteurs et l’échelle de ses poses basses. Il n’instancie pas l’interface : il complète la revue visuelle sans la remplacer.

Paquet contrôlé : `HOTD_Anthologie_final.pck` — **95 935 632 octets**. SHA-256 :

```text
690ebbb7f1c82cc9954ac474ff5b87e9e8a6b29f6fb714ae698ab4c71c7733a3
```

Le détail est conservé dans [PACK_QA.json](PACK_QA.json), avec le bilan dans [RAPPORT.md](RAPPORT.md). La suite Curien signale trois instances ObjectDB non libérées à la fermeture ; son résultat fonctionnel reste à zéro échec, avec un code de sortie 0.

## Distribution

Le lancement natif du PCK demande **Godot 4.7.1**. Les fragments et `fragments.json` doivent appartenir au même lot ; `assembler.py` vérifie leurs tailles et leurs empreintes avant de reconstituer le paquet. La reconstruction du paquet final a été vérifiée depuis ses **27 fragments**, ainsi que l’identité de son empreinte avec celle de `site/index.pck`.

La procédure web **depuis les sources** demande une copie complète du dépôt, contenant `build/web`, puis l’exécution de `preparer_web.py` avec Python 3.8 ou plus récent. Le script prépare `site/` avant le lancement de `Jouer.py` ou `Jouer-Windows.cmd`. Le moteur web fourni est bien en version **4.7.1**, avec les threads désactivés.

La **livraison web finale comprend `site/` déjà préparé** : elle ne demande ni Godot ni assemblage au joueur. Sous Windows, le lanceur dispose d’une solution de repli PowerShell si Python est absent. Il faut donc conserver ce dossier préparé dans l’archive finale ; les lanceurs ne le reconstruisent pas eux-mêmes. L’ancien ZIP du volume IV reste une livraison historique.

**Obstacle observé dans l’environnement de contrôle :** le Chromium partagé signale l’absence de WebGL2 avant de démarrer le jeu. Le résultat persiste après un rechargement. Le fonctionnement visuel web reste à confirmer sur un navigateur exposant WebGL2. Les protections du navigateur n’ont pas été modifiées. Le lanceur Windows n’a pas été exécuté sous Linux.

## Limites et travail restant

- **Aucune certification de fidélité 1:1 ni de couverture intégrale de la franchise.** Justice, The Star et The Empress EX demandent encore une comparaison visuelle plus solide. Les détails de Hedlin, Nikelle, Warm Hedlin et Shell Hedlin restent à vérifier ; le prompt original d’UDS-06B n’a pas été retrouvé.
- Les **204 masters historiques manquants** ne sont pas récupérés par ce lot. Les 23 images récupérées proviennent d’une production locale plus récente.
- Le minimum suivi reste de **299 poses nommées manquantes** : 291 dans l’inventaire antérieur et huit pour Linda — montée de saut, descente de saut, blocage, projection, victoire, provocation, finisher et recharge. Ce minimum exclut les images intermédiaires et les futurs cycles des nouveaux sujets du bestiaire.
- Les illustrations statiques des ennemis et boss ne constituent pas leurs animations, collisions, comportements ou rencontres complètes. Le contrôle natif de Linda valide les cas observés ; il ne certifie pas l’ensemble des transitions ou une animation complète.
- Gil, The World dans EX, les couleurs 2P/3P de Zombie Revenge et les costumes corrigés de Zobio/Zobiko restent à documenter ou à compléter. Aucune nouvelle arène ni pièce détachée n’est ajoutée par cette expansion.

Le périmètre exact et les réserves sont consignés dans [MANQUANTS_COMPLEMENT.json](MANQUANTS_COMPLEMENT.json).

## État de publication

Les sources, les ressources, les références, les preuves de contrôle et les 27 fragments sont prêts dans le lot local. Le reçu de livraison donne son identifiant de commit exact.

Le contrôle automatique a refusé le push vers `darknigthmare/the-house-of-the-dead-25d`, branche `feat/dossier-curien-combat`, car l’autorisation explicite d’exporter ce code et ces ressources vers GitHub a été jugée insuffisante. Aucune autre voie de publication n’a été tentée. Ce document est prêt pour la PR **n° 2**, mais aucune publication distante n’est annoncée.
