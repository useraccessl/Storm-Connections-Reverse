# Runs every offline verification of the engine and the importer, in order, and writes a
# summary (the command, its exit code and time, its last lines) to
# captured_assets/procedural/verification_suite_log.txt. Every line must say "exit 0".
# Some steps need game_cache/survey_addon (survey packages), the GPU captures of
# gpu_captures/ and Garry's Mod's bin/win64/lua_shared.dll (read only). About 9 minutes.
#   powershell -ExecutionPolicy Bypass -File run_verification_suite.ps1
# Nothing here proves the engine in Garry's Mod: it all runs offline.
$py = 'C:\Users\edenm\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
$tools = $PSScriptRoot
$log = Join-Path $tools 'captured_assets\procedural\verification_suite_log.txt'
Set-Location $tools
'' | Out-File -Encoding utf8 $log
$commands = @(
    @('verify_port_constants.py'),
    @('verify_procedural_player.py'),
    @('verify_import_equivalence.py'),
    @('verify_port_winding.py'),
    @('verify_skill_behaviours.py'),
    @('verify_skill_actor_native.py'),
    @('verify_sampler_state_native.py'),
    @('verify_point_light_native.py'),
    @('verify_point_lights.py'),
    @('verify_package_shaders.py', '4efb_amt1_x'),
    @('verify_package_shaders.py', '3efb_3ssk1_x'),
    @('verify_package_shaders.py', 'cw0_x', '--addon', 'game_cache\survey_addon'),
    @('verify_package_shaders.py', '5efb_9ind1_x', '--addon', 'game_cache\survey_addon'),
    @('verify_package_shaders.py', '1efcmn_x', '--addon', 'game_cache\survey_addon'),
    @('verify_port_shaders.py'),
    @('verify_skinning_capture.py'),
    @('verify_skin_palette_capture.py'),
    @('verify_skinned_models.py', '3mdr_2_x', '4mnr_x', '3efbtf_srd1_x', '5obt_x'),
    @('verify_trail_native.py'),
    @('verify_facing_native.py'),
    @('verify_billboard_members.py'),
    @('verify_trails.py', '--package', '1efcmn_x', '--frames', '150'),
    @('verify_trails.py', '--package', '1hak_x', '--frames', '150'),
    @('verify_trails.py', '--package', '1efb_bss_x', '--frames', '150'),
    @('verify_package_shaders.py', '1hak_x', '--addon', 'game_cache\survey_addon'),
    @('verify_luajit.py'),
    @('verify_luajit_runtime.py'),
    @('verify_anm_hierarchy.py'),
    @('verify_trail_capture.py'),
    @('verify_trails.py', '--package', '4efb_amt1_x', '--frames', '150', '--addon', '..\storm_amaterasu_lab'),
    @('verify_selftest.py'),
    @('verify_resource_billboards.py'),
    @('verify_api.py')
)
# verify_clean_engine.py (the clean addon against the lab's r27 engine, every draw identical)
# proved the rewrite of R109; it is retired since the batched packages of R110, which the
# reference engine cannot draw.
foreach ($c in $commands) {
    $start = Get-Date
    $out = & $py @c 2>&1 | ForEach-Object { "$_" }
    $code = $LASTEXITCODE
    $seconds = [int]((Get-Date) - $start).TotalSeconds
    "==== $($c -join ' ')  (exit $code, $seconds s)" | Out-File -Encoding utf8 -Append $log
    ($out | Select-Object -Last 6) | Out-File -Encoding utf8 -Append $log
}
'SUITE DONE' | Out-File -Encoding utf8 -Append $log
