# La deuxième paire d’agents et les deux boss de fin

Ce cahier accompagne les quatre combattants ajoutés aux parcours de l’AMS. Les modèles de référence sont ceux de *The House of the Dead 2* et *The House of the Dead III*. Les dessins de profil, les attitudes et leur durée à l’écran ont été créés pour le mode de combat.

## Ce qui identifie chaque silhouette

| Combattant | Élément à reconnaître à la distance normale de combat | Ce que le passage en 2D change |
|---|---|---|
| Emperor, Type α | Corps humanoïde anguleux, matière bleutée presque transparente, noyau rose et petites sphères d’argent. Dans la rencontre originale, le ciel se voit sur la surface de la créature. | Un liseré indigo et des reflets clairs fixent la silhouette sur les décors sombres comme sur les décors clairs. Le contact allonge la lame de mercure vers l’adversaire. La garde représente la forme originale choisie pour le duel. |
| Wheel of Fate, Type 0000 | Un humanoïde métallique se tient dans une immense roue à pointes. Les panneaux bleus et violets séparent la jante du corps argenté. Le torse porte un accent vert. | La vue de trois quarts garde l’ouverture de la roue visible. Le corps agit à l’intérieur du cercle. La roue et l’humanoïde partagent une image avec un seul pivot. Les pointes et les jours entre les rayons se lisent en transparence. |
| Gary Stewart | Jeune agent de l’AMS. Le manuel Dreamcast montre sa mèche latérale, son visage découvert et sa tenue de ville. Costume bleu, chemise blanche, cravate grise et chaussures brunes distinguent Gary de son partenaire James. | La garde rapproche les mains du buste. Le spécial combine un pas de retrait et une visée tendue vers la droite. Un cinquième dessin réserve le coude au coup léger. |
| Daniel Curien | Dans la scène où il se présente, Daniel porte de petites lunettes claires à monture fine, des cheveux châtains courts, une veste grise ouverte et un haut sombre à col rond. | L’arme longue du dernier chapitre sert d’appui visuel. À l’anticipation elle suit la ligne des épaules. La poussée et le recul changent sa diagonale. Un reflet bref dessine la monture sans masquer les yeux. |

### Documents d’identification

