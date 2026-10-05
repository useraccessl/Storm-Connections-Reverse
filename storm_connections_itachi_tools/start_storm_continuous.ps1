param([switch]$SelfTest)
$ErrorActionPreference = 'Stop'
$taskExe = Join-Path $env:TEMP 'storm_renderdoc_1_46\RenderDoc_1.46_64\qrenderdoc.exe'
$taskConfig = Join-Path $env:APPDATA 'qrenderdoc\UI.config'
$taskOptions = Join-Path $PSScriptRoot 'continuous_capture_options.json'
$taskStatus = Join-Path $PSScriptRoot 'gpu_captures\continuous_status.txt'
if (-not (Test-Path -LiteralPath $taskExe)) { throw 'RenderDoc portable introuvable.' }
if (-not $SelfTest -and (Get-Process -Name NSUNSC -ErrorAction SilentlyContinue)) {
    throw 'Ferme STORM Connections normalement avant de lancer la capture continue.'
}
if (Get-Process -Name qrenderdoc -ErrorAction SilentlyContinue) { throw 'Ferme RenderDoc avant ce lancement.' }
$taskOriginalOptions = [IO.File]::ReadAllText($taskOptions)
$taskOriginalConfig = [IO.File]::ReadAllText($taskConfig)
$taskAnalyticsWasEnabled = $taskOriginalConfig.Contains('"Analytics_TotalOptOut": false')
try {
    if ($SelfTest) { [IO.File]::WriteAllText($taskOptions,'{"frames":180,"self_test":true}') }
    if ($taskAnalyticsWasEnabled) {
        [IO.File]::WriteAllText($taskConfig,$taskOriginalConfig.Replace('"Analytics_TotalOptOut": false','"Analytics_TotalOptOut": true'))
    }
    [IO.File]::WriteAllText($taskStatus,'STARTING: lancement du lecteur de capture.')
    $taskScript = Join-Path $PSScriptRoot 'capture_continuous.py'
    $taskProcess = Start-Process $taskExe -ArgumentList @('--python',('"'+$taskScript+'"')) -WindowStyle Hidden -PassThru
    Write-Output 'En entrainement Itachi, appuie UNE FOIS sur F8 au debut des petites flammes.'
    Write-Output '180 captures consecutives : environ 40 Go. Le jeu peut ralentir pendant la capture.'
    $taskLastStatus = ''
    while (-not $taskProcess.HasExited) {
        $taskCurrentStatus = [IO.File]::ReadAllText($taskStatus)
        if ($taskCurrentStatus -ne $taskLastStatus) { Write-Output $taskCurrentStatus; $taskLastStatus=$taskCurrentStatus }
        Start-Sleep -Milliseconds 500
        $taskProcess.Refresh()
    }
    Write-Output ([IO.File]::ReadAllText($taskStatus))
} finally {
    if ($SelfTest) { [IO.File]::WriteAllText($taskOptions,$taskOriginalOptions) }
    if ($taskAnalyticsWasEnabled) {
        $taskCurrentConfig=[IO.File]::ReadAllText($taskConfig)
        [IO.File]::WriteAllText($taskConfig,$taskCurrentConfig.Replace('"Analytics_TotalOptOut": true','"Analytics_TotalOptOut": false'))
    }
}
