[CmdletBinding()]
param(
    [string]$RepoRoot,
    [string]$HostName = $env:COMPUTERNAME,
    [string]$Language,
    [switch]$ConsoleOnly
)

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

. (Join-Path $PSScriptRoot '..\powershell\AgentInstaller.Common.ps1')
. (Join-Path $PSScriptRoot 'i18n.ps1')
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
    language = 'de'
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
        } elseif ($line -match '^\s*language:\s*"?([a-zA-Z_-]+)"?\s*$') {
            $values['language'] = ConvertFrom-AgentConfigScalar -Value $Matches[1]
        }
    }

    return $values
}

$configurationMode = if (Test-Path -LiteralPath $configPath) { 'reconfigure' } else { 'first-run' }
$defaults = Merge-AgentExistingFirstRunConfig -Path $configPath -Fallback $defaults
$agentLanguage = Resolve-AgentLanguage -ExplicitLanguage $Language -ConfigLanguage ([string]$defaults['language'])

function T {
    param([Parameter(Mandatory = $true)][string]$Key)
    return Get-AgentText -Key $Key -Language $agentLanguage
}

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
        Write-Host (T 'answer_yes_no')
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
        $form.Text = T 'form_title'
        $form.Width = 760
        $form.Height = 900
        $form.AutoScroll = $true
        $form.StartPosition = 'CenterScreen'
        $form.TopMost = $true

        $intro = [System.Windows.Forms.Label]::new()
        $intro.Text = T 'form_intro'
        $intro.AutoSize = $false
        $intro.Width = 700
        $intro.Height = 50
        $intro.Left = 20
        $intro.Top = 20
        $form.Controls.Add($intro)

        $profileLabel = [System.Windows.Forms.Label]::new()
        $profileLabel.Text = T 'form_profile'
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

        $languageLabel = [System.Windows.Forms.Label]::new()
        $languageLabel.Text = T 'language_label'
        $languageLabel.AutoSize = $false
        $languageLabel.Width = 260
        $languageLabel.Height = 25
        $languageLabel.Left = 25
        $languageLabel.Top = 165
        $form.Controls.Add($languageLabel)

        $languageBox = [System.Windows.Forms.ComboBox]::new()
        $languageBox.Left = 300
        $languageBox.Top = 162
        $languageBox.Width = 120
        [void]$languageBox.Items.Add('de')
        [void]$languageBox.Items.Add('en')
        $languageBox.SelectedItem = $agentLanguage
        $form.Controls.Add($languageBox)

        $items = [ordered]@{
            allow_baseline = T 'allow_baseline'
            allow_security_recommendations = T 'allow_security_recommendations'
            allow_package_recommendations = T 'allow_package_recommendations'
            allow_update_maintenance = T 'allow_update_maintenance'
            allow_package_source_audit = T 'allow_package_source_audit'
            allow_disk_health_review = T 'allow_disk_health_review'
            allow_encryption_recommendations = T 'allow_encryption_recommendations'
            allow_security_exception_review = T 'allow_security_exception_review'
            allow_startup_service_review = T 'allow_startup_service_review'
            allow_workspace_hygiene_review = T 'allow_workspace_hygiene_review'
            allow_developer_toolchain_review = T 'allow_developer_toolchain_review'
            allow_container_exposure_review = T 'allow_container_exposure_review'
            allow_optional_av = T 'allow_optional_av'
            allow_blocklist_pilot = T 'allow_blocklist_pilot'
            allow_firewall_ip_blocklists = T 'allow_firewall_ip_blocklists'
            windows_wsl_backend = T 'windows_wsl_backend'
            windows_wsl_with_docker = T 'windows_wsl_with_docker'
            windows_portainer_ui = T 'windows_portainer_ui'
            require_confirmation_for_system_changes = T 'require_confirmation_for_system_changes'
        }
        $checks = @{}
        $top = 205
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
        $ok.Text = T 'form_save'
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
            $values['language'] = Resolve-AgentLanguage -ExplicitLanguage ([string]$languageBox.SelectedItem)
            $usedUi = 'powershell-windows-forms'
        } else {
            throw (T 'form_cancelled')
        }
    } catch {
        Write-Warning ((T 'gui_unavailable') -f $_.Exception.Message)
    }
}