- **Gary.** Le manuel édité par SEGA présente James et Gary dans la double page intitulée *Character Introductions*. Le portrait de Gary se trouve sur la page imprimée 3, dans la moitié droite du fichier numérisé. La reproduction consultée est monochrome. La couleur du costume provient de l’apparence du personnage dans le jeu. [Manuel Dreamcast, p. 3](https://www.digitpress.com/library/manuals/dreamcast/house_dead_2.pdf#page=2) · [SEGA, fiche arcade de The House of the Dead 2](https://www.sega.jp/history/arcade/product/8991/)
- **Emperor.** L’écran d’identification présente le nom, le type et la silhouette. Le combat dans le ciel montre le rapport entre noyau, corps et sphères. La palette varie avec les reflets et l’état du boss. [Écran d’identification du jeu](https://www.k-triggerhappy.com/hod2/boss6.jpg) · [Forme bleue](https://www.k-triggerhappy.com/hod2/boss6-1.jpg) · [Autre état lumineux](https://www.k-triggerhappy.com/hod2/boss6-2.jpg)
- **Wheel of Fate.** Le dessin en pied montre la roue complète, la proportion du corps et les pointes extérieures. Le combat confirme la forte luminosité des quartiers bleus et la place du corps dans l’ouverture. [Rendu du personnage](https://pbs.twimg.com/media/ERZvveUXYAATjPh.jpg) · [Capture de la roue en jeu](https://www.k-triggerhappy.com/hod3/boss5-1.jpg) · [Chapitre 5 et autres vues](https://www.k-triggerhappy.com/hod3/chapter5.html)
- **Daniel.** Le manuel présente le jeune homme lié au site EFI et la cinématique donne une vue rapprochée de ses lunettes, du col et de la veste. [Manuel PC de The House of the Dead III, fiche de Daniel](https://www.arcadeguns.com/download/HOD3_Manual.pdf#page=10) · [Daniel dans la cinématique de présentation sur PC](https://www.vizzed.com/videogames/screenshots/50/502012/83827/The%20House%20of%20the%20Dead%20III_hod3pc%202019-06-07%2015-11-36-121559919534-full.png)

## Lecture des quatre dessins

| Combattant | Garde | Anticipation | Contact | Recul |
|---|---|---|---|---|
| Emperor | Noyau dégagé et sphères en orbite | Bras ramené, sphères resserrées | Lame projetée horizontalement | Buste cambré, satellites écartés |
| Wheel of Fate | Humanoïde au centre de sa roue | Épaules rentrées et roue inclinée | Bras tendu près du bord intérieur | Buste et épaules rejetés en arrière |
| Gary | Pistolet court près de la poitrine | Poids reporté sur le pied arrière | Pistolet au bout des bras, tir en retrait | Buste rejeté, pan de veste et cravate en mouvement |
| Daniel | Arme basse, veste entrouverte | L’arme et les coudes reviennent au buste | Poussée des deux bras | Appui arrière et canon relevé |


## Écarts visibles avec les modèles d’origine

En vue frontale, la tête d’Emperor dessine deux pointes latérales. Le profil du sprite réunit ces pointes en une crête projetée vers l’arrière. La garde laisse quatre sphères visibles. Le noyau d’origine est arrondi et mobile. Dans les quatre dessins, ses facettes roses et sa position sur le sternum fournissent un repère stable au réticule du duel. La couleur indigo de l’ombre détache le corps de l’arrière-plan.

Sur le rendu de référence de Wheel of Fate, le corps argenté mesure environ la moitié du diamètre extérieur de la roue, pointes comprises. Dans la garde, la tête et les pieds occupent environ 48 % de cette hauteur. Le motif des panneaux et les pointes secondaires sont simplifiés pour rester visibles à la taille de jeu. Les segments restent attachés à la silhouette lors du retournement. Dans la scène de duel, la garde de Wheel occupe 360 unités en hauteur, contre 310 pour Emperor, 273 pour Gary et 275 pour Daniel. La roue s’élève ainsi environ 31 % plus haut que Daniel.

La frange de Gary et les lunettes de Daniel sont redessinées d’après des visages rendus en trois dimensions. L’angle de la raie, les plis et la longueur apparente des accessoires varient légèrement entre poses. Les dessins emploient la même palette de costume et le même point d’appui.

## Mesures de livraison

Les dix-sept PNG en RGBA se trouvent dans `assets/dossier_curien/saga/`. Leur hauteur de texture est de 1 024 px. Le repère au sol utilise x = largeur / 2, y = 960, quelle que soit la largeur du dessin. Pour les agents et Emperor, l’axe horizontal suit les appuis. Pour Wheel of Fate il suit le centre de l’enveloppe de la roue. Les rectangles ci-dessous englobent tous les pixels non transparents. Les coordonnées de droite et du bas sont exclusives.

| Fichier PNG | Texture (px) | Axe x (px) | Rectangle alpha (gauche, haut, droite, bas) |
|---|---:|---:|---|
| `emperor_guard.png` | 1024 × 1024 | 512 | 291, 55, 766, 960 |
| `emperor_windup.png` | 1024 × 1024 | 512 | 240, 95, 916, 960 |
| `emperor_contact.png` | 2272 × 1024 | 1136 | 690, 107, 2247, 960 |
| `emperor_recoil.png` | 1120 × 1024 | 560 | 25, 90, 883, 960 |
| `wheel_guard.png` | 1024 × 1024 | 512 | 102, 55, 921, 960 |
| `wheel_windup.png` | 1024 × 1024 | 512 | 163, 55, 861, 960 |
| `wheel_contact.png` | 1024 × 1024 | 512 | 98, 55, 927, 960 |
| `wheel_recoil.png` | 1024 × 1024 | 512 | 108, 69, 916, 960 |
| `gary_guard.png` | 1024 × 1024 | 512 | 248, 55, 778, 960 |
| `gary_windup.png` | 1024 × 1024 | 512 | 201, 121, 825, 960 |
| `gary_contact.png` | 1024 × 1024 | 512 | 221, 71, 934, 960 |
| `gary_recoil.png` | 1024 × 1024 | 512 | 247, 94, 757, 960 |
| `gary_melee.png` | 1024 × 1024 | 512 | 174, 99, 874, 960 |
| `daniel_guard.png` | 1024 × 1024 | 512 | 239, 55, 815, 960 |
| `daniel_windup.png` | 1024 × 1024 | 512 | 249, 119, 776, 960 |
| `daniel_contact.png` | 1648 × 1024 | 824 | 432, 92, 1622, 960 |
| `daniel_recoil.png` | 1024 × 1024 | 512 | 252, 107, 773, 960 |

La [planche des 17 poses](Combattants_volume_III.webp) réunit les prises de vue à taille comparable dans l’ordre garde, anticipation, contact, recul. Un cartouche supplémentaire montre le coup de coude de Gary, réservé à son attaque légère. La ligne horizontale de chaque case figure l’appui commun.
