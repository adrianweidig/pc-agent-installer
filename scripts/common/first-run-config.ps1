[CmdletBinding()]
param(
    [string]$RepoRoot,
    [string]$HostName = $env:COMPUTERNAME,
    [switch]$ConsoleOnly
)

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

. (Join-Path $PSScriptRoot '..\powershell\AgentInstaller.Common.ps1')
$guard = Assert-AgentHostWriteAllowed -RepoRoot $RepoRoot
if (-not $HostName) { $HostName = [System.Net.Dns]::GetHostName() }
$hostRoot = New-AgentHostTree -RepoRoot $RepoRoot -HostName $HostName
$configPath = Join-Path $hostRoot 'state/first-run-config.yaml'

$defaults = [ordered]@{
    allow_baseline = $true
    allow_security_recommendations = $true
    allow_package_recommendations = $true
    allow_update_maintenance = $true
    allow_package_source_audit = $true
    allow_disk_health_review = $true
    allow_encryption_recommendations = $true
    allow_security_exception_review = $true
    allow_startup_service_review = $true
    allow_workspace_hygiene_review = $true
    allow_developer_toolchain_review = $true
    allow_container_exposure_review = $true
    allow_optional_av = $false
    allow_blocklist_pilot = $false
    allow_firewall_ip_blocklists = $false
    windows_wsl_backend = $false
    windows_wsl_with_docker = $false
    windows_portainer_ui = $false
    windows_wsl_recommendations = $false
    require_confirmation_for_system_changes = $true
}
$isWindowsHost = $env:OS -eq 'Windows_NT'
$isWindowsVariable = Get-Variable -Name IsWindows -ErrorAction SilentlyContinue
if (-not $isWindowsHost -and $isWindowsVariable) {
    $isWindowsHost = [bool]$isWindowsVariable.Value
}

function ConvertFrom-AgentConfigScalar {
    param([string]$Value)
    if ($null -eq $Value) { return '' }
    return $Value.Replace('\"', '"')
}

function Merge-AgentExistingFirstRunConfig {
    param(
        [string]$Path,
        [System.Collections.Specialized.OrderedDictionary]$Fallback
    )

    $values = [ordered]@{}
    foreach ($key in $Fallback.Keys) { $values[$key] = $Fallback[$key] }
    $values['person_description'] = ''
    $values['note'] = ''

    if (-not (Test-Path -LiteralPath $Path)) { return $values }

    foreach ($line in Get-Content -LiteralPath $Path) {
        if ($line -match '^\s+([a-z0-9_]+):\s*(true|false)\s*$') {
            $values[$Matches[1]] = ($Matches[2] -eq 'true')
        } elseif ($line -match '^\s+person_description:\s*"(.*)"\s*$') {
            $values['person_description'] = ConvertFrom-AgentConfigScalar -Value $Matches[1]
        } elseif ($line -match '^\s*note:\s*"(.*)"\s*$') {
            $values['note'] = ConvertFrom-AgentConfigScalar -Value $Matches[1]
        }
    }

    return $values
}

$configurationMode = if (Test-Path -LiteralPath $configPath) { 'reconfigure' } else { 'first-run' }
$defaults = Merge-AgentExistingFirstRunConfig -Path $configPath -Fallback $defaults

function Read-AgentYesNo {
    param([string]$Prompt, [bool]$Default)
    $suffix = if ($Default) { '[J/n]' } else { '[j/N]' }
    while ($true) {
        $answer = Read-Host "$Prompt $suffix"
        if ([string]::IsNullOrWhiteSpace($answer)) { return $Default }
        switch -Regex ($answer.Trim()) {
            '^(j|ja|y|yes)$' { return $true }
            '^(n|nein|no)$' { return $false }
        }
        Write-Host 'Bitte mit Ja oder Nein antworten.'
    }
}

function Read-AgentText {
    param([string]$Prompt, [string]$Default = '')
    if ([string]::IsNullOrWhiteSpace($Default)) {
        return (Read-Host $Prompt)
    }
    $answer = Read-Host "$Prompt [$Default]"
    if ([string]::IsNullOrWhiteSpace($answer)) { return $Default }
    return $answer
}

$values = [ordered]@{}
$usedUi = 'console'

