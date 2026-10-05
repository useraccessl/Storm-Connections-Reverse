param(
    [Parameter(Mandatory=$true)][string]$Script,
    [int]$TimeoutSeconds = 180
)
# Runs a RenderDoc Python script headless. Like run_renderdoc_analysis.ps1, but
# it also works when qrenderdoc has no UI.config yet: a temporary one is
# created to suppress the first-run analytics dialog and removed afterwards.
$ErrorActionPreference = 'Stop'
$configDir = Join-Path $env:APPDATA 'qrenderdoc'
$configPath = Join-Path $configDir 'UI.config'
$hadConfig = Test-Path -LiteralPath $configPath
$hadDir = Test-Path -LiteralPath $configDir
$originalConfig = if ($hadConfig) { Get-Content -LiteralPath $configPath -Raw } else { $null }
try {
    if ($hadConfig) {
        Set-Content -LiteralPath $configPath -Value ($originalConfig.Replace('"Analytics_TotalOptOut": false', '"Analytics_TotalOptOut": true')) -Encoding utf8
    } else {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
        Set-Content -LiteralPath $configPath -Value '{"rdocConfigData": 1, "Analytics_TotalOptOut": true, "Analytics_ManualCheck": false, "CheckUpdate_AllowChecks": false, "Tips_HasSeenFirst": true}' -Encoding utf8
    }
    $scriptAbsolute = (Resolve-Path -LiteralPath $Script).Path
    $exe = Join-Path $env:TEMP 'storm_renderdoc_1_46\RenderDoc_1.46_64\qrenderdoc.exe'
    $rdProcess = Start-Process -FilePath $exe -ArgumentList @('--python', ('"' + $scriptAbsolute + '"')) -WindowStyle Hidden -PassThru
    if (-not $rdProcess.WaitForExit($TimeoutSeconds * 1000)) { Stop-Process -Id $rdProcess.Id; throw "Replay exceeded $TimeoutSeconds seconds" }
    if ($rdProcess.ExitCode -ne 0) { throw "Replay exit code $($rdProcess.ExitCode)" }
} finally {
    if ($hadConfig) {
        Set-Content -LiteralPath $configPath -Value $originalConfig -Encoding utf8
    } else {
        Remove-Item -LiteralPath $configPath -Force -ErrorAction SilentlyContinue
        if (-not $hadDir) { Remove-Item -LiteralPath $configDir -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

