param([string]$Root = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference = 'Stop'
$required = @('SKILL.md','scripts/bootstrap.sh','scripts/prepare-luna-catalog.sh','scripts/validate-setup.ps1','scripts/validate-role-definitions.ps1','references/task-card.md','references/stage-gates.md','references/reporting-contract.md','references/routing-protocol.md','references/cost-quality-metrics.md')
foreach ($item in $required) { if (-not (Test-Path (Join-Path $Root $item))) { throw "Missing: $item" } }
$files = Get-ChildItem -Recurse -File $Root | Where-Object { $_.Name -ne 'validate-setup.ps1' }
$text = ($files | ForEach-Object { Get-Content -Raw -Encoding UTF8 $_.FullName }) -join "`n"
if ($text -match '(?i)(sk-[A-Za-z0-9]{20,}|api[_-]?key\s*[:=]\s*[A-Za-z0-9+/]{20,}|-----BEGIN [A-Z ]+PRIVATE KEY-----)') { throw 'Possible secret material found' }
Write-Output 'VALIDATE_SETUP_OK'