if (-not $ConsoleOnly -and $isWindowsHost) {
    try {
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
        $form = [System.Windows.Forms.Form]::new()
        $form.Text = 'PC Agent Installer - Agenten-Konfiguration'
        $form.Width = 760
        $form.Height = 900
        $form.AutoScroll = $true
        $form.StartPosition = 'CenterScreen'
        $form.TopMost = $true

        $intro = [System.Windows.Forms.Label]::new()
        $intro.Text = 'Lege fest, was der Agent auf diesem PC vorbereiten darf. Bestehende Optionen koennen hier erneut aktiviert oder deaktiviert werden.'
        $intro.AutoSize = $false
        $intro.Width = 700
        $intro.Height = 50
        $intro.Left = 20
        $intro.Top = 20
        $form.Controls.Add($intro)

        $profileLabel = [System.Windows.Forms.Label]::new()
        $profileLabel.Text = 'Beschreibe dich kurz, damit der Agent sinnvolle Programme und Einstellungen ableiten kann. Beispiel: "Ich bin Entwickler und nutze KI-Tools."'
        $profileLabel.AutoSize = $false
        $profileLabel.Width = 700
        $profileLabel.Height = 40
        $profileLabel.Left = 20
        $profileLabel.Top = 75
        $form.Controls.Add($profileLabel)

        $profile = [System.Windows.Forms.TextBox]::new()
        $profile.Left = 25
        $profile.Top = 115
        $profile.Width = 690
        $profile.Height = 45
        $profile.Multiline = $true
        $profile.Text = [string]$defaults['person_description']
        $form.Controls.Add($profile)

        $items = [ordered]@{
            allow_baseline = 'Host-Baseline erfassen und dokumentieren'
            allow_security_recommendations = 'Usability-first Sicherheitsempfehlungen anzeigen'
            allow_package_recommendations = 'Kostenlose, aktuelle Tools und Updates empfehlen'
            allow_update_maintenance = 'Betriebssystem-, App- und Paketupdates prüfen'
            allow_package_source_audit = 'Paketquellen, Stores und Dritt-Repositories prüfen'
            allow_disk_health_review = 'Datenträgerzustand, Dateisystem und Speicherplatz prüfen'
            allow_encryption_recommendations = 'Geräteverschlüsselung prüfen und empfehlen'
            allow_security_exception_review = 'Security-Ausnahmen wie AV-Exclusions prüfen'
            allow_startup_service_review = 'Autostart, Dienste und Hintergrundprozesse bewerten'
            allow_workspace_hygiene_review = 'Workspace-Hygiene, Backups und Duplikate prüfen'
            allow_developer_toolchain_review = 'Entwickler-Toolchains und Paketmanager bewerten'
            allow_container_exposure_review = 'Container-Ports, Volumes und Secrets prüfen'
            allow_optional_av = 'Optionalen kostenlosen On-Demand-Malware-Scanner anbieten'
            allow_blocklist_pilot = 'DNS-/Host-Blocklisten nur im Pilotmodus anbieten'
            allow_firewall_ip_blocklists = 'IP-Firewall-Blocklisten als riskante Option anbieten'
            windows_wsl_backend = 'Windows: WSL-Backend fuer Linux-Tools vorbereiten'
            windows_wsl_with_docker = 'Windows: Docker mit WSL-Unterstuetzung einplanen'
            windows_portainer_ui = 'Windows: Portainer CE als Docker-Verwaltungsoberflaeche empfehlen'
            require_confirmation_for_system_changes = 'Vor systemwirksamen Aenderungen immer bestaetigen lassen'
        }
        $checks = @{}
        $top = 175
        foreach ($key in $items.Keys) {
            $box = [System.Windows.Forms.CheckBox]::new()
            $box.Text = $items[$key]
            $box.Width = 690
            $box.Left = 25
            $box.Top = $top
            $box.Checked = [bool]$defaults[$key]
            $form.Controls.Add($box)
            $checks[$key] = $box
            $top += 35
        }

        $checks['windows_wsl_with_docker'].Enabled = [bool]$checks['windows_wsl_backend'].Checked
        $checks['windows_portainer_ui'].Enabled = [bool]$checks['windows_wsl_with_docker'].Checked
        $checks['windows_wsl_backend'].Add_CheckedChanged({
            $checks['windows_wsl_with_docker'].Enabled = [bool]$checks['windows_wsl_backend'].Checked
            if (-not $checks['windows_wsl_backend'].Checked) {
                $checks['windows_wsl_with_docker'].Checked = $false
                $checks['windows_portainer_ui'].Checked = $false
            }
        })
        $checks['windows_wsl_with_docker'].Add_CheckedChanged({
            $checks['windows_portainer_ui'].Enabled = [bool]$checks['windows_wsl_with_docker'].Checked
            if (-not $checks['windows_wsl_with_docker'].Checked) {
                $checks['windows_portainer_ui'].Checked = $false
            }
            if ($checks['windows_wsl_with_docker'].Checked) {
                $checks['windows_wsl_backend'].Checked = $true
            }
        })
        $checks['windows_portainer_ui'].Add_CheckedChanged({
            if ($checks['windows_portainer_ui'].Checked) {
                $checks['windows_wsl_backend'].Checked = $true
                $checks['windows_wsl_with_docker'].Checked = $true
            }
        })

        $note = [System.Windows.Forms.TextBox]::new()
        $note.Left = 25
        $note.Top = $top + 10
        $note.Width = 690
        $note.Height = 80
        $note.Multiline = $true
        $note.Text = [string]$defaults['note']
        $form.Controls.Add($note)

        $ok = [System.Windows.Forms.Button]::new()
        $ok.Text = 'Konfiguration speichern'
        $ok.Width = 180
        $ok.Left = 535
        $ok.Top = $top + 110
        $ok.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.AcceptButton = $ok
        $form.Controls.Add($ok)

        if ($form.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            foreach ($key in $items.Keys) { $values[$key] = [bool]$checks[$key].Checked }
            $values['windows_wsl_recommendations'] = [bool]$values.windows_wsl_backend
            $values['person_description'] = $profile.Text
            $values['note'] = $note.Text
            $usedUi = 'powershell-windows-forms'
        } else {
            throw 'Erststart-Konfiguration wurde abgebrochen.'
        }
    } catch {
        Write-Warning "GUI-Konfiguration nicht verfuegbar: $($_.Exception.Message)"
    }
}

