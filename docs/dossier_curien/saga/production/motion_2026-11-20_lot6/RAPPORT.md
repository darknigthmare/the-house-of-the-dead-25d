# Motion — lot 6 du 20 novembre 2026

## Livraison

Neuf nouvelles poses individuelles complètent **Rikiya Busujima, tenue de base déjà jouable**. Chaque pose utilise un PNG natif distinct de 1254 × 1254 pixels, en RGBA transparent, généré avec le dessin existant `assets/dossier_curien/saga/rikiya_guard.png` comme référence d’identité, de tenue et de style. Les neuf images représentent 6 765 323 octets. Les images historiques, le manifeste du 19 novembre et les dessins de la garde, du contact, des marches et de la récupération sont conservés. Les trois derniers états (`victory`, `taunt`, `finish`) ont été ajoutés après le premier contrôle à six poses ; les six premiers PNG et leurs entrées runtime sont restés identiques.

| Identifiant | État du combat qui consomme le dessin | Manque historique clos |
| --- | --- | --- |
| `rikiya_jump_rise` | Saut sans attaque, vitesse verticale positive | `rikiya / jump_rise` |
| `rikiya_jump_fall` | Saut sans attaque, altitude positive et vitesse verticale nulle ou négative | `rikiya / jump_fall` |
| `rikiya_crouch` | Accroupissement au sol sans garde | `rikiya / crouch` |
| `rikiya_crouch_guard` | Accroupissement et garde basse au sol | `rikiya / crouch_guard` |
| `rikiya_block` | Réaction à un impact bloqué debout, ou garde immobile | `rikiya / block` |
| `rikiya_throw` | Action de projection, depuis sa préparation jusqu’à sa récupération existante | `rikiya / throw` |
| `rikiya_victory` | Vainqueur pendant la fin de manche, l’opportunité de finition et le résultat | `rikiya / victory` |
| `rikiya_taunt` | Provocation neutre pendant son minuteur cosmétique existant | `rikiya / taunt` |
| `rikiya_finish` | Vainqueur pendant la cinématique de finition existante | `rikiya / finish` |

Ces états étaient déjà routés par `presentation.gd:pose_suffix`. Le lot leur fournit une image propre et la rend disponible au chargeur. Il ne modifie ni dégâts, ni timings, ni portée, ni hitboxes. La projection utilise une seule image de saisie pendant son action : elle compte pour **un** manque résolu, sans revendiquer une animation de projection complète. La posture de saut ascendant utilise le genou opposé à celui demandé dans le prompt initial ; cette variation a été retenue car le genou n’est associé à aucun équipement ou contact particulier dans cette action.

## Production et pixels natifs

Les prompts exacts, les références et les chemins de sortie sont conservés dans les neuf reçus `*_generation.json`. La copie déposée dans `assets/dossier_curien/motion_2026-11-20_lot6/` possède la même empreinte SHA-256 que sa sortie native. Aucune image finale n’a subi de redimensionnement, de détourage, de recolorisation ou de réencodage local.

Le premier essai de garde basse contenait un halo gris-beige. Il est conservé dans `rejected/`, avec son reçu et sa raison de rejet, et n’est pas répertorié comme asset jouable. Une correction ciblée par **image_gen.imagegen** a supprimé ce halo en conservant la posture. L’image corrigée a été revue et copiée directement. Les neuf sorties finales possèdent un alpha minimum de 0, un alpha maximum de 255 et aucun pixel d’alpha supérieur à 127 sur les quatre bords. Les boîtes visibles au seuil 16 restent limitées à la silhouette : aucun halo comparable à celui du rejet n’est conservé.

L’identité visuelle reprise comprend les cheveux noirs bouclés, les lunettes sombres, le torse nu, le harnais brun à boucles métalliques, le jean bleu et les chaussures brunes. Les mains restent vides. Cette continuité avec le dessin du projet ne constitue pas une certification canonique 1:1.

## Calibration

`calibration.json` conserve les repères mesurés dans les pixels natifs. Le dessin de garde a une hauteur visible de 901 pixels et un intervalle couronne-menton de 156 pixels. Certaines nouvelles images ont agrandi le personnage pour remplir davantage le canevas malgré leur posture basse ; réutiliser seulement le ratio 1254/1024 aurait donc grossi sa tête lors de l’accroupissement.

La hauteur debout équivalente est calculée avec le rapport des repères de tête, et non avec la hauteur de la boîte de la pose accroupie. Le pivot suit l’axe du bassin et la semelle d’appui la plus basse. Pour les deux sauts, il représente la ligne virtuelle de semelle avant application de l’altitude simulée. Le moteur applique cette échelle et ce pivot sans modifier le PNG. Une hauteur debout équivalente peut dépasser la hauteur du canevas pour une silhouette très repliée : elle décrit la stature dépliée, pas les dimensions du fichier.

| Pose | Pivot natif | Hauteur debout équivalente |
| --- | --- | ---: |
| Accroupissement | (600, 1173) | 1299,519 px |
| Garde basse | (585, 1193) | 1339,949 px |
| Blocage debout | (590, 1175) | 1178,231 px |
| Montée du saut | (560, 1100) | 1103,147 px |
| Descente du saut | (585, 1160) | 1195,558 px |
| Saisie | (550, 1136) | 1212,885 px |
| Victoire | (610, 1223) | 1051,167 px |
| Provocation | (590, 1196) | 1230,212 px |
| Finition | (580, 1172) | 1299,519 px |

