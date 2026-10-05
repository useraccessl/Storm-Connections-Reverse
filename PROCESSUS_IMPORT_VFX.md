# Processus générique d’import des VFX Storm

Objectif : pour chaque skill, extraire ses paramètres, ses émetteurs et animations, ses modèles, matériaux, textures et shaders, ses comportements, puis les jouer dans Garry’s Mod avec un moteur réimplémenté d’après le code du jeu. Amaterasu sert de cas de validation ; il ne définit pas le périmètre du moteur.

État au 2026-10-02 (journal `MOTEUR_EFFETS_REVERSE.md`, R62–R81 ; suite dans la dernière section de `NEXT_STEPS.md`). Toutes les vérifications citées tournent hors-ligne ; **le moteur r22 n’a pas été vu dans Garry’s Mod**.

## Importer un skill

Depuis `storm_connections_itachi_tools`, avec le Python fourni :

```
python storm_import.py <nom du fichier de skill sans extension>     # ex. 4efb_amt1_x
python verify_package_shaders.py <nom>                               # shaders du paquet contre le bytecode du jeu
python play_package.py <nom>                                         # joue chaque script dans le moteur, hors-ligne
python install_storm_fx.py                                           # copie moteur + paquets dans Garry’s Mod (jeu fermé)
```

Dans le jeu : `storm_fx_list <paquet>`, `storm_fx_cast <paquet> [script] [échelle] [graine]`, `storm_fx_diag`.

## Ce que fait la chaîne

1. **Scripts de skill** (`skill_script.py`) : XML de `data/skill/*_x.xfbin` — actions (type de mouvement, paramètres, animation), événements, commandes, effets lancés et type de tir. Tout est conservé tel quel dans le paquet.
2. **Références entre fichiers** (`chunk_index.py`) : un chunk référencé par (type, chemin, nom) est retrouvé dans l’index de tous les fichiers d’effets, de personnages et de boss.
3. **Effets** (`storm_import.py`) : émetteurs et forces du chunk particule, ressources (billboard, clump, ressource animée), animations (`decode_effect_animation.py`), modèles NUD, matériaux (`nuccChunkMaterial`), textures NUT → VTF (`nut_to_vtf.py`). L’échantillonnage de chaque texture vient de son enregistrement NUD : adressage, filtre, biais de LOD ; selon le cas la VTF garde le niveau 0 seul ou tous les niveaux du NUT.
4. **Shaders** (`shader_port.py`) : le couple du jeu pour la clé du matériau est traduit du bytecode SM4 vers SM3 ; chaque constante vient du draw (16 flottants de constantes pixel), de la scène (cuite dans les coordonnées de texture du mesh, deux ou quatre flottants par canal), du matériau (compilée) ou de l’espace objet. Le niveau de mip est calculé par le shader quand le sampler du jeu en atteint plusieurs.
5. **Moteur** (`lua/storm_fx/player.lua` et les cœurs `lua/storm_amt_lab/*_core.lua`) : simulation des particules, animations, matériaux animés, objets de skill (mouvements, guidage, événements, tirs), lumières ponctuelles des effets (registre de scène, sélection par modèle), rendu selon les règles d’état du jeu.

## Ce que l’importeur refuse, et le dit

Le paquet liste ce qui n’a pas été importé (`unsupported`) avec la raison, et le moteur ce qu’il n’a pas rendu (`storm_fx_diag`) : sommets NUD skinnés, membres de clump qui ne sont pas des modèles, scripts définis dans plusieurs fichiers, plus de quatre textures, flux de contrôle dans un shader, cibles internes du jeu (profondeur de scène, ombres), trails, textures non puissances de deux. `survey_play.py` mesure ces manques sur un échantillon de skills.

## Niveaux de preuve

- **désassemblé** : la routine du jeu est lue et décrite dans le journal ;
- **traduit** : elle existe en Lua ou en Python, d’après la lecture ;
- **vérifié contre le natif** : le code du jeu est exécuté (`native_image.py`, ou une routine isolée) sur les mêmes entrées, sorties identiques au bit ;
- **vérifié sur capture** : le résultat est comparé aux draws ou aux constantes des captures GPU d’Amaterasu ;
- **vu dans Garry’s Mod** : aucun élément à ce jour.

Ce qu’un monde de jeu fournit (cible, sol, obstacles, lumière de scène, fog) est une entrée de l’hôte : le moteur le dit dans son code et ne le présente pas comme reversé. Dans l’autre sens, ce que le jeu fait à son monde est un substitut d’hôte : les lumières ponctuelles des effets éclairent le monde Source par des lumières dynamiques (`STORM_FX.host.dynamicLights`), sans équivalence de rendu.
