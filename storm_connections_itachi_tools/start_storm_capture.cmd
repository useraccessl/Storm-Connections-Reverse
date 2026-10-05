@echo off
setlocal
set "storm_capture_tool=%TEMP%\storm_renderdoc_1_46\RenderDoc_1.46_64\renderdoccmd.exe"
set "storm_capture_game=C:\Program Files (x86)\Steam\steamapps\common\NARUTO X BORUTO Ultimate Ninja STORM CONNECTIONS"
if not exist "%storm_capture_tool%" (
    echo RenderDoc portable x64 introuvable.
    exit /b 1
)
if not exist "%storm_capture_game%\NSUNSC.exe" (
    echo Executable STORM Connections introuvable.
    exit /b 1
)
tasklist /FI "IMAGENAME eq NSUNSC.exe" /NH 2>nul | find /I "NSUNSC.exe" >nul
if not errorlevel 1 (
    echo Ferme STORM Connections normalement, puis relance ce fichier.
    exit /b 1
)
if not exist "%~dp0gpu_captures" mkdir "%~dp0gpu_captures"
if not exist "%~dp0gpu_captures" exit /b 1
echo Lance Itachi en entrainement. Appuie sur Impr. ecran pendant Amaterasu.
echo Captures : %~dp0gpu_captures
"%storm_capture_tool%" capture --opt-hook-children --working-dir "%storm_capture_game%" --capture-file "%~dp0gpu_captures\itachi_amaterasu" "%storm_capture_game%\NSUNSC.exe"
rem RenderDoc returns a connection identifier on success, not exit code zero.
endlocal
