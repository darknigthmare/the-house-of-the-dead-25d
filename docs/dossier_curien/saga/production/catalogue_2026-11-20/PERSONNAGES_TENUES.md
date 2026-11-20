# Personnages, formes et tenues — inventaire du 20 novembre 2026

Base contrôlée : `59372b618882da17510351f2a5bd46226682eac4`. L’inventaire porte sur les jeux et éditions du corpus existant. **Il ne prétend pas avoir identifié tous les figurants, toutes les palettes ni chaque créature de toutes les versions mobiles.** Les inconnues restent des tâches de recherche.

Le [delta de livraison du 20 novembre](DELTA_LIVRAISON.md) réconcilie cet état initial avec les neuf nouvelles bases de galerie. Les tableaux ci-dessous restent ceux du baseline pour conserver une comparaison reproductible.

## Ce qui est réellement publié

| Indicateur | Nombre vérifié | Ce que le nombre signifie |
|---|---:|---|
| Profils jouables de Dossier Curien | 24 | Entrées de `combatant.gd::PROFILES` ; une nouvelle image seule ne change pas ce nombre. |
| Fiches de galerie | 40 | Entrées hors poses du manifeste d’expansion ; pas 40 identités inédites. |
| PNG Dossier Curien | 332 chemins / 330 blobs Git distincts | Personnages, poses, arènes, accessoires et silhouettes mélangés. |
| Lot motion 19 novembre | 30 entrées | 24 nouveaux dessins retenus, 4 récupérations, 2 gardes EX recâblées ; aucune nouvelle tenue par simple pose. |
| Tenues alternatives sélectionnables | 2 | `kate_soiree` et `ryan_soiree` ; le mode automatique est une règle de sélection. |

Le [snapshot des chemins et empreintes Git](baseline_59372b6.json) permet de refaire les comptes sans télécharger tous les binaires. Le [registre JSON](personnages_tenues.json) conserve les 24 profils, les 40 fiches, les variantes et les preuves. Les fichiers de l’ancien jeu et les images Dossier Curien sont comptés séparément. Une fiche de galerie porte son propre statut : Linda, Zobio et Zobiko peuvent avoir une fiche non interactive et, séparément, un profil jouable. Les deux compteurs ne s’additionnent pas comme des identités distinctes.

## Huit identités humaines réellement sans sprite dédié dans la base

