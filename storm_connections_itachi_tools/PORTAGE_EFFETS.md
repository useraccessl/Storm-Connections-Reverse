# Portage des effets Storm Connections vers GMod

## Objectif et Ã©tat

Reproduire les calculs et les ressources du moteur, puis vÃ©rifier leur sortie.
Le lecteur r6 interpole des transformations GPU capturÃ©es : il sert uniquement
de rÃ©fÃ©rence visuelle. `procedural_player.lua` exÃ©cute dÃ©sormais l'impact
Amaterasu Ã  partir des fichiers, sans ces transformations. Ce lecteur r7 est
un diagnostic fonctionnel, **pas encore un portage visuellement exact**.
La rÃ©vision r8 charge les maillages une fois et les transforme au rendu ;
elle remplace la reconstruction de tous les sommets par image. Le fog reste
calculÃ© par sommet, maintenant dans `amt_secondary_r8_vs30` Ã  partir du clip W.

ExÃ©cutable analysÃ© : `NSUNSC.exe`, SHA256
`cecf0405b5ac00b9b9c95e8ff594bde5f8543413b6308f74991c701218b20d1e`.
Les adresses ci-dessous correspondent Ã  cette version. Pour une autre version,
retrouver les fonctions et vÃ©rifier les instructions avant de rÃ©utiliser les offsets.

## Processus rÃ©utilisable

1. Identifier le skill et ses Ã©vÃ©nements dans `data/skill/*.xfbin` ; retrouver
   les effets rÃ©ellement dÃ©clenchÃ©s. Amaterasu utilise `4efb_amt1_x` et
   `4efb_amt1`, pas l'ancien `2efb_amt00`.
2. Extraire le graphe de rÃ©fÃ©rences de chaque nuccChunkParticle : ressources,
   attaches, forces, Ã©vÃ©nements. PrÃ©server l'ordre du fichier et les octets
   bruts des champs inconnus. Charger aussi les dÃ©pendances partagÃ©es
   (`1efcmn.xfbin` ici). Ne pas choisir les ressources Ã  leur seul nom.
3. Exporter NUD (positions, UV, RGBA, triangles, Ã©tats de rendu), NUT, BB et
   ANM. `export_procedural_assets.py` et `export_auxiliary_resources.py`
   montrent cette extraction pour le jeu de rÃ©fÃ©rences Amaterasu actuel.
   Leur sÃ©lection d'entrÃ©e reste spÃ©cifique Ã  cet effet ; il faut la rendre
   configurable avant de les appeler pour un autre skill.
4. Convertir les blocs BC1/BC2/BC3 NUT directement en VTF avec
   `nut_to_vtf.py`. VÃ©rifier l'Ã©galitÃ© des blocs, les dimensions et le format ;
   aucune texture dessinÃ©e ni recompression n'est nÃ©cessaire.
5. DÃ©coder les paramÃ¨tres avec `build_runtime_data.py --captured`.
   Garder les indices numÃ©riques des canaux BB dans Lua. Le JSON les change
   en chaÃ®nes : l'exporteur doit les reconvertir explicitement.
6. Pour chaque branche rencontrÃ©e, retrouver le calcul dans l'exÃ©cutable,
   conserver la preuve, transcrire dans un module pur, puis vÃ©rifier avec des
   entrÃ©es indÃ©pendantes. Une branche inconnue doit apparaÃ®tre dans la
   couverture ; ne pas lui attribuer silencieusement un comportement visuel.
7. Raccorder la scÃ¨ne : calendrier et ordre des gÃ©nÃ©rateurs, coordonnÃ©es ANM,
   topologie des attaches, seed global, forces globales/locales et activation.
   `procedural_scene.lua` fournit maintenant le raccord pour l'impact ; les
   appels du moteur hÃ´te encore inconnus restent des entrÃ©es Ã  rÃ©soudre.
8. Raccorder chaque famille de ressources et chaque shader. Conserver la
   distinction entre cible couleur et cible diffÃ©rÃ©e de posttraitement.
9. Utiliser les captures GPU comme oracle, pas comme stockage de positions
   pour le lecteur final. Comparer Ã  des Ã¢ges connus : naissances, positions,
   bases, tailles, couleurs, UV, constantes, textures, Ã©tats et sortie pixel.
10. Tester dans GMod en tournant la camÃ©ra et en changeant le framerate.
    Ne qualifier le portage d'exact qu'aprÃ¨s comparaison complÃ¨te, notamment
    aux limites de lifetime, aux Ã©vÃ©nements stop et aux changements d'atlas.

## Routines et modules

