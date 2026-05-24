[CmdletBinding()]
param([string]$RepoRoot)

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

$required = @(
    'AGENTS.md',
    'README.md',
    'LICENSE',
    'repo-mode.yaml',
    'schemas/host.schema.yaml',
    'schemas/repo-mode.schema.yaml',
    'scripts/common/detect-repo-mode.ps1',
    'scripts/common/detect-repo-mode.sh',
    'scripts/powershell/collect-baseline.ps1',
    'scripts/bash/collect-baseline.sh',
    'scripts/container/detect-container-stack.ps1',
    'scripts/container/detect-container-stack.sh',
    'hosts/.gitkeep'
)

$missing = @()
foreach ($path in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot $path))) { $missing += $path }
}

$hostChildren = @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'hosts') -Force | Where-Object { $_.Name -ne '.gitkeep' })
$templateFiles = @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'Vorlage') -Recurse -Filter '*.md')
$badFrontmatter = @()
foreach ($file in $templateFiles) {
    $first = Get-Content -LiteralPath $file.FullName -TotalCount 1
    if ($first -ne '---') { $badFrontmatter += $file.FullName }
}

$result = [ordered]@{
    required_missing = $missing
    hosts_has_only_gitkeep = ($hostChildren.Count -eq 0)
    template_file_count = $templateFiles.Count
    template_frontmatter_missing = $badFrontmatter
    ok = ($missing.Count -eq 0 -and $hostChildren.Count -eq 0 -and $badFrontmatter.Count -eq 0)
}

$result | ConvertTo-Json -Depth 4
if (-not $result.ok) { exit 1 }
