[CmdletBinding()]
param(
    [string]$Language = 'de',
    [string]$RepoRoot
)

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

$languagesPath = Join-Path $RepoRoot 'i18n/languages.tsv'
$componentsPath = Join-Path $RepoRoot 'i18n/product-components.tsv'

function Read-AgentTsvTable {
    param([Parameter(Mandatory = $true)][string]$Path)
    $lines = @(Get-Content -LiteralPath $Path | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $headers = $lines[0] -split "`t"
    $rows = @()
    foreach ($line in $lines[1..($lines.Count - 1)]) {
        $cols = $line -split "`t"
        $row = [ordered]@{}
        for ($i = 0; $i -lt $headers.Count; $i++) { $row[$headers[$i]] = $cols[$i] }
        $rows += [pscustomobject]$row
    }
    return $rows
}

$languageRows = @(Read-AgentTsvTable -Path $languagesPath)
$languageCodes = @($languageRows | ForEach-Object { $_.code })
$normalized = $Language.Trim().ToLowerInvariant().Replace('_', '-')
$selected = 'de'
foreach ($code in $languageCodes) {
    $candidate = $code.ToLowerInvariant()
    if ($normalized -eq $candidate -or $normalized.StartsWith("$candidate-")) {
        $selected = $code
        break
    }
}
if ($normalized -eq 'zh' -or $normalized -eq 'zh-cn' -or $normalized -eq 'zh-hans') {
    $selected = 'zh-Hans'
}

$componentRows = @(Read-AgentTsvTable -Path $componentsPath)
$byComponent = [ordered]@{}
foreach ($row in $componentRows) {
    if (-not $byComponent.Contains($row.component_id)) {
        $byComponent[$row.component_id] = [ordered]@{ id = $row.component_id; name = ''; summary = '' }
    }
    $byComponent[$row.component_id][$row.field] = $row.$selected
}

foreach ($component in $byComponent.Values) {
    [pscustomobject]@{
        id = $component.id
        language = $selected
        name = $component.name
        summary = $component.summary
    }
}
