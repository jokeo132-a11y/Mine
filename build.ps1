[CmdletBinding()]
param(
  [switch]$Clean,
  [string]$Repo = $(if ($env:XMRIG_REPO) { $env:XMRIG_REPO } else { 'git@github.com:xmrig/xmrig.git' }),
  [string]$Ref = $(if ($env:XMRIG_REF) { $env:XMRIG_REF } else { 'v6.26.0' })
)
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Src = if ($env:XMRIG_SOURCE_DIR) { $env:XMRIG_SOURCE_DIR } else { Join-Path $Root '.vendor/xmrig' }
$Build = if ($env:XMRIG_BUILD_DIR) { $env:XMRIG_BUILD_DIR } else { Join-Path $Root 'build' }
foreach ($tool in @('git','cmake')) { if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) { throw "Missing required tool: $tool" } }
New-Item -ItemType Directory -Force -Path (Split-Path $Src) | Out-Null
if (-not (Test-Path (Join-Path $Src '.git'))) {
  git clone --depth 1 --branch $Ref $Repo $Src
} else {
  git -C $Src fetch --depth 1 origin $Ref
  git -C $Src checkout --detach FETCH_HEAD
}
if ($Clean -and (Test-Path $Build)) { Remove-Item -Recurse -Force $Build }
cmake -S $Src -B $Build -DCMAKE_BUILD_TYPE=Release -DWITH_HWLOC=OFF
cmake --build $Build --config Release --parallel
Write-Host "Build complete: $Build"
