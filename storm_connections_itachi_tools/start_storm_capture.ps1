$ErrorActionPreference = 'Stop'
$captureGame = 'C:\Program Files (x86)\Steam\steamapps\common\NARUTO X BORUTO Ultimate Ninja STORM CONNECTIONS'
$captureToolRoot = Join-Path $env:TEMP 'storm_renderdoc_1_46'
$captureTool = Join-Path $captureToolRoot 'RenderDoc_1.46_64\renderdoccmd.exe'
if (-not (Test-Path -LiteralPath $captureTool)) { throw 'RenderDoc portable x64 introuvable.' }
if (Get-Process -Name NSUNSC -ErrorAction SilentlyContinue) {
    throw 'Ferme STORM Connections normalement, puis relance ce script pour activer la capture dès son démarrage.'
}
$captureFolder = Join-Path $PSScriptRoot 'gpu_captures'
New-Item -ItemType Directory -Path $captureFolder -Force | Out-Null
Write-Output 'Lance Itachi en entraînement. Appuie sur Impr. écran au pic des flammes.'
Write-Output ('Les fichiers .rdc seront enregistrés dans : ' + $captureFolder)
& $captureTool capture --working-dir $captureGame --capture-file (Join-Path $captureFolder 'itachi_amaterasu') (Join-Path $captureGame 'NSUNSC.exe')
# renderdoccmd returns the capture connection identifier, not a conventional
# success exit code. Its own diagnostic output reports launch failures.
