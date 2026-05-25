[CmdletBinding()]
param([string]$RepoRoot)

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

$languagesPath = Join-Path $RepoRoot 'i18n/languages.tsv'
$componentsPath = Join-Path $RepoRoot 'i18n/product-components.tsv'
$requiredLanguages = @('de', 'en', 'es', 'fr', 'it', 'pt', 'nl', 'pl', 'tr', 'ru', 'zh-Hans', 'ja')
$errors = New-Object System.Collections.Generic.List[string]

function Read-AgentTsv {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Datei fehlt: $Path"
    }
    $lines = @(Get-Content -LiteralPath $Path | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($lines.Count -lt 2) {
        throw "TSV-Datei enthält keine Datenzeilen: $Path"
    }
    return $lines
}

try {
    $languageLines = Read-AgentTsv -Path $languagesPath
    $languageHeader = $languageLines[0] -split "`t"
    if (($languageHeader -join '|') -ne 'code|native_name|english_name|role') {
        $errors.Add('i18n/languages.tsv hat einen ungültigen Header.')
    }
    $languageCodes = @()
    foreach ($line in $languageLines[1..($languageLines.Count - 1)]) {
        $cols = $line -split "`t"
        if ($cols.Count -ne 4) {
            $errors.Add("Ungültige Spaltenzahl in i18n/languages.tsv: $line")
            continue
        }
        if ($cols[0] -notmatch '^[a-z]{2}(-[A-Za-z]+)?$') {
            $errors.Add("Ungültiger Sprachcode: $($cols[0])")
        }
        foreach ($col in $cols) {
            if ([string]::IsNullOrWhiteSpace($col)) { $errors.Add("Leerer Wert in i18n/languages.tsv: $line") }
        }
        $languageCodes += $cols[0]
    }
    foreach ($language in $requiredLanguages) {
        if ($languageCodes -notcontains $language) { $errors.Add("Pflichtsprache fehlt in i18n/languages.tsv: $language") }
    }
    if (($languageCodes | Sort-Object -Unique).Count -ne $languageCodes.Count) {
        $errors.Add('i18n/languages.tsv enthält doppelte Sprachcodes.')
    }
    if ($languageCodes.Count -lt 10) {
        $errors.Add('Es müssen mindestens zehn Produktsprachen definiert sein.')
    }

    $componentLines = Read-AgentTsv -Path $componentsPath
    $componentHeader = $componentLines[0] -split "`t"
    if ($componentHeader.Count -ne (2 + $languageCodes.Count)) {
        $errors.Add('i18n/product-components.tsv Header passt nicht zur Sprachliste.')
    }
    if ($componentHeader[0] -ne 'component_id' -or $componentHeader[1] -ne 'field') {
        $errors.Add('i18n/product-components.tsv muss mit component_id und field beginnen.')
    }
    foreach ($language in $languageCodes) {
        if ($componentHeader -notcontains $language) {
            $errors.Add("Sprache fehlt im Produktkomponenten-Header: $language")
        }
    }

    $seen = @{}
    $components = New-Object System.Collections.Generic.HashSet[string]
    foreach ($line in $componentLines[1..($componentLines.Count - 1)]) {
        $cols = $line -split "`t"
        if ($cols.Count -ne $componentHeader.Count) {
            $errors.Add("Ungültige Spaltenzahl in i18n/product-components.tsv: $($cols[0])/$($cols[1])")
            continue
        }
        $componentId = $cols[0]
        $field = $cols[1]
        if ($componentId -notmatch '^[a-z0-9_]+$') {
            $errors.Add("Ungültige Produktkomponenten-ID: $componentId")
        }
        if ($field -ne 'name' -and $field -ne 'summary') {
            $errors.Add("Ungültiges Produktkomponenten-Feld: $componentId/$field")
        }
        $key = "$componentId/$field"
        if ($seen.ContainsKey($key)) {
            $errors.Add("Doppelter Produktkomponenten-Eintrag: $key")
        }
        $seen[$key] = $true
        [void]$components.Add($componentId)
        for ($i = 2; $i -lt $cols.Count; $i++) {
            if ([string]::IsNullOrWhiteSpace($cols[$i])) {
                $errors.Add("Leere Übersetzung: $componentId/$field/$($componentHeader[$i])")
            }
        }
    }

    foreach ($component in $components) {
        foreach ($field in @('name', 'summary')) {
            if (-not $seen.ContainsKey("$component/$field")) {
                $errors.Add("Produktkomponente ohne ${field}: $component")
            }
        }
    }

    $result = [ordered]@{
        language_count = $languageCodes.Count
        languages = $languageCodes
        component_count = $components.Count
        required_languages_present = @($requiredLanguages | Where-Object { $languageCodes -contains $_ }).Count
        errors = @($errors)
        ok = $errors.Count -eq 0
    }
    $result | ConvertTo-Json -Depth 4
    if (-not $result.ok) { exit 1 }
} catch {
    Write-Error $_.Exception.Message
    exit 1
}