| Cible | Statut dans son jeu | Référence utile | État de la référence |
|---|---|---|
| Varla Guns | PNJ dans Overkill ; jouable dans Extended Cut | [SEGA — The Typing of the Dead Overkill, manuel Steam](https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/246580/manuals/TOTDO_STEAM_MANUAL_ENG.PDF?t=1763675367) · [SEGA / PlayStation Blog — Naked Terror](https://blog.playstation.com/2011/08/01/house-of-the-dead-overkill-naked-terror-revealed/) | Portraits vérifiés ; tenue complète à recouper |
| Candi Stryper | Protagoniste jouable dans le jeu source | [SEGA — The Typing of the Dead Overkill, manuel Steam](https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/246580/manuals/TOTDO_STEAM_MANUAL_ENG.PDF?t=1763675367) · [SEGA / PlayStation Blog — Naked Terror](https://blog.playstation.com/2011/08/01/house-of-the-dead-overkill-naked-terror-revealed/) | Portraits vérifiés ; tenue complète à recouper |
| Amy Crystal | Personnage de soutien (PNJ) | [SEGA — HOTD2, manuel Dreamcast](https://www.digitpress.com/library/manuals/dreamcast/house_dead_2.pdf) · [Captures HOTD2 reproduites par IMFDB](https://www.imfdb.org/wiki/The_House_of_the_Dead_2) | Corps monochrome et capture couleur du jeu croisés |
| Harry Harris | Personnage de soutien (PNJ) | [SEGA — HOTD2, manuel Dreamcast](https://www.digitpress.com/library/manuals/dreamcast/house_dead_2.pdf) · [Captures HOTD2 reproduites par IMFDB](https://www.imfdb.org/wiki/The_House_of_the_Dead_2) | Corps monochrome et capture couleur du jeu croisés |
| Goldman — forme humaine | Antagoniste humain | [SEGA — HOTD2, manuel Dreamcast](https://www.digitpress.com/library/manuals/dreamcast/house_dead_2.pdf) | Corps assis monochrome ; couleur à documenter |
| Thornheart | Antagoniste humain | [SEGA — Scarlet Dawn](https://hod.sega.jp/) · [Wiki of the Dead — Thornheart, galerie](https://thehouseofthedead.fandom.com/wiki/Thornheart/Gallery) | Référence visuelle encore nécessaire |
| Papa Caesar | Antagoniste humain | [Wiki of the Dead — List of characters](https://thehouseofthedead.fandom.com/wiki/List_of_characters) · [Index de collecte des concept arts Extended Cut](https://www.k-triggerhappy.com/hodoverkill_ps3/collection.html) | Référence visuelle encore nécessaire |
| Clement Darling | Antagoniste humain | [Wiki of the Dead — List of characters](https://thehouseofthedead.fandom.com/wiki/List_of_characters) · [Index de collecte des concept arts Extended Cut](https://www.k-triggerhappy.com/hodoverkill_ps3/collection.html) | Référence visuelle encore nécessaire |

Les sources définissent les rôles originaux. Dans le projet, ces huit cibles restent non jouables tant qu’un profil, des actions, des animations et leur validation ne sont pas livrés. Les costumes du mode Original de HOTD2 remplacent un modèle ; ils ne réécrivent pas les rôles de la campagne.

## Quatre éléments à réutiliser avant de régénérer

| Sujet | Art historique existant | Travail encore nécessaire |
|---|---|---|
| sophie | `assets/sprites/heroes/sophie-hotd.png`<br>`assets/sprites_v2/npcs/sophie_richards/sophie_richards__v2__action_cycle__8dirx8f.png` | Référence de l’édition, adaptation Dossier Curien, puis éventuelle intégration. |
| curien | `assets/sprites/npcs/dr-curien.png`<br>`assets/sprites_v2/npcs/dr_curien/dr_curien__v2__action_cycle__8dirx8f.png` | Référence de l’édition, adaptation Dossier Curien, puis éventuelle intégration. |
| hangedman | `assets/sprites/bosses/hangedman.png`<br>`assets/sprites_v2/bosses/hangedman/hangedman__v2__action_cycle__8dirx8f.png` | Référence de l’édition, adaptation Dossier Curien, puis éventuelle intégration. |
| hermit | `assets/sprites/bosses/hermit-type-6803.png`<br>`assets/sprites_v2/bosses/hermit/hermit__v2__action_cycle__8dirx8f.png` | Référence de l’édition, adaptation Dossier Curien, puis éventuelle intégration. |

Sophie et Curien ne sont donc pas des identités graphiquement absentes de tout le dépôt. Hangedman et Hermit ont eux aussi des atlas historiques ; l’animation d’un atlas ancien ne garantit pas sa compatibilité avec le combat Dossier Curien.

## Boss : couverture par rencontre et par édition

Le tableau décrit des rencontres et apparences, pas un total de personnes. Judgment regroupe Zeal et Kuarl ; Nigel & Sebastian et Coco & Sindy sont des paires. La base humaine de Curien et Wheel of Fate restent des formes à distinguer. Les types numériques ne sont pas recopiés lorsque les listes secondaires se contredisent. [Index de travail des boss](https://thehouseofthedead.fandom.com/wiki/Bosses).

| Jeu | Rencontre | État de la base |
|---|---|---|
| HOTD1 | Chariot | Base déjà jouable dans Dossier Curien ; vérifier la variante de cet épisode |
| HOTD1 | Hangedman | Ancien sprite présent ; adaptation Dossier Curien absente |
| HOTD1 | Hermit | Ancien sprite présent ; adaptation Dossier Curien absente |
| HOTD1 | Magician | Base déjà jouable dans Dossier Curien ; vérifier la variante de cet épisode |
| HOTD2 | Judgment (Zeal + Kuarl) | Aucune base de personnage dédiée |
| HOTD2 | Hierophant | Base déjà jouable dans Dossier Curien ; vérifier la variante de cet épisode |
| HOTD2 | Tower | Aucune base de personnage dédiée |
| HOTD2 | Strength | Aucune base de personnage dédiée |
| HOTD2 | Magician | Base déjà jouable dans Dossier Curien ; vérifier la variante de cet épisode |
| HOTD2 | Emperor | Base déjà jouable dans Dossier Curien ; vérifier la variante de cet épisode |
| HOTD III | Death | Base déjà jouable dans Dossier Curien ; vérifier la variante de cet épisode |
| HOTD III | Fool | Aucune base de personnage dédiée |
| HOTD III | Sun | Aucune base de personnage dédiée |
| HOTD III | Wheel of Fate | Base déjà jouable dans Dossier Curien ; vérifier la variante de cet épisode |
| HOTD4 | Justice | Base déjà jouable dans Dossier Curien ; vérifier la variante de cet épisode |
| HOTD4 | Lovers | Base présente dans la galerie EX ; comparaison avec HOTD4 requise |
| HOTD4 | Empress | Base présente dans la galerie EX ; comparaison avec HOTD4 requise |
| HOTD4 | Temperance | Base présente dans la galerie EX ; comparaison avec HOTD4 requise |
| HOTD4 | Star | Base présente dans la galerie EX ; comparaison avec HOTD4 requise |
| HOTD4 | The World | Base déjà jouable dans Dossier Curien ; vérifier la variante de cet épisode |
| HOTD4 Special | Justice | Base déjà jouable dans Dossier Curien ; vérifier la variante de cet épisode |
| HOTD4 Special | Magician | Base déjà jouable dans Dossier Curien ; vérifier la variante de cet épisode |
| Scarlet Dawn | Chariot | Base déjà jouable dans Dossier Curien ; vérifier la variante de cet épisode |
| Scarlet Dawn | Hangedman | Ancien sprite présent ; adaptation Dossier Curien absente |
| Scarlet Dawn | High Priestess | Aucune base de personnage dédiée |
| Scarlet Dawn | Moon | Base déjà jouable dans Dossier Curien ; vérifier la variante de cet épisode |
| Overkill | Jasper Guns — mutant | Base déjà jouable dans Dossier Curien ; vérifier la variante de cet épisode |
| Overkill | Screamer | Aucune base de personnage dédiée |
| Overkill | Nigel & Sebastian | Aucune base de personnage dédiée |
| Overkill | Crawler | Aucune base de personnage dédiée |
| Overkill | Lobber | Aucune base de personnage dédiée |
| Overkill | Brutus | Aucune base de personnage dédiée |
| Overkill | Mother — boss | Aucune base de personnage dédiée |
| Overkill Extended Cut | Coco & Sindy | Aucune base de personnage dédiée |
| Overkill Extended Cut | Meat Katie | Aucune base de personnage dédiée |

**Lovers, Empress, Temperance et Star ont déjà des bases dans la galerie étiquetée EX.** Leur adaptation HOTD4 n’est donc pas à compter automatiquement comme une identité sans aucun art. Vérifier le design exact et la provenance avant réutilisation. La présence d’une fiche `boss_base` dans le manifeste ne certifie pas que cette apparition est un boss de combat dans EX.

La livraison d’une adaptation Hangedman **HOTD1** ne clôt pas son redesign de Scarlet Dawn. Ce redesign demeure une comparaison et une production distinctes.

## Tenues et formes : règles de production

- **Costume vérifié** : nom du personnage, édition et source montrant effectivement la tenue. Un portrait monochrome seul ne fixe pas toutes les couleurs ni les chaussures.
- **Équipement ou vieillissement** : G Overkill, G III, Rogan III et les équipements de Typing restent rattachés à leur identité existante.
- **Substitution de modèle** : Amy/Harry/G/Rogan/Goldman/Civilian/Bruno dans Original Mode sont des objets de mode ; Bruno reste un personnage invité.
- **Ensemble non documenté** : les costumes Dreamcast de Zombie Revenge ne reçoivent ni faux noms ni compte de palettes distinctes sans images.
- **Remakes et éditions dérivées** : chaque différence visuelle est attachée à une édition ; un port sans nouveau design attesté ne crée pas une nouvelle tenue par défaut.
- **Forme et fin alternative** : Jasper humain/mutant, Mother humain/boss et Sophie/Goldman zombies ne deviennent pas de nouvelles identités à additionner.

Les deux variantes III disposent de références couleur inspectées : [rendu de G/Lisa](https://www.imfdb.org/images/9/9e/HodIII_GandLisa.jpg), [rendu plein pied](https://www.imfdb.org/images/3/37/HodIII_GandLisa_2.jpg), [capture Rogan/Dan](https://www.imfdb.org/images/6/60/HodIII_DanandRogan.jpg). Ce sont des visuels du jeu hébergés par un site secondaire. Les zones cachées, l’éclairage et les différences entre rendu promotionnel et modèle final restent des limites explicites.

## Registre détaillé des travaux

`P1` : cible proche de la production avec source exploitable ; `P2` : manque majeur ou adaptation prioritaire ; `P3` : complément ; `P4` : recherche préalable. Une priorité ne signifie pas que la silhouette entière est déjà suffisamment référencée.

| ID | Sujet / édition | Type de tâche | Priorité | État à la base | Référence visuelle |
|---|---|---|---|---|
| `varla` | Varla Guns (Overkill Extended Cut) | Identité de personnage | P1 | Aucune base de personnage dédiée | Portraits vérifiés ; tenue complète à recouper |
| `candi` | Candi Stryper (Overkill Extended Cut) | Identité de personnage | P1 | Aucune base de personnage dédiée | Portraits vérifiés ; tenue complète à recouper |
| `amy` | Amy Crystal (HOTD2) | Identité de personnage | P1 | Aucune base de personnage dédiée | Corps monochrome et capture couleur du jeu croisés |
| `harry` | Harry Harris (HOTD2) | Identité de personnage | P1 | Aucune base de personnage dédiée | Corps monochrome et capture couleur du jeu croisés |
| `goldman_human` | Goldman — forme humaine (HOTD2) | Identité de personnage | P1 | Aucune base de personnage dédiée | Corps assis monochrome ; couleur à documenter |
| `thornheart` | Thornheart (Scarlet Dawn) | Identité de personnage | P2 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `papa_caesar` | Papa Caesar (Overkill) | Identité de personnage | P2 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `clement` | Clement Darling (Overkill) | Identité de personnage | P2 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `sophie` | Sophie Richards (HOTD1) | Identité de personnage | P2 | Ancien sprite présent ; adaptation Dossier Curien absente | Sprite historique présent ; comparaison canonique à faire |
| `curien` | Dr. Curien (HOTD1) | Identité de personnage | P2 | Ancien sprite présent ; adaptation Dossier Curien absente | Sprite historique présent ; comparaison canonique à faire |
| `dan_taylor` | Dan Taylor (HOTD III) | Personnage secondaire à documenter | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `yukio` | Yukio (HOTD III) | Personnage secondaire à documenter | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `jasper_human` | Jasper Guns — forme humaine (Overkill) | Forme d’un personnage existant | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `mother_human` | Mother — forme humaine (Overkill) | Forme d’un personnage existant | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `bart_picard` | Bart Picard (Overkill) | Personnage secondaire à documenter | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `hangedman` | Hangedman (HOTD1) | Apparence d’une rencontre de boss | P2 | Ancien sprite présent ; adaptation Dossier Curien absente | Sprite historique présent ; comparaison canonique à faire |
| `hermit` | Hermit (HOTD1) | Apparence d’une rencontre de boss | P2 | Ancien sprite présent ; adaptation Dossier Curien absente | Sprite historique présent ; comparaison canonique à faire |
| `judgment` | Judgment (Zeal + Kuarl) (HOTD2) | Apparence d’une rencontre de boss | P2 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `tower` | Tower (HOTD2) | Apparence d’une rencontre de boss | P2 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `strength` | Strength (HOTD2) | Apparence d’une rencontre de boss | P2 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `fool` | Fool (HOTD III) | Apparence d’une rencontre de boss | P2 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `sun` | Sun (HOTD III) | Apparence d’une rencontre de boss | P2 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `high_priestess` | High Priestess (Scarlet Dawn) | Apparence d’une rencontre de boss | P2 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `screamer` | Screamer (Overkill) | Apparence d’une rencontre de boss | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `nigel_sebastian` | Nigel & Sebastian (Overkill) | Apparence d’une rencontre de boss | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `crawler` | Crawler (Overkill) | Apparence d’une rencontre de boss | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `lobber` | Lobber (Overkill) | Apparence d’une rencontre de boss | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `brutus` | Brutus (Overkill) | Apparence d’une rencontre de boss | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `mother` | Mother — boss (Overkill) | Apparence d’une rencontre de boss | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `coco_sindy` | Coco & Sindy (Overkill Extended Cut) | Apparence d’une rencontre de boss | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `meat_katie` | Meat Katie (Overkill Extended Cut) | Apparence d’une rencontre de boss | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `g_overkill` | Agent G — Overkill (Overkill) | Apparence d’une autre époque | P1 | Aucune base de personnage dédiée | Portrait vérifié ; tenue complète à recouper |
| `g_hotd3` | Agent G — HOTDIII (HOTD III) | Apparence d’une autre époque | P1 | Aucune base de personnage dédiée | Rendus promotionnels couleur et plein pied inspectés |
| `rogan_hotd3` | Thomas Rogan — HOTDIII (HOTD III) | Apparence d’une autre époque | P1 | Aucune base de personnage dédiée | Capture inspectée ; chaussures partiellement cachées |
| `james_hotd4` | James Taylor — HOTD4 (HOTD4) | Tenue propre à une édition | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `g_hotd4special` | G — HOTD4 Special (HOTD4 Special) | Tenue propre à une édition | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `james_typing` | James — matériel de Typing (The Typing of the Dead) | Variante d’équipement | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `gary_typing` | Gary — matériel de Typing (The Typing of the Dead) | Variante d’équipement | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `typing2_player_equipment` | Lisa/G/Daniel — équipement Typing2 (The Typing of the Dead 2) | Ensemble de variantes à documenter | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `typing2004_kids` | James/Gary — Kids2004 (The Typing of the Dead 2004) | Variantes d’âge à documenter | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `rogan_saturn2` | Rogan2 — Saturn Mode (HOTD1 — Saturn Mode) | Modèle alternatif | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `g_saturn2` | G2 — Saturn Mode (HOTD1 — Saturn Mode) | Modèle alternatif | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `sophie_saturn` | Sophie — modèle Saturn Mode (HOTD1 — Saturn Mode) | Modèle propre à un mode | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `researcher_saturn` | Chercheur DBR — Saturn Mode (HOTD1 — Saturn Mode) | Modèle générique | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `stick_alts` | Stick — tenues alternatives Dreamcast (Zombie Revenge) | Ensemble de tenues à documenter | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `linda_alts` | Linda — tenues alternatives Dreamcast (Zombie Revenge) | Ensemble de tenues à documenter | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `rikiya_alts` | Rikiya — tenues alternatives Dreamcast (Zombie Revenge) | Ensemble de tenues à documenter | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `sophie_zombie` | Sophie — fin zombie (HOTD1) | Forme de fin alternative | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `goldman_zombie` | Goldman — fin zombie (HOTD2) | Forme de fin alternative | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `hotd_remake_redesigns` | Rogan/G/Sophie/Curien et boss — Remake1 (HOTD Remake) | Apparences du remake à comparer | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `hotd2_remake_redesigns` | Personnages et boss — Remake2 (HOTD2 Remake) | Apparences du remake à comparer | P3 | Aucune base de personnage dédiée | Référence visuelle encore nécessaire |
| `original_model_amy` | Amy — objet Original Mode (HOTD2 — Original Mode) | Objet remplaçant le modèle joueur | P3 | Objet de mode non implémenté ; aucune identité nouvelle à compter | Référence visuelle encore nécessaire |
| `original_model_harry` | Harry — objet Original Mode (HOTD2 — Original Mode) | Objet remplaçant le modèle joueur | P3 | Objet de mode non implémenté ; aucune identité nouvelle à compter | Référence visuelle encore nécessaire |
| `original_model_g` | G — objet Original Mode (HOTD2 — Original Mode) | Objet remplaçant le modèle joueur | P3 | Objet de mode non implémenté ; aucune identité nouvelle à compter | Référence visuelle encore nécessaire |
| `original_model_rogan` | Rogan — objet Original Mode (HOTD2 — Original Mode) | Objet remplaçant le modèle joueur | P3 | Objet de mode non implémenté ; aucune identité nouvelle à compter | Référence visuelle encore nécessaire |
| `original_model_goldman` | Goldman — objet Original Mode (HOTD2 — Original Mode) | Objet remplaçant le modèle joueur | P3 | Objet de mode non implémenté ; aucune identité nouvelle à compter | Référence visuelle encore nécessaire |
| `original_model_civilian` | Civilian — objet Original Mode (HOTD2 — Original Mode) | Objet remplaçant le modèle joueur | P3 | Objet de mode non implémenté ; aucune identité nouvelle à compter | Référence visuelle encore nécessaire |
| `original_model_bruno` | Bruno Delinger — objet Original Mode (HOTD2 — Original Mode) | Objet remplaçant le modèle joueur | P3 | Objet de mode non implémenté ; aucune identité nouvelle à compter | Référence visuelle encore nécessaire |
| `site_doctor` | Docteur et créature de The Site of the Dead (The Site of the Dead) | Recherche préalable | P4 | Branche documentée ; personnages exacts à établir | Référence visuelle encore nécessaire |
| `reawakened_roster` | Personnages de Reawakened (Reawakened) | Recherche préalable | P4 | Branche documentée ; personnages exacts à établir | Référence visuelle encore nécessaire |
| `mobile_nightmare_roster` | Variantes Mobile / Nightmare (Mobile / Nightmare) | Recherche préalable | P4 | Branche documentée ; personnages exacts à établir | Référence visuelle encore nécessaire |
| `ex_unverified_cameos` | Rôles des apparitions secondaires EX (HOTD EX) | Recherche préalable | P4 | Branche documentée ; personnages exacts à établir | Référence visuelle encore nécessaire |

Les remarques propres à chaque ligne, les liens vers les sources et les chemins de réutilisation sont dans [personnages_tenues.json](personnages_tenues.json). Ce registre ne constitue pas une promesse de reconstruction 1:1.

## Toutes les branches du corpus : état de l’audit

| Œuvre / édition | État des personnages et tenues |
|---|---|
| The House of the Dead | Personnages principaux et rencontres de boss indexés ; figurants non exhaustifs |
| The House of the Dead 2 | Personnages principaux et rencontres de boss indexés ; figurants non exhaustifs |
| The House of the Dead III | Personnages principaux et rencontres de boss indexés ; figurants non exhaustifs |
| The House of the Dead 4 | Personnages principaux et rencontres de boss indexés ; figurants non exhaustifs |
| The House of the Dead 4 Special | Personnages principaux et rencontres de boss indexés ; figurants non exhaustifs |
| House of the Dead: Scarlet Dawn | Personnages principaux et rencontres de boss indexés ; figurants non exhaustifs |
| The House of the Dead: Overkill | Personnages principaux et rencontres de boss indexés ; figurants non exhaustifs |
| The House of the Dead: Overkill – Extended Cut | Œuvre inscrite au corpus ; apparences non examinées exhaustivement |
| The House of the Dead: Overkill – The Lost Reels | Œuvre inscrite au corpus ; apparences non examinées exhaustivement |
| Zombie Revenge | Trio jouable et 42 ressources publiées indexés ; tenues alternatives à documenter |
| Loving Deads: The House of the Dead EX | Duo jouable et sept fiches de galerie indexés ; rôles des apparitions à confirmer |
| The Typing of the Dead | Œuvre inscrite au corpus ; apparences non examinées exhaustivement |
| The Typing of the Dead 2 | Œuvre inscrite au corpus ; apparences non examinées exhaustivement |
| The Typing of the Dead: Zombie Panic | Œuvre inscrite au corpus ; apparences non examinées exhaustivement |
| The Typing of the Dead Online | Œuvre inscrite au corpus ; apparences non examinées exhaustivement |
| The Typing of the Dead: Overkill | Œuvre inscrite au corpus ; apparences non examinées exhaustivement |
| K-Typing of the Dead | Œuvre inscrite au corpus ; apparences non examinées exhaustivement |
| Zombie Da: Flick of the Dead | Œuvre inscrite au corpus ; apparences non examinées exhaustivement |
| English of the Dead | Œuvre inscrite au corpus ; apparences non examinées exhaustivement |
| The Pinball of the Dead | Œuvre inscrite au corpus ; apparences non examinées exhaustivement |
| Darts of the Dead | Œuvre inscrite au corpus ; apparences non examinées exhaustivement |
| The Site of the Dead | Œuvre inscrite au corpus ; apparences non examinées exhaustivement |
| The House of the Dead Mobile | Œuvre inscrite au corpus ; apparences non examinées exhaustivement |
| The House of the Dead: Nightmare | Œuvre inscrite au corpus ; apparences non examinées exhaustivement |
| The House of the Dead 2 & 3 Return | Identités communes ; différences visuelles propres à l’édition à comparer |
| The House of the Dead: Remake | Identités communes ; différences visuelles propres à l’édition à comparer |
| The House of the Dead 2: Remake | Identités communes ; différences visuelles propres à l’édition à comparer |
| House of the Dead: Scarlet Dawn – The Attraction | Œuvre inscrite au corpus ; apparences non examinées exhaustivement |
| House of the Dead: Scarlet Dawn – Battle Genesis | Œuvre inscrite au corpus ; apparences non examinées exhaustivement |
| Winning Cash – House of the Dead Scarlet Dawn on Reels | Œuvre inscrite au corpus ; apparences non examinées exhaustivement |
| House of the Dead: Reawakened | Titre officiel vérifié ; liste nominative non établie |
| The Typing of the Dead 2003, The Typing of the Dead 2004 | Éditions consignées ; nouveautés visuelles non supposées. |
| The Typing of the Dead featuring Rakuten Minna no Shūshoku Katsudō Nikki, Zombie Da: Typing Lariat for Mac | Éditions consignées ; nouveautés visuelles non supposées. |
| The Typing of the Dead US Edition | Éditions consignées ; nouveautés visuelles non supposées. |
| The Typing of the Dead, édition à prix révisé (2005) | Éditions consignées ; nouveautés visuelles non supposées. |
| Zombie Da: Typing Lariat (Windows) | Éditions consignées ; nouveautés visuelles non supposées. |

**Restent ouverts :** tous les ennemis ordinaires hors sous-ensemble déjà présent, variantes de figurants, formes mobiles, personnages du laboratoire Site, détails de Kids 2004, silhouettes de Reawakened et différences exactes de chaque remake. Reawakened est confirmé par [SEGA le 28 octobre 2026](https://segaarcade.com/news/dare-to-experience-house-of-the-dead-reawakened) ; l’annonce ne fournit pas à elle seule un nouveau roster nominatif.

Le cinéma constitue une continuité séparée. Les invités SEGA restent des invités. *Requiem* et *Absolution* sont des créations du projet. *Blood Bullet* est un nom de développement de *Zombie Revenge*, et les homonymes ou titres non établis ne reçoivent aucun personnage inventé. Le [registre existant](../../SOURCES_SAGA.json) conserve les références de ces frontières.

## Points à corriger dans la lecture des anciens documents

- Gary, Daniel, Emperor, Wheel of Fate, The World, Moon et Linda sont déjà livrés ; une vieille table « à produire » ne doit plus les présenter comme totalement absents.
- Les arènes `goldman_*` et `clocktower_*` ne sont pas les sprites de Goldman ni de Tower.
- Le manifeste d’expansion contient encore des statuts de revue partielle. « Présent » signifie qu’un fichier est livré, jamais que sa fidélité canonique ou son animation sont entièrement certifiées.
- La nationalité d’Amy diffère entre le manuel SEGA original et une page de support Remake. Ce catalogue n’arbitre pas une biographie hybride.
- Les générations du 20 novembre figurent dans leurs manifestes de lot. Le baseline 59372b6 reste gelé pour que la réduction des manques soit mesurable.

## Sources et vérification

[Sources classées et limites d’accès](sources_personnages_tenues.json). Sources primaires, documents SEGA réhébergés, captures du jeu chez des tiers et index communautaires portent des niveaux distincts. Les liens hérités du corpus sont signalés comme non réexaminés exhaustivement.

Contrôles documentaires effectués :24 profils extraits du code,40 fiches hors poses extraites du manifeste,332 chemins PNG de l’arbre distant,330 blobs distincts,30 entrées motion,2 costumes alternatifs pilotés par le menu. Tous les chemins de réutilisation sont présents à la base. Aucune modification du runtime, aucun export ni test moteur n’est requis par ces seuls documents.
