# Capture du rendu original

Le portage exact nécessite de vérifier les constantes effectivement envoyées
au GPU : `g_ambientColor`, `g_multColor`, `g_commonParam`, `g_ScreenToUV`, les
deux UV de base, le scroll écran, ainsi que les états blend/depth/cull et les
passes utilisant la seconde cible de rendu. Les textures et les shaders seuls
ne permettent pas de confirmer ces valeurs.

## Procédure préparée

1. Steam doit être ouvert. Fermer STORM Connections normalement s'il tourne.
2. Dans PowerShell, exécuter :

   ```powershell
   & 'C:\Users\edenm\Desktop\Projects\Storm Connections Reverse\storm_connections_itachi_tools\start_storm_capture.cmd'
   ```

   Le lanceur `.cmd` appelle directement RenderDoc et fonctionne même si
   PowerShell désactive les scripts `.ps1`. Aucune politique d'exécution
   Windows n'est modifiée.

3. Ouvrir un entraînement avec Itachi et lancer Amaterasu. L'indicateur
   RenderDoc doit apparaître dans le jeu.
4. Appuyer sur **Impr. écran** pendant les petites flammes, puis au pic de
   l'éruption. Si le moment est manqué, répéter la technique et la capture.
5. Les fichiers `.rdc` sont écrits dans le sous-dossier `gpu_captures` de ce
   dossier. Fournir leur chemin. Une capture PNG n'inclut pas les constantes.

RenderDoc portable officiel 1.46 est préparé dans
`%TEMP%\storm_renderdoc_1_46`. Le script n'altère pas les fichiers du jeu.
Il lance le processus sous RenderDoc pour instrumenter les appels graphiques.
La compatibilité avec ce jeu n'est pas encore vérifiée ; conserver le message
exact si le lancement ou la capture échoue.

Documentation officielle :
https://github.com/baldurk/renderdoc/blob/v1.x/docs/getting_started/quick_start.rst

## État du lecteur GMod

`storm_amt_decoded 0 1 0.6` tient la phase d'impact au temps 0.6 s.
`storm_amt_decoded 1 1 0.6` tient les émetteurs du projectile.
Ce lecteur sert au diagnostic, ce n'est pas encore le résultat final.
Il évalue les taux d'émission, les événements, les courbes XYZ/alpha et tous
les UV décodés. Les shaders SM3 utilisent VPOS et le mélange original des
textures. Les animations sont exportées mais les rotations des attachments,
les forces, les autres ressources et le contexte RGB ne sont pas encore
intégrés/validés. La cinématique aléatoire du lecteur reste partiellement
reconstruite ; elle ne doit pas être présentée comme une simulation exacte.

Le cinquième argument `1` demande d'appliquer les couleurs des courbes de
particules pour comparaison. Le transfert RGB effectif par le contexte de
rendu original doit encore être confirmé. `storm_amt_decoded_hide` masque
ce diagnostic. Les commandes précédentes restent le montage provisoire.