if ($values.Count -eq 0) {
    if ($configurationMode -eq 'reconfigure') {
        Write-Host 'Agenten-Konfiguration wird erneut geoeffnet. Leere Antworten behalten vorhandene Werte bei.'
    } else {
        Write-Host 'Agenten-Konfiguration wird gestartet.'
    }
    $values['person_description'] = Read-AgentText -Prompt 'Beschreibe dich kurz fuer sinnvolle Programmempfehlungen, z. B. "Ich bin Entwickler"' -Default ([string]$defaults['person_description'])
    $values['allow_baseline'] = Read-AgentYesNo -Prompt 'Host-Baseline erfassen und dokumentieren?' -Default ([bool]$defaults['allow_baseline'])
    $values['allow_security_recommendations'] = Read-AgentYesNo -Prompt 'Usability-first Sicherheitsempfehlungen anzeigen?' -Default ([bool]$defaults['allow_security_recommendations'])
    $values['allow_package_recommendations'] = Read-AgentYesNo -Prompt 'Kostenlose, aktuelle Tools und Updates empfehlen?' -Default ([bool]$defaults['allow_package_recommendations'])
    $values['allow_update_maintenance'] = Read-AgentYesNo -Prompt 'Betriebssystem-, App- und Paketupdates prüfen?' -Default ([bool]$defaults['allow_update_maintenance'])
    $values['allow_package_source_audit'] = Read-AgentYesNo -Prompt 'Paketquellen, Stores und Dritt-Repositories prüfen?' -Default ([bool]$defaults['allow_package_source_audit'])
    $values['allow_disk_health_review'] = Read-AgentYesNo -Prompt 'Datenträgerzustand, Dateisystem und Speicherplatz prüfen?' -Default ([bool]$defaults['allow_disk_health_review'])
    $values['allow_encryption_recommendations'] = Read-AgentYesNo -Prompt 'Geräteverschlüsselung prüfen und empfehlen?' -Default ([bool]$defaults['allow_encryption_recommendations'])
    $values['allow_security_exception_review'] = Read-AgentYesNo -Prompt 'Security-Ausnahmen wie AV-Exclusions prüfen?' -Default ([bool]$defaults['allow_security_exception_review'])
    $values['allow_startup_service_review'] = Read-AgentYesNo -Prompt 'Autostart, Dienste und Hintergrundprozesse bewerten?' -Default ([bool]$defaults['allow_startup_service_review'])
    $values['allow_workspace_hygiene_review'] = Read-AgentYesNo -Prompt 'Workspace-Hygiene, Backups und Duplikate prüfen?' -Default ([bool]$defaults['allow_workspace_hygiene_review'])
    $values['allow_developer_toolchain_review'] = Read-AgentYesNo -Prompt 'Entwickler-Toolchains und Paketmanager bewerten?' -Default ([bool]$defaults['allow_developer_toolchain_review'])
    $values['allow_container_exposure_review'] = Read-AgentYesNo -Prompt 'Container-Ports, Volumes und Secrets prüfen?' -Default ([bool]$defaults['allow_container_exposure_review'])
    $values['allow_optional_av'] = Read-AgentYesNo -Prompt 'Optionalen kostenlosen On-Demand-Malware-Scanner anbieten?' -Default ([bool]$defaults['allow_optional_av'])
    $values['allow_blocklist_pilot'] = Read-AgentYesNo -Prompt 'DNS-/Host-Blocklisten nur im Pilotmodus anbieten?' -Default ([bool]$defaults['allow_blocklist_pilot'])
    $values['allow_firewall_ip_blocklists'] = Read-AgentYesNo -Prompt 'IP-Firewall-Blocklisten als riskante Option anbieten?' -Default ([bool]$defaults['allow_firewall_ip_blocklists'])
    $values['windows_wsl_backend'] = Read-AgentYesNo -Prompt 'Windows: WSL-Backend fuer Linux-Tools vorbereiten?' -Default ([bool]$defaults['windows_wsl_backend'])
    if ($values.windows_wsl_backend) {
        $values['windows_wsl_with_docker'] = Read-AgentYesNo -Prompt 'Windows: Docker mit WSL-Unterstuetzung einplanen?' -Default ([bool]$defaults['windows_wsl_with_docker'])
        if ($values.windows_wsl_with_docker) {
            $values['windows_portainer_ui'] = Read-AgentYesNo -Prompt 'Windows: Portainer CE als Docker-Verwaltungsoberflaeche empfehlen?' -Default ([bool]$defaults['windows_portainer_ui'])
        } else {
            $values['windows_portainer_ui'] = $false
        }
        $values['windows_wsl_recommendations'] = $true
    } else {
        $values['windows_wsl_with_docker'] = $false
        $values['windows_portainer_ui'] = $false
        $values['windows_wsl_recommendations'] = $false
    }
    $values['require_confirmation_for_system_changes'] = Read-AgentYesNo -Prompt 'Vor systemwirksamen Aenderungen immer bestaetigen lassen?' -Default ([bool]$defaults['require_confirmation_for_system_changes'])
    $values['note'] = Read-AgentText -Prompt 'Optionale Notiz fuer den Agenten' -Default ([string]$defaults['note'])
}

