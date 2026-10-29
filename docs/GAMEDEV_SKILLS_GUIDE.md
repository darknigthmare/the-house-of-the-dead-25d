# Guide de développement — House of the Dead 2.5D

Source méthodologique : https://github.com/gamedev-skills/awesome-gamedev-agent-skills

## Contrat de travail
- Conserver Godot 4.7.1, le rendu GL Compatibility et l'architecture existante.
- Charger uniquement les guides pertinents à la tâche, en commençant par router/SKILL.md.
- Inspecter les scripts, scènes, manifestes et tests avant toute modification.
- Ne pas annoncer une fidélité arcade certifiée sans comparaison avec une référence autorisée.
- Ne jamais remplacer les sprites V2 par de faux V3 ni confondre un test automatisé avec un contrôle visuel.

## Guides par chantier
| Chantier | Guides à consulter | Critères d'acceptation |
|---|---|---|
| Architecture | godot-nodes-scenes, godot-gdscript | Références de nœuds valides, transitions sans erreurs |
| Animations | create-game-assets, godot-animation | 5 clips, 8 directions, 8 images chronologiques, pivots stables, alpha contrôlé, fallback atomique V2 |
| Rails et décors | level-design, camera-systems, godot-3d-essentials | Raccords visuels/physiques, géométrie praticable, embranchements sans impasse |
| Combats | game-ai, game-feel | Télégraphes lisibles, annulation des attaques lors des impacts, collisions cohérentes |
| Entrées et HUD | input-systems, game-ui-ux | Deux joueurs indépendants, rechargement hors écran, navigation manette |
| QA | godot-gdscript-headless-testing, godot-export | Import Godot préalable, erreurs fatales, codes de sortie non nuls, exports et vérification navigateur |

## Priorités suivies (à vérifier sur la branche de travail avant intervention)
1. P0 : continuité des décors entre les nœuds, surfaces et escaliers réellement praticables.
2. P0 : références autorisées des embranchements 2/3/4/6/9 ; maintenir les marqueurs TBD-AUTH tant que non validés.
3. P1 : migration progressive des 37 acteurs V2 restants, en conservant Sam A1 comme référence technique V3 (1/38).
4. P1 : QA visuelle Web et nouveaux exports Windows/Linux postérieurs à v0.5.0.
5. P2 : optimisation mesurée seulement après profilage.

## Commandes de validation
```sh
npm test
npm run qa
npm run qa:web
npm run verify:web
```

Avant toute QA sur checkout propre : importer les ressources avec Godot 4.7.1 en mode headless. Respecter les scripts existants du dépôt ; ne pas remplacer leur orchestration sans audit.

## Définition de terminé
Une modification n'est terminée que si son comportement est démontré, les tests ciblés passent, la suite de régression ne recule pas, les captures de contrôle sont examinées quand le rendu change et les limitations restantes sont documentées. Une PR non testée reste en brouillon.
