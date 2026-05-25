[CmdletBinding()]
param()

function Resolve-AgentLanguage {
    param(
        [string]$ExplicitLanguage,
        [string]$ConfigLanguage
    )

    $candidates = @(
        $ExplicitLanguage,
        $ConfigLanguage,
        $env:PC_AGENT_LANG
    )

    foreach ($candidate in $candidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) { continue }
        $normalized = $candidate.Trim().ToLowerInvariant().Replace('_', '-')
        if ($normalized -eq 'de' -or $normalized.StartsWith('de-')) { return 'de' }
        if ($normalized -eq 'en' -or $normalized.StartsWith('en-')) { return 'en' }
    }

    return 'de'
}

$script:AgentMessages = @{
    de = @{
        answer_yes_no = 'Bitte mit Ja oder Nein antworten.'
        config_started = 'Agenten-Konfiguration wird gestartet.'
        config_reopened = 'Agenten-Konfiguration wird erneut geöffnet. Leere Antworten behalten vorhandene Werte bei.'
        first_run_missing_title = 'ERSTSTART-KONFIGURATION NICHT ABGESCHLOSSEN'
        first_run_missing_body = 'Der Agent darf noch keine Host-Baseline, Sicherheitsänderung, Installation oder Systemänderung ausführen.'
        first_run_missing_run = 'Bitte zuerst ausführen:'
        first_run_missing_prompt = 'Agentischer Startsatz:'
        first_run_missing_retry = 'Danach diesen Schritt erneut starten.'
        first_run_present = 'Erststart-Konfiguration vorhanden: {0}'
        form_title = 'PC Agent Installer - Agenten-Konfiguration'
        form_intro = 'Lege fest, was der Agent auf diesem PC vorbereiten darf. Bestehende Optionen können hier erneut aktiviert oder deaktiviert werden.'
        form_profile = 'Beschreibe dich kurz, damit der Agent sinnvolle Programme und Einstellungen ableiten kann. Beispiel: "Ich bin Entwickler und nutze KI-Tools."'
        form_save = 'Konfiguration speichern'
        form_cancelled = 'Erststart-Konfiguration wurde abgebrochen.'
        gui_unavailable = 'GUI-Konfiguration nicht verfügbar: {0}'
        config_saved = 'Erststart-Konfiguration gespeichert: {0}'
        language_prompt = 'Sprache für Agenten-Ausgaben wählen (de/en)'
        language_label = 'Sprache der Agenten-Ausgaben'
        profile_prompt = 'Beschreibe dich kurz für sinnvolle Programmempfehlungen, z. B. "Ich bin Entwickler"'
        note_prompt = 'Optionale Notiz für den Agenten'
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
        windows_wsl_backend = 'Windows: WSL-Backend für Linux-Tools vorbereiten'
        windows_wsl_backend_shell = 'Windows/WSL: WSL-Backend für Linux-Tools vorbereiten oder berücksichtigen'
        windows_wsl_with_docker = 'Windows: Docker mit WSL-Unterstützung einplanen'
        windows_wsl_with_docker_shell = 'Windows/WSL: Docker mit WSL-Unterstützung einplanen'
        windows_portainer_ui = 'Windows: Portainer CE als Docker-Verwaltungsoberfläche empfehlen'
        windows_portainer_ui_shell = 'Windows/WSL: Portainer CE als Docker-Verwaltungsoberfläche empfehlen'
        require_confirmation_for_system_changes = 'Vor systemwirksamen Änderungen immer bestätigen lassen'
        snapshot_missing_next = 'Erststart-Konfiguration und aktuelle Baseline ausführen, danach Soll-Ist-Abgleich dokumentieren.'
        snapshot_ok_next = 'Soll-Ist-Abgleich im Change-Eintrag dokumentieren, dann Änderung nur mit Freigabe ausführen.'
        snapshot_missing_error = "Aktueller Infrastruktur-Snapshot fehlt oder ist unvollständig.`nDer Agent darf im Vollzugriff keine Installation, Löschung, Dienst-, Firewall-, Container- oder Paketmanager-Änderung ausführen, bevor die aktuelle Umgebung geprüft und ein Soll-Ist-Abgleich dokumentiert wurde.`n`nEmpfohlener nächster Schritt:`n  ./scripts/powershell/collect-baseline.ps1"
    }
    en = @{
        answer_yes_no = 'Please answer yes or no.'
        config_started = 'Agent configuration is starting.'
        config_reopened = 'Agent configuration is being reopened. Empty answers keep existing values.'
        first_run_missing_title = 'FIRST-RUN CONFIGURATION NOT COMPLETED'
        first_run_missing_body = 'The agent may not collect a host baseline, security change, installation, or system change yet.'
        first_run_missing_run = 'Run this first:'
        first_run_missing_prompt = 'Agent prompt:'
        first_run_missing_retry = 'Then run this step again.'
        first_run_present = 'First-run configuration exists: {0}'
        form_title = 'PC Agent Installer - Agent Configuration'
        form_intro = 'Choose what the agent may prepare on this PC. Existing options can be enabled or disabled again here.'
        form_profile = 'Briefly describe yourself so the agent can infer useful applications and settings. Example: "I am a developer and use AI tools."'
        form_save = 'Save configuration'
        form_cancelled = 'First-run configuration was cancelled.'
        gui_unavailable = 'GUI configuration unavailable: {0}'
        config_saved = 'First-run configuration saved: {0}'
        language_prompt = 'Choose language for agent output (de/en)'
        language_label = 'Agent output language'
        profile_prompt = 'Briefly describe yourself for useful application recommendations, for example "I am a developer"'
        note_prompt = 'Optional note for the agent'
        allow_baseline = 'Collect and document host baseline'
        allow_security_recommendations = 'Show usability-first security recommendations'
        allow_package_recommendations = 'Recommend free, current tools and updates'
        allow_update_maintenance = 'Check operating system, app, and package updates'
        allow_package_source_audit = 'Check package sources, stores, and third-party repositories'
        allow_disk_health_review = 'Check disk health, file systems, and free space'
        allow_encryption_recommendations = 'Check and recommend device encryption'
        allow_security_exception_review = 'Check security exceptions such as antivirus exclusions'
        allow_startup_service_review = 'Evaluate startup items, services, and background processes'
        allow_workspace_hygiene_review = 'Check workspace hygiene, backups, and duplicates'
        allow_developer_toolchain_review = 'Evaluate developer toolchains and package managers'
        allow_container_exposure_review = 'Check container ports, volumes, and secrets'
        allow_optional_av = 'Offer an optional free on-demand malware scanner'
        allow_blocklist_pilot = 'Offer DNS/hosts blocklists only in pilot mode'
        allow_firewall_ip_blocklists = 'Offer IP firewall blocklists as a risky option'
        windows_wsl_backend = 'Windows: prepare WSL backend for Linux tools'
        windows_wsl_backend_shell = 'Windows/WSL: prepare or consider WSL backend for Linux tools'
        windows_wsl_with_docker = 'Windows: plan Docker with WSL support'
        windows_wsl_with_docker_shell = 'Windows/WSL: plan Docker with WSL support'
        windows_portainer_ui = 'Windows: recommend Portainer CE as Docker management UI'
        windows_portainer_ui_shell = 'Windows/WSL: recommend Portainer CE as Docker management UI'
        require_confirmation_for_system_changes = 'Always require confirmation before system-impacting changes'
        snapshot_missing_next = 'Run first-run configuration and a current baseline, then document target/current-state comparison.'
        snapshot_ok_next = 'Document target/current-state comparison in the change entry, then run the change only after approval.'
        snapshot_missing_error = "Current infrastructure snapshot is missing or incomplete.`nThe agent may not install, delete, or change services, firewalls, containers, or package managers with full access before the current environment has been checked and target/current-state comparison has been documented.`n`nRecommended next step:`n  ./scripts/powershell/collect-baseline.ps1"
    }
}

function Get-AgentText {
    param(
        [Parameter(Mandatory = $true)][string]$Key,
        [string]$Language = 'de'
    )

    $lang = Resolve-AgentLanguage -ExplicitLanguage $Language
    if ($script:AgentMessages[$lang].ContainsKey($Key)) { return $script:AgentMessages[$lang][$Key] }
    if ($script:AgentMessages['de'].ContainsKey($Key)) { return $script:AgentMessages['de'][$Key] }
    return $Key
}
