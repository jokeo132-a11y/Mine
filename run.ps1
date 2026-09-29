[CmdletBinding()]
param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Arguments)
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Bin = if ($env:XMRIG_BINARY) { $env:XMRIG_BINARY } else { Join-Path $Root 'build/Release/xmrig.exe' }
if (-not (Test-Path $Bin)) {
  Write-Host 'Build not found; building first...'
  & (Join-Path $Root 'build.ps1')
}
if (-not (Test-Path $Bin)) {
  $Bin = Join-Path $Root 'build/xmrig.exe'
}
& $Bin '-c' (Join-Path $Root 'config.local.json') @Arguments
exit $LASTEXITCODE