if ($values.Count -eq 0) {
    if ($configurationMode -eq 'reconfigure') {
        Write-Host (T 'config_reopened')
    } else {
        Write-Host (T 'config_started')
    }
    $agentLanguage = Resolve-AgentLanguage -ExplicitLanguage (Read-AgentText -Prompt (T 'language_prompt') -Default $agentLanguage)
    $values['language'] = $agentLanguage
    $values['person_description'] = Read-AgentText -Prompt (T 'profile_prompt') -Default ([string]$defaults['person_description'])
    $values['allow_baseline'] = Read-AgentYesNo -Prompt (T 'allow_baseline') -Default ([bool]$defaults['allow_baseline'])
    $values['allow_security_recommendations'] = Read-AgentYesNo -Prompt (T 'allow_security_recommendations') -Default ([bool]$defaults['allow_security_recommendations'])
    $values['allow_package_recommendations'] = Read-AgentYesNo -Prompt (T 'allow_package_recommendations') -Default ([bool]$defaults['allow_package_recommendations'])
    $values['allow_update_maintenance'] = Read-AgentYesNo -Prompt (T 'allow_update_maintenance') -Default ([bool]$defaults['allow_update_maintenance'])
    $values['allow_package_source_audit'] = Read-AgentYesNo -Prompt (T 'allow_package_source_audit') -Default ([bool]$defaults['allow_package_source_audit'])
    $values['allow_disk_health_review'] = Read-AgentYesNo -Prompt (T 'allow_disk_health_review') -Default ([bool]$defaults['allow_disk_health_review'])
    $values['allow_encryption_recommendations'] = Read-AgentYesNo -Prompt (T 'allow_encryption_recommendations') -Default ([bool]$defaults['allow_encryption_recommendations'])
    $values['allow_security_exception_review'] = Read-AgentYesNo -Prompt (T 'allow_security_exception_review') -Default ([bool]$defaults['allow_security_exception_review'])
    $values['allow_startup_service_review'] = Read-AgentYesNo -Prompt (T 'allow_startup_service_review') -Default ([bool]$defaults['allow_startup_service_review'])
    $values['allow_workspace_hygiene_review'] = Read-AgentYesNo -Prompt (T 'allow_workspace_hygiene_review') -Default ([bool]$defaults['allow_workspace_hygiene_review'])
    $values['allow_developer_toolchain_review'] = Read-AgentYesNo -Prompt (T 'allow_developer_toolchain_review') -Default ([bool]$defaults['allow_developer_toolchain_review'])
    $values['allow_container_exposure_review'] = Read-AgentYesNo -Prompt (T 'allow_container_exposure_review') -Default ([bool]$defaults['allow_container_exposure_review'])
    $values['allow_optional_av'] = Read-AgentYesNo -Prompt (T 'allow_optional_av') -Default ([bool]$defaults['allow_optional_av'])
    $values['allow_blocklist_pilot'] = Read-AgentYesNo -Prompt (T 'allow_blocklist_pilot') -Default ([bool]$defaults['allow_blocklist_pilot'])
    $values['allow_firewall_ip_blocklists'] = Read-AgentYesNo -Prompt (T 'allow_firewall_ip_blocklists') -Default ([bool]$defaults['allow_firewall_ip_blocklists'])
    $values['windows_wsl_backend'] = Read-AgentYesNo -Prompt (T 'windows_wsl_backend') -Default ([bool]$defaults['windows_wsl_backend'])
    if ($values.windows_wsl_backend) {
        $values['windows_wsl_with_docker'] = Read-AgentYesNo -Prompt (T 'windows_wsl_with_docker') -Default ([bool]$defaults['windows_wsl_with_docker'])
        if ($values.windows_wsl_with_docker) {
            $values['windows_portainer_ui'] = Read-AgentYesNo -Prompt (T 'windows_portainer_ui') -Default ([bool]$defaults['windows_portainer_ui'])
        } else {
            $values['windows_portainer_ui'] = $false
        }
        $values['windows_wsl_recommendations'] = $true
    } else {
        $values['windows_wsl_with_docker'] = $false
        $values['windows_portainer_ui'] = $false
        $values['windows_wsl_recommendations'] = $false
    }
    $values['require_confirmation_for_system_changes'] = Read-AgentYesNo -Prompt (T 'require_confirmation_for_system_changes') -Default ([bool]$defaults['require_confirmation_for_system_changes'])
    $values['note'] = Read-AgentText -Prompt (T 'note_prompt') -Default ([string]$defaults['note'])
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
$safeLanguage = Resolve-AgentLanguage -ExplicitLanguage ([string]$values.language)
$yaml = @"
completed: true
configured_at: "$now"
configured_by: "first-run-config.ps1"
configuration_mode: "$configurationMode"
ui: "$usedUi"
repo_mode: "$($guard.repo_mode)"
visibility: "$($guard.visibility)"
host: "$HostName"
language: "$safeLanguage"
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
Write-Host ((T 'config_saved') -f $configPath)