La sélection des postures basses existante conserve une hauteur de profil de 284 unités avant application de cette calibration ; elle n’ajoute pas la réduction automatique de 71 % utilisée par les solutions de repli. Aucun émetteur de projectile n’est déclaré pour ces actions à mains vides. Des repères de semelles et de paumes sont conservés pour le contrôle géométrique.

La victoire se tient plus droite que la garde fléchie, avec une échelle de tête commune ; sa stature visible n’est donc pas normalisée à la hauteur de la silhouette de garde. L’ancre `striking_palm` de la finition sert au contrôle géométrique. La cinématique de Rikiya dessine déjà ses marques de paume sur la cible et ne consomme pas d’origine de projectile : aucun émetteur ni nouvel effet n’a été ajouté. La provocation utilise la main opposée à celle demandée dans le prompt, sans changement d’équipement ni de collision ; il s’agit toujours du même geste cosmétique d’invitation.

## Chargement et conservation

`saga_motion.gd` lit explicitement les deux manifestes datés, dans l’ordre historique puis lot 6. Une collection absente ou malformée ne supprime pas les poses déjà acceptées ; une identité dupliquée ne remplace jamais la première image. Les racines d’assets restent limitées aux deux répertoires déclarés. Le validateur de publication contrôle séparément chaque répertoire et refuse les doublons entre collections.

La collection historique compte 30 images ; ce lot en ajoute neuf, soit **39 poses cataloguées** et **42 660 963 octets** dans les deux manifestes réunis. Le script reproductible `build_manifest.py` recalcule les métadonnées et rapproche les actions du bilan historique sans toucher aux pixels.

## Listing des manques

`MANQUANTS.json` cite le fichier du 19 novembre et son SHA-256. Il conserve les 22 résolutions historiques et ajoute les neuf correspondances précises ci-dessus. Le minimum suivi passe de **277 à 268 poses nommées manquantes** ; le total résolu depuis la base de 299 passe de 22 à 31. La ligne de Rikiya comprend désormais ses **16 poses nommées attendues, zéro manque nommé** dans cette matrice. Cela ne complète pas ses animations intermédiaires. Le delta de l’extension conserve aussi l’étape initiale de 271 puis les trois derniers manques clos.

Les 204 maîtres historiques non récupérés restent signalés. Les images intermédiaires, animations continues, autres mouvements, personnages, tenues et arènes restent des périmètres séparés. Aucune nouvelle carte de galerie, tenue sélectionnable ou place dans le roster n’est comptée pour ces neuf poses.

## Validation et limites

Le contrôle Node de publication accepte les deux collections finales et leurs **39 images, 42 660 963 octets**. Les deux manifestes ont `provisional=false`. Les 15 cas du validateur, inchangé pendant l’extension, couvrent notamment les empreintes, les dimensions, les pivots, la provenance en attente, les chemins non autorisés, les fichiers non déclarés et les doublons entre collections. Le statut final et les résultats de publication sont consignés dans `FINAL_REVIEW.json`.

Le premier passage ciblé sous **Godot 4.7.2 a réussi 196 contrôles avec zéro échec**, pour les six premières poses. Son reçu, son manifeste, sa calibration et son journal sont conservés dans `pre_extension/`. La suite étendue passe **227 contrôles, zéro échec, aucun avertissement**. Elle vérifie également les touches réelles O/J/Échap/I/Y, les K.-O. de manche et de match, la pause de l’opportunité de finition, le refus de la commande du perdant, les 72 tics de cinématique et le retour à la victoire. Elle conserve les vérifications des textures natives, sauts, poses basses, blocage, projection, pivots dans les deux orientations et calibrations historiques. L’empreinte des neuf entrées runtime est identique entre le test et la finalisation de leur statut. Les résultats finaux de l’extension sont conservés dans `FINAL_REVIEW.json` et `qa_logs/`.

L’agent principal a également examiné indépendamment les neuf PNG natifs, en deux revues successives de six puis trois images, et les a comparés à la garde historique : identité, harnais, jean, chaussures, mains vides, membres et appuis entiers, états distincts. Sur les trois derniers PNG, les pixels rouge/vert vifs examinés aux contours ont un alpha maximal de 2/255 pour la victoire, 4/255 pour la provocation et 2/255 pour la finition ; aucun n’excède 16/255. Cette revue porte sur les sources et les repères anatomiques, pas sur une capture du duel.

**Aucune capture native du combat n’est revendiquée dans ce lot.** Le serveur Xorg local ne peut pas démarrer : la création d’un socket AF_UNIX est refusée par le système avec `EPERM / Operation not permitted`. Les diagnostics sont conservés dans `qa_logs/native-display-diagnostic.txt` et `qa_logs/xorg-capture-attempt.txt`. Le script de capture est prêt pour les neuf nouvelles poses et pour les deux manifestes, mais il conserve son refus des faux rendus headless/dummy. Les pixels sources ont été examinés visuellement ; le contrôle géométrique et les tests Godot sans affichage ne remplacent pas une revue visuelle du duel rendu.

Aucun export PCK ou web, commit, push ou fusion n’est réalisé par ce chantier motion. L’intégration et la publication commune du lot sont suivies séparément.
