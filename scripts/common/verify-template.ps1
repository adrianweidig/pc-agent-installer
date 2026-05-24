[CmdletBinding()]
param([string]$RepoRoot)

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

$ErrorActionPreference = 'Stop'
$failures = New-Object System.Collections.Generic.List[string]

function Invoke-Check {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][scriptblock]$ScriptBlock
    )
    Write-Host "==> $Name"
    try {
        & $ScriptBlock
        Write-Host "OK: $Name"
    } catch {
        $script:failures.Add("${Name}: $($_.Exception.Message)")
        Write-Error "FEHLER: $Name - $($_.Exception.Message)" -ErrorAction Continue
    }
}

Invoke-Check 'Repo-Modus erkennen' {
    & (Join-Path $RepoRoot 'scripts/common/detect-repo-mode.ps1') -RepoRoot $RepoRoot | Out-Host
}

Invoke-Check 'Template-Struktur validieren' {
    & (Join-Path $RepoRoot 'scripts/common/validate-template.ps1') -RepoRoot $RepoRoot | Out-Host
}

Invoke-Check 'PowerShell-Skripte parsen' {
    $parseErrors = New-Object System.Collections.Generic.List[string]
    Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'scripts') -Recurse -File -Filter '*.ps1' | ForEach-Object {
        try {
            [scriptblock]::Create([System.IO.File]::ReadAllText($_.FullName)) | Out-Null
        } catch {
            $parseErrors.Add("$($_.FullName): $($_.Exception.Message)")
        }
    }
    if ($parseErrors.Count -gt 0) { throw ($parseErrors -join "`n") }
}

Invoke-Check 'PowerShell-Encoding prüfen' {
    $missingBom = New-Object System.Collections.Generic.List[string]
    Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'scripts') -Recurse -File -Filter '*.ps1' | ForEach-Object {
        $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
        if ($bytes.Length -lt 3 -or $bytes[0] -ne 0xEF -or $bytes[1] -ne 0xBB -or $bytes[2] -ne 0xBF) {
            $missingBom.Add($_.FullName)
        }
    }
    if ($missingBom.Count -gt 0) { throw ("UTF-8-BOM fehlt: " + ($missingBom -join ', ')) }
}

Invoke-Check 'Secret-Pattern-Scan' {
    if (-not (Get-Command rg -ErrorAction SilentlyContinue)) {
        Write-Host 'rg nicht verfügbar, Secret-Pattern-Scan übersprungen.'
        return
    }
    $pattern = '(AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9_]{36,}|github_pat_[A-Za-z0-9_]+|sk-[A-Za-z0-9]{20,}|xox[baprs]-[A-Za-z0-9-]+|-----BEGIN (RSA |OPENSSH |EC |DSA )?PRIVATE KEY-----|password\s*[:=]|passwd\s*[:=]|api[_-]?key\s*[:=]|secret\s*[:=]|token\s*[:=])'
    & rg -n --hidden -S $pattern -g '!LICENSE' -g '!.git/**' $RepoRoot
    if ($LASTEXITCODE -eq 0) { throw 'Mögliche Secret-Treffer gefunden.' }
    if ($LASTEXITCODE -gt 1) { throw "rg fehlgeschlagen mit Exitcode $LASTEXITCODE." }
}

Invoke-Check 'Git-Diff-Whitespace prüfen' {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host 'git nicht verfügbar, git diff --check übersprungen.'
        return
    }
    git -C $RepoRoot diff --check
    if ($LASTEXITCODE -ne 0) { throw "git diff --check fehlgeschlagen mit Exitcode $LASTEXITCODE." }
}

if ($failures.Count -gt 0) {
    Write-Error ("Verify fehlgeschlagen:`n" + ($failures -join "`n"))
    exit 1
}

Write-Host 'verify-template.ps1 erfolgreich.'