| Calcul | Fonction originale | Module |
|---|---|---|
| RNG / intervalles | 0x1412cd5c0 / 5f0 / 630 | particle_spawn_core.lua |
| Ã‰mission et Ã©vÃ©nements | 0x14131bbb0 | emission_core.lua |
| Naissance, sÃ©lection ressource | 0x14131b5c0 | procedural_runtime.lua |
| Naissance sur une attache | 0x14131c560 | particle_spatial_core.lua |
| Naissance entre attaches | 0x14131cbf0 | particle_spatial_core.lua |
| Cone / axe | 0x1412cd160 | particle_spatial_core.lua |
| Taille et couleur | 0x14131d460 | runtime_core.lua |
| Forces | 0x141385ec0 | particle_motion_core.lua |
| IntÃ©gration et masques de forces | 0x141386b70 | particle_motion_core.lua / routeFields |
| Horloge BB | 0x14130b200 / 0x1412c7b00 | runtime_core.billboardFromParticle |
| Compteur de ruptures | 0x1413856b0 | scene_spatial_core.segments |
| Getter rupture (+68 virtuel) | 0x1413852f0 | scene_spatial_core.segments |

### Topologie retrouvÃ©e

Le loader place le champ fichier +0x1c Ã  +0xc dans la configuration de
l'attache rÃ©fÃ©rencÃ©e par le nÅ“ud. L'ajout incrÃ©mente le nombre de ruptures
quand ce champ est non nul ; le getter virtuel +0x68 lit le mÃªme champ.
Le choix alÃ©atoire utilise `n - ruptures` (ou `n` si tous sont des ruptures).
L'indice zÃ©ro utilise directement les deux premiers nÅ“uds. Les autres indices
parcourent les nÅ“uds sans rupture ; la fin retombe sur les deux derniers nÅ“uds.
Il n'y a pas de fermeture automatique dernierâ†’premier. La transposition
prÃ©serve mÃªme les choix dupliquÃ©s de cette routine.

`inspect_attachment_topology.py` relit le vtable et les instructions de cette
version. `spawn_multi_attachment.asm` contient la branche de sÃ©lection.

## VÃ©rifications disponibles

Utiliser Python du runtime Codex et les dÃ©pendances locales `vendor` :

```powershell
$stormPython = 'C:\Users\edenm\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
& $stormPython verify_file_motion.py
& $stormPython verify_procedural_assets.py
& $stormPython verify_particle_spatial.py
& $stormPython verify_secondary_reference.py
& $stormPython verify_procedural_scene.py
& $stormPython verify_procedural_player.py
& $stormPython audit_secondary_parameters.py
```

Les deux derniers contrÃ´les vÃ©rifient la scÃ¨ne complÃ¨te pendant 360 mises Ã 
jour, puis le raccord Source pendant 180 images avec API simulÃ©e. Ils couvrent
les naissances des cendres/flammes latÃ©rales, la fin des particules, la
reproductibilitÃ© du RNG, les valeurs finies et les triangles soumis. Ils ne
font pas fonctionner les shaders sur le GPU de GMod.

AprÃ¨s correction de l'Ã©chantillonnage BB avant incrÃ©ment, 130 des 147 draws
secondaires ont un triplet UV/couleur/opacitÃ© compatible avec les courbes
originales, Ã  1e-4 prÃ¨s. L'ancien Ã©chantillonnage aprÃ¨s incrÃ©ment n'en couvrait
que 84 dans le premier audit. Le rapport conserve les 17 Ã©carts : surtout
des Ã©lÃ©ments tardifs et deux draws fire04. L'audit cherche des Ã¢ges/lifetimes
compatibles ; il ne retrouve pas les identitÃ©s des particules et ne valide
donc ni leur mouvement ni la couleur finale aprÃ¨s posttraitement.

Le test Source simulÃ© ne soumet plus aucun sommet pendant 180 images :
10 134 sommets chargÃ©s Ã  l'activation, contre 2 977 710 soumissions dans
l'ancien chemin pour cette mÃªme sÃ©quence de diagnostic. Ce dÃ©compte prouve
la suppression du travail par sommet en Lua, pas un multiplicateur de FPS.

Le contrÃ´le secondaire compare 147 draws des sept RDC dÃ©jÃ  disponibles aux
ressources originales et aux clÃ©s UV. Il ne prouve pas que la scÃ¨ne simulÃ©e
gÃ©nÃ¨re ces mÃªmes draws aux mÃªmes instants.

## Test du nouveau lecteur

Console **client** GMod :

```text
lua_openscript_cl storm_amt_lab/procedural_player.lua
storm_amt_procedural 1 1
storm_amt_procedural_diag
storm_amt_procedural_hide
```

Le deuxiÃ¨me argument est une seed de diagnostic reproductible, pas la seed
retrouvÃ©e d'une capture. Viser le sol avant de lancer. Le lecteur joue l'impact
au point visÃ©. `storm_amt_capture_replay` reste le lecteur r6 de rÃ©fÃ©rence.
`storm_amt_procedural_diag` indique aussi le temps CPU de simulation et de
soumission du rendu, le nombre de draws et le nombre total de maillages chargÃ©s.
Il ne mesure pas le temps GPU.

## Ã‰carts encore Ã  rÃ©soudre

