# Étape 1 : application générique des animations de matériau

## Résultat

Le bloc original 0x1412f6380..0x1412f64f3 lit un mot de masque à l’adresse de payload, puis une suite compacte de mots 32 bits. Il n’utilise pas une table dense de 23 floats : seuls les canaux présents consomment une valeur. Les bits au-delà de 22 sont ignorés par ce bloc.

Destination = instance de matériau. Pour chaque bit actif, le bloc copie le prochain mot vers la destination correspondante. Les mots sont copiés sans calcul, conversion ou clamp. Leur interprétation appartient au binder ; +88 reste un mot opaque dont la sémantique complète n’est pas établie.

| Bit / index ANM | Offset destination | Paramètre du binder |
|---|---|---|
| 0,1 | +30,+34 | UV0 offset.xy |
| 2,3 | +38,+3c | UV1 offset.xy |
| 4,5 | +40,+44 | UV2 offset.xy |
| 6,7 | +48,+4c | UV3 offset.xy / poids des films pour 19f002 |
| 8,9 | +50,+54 | UV0 scale.xy |
| 10,11 | +58,+5c | UV1 scale.xy |
| 12,13 | +70,+74 | blendRate.xy |
| 14 | +78 | override UV2.x sous condition du flag matériau |
| 15 | +7c | commonParam.w |
| 16 | +80 | seuil alpha |
| 17 | +84 | paramètre appelé olid dans les notes ; division par 255 dans le binder |
| 18,19 | +68,+6c | UV3 scale.xy |
| 20,21 | +60,+64 | UV2 scale.xy |
| 22 | +88 | mot opaque exporté vers contexte +6e0 |

## Implémentation

material_animation_core.lua applique le payload compact et peut construire ce payload depuis des canaux indexés 0..22 déjà échantillonnés. Le module n’invente aucune interpolation ni phase d’horloge. Il est conservé côté outils et dans les sources de l’addon, mais n’est pas encore connecté au lecteur.

## Vérification indépendante

verify_material_animation_native.py exécute une copie bornée de la fonction machine originale dans un processus Python de test isolé. Le bloc a été inspecté : aucun appel externe, syscall, accès RIP, écriture de stack ou branche hors de la copie ; ses seuls accès mémoire concernent les buffers fournis. Tous les 36 mots de l’instance et les gardes mémoire sont comparés au module Lua.

Résultat : 2 026 masques passent, incluant chaque bit isolé, tous les bits, masque vide, bits supérieurs et masques aléatoires. Cette vérification ne réimplémente pas un oracle mathématique supposé : elle utilise les instructions du binaire local.

verify_material_animation_binding.py relie les valeurs ANM type 4 de amt15 aux constantes originales de huit draws : UV0/UV1, poids de deux films, blendRate, common.w et seuil alpha. Une clé de courbe est compatible avec les constantes dans chaque draw. La phase est recherchée pour contrôler la correspondance ; elle ne constitue pas la récupération indépendante de l’horloge.

## Points ouverts

Les recherches directes de CALL, pointeurs absolus et LEA vers 0x1412f6380/0x1412f6500 n’ont pas retrouvé d’appelant. Le chemin d’invocation actif doit encore être établi (possible code inliné ou autre dispatcher). Ne pas présenter ce point d’entrée comme un callback exécuté avec certitude sur les frames capturées.

La preuve établit les destinations de canaux, leurs copies natives et leur compatibilité GPU, pas l’interpolation ou l’ordonnancement. Prochaine étape : retrouver les samplers scalaires/quaternions et le producteur des blocs masqués, puis les horloges et l’application aux repères. La reconstruction reste incomplète et aucune nouvelle version visuelle n’est demandée à l’utilisateur.

## Screen-scroll consumer in the generic shader binder

The mapping above now connects to a native consumer: `0x1412f5ff0` reads the
UV2 scale pair at material `+60/+64` and UV3 scale pair at `+68/+6c`, applies
the native material clock and signed-fraction wrap, and stores the four results
at render-context `+0x4f0`. Generic shader accessor 50 exposes that as
`g_uvOffsetScreen` (GPU byte offset 240 in the captured main-fire VS buffer).
Rates with `abs(rate) < 1.1920928955078125e-7f` produce zero. This proves the
CPU producer/consumer chain for screen-scroll offset; the clock's epoch and
frame-update denominator still need their live source. See
`generic_shader_parameter_map.md` and `generic_shader_capture_crosswalk.json`.

## Serialized material values -> native resource -> runtime binder (2026-10-02)

The asset-to-instance map is now recovered from the local executable. Class
vtable data adjacent to the embedded source path `nuccChunkMaterial.cpp`
identifies its format reader at `0x14134cde0`; the reader tests format bits in
ascending order and copies each present 16-byte block to these parsed-resource
offsets:

| Format bit | Float count | Parsed-resource destinations |
|---:|---:|---|
| `0x01` | 4 | `+28,+2c,+48,+4c` |
| `0x02` | 4 | `+30,+34,+50,+54` |
| `0x04` | 4 | `+38,+3c,+58,+5c` |
| `0x08` | 4 | `+40,+44,+60,+64` |
| `0x10` | 2 | `+68,+6c` |
| `0x20` | 1 | `+74` |
| `0x40` | 1 | `+78` |
| `0x80` | 1 | `+7c` |

Constructor `0x1412f5920` copies the eight vector pairs at parsed offsets
`+28..+60` to runtime material offsets `+30..+68` in order, and copies the
scalar fields to runtime `+70,+74,+78,+84,+88`. This closes the static
XFBIN-float -> parsed-resource -> runtime-material mapping. The reusable
decoder and all 18 material records are in
`decode_native_material_fields.py` and
`native_material_parameter_map.json`; it fails if any serialized float is
left unconsumed.

The initial comparison used `2efb_amt.xfbin`, which is a different effect and
does not own the principal-fire draws. Captured draw identities resolve to
`4efb_amt00` and `4efb_amt01` in `4efb_amt1.xfbin`; their decoded rates are
`(0,1,1,1)` and match the captured vector `(0,t,t,t)`. The corrected all-frame
comparison is recorded in `native_material_scroll_capture_audit.json`.
