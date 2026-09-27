param([switch]$Keys)

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$configDir = Join-Path ([System.IO.Path]::GetTempPath()) ('micro-mark-' + [guid]::NewGuid())
$pluginDir = Join-Path $configDir 'plug\emacsbindings'
$previousTest = $env:MICRO_MARK_TEST
$previousKeys = $env:MICRO_TEST_KEY

try {
    New-Item -ItemType Directory -Path $pluginDir -Force | Out-Null
    Copy-Item (Join-Path $root 'emacsbindings.lua'), (Join-Path $root 'repo.json') $pluginDir
    Copy-Item (Join-Path $PSScriptRoot 'mark.lua') (Join-Path $pluginDir 'test.lua')
    $env:MICRO_MARK_TEST = '1'
    $env:MICRO_TEST_KEY = if ($Keys) { '1' } else { '0' }
    if ($Keys) {
        Write-Host 'Press Ctrl-x, release Ctrl, then press m. The test exits automatically.'
    }
    & micro -config-dir $configDir -clipboard internal
    if ($LASTEXITCODE -ne 0) {
        throw "micro mark test failed (exit $LASTEXITCODE)"
    }
} finally {
    $env:MICRO_MARK_TEST = $previousTest
    $env:MICRO_TEST_KEY = $previousKeys
    Remove-Item $configDir -Recurse -Force
}