[CmdletBinding()]
param([string]$RepoRoot)

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

$remotes = @(git -C $RepoRoot remote -v 2>$null)
if ($remotes.Count -gt 0) {
    throw 'Local-only-Modus wird nicht aktiviert, solange Git-Remotes vorhanden sind. Remote nicht automatisch entfernen.'
}

$content = @"
repo_mode: local-only
visibility_required: no_remote
allowed_to_write_hosts: true
allowed_to_document_sensitive_context: true
allowed_to_store_plaintext_secrets: false
"@
[System.IO.File]::WriteAllText((Join-Path $RepoRoot 'repo-mode.yaml'), ($content.TrimEnd() + "`n"), [System.Text.UTF8Encoding]::new($false))
Write-Host 'Local-only-Modus aktiviert. Push bleibt verboten, bis ein privater Remote geprüft wurde.'
