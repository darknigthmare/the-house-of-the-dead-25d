# Récupération Zombie Revenge / EX — 19 novembre 2026

23 dessins statiques distincts ont été récupérés sans modifier leurs pixels. Le catalogue consommable est `data/assets/dossier_curien_expansion.json`. Les empreintes SHA-256, dimensions, limites alpha, sources et prompts disponibles y sont consignés.

## Qualité et usage

- Justice, Star et Empress EX restent à comparer à des captures du jeu : leurs anciennes fiches étaient fondées sur des descriptions.
- UDS-04C a été recontrôlé par composition RGBA sur fond opaque : le halo apparent était du RGB caché dans des pixels transparents. Sa silhouette est entière et aucun halo visible ni rognage n’a été confirmé. Les mesures aux seuils alpha 1, 16 et 128 sont consignées dans `ALPHA_FRAMING_QA.json`.
- Neclien présente des pixels alpha faibles au bord inférieur ; ses deux pieds visibles sont entiers.
- Yoko et Marco Cloud sont des portraits de dialogue, pas des combattants en pied.
- UDS-06B a été identifié par comparaison avec la capture sauvegardée ; son prompt original n’était pas disponible et n’a pas été inventé.
- Aucune fidélité 1:1 ni animation complète n’est certifiée par ce lot.

## Archives distinctes

Six originaux supplémentaires sont conservés sous `docs/dossier_curien/sources_art/recovered-2026-11-19/` : cinq variantes écartées et une ancienne maquette du menu. Ils ne sont pas actifs dans le jeu. Les références source utilisées sont rangées séparément sous `docs/dossier_curien/sources_art/references-2026-11-19/`.

L’inventaire `RECOVERY_INVENTORY.json` distingue ces catégories. Aucun des 204 originaux historiques signalés dans le précédent audit n’a été retrouvé dans l’environnement disponible.

## Provenance du guide retrouvée après récupération

Les captures des ennemis correspondent à la galerie du [Zombie Revenge Perfect Guide](https://thehouseofthedead.fandom.com/wiki/Zombie_Revenge_Perfect_Guide), notamment aux pages 30–31 et 32–33. La [liste des zombies de Zombie Revenge](https://thehouseofthedead.fandom.com/wiki/List_of_zombies_in_Zombie_Revenge) renvoie également à ces scans. Les fiches historiques restent conservées avec leur attribution d’origine ; le catalogue actif peut compléter ses sources avec ces liens.
