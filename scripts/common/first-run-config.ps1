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
        $form.Height = 520
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

        $items = [ordered]@{
            allow_baseline = 'Host-Baseline erfassen und dokumentieren'
            allow_security_recommendations = 'Usability-first Sicherheitsempfehlungen anzeigen'
            allow_package_recommendations = 'Kostenlose, aktuelle Tools und Updates empfehlen'
            allow_optional_av = 'Optionalen kostenlosen On-Demand-Malware-Scanner anbieten'
            allow_blocklist_pilot = 'DNS-/Host-Blocklisten nur im Pilotmodus anbieten'
            allow_firewall_ip_blocklists = 'IP-Firewall-Blocklisten als riskante Option anbieten'
            require_confirmation_for_system_changes = 'Vor systemwirksamen Aenderungen immer bestaetigen lassen'
        }
        $checks = @{}
        $top = 85
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
    foreach ($key in $defaults.Keys) {
        $label = ($key -replace '_', ' ')
        $values[$key] = Read-AgentYesNo -Prompt $label -Default ([bool]$defaults[$key])
    }
    $values['note'] = Read-Host 'Optionale Notiz fuer den Agenten'
}

$now = (Get-Date).ToString('o')
$safeNote = (Protect-AgentSecretText -Text ([string]$values.note)).Replace('"', '\"')
$yaml = @"
completed: true
configured_at: "$now"
configured_by: "first-run-config.ps1"
ui: "$usedUi"
repo_mode: "$($guard.repo_mode)"
visibility: "$($guard.visibility)"
host: "$HostName"
preferences:
  allow_baseline: $($values.allow_baseline.ToString().ToLowerInvariant())
  allow_security_recommendations: $($values.allow_security_recommendations.ToString().ToLowerInvariant())
  allow_package_recommendations: $($values.allow_package_recommendations.ToString().ToLowerInvariant())
  allow_optional_av: $($values.allow_optional_av.ToString().ToLowerInvariant())
  allow_blocklist_pilot: $($values.allow_blocklist_pilot.ToString().ToLowerInvariant())
  allow_firewall_ip_blocklists: $($values.allow_firewall_ip_blocklists.ToString().ToLowerInvariant())
  require_confirmation_for_system_changes: $($values.require_confirmation_for_system_changes.ToString().ToLowerInvariant())
note: "$safeNote"
"@

Write-AgentUtf8 -Path $configPath -Content $yaml
Write-Host "Erststart-Konfiguration gespeichert: $configPath"