- Trajectoire du projectile au sol, activation extÃ©rieure, boucle et traitement
  complet des Ã©vÃ©nements stop par le moteur hÃ´te.
- Le routage lit dÃ©sormais les listes du contexte +90, +88, +80 selon les
  bits 0, 8, 16, dans cet ordre. Le push des forces locales vers +90 est
  retrouvÃ© Ã  0x1412765c0. Les listes externes +88/+80 restent des entrÃ©es du
  moteur hÃ´te Ã  retrouver pour les skills qui en ont besoin.
  Amaterasu contient 22 masques `1` et deux masques `257` ; ces deux derniers
  consultent Ã©galement +88. L'absence Ã©ventuelle de forces dans cette liste
  doit Ãªtre prouvÃ©e ; le diagnostic la laisse vide actuellement.
- ANM animÃ©es : interpolation quaternion et phase initiale des ressources.
- Contexte des matÃ©riaux : scroll global, phase, ambient/fog de la scÃ¨ne.
  Le diagnostic dÃ©marre avec les valeurs des fichiers ; son fog secondaire
  utilise le contexte de la capture de rÃ©fÃ©rence. Le callback
  `STORM_AMATERASU_SHADER_CONTEXT` permet de raccorder le binder lorsqu'il
  sera identifiÃ©. Ce fallback ne garantit pas la paritÃ© visuelle.
- Joueurs non-BB : amt1_ptc02, light00, fire03a, shock09, nor_dst03. Les
  donnÃ©es sont extraites ; leurs particules consomment bien le RNG mais leur
  rendu est absent. Le diagnostic affiche leur nombre dans la console.
- Blend spÃ©cifique de part11b, cible diffÃ©rÃ©e, distorsion et posttraitement.
- Validation des positions/constantes calculÃ©es contre les captures et
  validation visuelle sur le vrai moteur Source.

Ces Ã©carts empÃªchent de considÃ©rer le rendu actuel comme l'Amaterasu final.

## Mise à jour r9 — matériaux et chaîne de composition

Les observations vérifiées, tests, limites et prochains points sont dans `captured_assets/procedural/r9_findings.md`. Le calcul de scroll utilise maintenant UV2.zw/UV3.zw, une horloge globale et des arrondis float32. Le shader secondaire respecte les modes ClampEdge et ClampBorder observés pour les spirales et petites flammes. Les passes de grading, glare, flou et composition sont identifiées mais pas encore portées.

## Mise à jour r18 — rendu sur les règles natives et séquence du skill

Détails et preuves : entrées R52 à R60 de `../MOTEUR_EFFETS_REVERSE.md`, sections 11 à 16 de `captured_assets/procedural/shader_constant_pipeline.md`.

Ce qui change par rapport à la liste d’écarts ci-dessus :

- **Joueurs non-BB** : `amt1_ptc02` (amt15), `light00`, `fire03a`, `shock09` et `nor_dst03` sont dessinés. `part11b` n’a pas d’événement de départ dans le fichier : il n’est jamais émis, dans le jeu non plus.
- **Shaders** : une seule famille `storm_fx_*` traduite des shaders du jeu (base, un film, deux films, falloff, réfraction), générée par `build_storm_fx_shaders.py`. Les anciens `amt_*` ne sont plus utilisés par `procedural_player.lua`.
- **États** : blend, écriture de profondeur, cull et ordre de dessin viennent du matériau NUD et de l’en-tête du modèle (`storm_fx_render.lua`). La flamme principale est opaque avec test alpha, comme dans le jeu ; le blend alpha de r17 était faux.
- **Contexte** : fog et ambiant par modèle (`model_context_data.lua`), opacité de nœud, fondu natif, taille des modèles en retard d’une mise à jour.
- **Trajectoire** : `storm_amt_skill [échelle] [seed]` lance le projectile rampant depuis le joueur vers le point visé puis l’impact. Le guidage natif n’est pas reproduit (ligne droite).

Commandes console client : `storm_amt_skill`, `storm_amt_procedural 1 1` (impact seul), `storm_amt_procedural 1 1 blt` (projectile immobile), `storm_amt_procedural_diag`, `storm_amt_procedural_hide`.

Vérifications à lancer après toute modification :

```powershell
& $stormPython build_storm_fx_shaders.py
& $stormPython make_vtf_address_variants.py
& $stormPython verify_procedural_player.py
& $stormPython verify_port_winding.py
& $stormPython verify_port_constants.py
& $stormPython verify_port_shaders.py
& $stormPython port_preview.py --skill --port-frame 22
```

`port_preview.py` écrit dans `gpu_captures/rd_dumps/port_preview/` l’image du port rendue dans la caméra d’une capture ; `--game-tag` y ajoute la cible du jeu au même cadrage.

Écarts restants : test dans GMod réel, test de profondeur de la réfraction, guidage et point de départ du projectile, lumière ponctuelle de `blt00`, post-traitement, effets propres au personnage. Le rendu n’est donc toujours pas à présenter comme exact.
