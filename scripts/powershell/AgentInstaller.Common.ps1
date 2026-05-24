Set-StrictMode -Version Latest

try {
    [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
    $OutputEncoding = [Console]::OutputEncoding
} catch {}

function Get-AgentRepoRoot {
    param([string]$StartPath = (Get-Location).Path)
    $current = Resolve-Path $StartPath
    while ($current) {
        if (Test-Path -LiteralPath (Join-Path $current '.git')) { return $current.Path }
        $parent = Split-Path -Parent $current.Path
        if (-not $parent -or $parent -eq $current.Path) { break }
        $current = Resolve-Path $parent
    }
    return (Resolve-Path $StartPath).Path
}

function Write-AgentUtf8 {
    param([string]$Path, [string]$Content)
    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    $encoding = if ([System.IO.Path]::GetExtension($Path) -ieq '.ps1') {
        [System.Text.UTF8Encoding]::new($true)
    } else {
        [System.Text.UTF8Encoding]::new($false)
    }
    [System.IO.File]::WriteAllText($Path, ($Content.TrimEnd() + "`n"), $encoding)
}

function Get-AgentRepoModeConfig {
    param([string]$RepoRoot)
    $configPath = Join-Path $RepoRoot 'repo-mode.yaml'
    $mode = 'template'
    $visibilityRequired = 'public'
    if (Test-Path -LiteralPath $configPath) {
        foreach ($line in Get-Content -LiteralPath $configPath) {
            if ($line -match '^\s*repo_mode:\s*["'']?([^"''#\s]+)') { $mode = $Matches[1] }
            if ($line -match '^\s*visibility_required:\s*["'']?([^"''#\s]+)') { $visibilityRequired = $Matches[1] }
        }
    }
    [pscustomobject]@{
        repo_mode = $mode
        visibility_required = $visibilityRequired
    }
}

function Get-AgentRepoGuard {
    param([string]$RepoRoot)
    $config = Get-AgentRepoModeConfig -RepoRoot $RepoRoot
    $remoteLines = @()
    try {
        $remoteLines = @(git -C $RepoRoot remote -v 2>$null)
    } catch {
        $remoteLines = @()
    }
    $remoteUrls = @($remoteLines | ForEach-Object {
        if ($_ -match '\s+([^\s]+)\s+\((fetch|push)\)$') { $Matches[1] }
    } | Sort-Object -Unique)

    $visibility = 'unknown'
    $visibilityChecked = $false
    $repoName = $null
    $isPrivate = $false

    if ($remoteUrls.Count -eq 0) {
        $visibility = 'no_remote'
        $visibilityChecked = $true
    } elseif (Get-Command gh -ErrorAction SilentlyContinue) {
        try {
            Push-Location $RepoRoot
            $raw = gh repo view --json isPrivate,visibility,nameWithOwner 2>$null
            Pop-Location
            if ($raw) {
                $gh = $raw | ConvertFrom-Json
                $visibility = ([string]$gh.visibility).ToLowerInvariant()
                $visibilityChecked = $true
                $repoName = $gh.nameWithOwner
                $isPrivate = [bool]$gh.isPrivate
            }
        } catch {
            try { Pop-Location } catch {}
        }
    }

    if (-not $visibilityChecked -and $remoteUrls.Count -gt 0 -and $env:GITHUB_TOKEN) {
        $firstRemote = [string]$remoteUrls[0]
        $ownerRepo = $null
        if ($firstRemote -match 'github\.com[:/](?<repo>[^/]+/.+?)(?:\.git)?$') {
            $ownerRepo = $Matches['repo'] -replace '\.git$', ''
        }
        if ($ownerRepo) {
            try {
                $headers = @{
                    Accept = 'application/vnd.github+json'
                    Authorization = "Bearer $env:GITHUB_TOKEN"
                    'X-GitHub-Api-Version' = '2022-11-28'
                }
                $api = Invoke-RestMethod -Uri "https://api.github.com/repos/$ownerRepo" -Headers $headers -Method Get
                $isPrivate = [bool]$api.private
                $visibility = if ($isPrivate) { 'private' } else { 'public' }
                $visibilityChecked = $true
                $repoName = $api.full_name
            } catch {}
        }
    }

    $allowed = $false
    $pushAllowed = $false
    if ($config.repo_mode -eq 'operational' -and $visibilityChecked -and ($isPrivate -or $visibility -eq 'private')) {
        $allowed = $true
        $pushAllowed = $true
    } elseif ($config.repo_mode -eq 'local-only' -and $visibilityChecked -and $visibility -eq 'no_remote') {
        $allowed = $true
    }

    if ($config.repo_mode -eq 'template') {
        $allowed = $false
        $pushAllowed = $false
    }

    [pscustomobject]@{
        repo_mode = $config.repo_mode
        visibility_required = $config.visibility_required
        visibility_checked = $visibilityChecked
        visibility = $visibility
        github_repo = $repoName
        remotes = $remoteUrls
        allowed_to_write_hosts = $allowed
        allowed_to_document_sensitive_context = $allowed
        allowed_to_store_plaintext_secrets = $false
        push_allowed = $pushAllowed
    }
}

function Assert-AgentHostWriteAllowed {
    param([string]$RepoRoot)
    $guard = Get-AgentRepoGuard -RepoRoot $RepoRoot
    if ($guard.allowed_to_write_hosts) { return $guard }
    $message = @"
WARNUNG:
Dieses Repository ist nicht als sicherer Hostdaten-Zielort bestätigt.
Modus: $($guard.repo_mode)
Sichtbarkeit: $($guard.visibility)
Sichtbarkeit geprüft: $($guard.visibility_checked)

Hostdaten, Infrastrukturinformationen, Secrets, Tokens, private Pfade und sicherheitskritische Konfigurationen werden hier nicht dokumentiert.

Sichere Optionen:
1. Private GitHub-Kopie aus Template erzeugen.
2. Lokales Git-Repo ohne Remote verwenden und local-only aktivieren.
3. Abbrechen.
"@
    Write-Error $message
    exit 10
}

function ConvertTo-AgentYamlScalar {
    param($Value)
    if ($null -eq $Value -or $Value -eq '') { return 'null' }
    $text = [string]$Value
    $escaped = $text.Replace('\', '\\').Replace('"', '\"')
    return '"' + $escaped + '"'
}

function Protect-AgentSecretText {
    param([string]$Text)
    if ($null -eq $Text) { return $null }
    $patterns = @(
        '(?i)(password|passwd|pwd|secret|token|api[_-]?key|credential|private[_-]?key)(\s*[:=]\s*)(\S+)',
        '(?i)(Authorization:\s*Bearer\s+)(\S+)',
        '(?i)(BEGIN\s+(RSA|OPENSSH|EC|DSA)?\s*PRIVATE\s+KEY)[\s\S]*?(END\s+(RSA|OPENSSH|EC|DSA)?\s*PRIVATE\s+KEY)'
    )
    $result = $Text
    foreach ($pattern in $patterns) {
        $result = [regex]::Replace($result, $pattern, {
            param($m)
            if ($m.Groups.Count -ge 4) { return $m.Groups[1].Value + $m.Groups[2].Value + '[REDACTED]' }
            return '[REDACTED-PRIVATE-KEY]'
        })
    }
    return $result
}

function New-AgentHostTree {
    param([string]$RepoRoot, [string]$HostName)
    $hostRoot = Join-Path $RepoRoot (Join-Path 'hosts' $HostName)
    $dirs = @(
        'baseline/raw', 'changes', 'rollback', 'security', 'container/docker',
        'container/compose', 'container/swarm', 'container/kubernetes',
        'container/podman', 'logs', 'state'
    )
    foreach ($dir in $dirs) {
        New-Item -ItemType Directory -Path (Join-Path $hostRoot $dir) -Force | Out-Null
    }
    return $hostRoot
}
