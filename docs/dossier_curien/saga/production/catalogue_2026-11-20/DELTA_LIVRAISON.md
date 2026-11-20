# Livraison graphique du 20 novembre 2026 — rapprochement avec l’inventaire

**Le lot apporte neuf bases de galerie : quatre identités, trois variantes de costume et deux adaptations de boss historiques.** Il ajoute aussi deux arènes, chacune en trois couches. Les 15 PNG représentent **13 466 764 octets**. Ces chiffres sont contrôlés sur les fichiers et manifestes locaux ; la publication distante relève du commit final.

| Mesure | Avant | Après intégration des sources |
|---|---:|---:|
| Fiches de galerie | 40 | 49 |
| Arènes enregistrées | 18 | 20 |
| PNG dans Dossier Curien | 332 | 347 |
| Blobs d’image distincts | 330 | 345 |
| Combattants jouables | 24 | 24 |
| Tenues alternatives dans le sélecteur | 2 | 2 |
| Lacunes de poses nommées de l’inventaire motion | 277 | 277 |

## Les neuf bases livrées

| Ligne de l’inventaire → ID de galerie | Nature de l’ajout | Contrôle visuel | Suite nécessaire |
|---|---|---|---|
| `amy` → `amy_crystal` | Identité nouvellement illustrée | Références comparées ; limites de fidélité conservées | Couleur des bottes interprétée depuis le manuel monochrome ; source couleur plus complète souhaitée. |
| `candi` → `candi_stryper` | Identité nouvellement illustrée | Base produite ; contrôle canonique encore nécessaire | Vue canonique plein pied : bas de tenue et orthèse à revoir. Animation ouverte. |
| `g_hotd3` → `g_hotd3` | Variante visuelle d’une identité existante | Références comparées ; limites de fidélité conservées | Vue trois-quarts, plis du gilet et fusil adaptés. Sélecteur de costumes inchangé. |
| `g_overkill` → `g_overkill` | Variante visuelle d’une identité existante | Références comparées ; limites de fidélité conservées | Garde avec une arme adaptée depuis un rendu à deux armes. Sélecteur inchangé. |
| `hangedman` → `hangedman` | Adaptation d’un boss déjà illustré dans l’ancien jeu | Références comparées ; limites de fidélité conservées | HOTD1 uniquement ; redesign Scarlet Dawn toujours manquant. Animation ouverte. |
| `harry` → `harry_harris` | Identité nouvellement illustrée | Références comparées ; limites de fidélité conservées | Détail des chaussures reconstruit ; pose de garde adaptée. |
| `hermit` → `hermit` | Adaptation d’un boss déjà illustré dans l’ancien jeu | Références comparées ; limites de fidélité conservées | Référence PC ; aucune équivalence détaillée Saturn/Remake. Animation ouverte. |
| `rogan_hotd3` → `rogan_hotd3` | Variante visuelle d’une identité existante | Références comparées ; limites de fidélité conservées | Chaussures partiellement cachées dans la capture ; détails complétés sobrement. Sélecteur inchangé. |
| `varla` → `varla_guns` | Identité nouvellement illustrée | Base produite ; contrôle canonique encore nécessaire | Vue canonique plein pied : jupe, bottes, holster et tatouages à revoir. Animation ouverte. |

Les sept entrées dont les références ont été comparées ne sont pas déclarées fidèles 1:1. Varla et Candi gardent explicitement le statut de revue visuelle canonique incomplète. Les limites exactes, prompts, références et empreintes restent dans le [manifeste de galerie](../../../../../data/assets/dossier_curien_gallery_2026-11-20.json).

## Comment lire les 62 lignes initiales

**Neuf lignes reçoivent une base statique Dossier Curien ; 53 lignes ne sont pas couvertes par ce lot.** Ce résultat décrit la couverture du lot. Les lignes initiales mélangent personnages, formes, rencontres de boss, groupes de tenues encore à documenter et recherches : 53 ne signifie donc pas 53 personnages restants.

Les neuf bases ne clôturent pas leurs animations ou leur éventuelle intégration au combat. Les deux costumes III et G Overkill sont consultables en galerie ; leur arrivée ne modifie pas les deux tenues du sélecteur historique. Hangedman/Hermit réutilisent des identités déjà présentes dans les sprites historiques : aucun nouveau personnage unique n’est ajouté à ce titre. L’apparence Scarlet Dawn de Hangedman demeure explicitement ouverte.

Le [registre JSON du delta](delta_livraison.json) relie chaque ID de production au bon fichier et conserve la liste précise des 53 lignes non couvertes. Le [baseline 59372b6](baseline_59372b6.json) est gelé ; le [catalogue initial](PERSONNAGES_TENUES.md) continue de décrire cet état, avec les sources et incertitudes de départ.

## Animations et décors

L’inventaire [motion du 19 novembre](../motion_2026-11-19/MANQUANTS.json) garde **277 lacunes de poses nommées**. Ces neuf images statiques n’en soustraient aucune. Un éventuel budget complet d’animation pour les nouveaux sujets demanderait une estimation séparée, selon leur rôle finalement retenu.

Les arènes ajoutées sont **Toit du train — Zombie Revenge** et **Abattoir — Creeping Flesh**. Leurs six couches représentent **5 725 296 octets** ; les neuf bases de galerie représentent **7 741 468 octets**. Le [rapport des décors](../stages_2026-11-20/RAPPORT.md) décrit leurs sources et leur transposition latérale.

## Vérification de cette réconciliation

Les 15 tailles et SHA256 concordent avec les manifestes ; tous les chemins de référence de la galerie existent. L’union de l’arbre distant de départ et des 15 nouveaux PNG donne 347 chemins et 345 blobs Git distincts. Aucun autre PNG Dossier Curien local nouveau n’est absent de ce rapprochement. Les vingt arènes sont présentes dans le registre de sources. Ces vérifications documentaires ne sont pas des captures du jeu ni une déclaration de test moteur par cet audit.
