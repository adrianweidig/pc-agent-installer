#!/usr/bin/env bash

agent_resolve_language() {
  local explicit="${1:-}" config="${2:-}" candidate normalized
  for candidate in "$explicit" "$config" "${PC_AGENT_LANG:-}"; do
    [[ -z "$candidate" ]] && continue
    normalized="$(printf '%s' "$candidate" | tr '[:upper:]_' '[:lower:]-')"
    case "$normalized" in
      de|de-*) printf 'de\n'; return 0 ;;
      en|en-*) printf 'en\n'; return 0 ;;
    esac
  done
  printf 'de\n'
}

agent_msg() {
  local lang key
  lang="$(agent_resolve_language "${AGENT_LANGUAGE:-}" "${AGENT_CONFIG_LANGUAGE:-}")"
  key="$1"
  case "$lang:$key" in
    de:answer_yes_no) echo 'Bitte mit Ja oder Nein antworten.' ;;
    de:config_started) echo 'Agenten-Konfiguration wird gestartet.' ;;
    de:config_reopened) echo 'Agenten-Konfiguration wird erneut geöffnet. Leere Antworten behalten vorhandene Werte bei.' ;;
    de:first_run_missing_title) echo 'ERSTSTART-KONFIGURATION NICHT ABGESCHLOSSEN' ;;
    de:first_run_missing_body) echo 'Der Agent darf noch keine Host-Baseline, Sicherheitsänderung, Installation oder Systemänderung ausführen.' ;;
    de:first_run_missing_run) echo 'Bitte zuerst ausführen:' ;;
    de:first_run_missing_prompt) echo 'Agentischer Startsatz:' ;;
    de:first_run_missing_retry) echo 'Danach diesen Schritt erneut starten.' ;;
    de:first_run_present) echo 'Erststart-Konfiguration vorhanden: %s' ;;
    de:config_saved) echo 'Erststart-Konfiguration gespeichert: %s' ;;
    de:language_prompt) echo 'Sprache für Agenten-Ausgaben wählen (de/en):' ;;
    de:profile_prompt) echo 'Beschreibe dich kurz für sinnvolle Programmempfehlungen, z. B. "Ich bin Entwickler":' ;;
    de:note_prompt) echo 'Optionale Notiz für den Agenten:' ;;
    de:allow_baseline) echo 'Host-Baseline erfassen und dokumentieren?' ;;
    de:allow_security_recommendations) echo 'Usability-first Sicherheitsempfehlungen anzeigen?' ;;
    de:allow_package_recommendations) echo 'Kostenlose, aktuelle Tools und Updates empfehlen?' ;;
    de:allow_update_maintenance) echo 'Betriebssystem-, App- und Paketupdates prüfen?' ;;
    de:allow_package_source_audit) echo 'Paketquellen, Stores und Dritt-Repositories prüfen?' ;;
    de:allow_disk_health_review) echo 'Datenträgerzustand, Dateisystem und Speicherplatz prüfen?' ;;
    de:allow_encryption_recommendations) echo 'Geräteverschlüsselung prüfen und empfehlen?' ;;
    de:allow_security_exception_review) echo 'Security-Ausnahmen wie AV-Exclusions prüfen?' ;;
    de:allow_startup_service_review) echo 'Autostart, Dienste und Hintergrundprozesse bewerten?' ;;
    de:allow_workspace_hygiene_review) echo 'Workspace-Hygiene, Backups und Duplikate prüfen?' ;;
    de:allow_developer_toolchain_review) echo 'Entwickler-Toolchains und Paketmanager bewerten?' ;;
    de:allow_container_exposure_review) echo 'Container-Ports, Volumes und Secrets prüfen?' ;;
    de:allow_optional_av) echo 'Optionalen kostenlosen On-Demand-Malware-Scanner anbieten?' ;;
    de:allow_blocklist_pilot) echo 'DNS-/Host-Blocklisten nur im Pilotmodus anbieten?' ;;
    de:allow_firewall_ip_blocklists) echo 'IP-Firewall-Blocklisten als riskante Option anbieten?' ;;
    de:windows_wsl_backend_shell) echo 'Windows/WSL: WSL-Backend für Linux-Tools vorbereiten oder berücksichtigen?' ;;
    de:windows_wsl_with_docker_shell) echo 'Windows/WSL: Docker mit WSL-Unterstützung einplanen?' ;;
    de:windows_portainer_ui_shell) echo 'Windows/WSL: Portainer CE als Docker-Verwaltungsoberfläche empfehlen?' ;;
    de:require_confirmation_for_system_changes) echo 'Vor systemwirksamen Änderungen immer bestätigen lassen?' ;;
    de:snapshot_missing_next) echo 'Erststart-Konfiguration und aktuelle Baseline ausführen, danach Soll-Ist-Abgleich dokumentieren.' ;;
    de:snapshot_ok_next) echo 'Soll-Ist-Abgleich im Change-Eintrag dokumentieren, dann Änderung nur mit Freigabe ausführen.' ;;
    de:snapshot_missing_error) printf '%s\n%s\n\n%s\n  bash ./scripts/bash/collect-baseline.sh\n' 'Aktueller Infrastruktur-Snapshot fehlt oder ist unvollständig.' 'Der Agent darf im Vollzugriff keine Installation, Löschung, Dienst-, Firewall-, Container- oder Paketmanager-Änderung ausführen, bevor die aktuelle Umgebung geprüft und ein Soll-Ist-Abgleich dokumentiert wurde.' 'Empfohlener nächster Schritt:' ;;
    en:answer_yes_no) echo 'Please answer yes or no.' ;;
    en:config_started) echo 'Agent configuration is starting.' ;;
    en:config_reopened) echo 'Agent configuration is being reopened. Empty answers keep existing values.' ;;
    en:first_run_missing_title) echo 'FIRST-RUN CONFIGURATION NOT COMPLETED' ;;
    en:first_run_missing_body) echo 'The agent may not collect a host baseline, security change, installation, or system change yet.' ;;
    en:first_run_missing_run) echo 'Run this first:' ;;
    en:first_run_missing_prompt) echo 'Agent prompt:' ;;
    en:first_run_missing_retry) echo 'Then run this step again.' ;;
    en:first_run_present) echo 'First-run configuration exists: %s' ;;
    en:config_saved) echo 'First-run configuration saved: %s' ;;
    en:language_prompt) echo 'Choose language for agent output (de/en):' ;;
    en:profile_prompt) echo 'Briefly describe yourself for useful application recommendations, for example "I am a developer":' ;;
    en:note_prompt) echo 'Optional note for the agent:' ;;
    en:allow_baseline) echo 'Collect and document host baseline?' ;;
    en:allow_security_recommendations) echo 'Show usability-first security recommendations?' ;;
    en:allow_package_recommendations) echo 'Recommend free, current tools and updates?' ;;
    en:allow_update_maintenance) echo 'Check operating system, app, and package updates?' ;;
    en:allow_package_source_audit) echo 'Check package sources, stores, and third-party repositories?' ;;
    en:allow_disk_health_review) echo 'Check disk health, file systems, and free space?' ;;
    en:allow_encryption_recommendations) echo 'Check and recommend device encryption?' ;;
    en:allow_security_exception_review) echo 'Check security exceptions such as antivirus exclusions?' ;;
    en:allow_startup_service_review) echo 'Evaluate startup items, services, and background processes?' ;;
    en:allow_workspace_hygiene_review) echo 'Check workspace hygiene, backups, and duplicates?' ;;
    en:allow_developer_toolchain_review) echo 'Evaluate developer toolchains and package managers?' ;;
    en:allow_container_exposure_review) echo 'Check container ports, volumes, and secrets?' ;;
    en:allow_optional_av) echo 'Offer an optional free on-demand malware scanner?' ;;
    en:allow_blocklist_pilot) echo 'Offer DNS/hosts blocklists only in pilot mode?' ;;
    en:allow_firewall_ip_blocklists) echo 'Offer IP firewall blocklists as a risky option?' ;;
    en:windows_wsl_backend_shell) echo 'Windows/WSL: prepare or consider WSL backend for Linux tools?' ;;
    en:windows_wsl_with_docker_shell) echo 'Windows/WSL: plan Docker with WSL support?' ;;
    en:windows_portainer_ui_shell) echo 'Windows/WSL: recommend Portainer CE as Docker management UI?' ;;
    en:require_confirmation_for_system_changes) echo 'Always require confirmation before system-impacting changes?' ;;
    en:snapshot_missing_next) echo 'Run first-run configuration and a current baseline, then document target/current-state comparison.' ;;
    en:snapshot_ok_next) echo 'Document target/current-state comparison in the change entry, then run the change only after approval.' ;;
    en:snapshot_missing_error) printf '%s\n%s\n\n%s\n  bash ./scripts/bash/collect-baseline.sh\n' 'Current infrastructure snapshot is missing or incomplete.' 'The agent may not install, delete, or change services, firewalls, containers, or package managers with full access before the current environment has been checked and target/current-state comparison has been documented.' 'Recommended next step:' ;;
    *) AGENT_LANGUAGE=de agent_msg "$key" ;;
  esac
}
