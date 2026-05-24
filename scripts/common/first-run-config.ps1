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
if ((Test-Path -LiteralPath $configPath) -and (Select-String -LiteralPath $configPath -Pattern '^\s*completed:\s*true\s*$' -Quiet)) {
    Write-Host "Erststart-Konfiguration ist bereits abgeschlossen: $configPath"
    exit 0
}

$defaults = [ordered]@{
    allow_baseline = $true
    allow_security_recommendations = $true
    allow_package_recommendations = $true
    allow_optional_av = $false
    allow_blocklist_pilot = $false
    allow_firewall_ip_blocklists = $false
    windows_wsl_backend = $false
    windows_wsl_with_docker = $false
    windows_portainer_ui = $false
    windows_wsl_recommendations = $false
    require_confirmation_for_system_changes = $true
}
$isWindowsHost = $IsWindows -or $env:OS -eq 'Windows_NT'

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

$values = [ordered]@{}
$usedUi = 'console'

if (-not $ConsoleOnly -and $isWindowsHost) {
    try {
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
        $form = [System.Windows.Forms.Form]::new()
        $form.Text = 'PC Agent Installer - Erststart-Konfiguration'
        $form.Width = 760
        $form.Height = 760
        $form.StartPosition = 'CenterScreen'
        $form.TopMost = $true

        $intro = [System.Windows.Forms.Label]::new()
        $intro.Text = 'Bitte lege fest, was der Agent auf diesem PC grundsaetzlich vorbereiten darf. Vor Abschluss dieser Konfiguration fuehrt der Agent keine Host-Arbeit aus.'
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
        $profile.Text = ''
        $form.Controls.Add($profile)

        $items = [ordered]@{
            allow_baseline = 'Host-Baseline erfassen und dokumentieren'
            allow_security_recommendations = 'Usability-first Sicherheitsempfehlungen anzeigen'
            allow_package_recommendations = 'Kostenlose, aktuelle Tools und Updates empfehlen'
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
        $note.Text = 'Notiz fuer den Agenten, z. B. bevorzugte Tools, Dinge die nicht veraendert werden sollen, oder spaeter zu klaerende Punkte.'
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
    Write-Host 'Erststart-Konfiguration ist noch nicht abgeschlossen.'
    $values['person_description'] = Read-Host 'Beschreibe dich kurz fuer sinnvolle Programmempfehlungen, z. B. "Ich bin Entwickler"'
    $values['allow_baseline'] = Read-AgentYesNo -Prompt 'Host-Baseline erfassen und dokumentieren?' -Default $true
    $values['allow_security_recommendations'] = Read-AgentYesNo -Prompt 'Usability-first Sicherheitsempfehlungen anzeigen?' -Default $true
    $values['allow_package_recommendations'] = Read-AgentYesNo -Prompt 'Kostenlose, aktuelle Tools und Updates empfehlen?' -Default $true
    $values['allow_optional_av'] = Read-AgentYesNo -Prompt 'Optionalen kostenlosen On-Demand-Malware-Scanner anbieten?' -Default $false
    $values['allow_blocklist_pilot'] = Read-AgentYesNo -Prompt 'DNS-/Host-Blocklisten nur im Pilotmodus anbieten?' -Default $false
    $values['allow_firewall_ip_blocklists'] = Read-AgentYesNo -Prompt 'IP-Firewall-Blocklisten als riskante Option anbieten?' -Default $false
    $values['windows_wsl_backend'] = Read-AgentYesNo -Prompt 'Windows: WSL-Backend fuer Linux-Tools vorbereiten?' -Default $false
    if ($values.windows_wsl_backend) {
        $values['windows_wsl_with_docker'] = Read-AgentYesNo -Prompt 'Windows: Docker mit WSL-Unterstuetzung einplanen?' -Default $false
        if ($values.windows_wsl_with_docker) {
            $values['windows_portainer_ui'] = Read-AgentYesNo -Prompt 'Windows: Portainer CE als Docker-Verwaltungsoberflaeche empfehlen?' -Default $false
        } else {
            $values['windows_portainer_ui'] = $false
        }
        $values['windows_wsl_recommendations'] = $true
    } else {
        $values['windows_wsl_with_docker'] = $false
        $values['windows_portainer_ui'] = $false
        $values['windows_wsl_recommendations'] = $false
    }
    $values['require_confirmation_for_system_changes'] = Read-AgentYesNo -Prompt 'Vor systemwirksamen Aenderungen immer bestaetigen lassen?' -Default $true
    $values['note'] = Read-Host 'Optionale Notiz fuer den Agenten'
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
