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
    '.github/ISSUE_TEMPLATE/bug_report.md',
    '.github/ISSUE_TEMPLATE/improvement.md',
    '.github/PULL_REQUEST_TEMPLATE.md',
    'schemas/host.schema.yaml',
    'schemas/repo-mode.schema.yaml',
    'scripts/common/detect-repo-mode.ps1',
    'scripts/common/detect-repo-mode.sh',
    'scripts/common/verify-template.ps1',
    'scripts/common/verify-template.sh',
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
$badFrontmatterFields = @()
$badControlTokens = @()
$requiredFrontmatterFields = @(
    'id',
    'title',
    'platform',
    'environment',
    'area',
    'requires_admin',
    'risk',
    'approval_required',
    'rollback_required',
    'idempotent',
    'applies_to'
)
foreach ($file in $templateFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw
    $first = ($content -split "`r?`n", 2)[0]
    if ($first -ne '---') { $badFrontmatter += $file.FullName }
    if ($content.Contains([string][char]13 + 'ollback_required')) { $badControlTokens += $file.FullName }
    $frontmatterMatch = [regex]::Match($content, '(?s)^---\r?\n(.*?)\r?\n---')
    if (-not $frontmatterMatch.Success) {
        $badFrontmatterFields += $file.FullName
        continue
    }
    $frontmatter = $frontmatterMatch.Groups[1].Value
    foreach ($field in $requiredFrontmatterFields) {
        if ($frontmatter -notmatch "(?m)^$([regex]::Escape($field))\s*:") {
            $badFrontmatterFields += "$($file.FullName):$field"
        }
    }
}

$result = [ordered]@{
    required_missing = $missing
    hosts_has_only_gitkeep = ($hostChildren.Count -eq 0)
    template_file_count = $templateFiles.Count
    template_frontmatter_missing = $badFrontmatter
    template_frontmatter_fields_missing = $badFrontmatterFields
    template_control_token_errors = $badControlTokens
    ok = (
        $missing.Count -eq 0 -and
        $hostChildren.Count -eq 0 -and
        $badFrontmatter.Count -eq 0 -and
        $badFrontmatterFields.Count -eq 0 -and
        $badControlTokens.Count -eq 0
    )
}

$result | ConvertTo-Json -Depth 4
if (-not $result.ok) { exit 1 }
