param([string]$Root = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference = 'Stop'
$roles = @(Get-ChildItem (Join-Path $Root 'roles') -Filter '*.yaml')
if ($roles.Count -ne 4) { throw "Expected 4 role definitions, found $($roles.Count)" }
foreach ($role in $roles) {
  $content = Get-Content -Raw -Encoding UTF8 $role.FullName
  foreach ($key in @('name:','model:','purpose:','permissions:','output_contract:')) {
    if ($content -notmatch [regex]::Escape($key)) { throw "$($role.Name) missing $key" }
  }
  if ($content -notmatch 'model:\s*gpt-5\.6-luna') { throw "$($role.Name) must use gpt-5.6-luna" }
}
Write-Output 'VALIDATE_ROLE_DEFINITIONS_OK'
