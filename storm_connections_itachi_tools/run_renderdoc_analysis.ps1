param([Parameter(Mandatory=$true)][string]$Script)
$ErrorActionPreference='Stop'
$configPath=Join-Path $env:APPDATA 'qrenderdoc\UI.config'
$originalConfig=Get-Content -LiteralPath $configPath -Raw
try {
 Set-Content -LiteralPath $configPath -Value ($originalConfig.Replace('"Analytics_TotalOptOut": false','"Analytics_TotalOptOut": true')) -Encoding utf8
 $scriptAbsolute=(Resolve-Path -LiteralPath $Script).Path
 $rdProcess=Start-Process -FilePath "$env:TEMP\storm_renderdoc_1_46\RenderDoc_1.46_64\qrenderdoc.exe" -ArgumentList @('--python', ('"'+$scriptAbsolute+'"')) -WindowStyle Hidden -PassThru
 if (-not $rdProcess.WaitForExit(45000)) { Stop-Process -Id $rdProcess.Id; throw 'Replay exceeded 45 seconds' }
 if ($rdProcess.ExitCode -ne 0) { throw "Replay exit code $($rdProcess.ExitCode)" }
} finally { Set-Content -LiteralPath $configPath -Value $originalConfig -Encoding utf8 }
