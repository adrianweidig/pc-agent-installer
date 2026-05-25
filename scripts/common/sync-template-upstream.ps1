[CmdletBinding()]
param(
    [string]$RepoRoot,
    [string]$TemplateRemoteName = 'template',
    [string]$TemplateRemoteUrl = 'https://github.com/adrianweidig/pc-agent-installer.git',
    [string]$TemplateBranch = 'main',
    [switch]$NoCommit
)

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

$detectScript = Join-Path $PSScriptRoot 'detect-repo-mode.ps1'
$guard = & $detectScript -RepoRoot $RepoRoot | ConvertFrom-Json
if ($guard.repo_mode -eq 'template') {
    throw 'Dieses Skript ist für private operational- oder local-only-Klone gedacht. Im Template-Repo normales git pull origin main verwenden.'
}

$status = @(git -C $RepoRoot status --porcelain)
if ($status.Count -gt 0) {
    throw 'Arbeitsbaum ist nicht sauber. Bitte zuerst private Änderungen committen oder bewusst beiseitelegen.'
}

$repoModePath = Join-Path $RepoRoot 'repo-mode.yaml'
$protectedRepoMode = if (Test-Path -LiteralPath $repoModePath) {
    Get-Content -LiteralPath $repoModePath -Raw
} else {
    $null
}

$existingRemote = git -C $RepoRoot remote get-url $TemplateRemoteName 2>$null
if ($LASTEXITCODE -ne 0) {
    git -C $RepoRoot remote add $TemplateRemoteName $TemplateRemoteUrl
} elseif ($existingRemote -ne $TemplateRemoteUrl) {
    git -C $RepoRoot remote set-url $TemplateRemoteName $TemplateRemoteUrl
}

git -C $RepoRoot fetch $TemplateRemoteName $TemplateBranch --tags
if ($LASTEXITCODE -ne 0) { throw 'Template-Remote konnte nicht gefetcht werden.' }

$targetRef = "$TemplateRemoteName/$TemplateBranch"
$current = (git -C $RepoRoot rev-parse HEAD).Trim()
$target = (git -C $RepoRoot rev-parse $targetRef).Trim()
if ($current -eq $target) {
    Write-Host "Bereits auf aktuellem Template-Stand: $targetRef"
    exit 0
}

git -C $RepoRoot merge --no-ff --no-commit $targetRef
$mergeExit = $LASTEXITCODE

if ($protectedRepoMode -and (Test-Path -LiteralPath $repoModePath)) {
    $currentRepoMode = Get-Content -LiteralPath $repoModePath -Raw
    if ($currentRepoMode -ne $protectedRepoMode) {
        [System.IO.File]::WriteAllText($repoModePath, $protectedRepoMode, [System.Text.UTF8Encoding]::new($false))
        git -C $RepoRoot add repo-mode.yaml
        Write-Host 'repo-mode.yaml wurde auf den privaten Operational-Modus zurückgesetzt.'
    }
}

$unmerged = @(git -C $RepoRoot diff --name-only --diff-filter=U)
if ($mergeExit -ne 0 -or $unmerged.Count -gt 0) {
    $message = @"
Template-Merge braucht manuelle Konfliktlösung.

Regeln:
- repo-mode.yaml muss operational oder local-only bleiben.
- hosts/ und private Secret-Referenzen nicht aus dem Template überschreiben.
- Nach der Konfliktlösung: git add <dateien> und git commit.
"@
    Write-Error $message
    exit 20
}

if ($NoCommit) {
    Write-Host 'Template-Merge ist vorbereitet, aber noch nicht committed.'
    exit 0
}

$pending = @(git -C $RepoRoot diff --cached --name-only)
if ($pending.Count -eq 0) {
    Write-Host 'Keine Template-Änderungen zu committen.'
    exit 0
}

git -C $RepoRoot commit -m "chore: synchronisiere template-upstream"
if ($LASTEXITCODE -ne 0) { throw 'Template-Sync-Commit fehlgeschlagen.' }

Write-Host "Template-Sync abgeschlossen. Push ins private origin bei Bedarf mit: git push origin main"