if (-not $values.windows_wsl_backend) {
    $values['windows_wsl_with_docker'] = $false
    $values['windows_portainer_ui'] = $false
    $values['windows_wsl_recommendations'] = $false
} elseif (-not $values.windows_wsl_with_docker) {
    $values['windows_portainer_ui'] = $false
    $values['windows_wsl_recommendations'] = $true
} else {
    $values['windows_wsl_recommendations'] = $true
}

$now = (Get-Date).ToString('o')
$safePersonDescription = (Protect-AgentSecretText -Text ([string]$values.person_description)).Replace("`r", ' ').Replace("`n", ' ').Replace('"', '\"')
$safeNote = (Protect-AgentSecretText -Text ([string]$values.note)).Replace("`r", ' ').Replace("`n", ' ').Replace('"', '\"')
$yaml = @"
completed: true
configured_at: "$now"
configured_by: "first-run-config.ps1"
configuration_mode: "$configurationMode"
ui: "$usedUi"
repo_mode: "$($guard.repo_mode)"
visibility: "$($guard.visibility)"
host: "$HostName"
user_context:
  person_description: "$safePersonDescription"
preferences:
  allow_baseline: $($values.allow_baseline.ToString().ToLowerInvariant())
  allow_security_recommendations: $($values.allow_security_recommendations.ToString().ToLowerInvariant())
  allow_package_recommendations: $($values.allow_package_recommendations.ToString().ToLowerInvariant())
  allow_update_maintenance: $($values.allow_update_maintenance.ToString().ToLowerInvariant())
  allow_package_source_audit: $($values.allow_package_source_audit.ToString().ToLowerInvariant())
  allow_disk_health_review: $($values.allow_disk_health_review.ToString().ToLowerInvariant())
  allow_encryption_recommendations: $($values.allow_encryption_recommendations.ToString().ToLowerInvariant())
  allow_security_exception_review: $($values.allow_security_exception_review.ToString().ToLowerInvariant())
  allow_startup_service_review: $($values.allow_startup_service_review.ToString().ToLowerInvariant())
  allow_workspace_hygiene_review: $($values.allow_workspace_hygiene_review.ToString().ToLowerInvariant())
  allow_developer_toolchain_review: $($values.allow_developer_toolchain_review.ToString().ToLowerInvariant())
  allow_container_exposure_review: $($values.allow_container_exposure_review.ToString().ToLowerInvariant())
  allow_optional_av: $($values.allow_optional_av.ToString().ToLowerInvariant())
  allow_blocklist_pilot: $($values.allow_blocklist_pilot.ToString().ToLowerInvariant())
  allow_firewall_ip_blocklists: $($values.allow_firewall_ip_blocklists.ToString().ToLowerInvariant())
  windows_wsl_backend: $($values.windows_wsl_backend.ToString().ToLowerInvariant())
  windows_wsl_with_docker: $($values.windows_wsl_with_docker.ToString().ToLowerInvariant())
  windows_portainer_ui: $($values.windows_portainer_ui.ToString().ToLowerInvariant())
  windows_wsl_recommendations: $($values.windows_wsl_recommendations.ToString().ToLowerInvariant())
  require_confirmation_for_system_changes: $($values.require_confirmation_for_system_changes.ToString().ToLowerInvariant())
note: "$safeNote"
"@

Write-AgentUtf8 -Path $configPath -Content $yaml
Write-Host "Erststart-Konfiguration gespeichert: $configPath"
