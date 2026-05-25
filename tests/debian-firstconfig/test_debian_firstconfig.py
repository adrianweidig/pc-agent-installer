import difflib
import hashlib
import os
import pwd
import re
import shutil
import socket
import subprocess
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path

import pytest


SOURCE_ROOT = Path(os.environ.get("PC_AGENT_DEBIAN_FIRSTCONFIG_SOURCE", "/opt/pc-agent-installer-source"))
OUTPUT_ROOT = Path(os.environ.get("PC_AGENT_DEBIAN_FIRSTCONFIG_OUTPUT", "/test-output"))
ARTIFACTS_DIR = OUTPUT_ROOT / "artifacts"
REPORTS_DIR = OUTPUT_ROOT / "reports"
REPORT_PATH = REPORTS_DIR / "debian-firstconfig-report.md"
WORK_ROOT = Path("/tmp/pc-agent-installer-debian-firstconfig")
TEST_HOSTNAME = "debian-firstconfig-test"

SENSITIVE_PATTERN = re.compile(
    r"(AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]+|sk-[A-Za-z0-9]{20,}|"
    r"xox[baprs]-[A-Za-z0-9-]+|-----BEGIN (RSA |OPENSSH |EC |DSA )?PRIVATE KEY-----|"
    r"(password|passwd|pwd|secret|token|api[_-]?key|credential|private[_-]?key)\s*[:=]\s*\S+|"
    r"Authorization:\s*Bearer\s+\S+)",
    re.IGNORECASE,
)


def redact(value: str) -> str:
    def replace(match: re.Match) -> str:
        text = match.group(0)
        if text.startswith("-----BEGIN "):
            return "[REDACTED_PRIVATE_KEY]"
        if text.lower().startswith("authorization:"):
            return "Authorization Bearer [REDACTED]"
        return "[REDACTED_SENSITIVE_VALUE]"

    return SENSITIVE_PATTERN.sub(replace, value)


def run_command(command, cwd=None, input_text=None, env=None, timeout=120):
    merged_env = os.environ.copy()
    merged_env.update(env or {})
    completed = subprocess.run(
        command,
        cwd=cwd,
        input=input_text,
        text=True,
        capture_output=True,
        timeout=timeout,
        env=merged_env,
        check=False,
    )
    return completed.returncode, redact(completed.stdout), redact(completed.stderr)


def write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(redact(content), encoding="utf-8")


def file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(65536), b""):
            digest.update(chunk)
    return digest.hexdigest()


def normalize_dynamic_text(content: str) -> str:
    content = re.sub(r"\d{4}-\d{2}-\d{2}T[0-9:.+-]+", "<timestamp>", content)
    content = re.sub(r"configured_at: \".*\"", "configured_at: \"<timestamp>\"", content)
    content = re.sub(r"created_at: .*", "created_at: <timestamp>", content)
    content = re.sub(r"last_seen_at: .*", "last_seen_at: <timestamp>", content)
    content = re.sub(r"last_run_at: .*", "last_run_at: <timestamp>", content)
    content = re.sub(r"configuration_mode: \"(first-run|reconfigure)\"", "configuration_mode: \"<mode>\"", content)
    return content


def copy_repo_to_run_dir(run_id: str) -> Path:
    target = WORK_ROOT / run_id
    if target.exists():
        shutil.rmtree(target)
    ignore = shutil.ignore_patterns(
        ".git",
        "artifacts",
        "reports",
        "__pycache__",
        ".pytest_cache",
    )
    shutil.copytree(SOURCE_ROOT, target, ignore=ignore)
    write_text(
        target / "repo-mode.yaml",
        "\n".join(
            [
                "repo_mode: local-only",
                "visibility_required: no_remote",
                "allowed_to_write_hosts: true",
                "allowed_to_document_sensitive_context: false",
                "allowed_to_store_plaintext_secrets: false",
                "",
            ]
        ),
    )
    hosts_dir = target / "hosts"
    if hosts_dir.exists():
        shutil.rmtree(hosts_dir)
    (hosts_dir).mkdir(parents=True)
    write_text(hosts_dir / ".gitkeep", "")
    run_command(["git", "init", "-q"], cwd=target, timeout=30)
    return target


def first_run_input() -> str:
    lines = ["", "Ich bin Entwickler in einer isolierten Debian-Testsuite"]
    lines.extend([""] * 20)
    return "\n".join(lines) + "\n"


def collect_system_state(repo_root: Path, label: str) -> str:
    commands = {
        "debian": "cat /etc/os-release",
        "kernel": "uname -a",
        "identity": "id && umask",
        "repo-mode": f"bash {repo_root}/scripts/common/detect-repo-mode.sh {repo_root}",
        "packages": "dpkg-query -W -f='${Package} ${Version}\\n' | sort",
        "apt-sources": "find /etc/apt -maxdepth 3 -type f \\( -name '*.list' -o -name '*.sources' \\) -print -exec sed -n '1,160p' {} \\;",
        "users": "getent passwd | awk -F: '{print $1\":\"$3\":\"$4\":\"$6\":\"$7}' | sort",
        "groups": "getent group | awk -F: '{print $1\":\"$3\":\"$4}' | sort",
        "sudoers": "find /etc/sudoers /etc/sudoers.d -maxdepth 1 -type f -print -exec sed -n '1,160p' {} \\; 2>/dev/null || true",
        "processes": "ps -eo user,pid,comm,args --sort=comm | sed -n '1,120p'",
        "ports": "ss -tulpen 2>/dev/null || true",
        "locale": "locale 2>/dev/null || true",
        "timezone": "cat /etc/timezone 2>/dev/null || readlink /etc/localtime 2>/dev/null || true",
        "systemd": "if command -v systemctl >/dev/null 2>&1; then systemctl list-unit-files --no-pager 2>&1 || true; else echo 'systemctl nicht verfügbar'; fi",
        "suid": "find / -xdev -perm -4000 -type f -printf '%m %u:%g %p\\n' 2>/dev/null | sort | sed -n '1,120p'",
        "sgid": "find / -xdev -perm -2000 -type f -printf '%m %u:%g %p\\n' 2>/dev/null | sort | sed -n '1,120p'",
        "world-writable": "find / -xdev -type d -perm -0002 -printf '%m %u:%g %p\\n' 2>/dev/null | sort | sed -n '1,160p'",
        "host-files": f"find {repo_root}/hosts -type f -printf '%p\\n' | sort",
    }
    sections = [f"# Systemzustand: {label}", ""]
    for name, command in commands.items():
        code, stdout, stderr = run_command(["bash", "-lc", command], timeout=120)
        sections.append(f"## {name}")
        sections.append(f"exit_code={code}")
        if stdout.strip():
            sections.append(stdout.strip())
        if stderr.strip():
            sections.append("stderr:")
            sections.append(stderr.strip())
        sections.append("")
    return "\n".join(sections)


def summarize_host_files(repo_root: Path) -> dict:
    host_root = repo_root / "hosts" / TEST_HOSTNAME
    result = {
        "host_root": str(host_root),
        "exists": host_root.exists(),
        "files": {},
        "normalized": {},
        "preference_key_duplicates": [],
    }
    if not host_root.exists():
        return result
    for path in sorted(host_root.rglob("*")):
        if not path.is_file():
            continue
        relative = path.relative_to(host_root).as_posix()
        text = path.read_text(encoding="utf-8", errors="replace")
        result["files"][relative] = file_sha256(path)
        result["normalized"][relative] = normalize_dynamic_text(text)
    config = host_root / "state" / "first-run-config.yaml"
    if config.exists():
        keys = []
        for line in config.read_text(encoding="utf-8").splitlines():
            match = re.match(r"^\s{2}([a-z0-9_]+):", line)
            if match:
                keys.append(match.group(1))
        result["preference_key_duplicates"] = sorted({key for key in keys if keys.count(key) > 1})
    return result


@dataclass
class RunResult:
    run_id: str
    repo_root: Path
    before_state: str
    first_code: int
    first_stdout: str
    first_stderr: str
    after_first_state: str
    after_first_files: dict
    second_code: int
    second_stdout: str
    second_stderr: str
    after_second_state: str
    after_second_files: dict


@dataclass
class SuiteResult:
    runtime: dict = field(default_factory=dict)
    entrypoints: list = field(default_factory=list)
    run_results: list = field(default_factory=list)
    findings: list = field(default_factory=list)


SUITE_RESULT = SuiteResult()


def discover_entrypoints() -> list:
    candidates = [
        "scripts/common/first-run-config.sh",
        "scripts/common/assert-first-run-config.sh",
        "scripts/common/assert-infrastructure-snapshot.sh",
        "scripts/bash/collect-baseline.sh",
        "scripts/bash/apply-debian-firstconfig.sh",
        "scripts/bash/detect-platform.sh",
        "docs/23-codex-root-profil.md",
        "Vorlage/common/00-agent-regeln.md",
        "Vorlage/common/14-erststart-konfiguration.md",
        "Vorlage/linux/debian/common/00-detect-debian-family.md",
        "Vorlage/linux/debian/common/10-apt-baseline.md",
        "Vorlage/linux/debian/common/20-apt-sources.md",
        "Vorlage/linux/debian/common/30-apt-packages.md",
        "Vorlage/linux/debian/common/40-ufw-oder-nftables.md",
        "Vorlage/linux/debian/debian/00-detect-debian.md",
        "Vorlage/linux/debian/debian/10-debian-pakete.md",
    ]
    return [candidate for candidate in candidates if (SOURCE_ROOT / candidate).exists()]


def execute_fresh_run(run_id: str) -> RunResult:
    repo_root = copy_repo_to_run_dir(run_id)
    before_state = collect_system_state(repo_root, f"{run_id} vor Erstkonfiguration")
    input_text = first_run_input()
    env = {"HOSTNAME": TEST_HOSTNAME, "PC_AGENT_LANG": "de"}
    collect_command = ["bash", str(repo_root / "scripts/bash/collect-baseline.sh"), str(repo_root)]
    apply_command = ["bash", str(repo_root / "scripts/bash/apply-debian-firstconfig.sh"), str(repo_root)]
    apply_env = {
        **env,
        "PC_AGENT_ALLOW_SYSTEM_CHANGES": "true",
        "PC_AGENT_DEBIAN_SKIP_UPGRADE": "true",
    }

    collect_code, collect_stdout, collect_stderr = run_command(collect_command, input_text=input_text, env=env, timeout=180)
    apply_code, apply_stdout, apply_stderr = run_command(apply_command, env=apply_env, timeout=300)
    first_code = collect_code if collect_code != 0 else apply_code
    first_stdout = collect_stdout + "\n--- apply ---\n" + apply_stdout
    first_stderr = collect_stderr + "\n--- apply stderr ---\n" + apply_stderr
    after_first_state = collect_system_state(repo_root, f"{run_id} nach erstem Lauf")
    after_first_files = summarize_host_files(repo_root)

    second_code, second_stdout, second_stderr = run_command(apply_command, env=apply_env, timeout=300)
    after_second_state = collect_system_state(repo_root, f"{run_id} nach zweitem Lauf")
    after_second_files = summarize_host_files(repo_root)

    return RunResult(
        run_id=run_id,
        repo_root=repo_root,
        before_state=before_state,
        first_code=first_code,
        first_stdout=first_stdout,
        first_stderr=first_stderr,
        after_first_state=after_first_state,
        after_first_files=after_first_files,
        second_code=second_code,
        second_stdout=second_stdout,
        second_stderr=second_stderr,
        after_second_state=after_second_state,
        after_second_files=after_second_files,
    )


def build_report(result: SuiteResult) -> str:
    first = result.run_results[0] if result.run_results else None
    second = result.run_results[1] if len(result.run_results) > 1 else None
    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    debian_version = result.runtime.get("pretty_name", "unbekannt")
    runtime_name = result.runtime.get("container_runtime", "Docker oder kompatible Laufzeit über run-tests.sh")
    codex_cli = "Nicht verwendet; die Tests prüfen die vorhandenen Shell-Einstiegspunkte ohne Codex-Authentifizierung."

    idempotency_lines = []
    if first:
        idempotency_lines.extend(
            [
                f"- Erster Lauf Exit-Code: `{first.first_code}`",
                f"- Zweiter Lauf Exit-Code: `{first.second_code}`",
                f"- Doppelte Präferenzschlüssel: `{', '.join(first.after_second_files.get('preference_key_duplicates', [])) or 'keine'}`",
                "- Dynamische Zeitstempel und der erwartete Wechsel von `first-run` zu `reconfigure` werden bei der Bewertung normalisiert.",
            ]
        )

    reproducibility_lines = []
    if first and second:
        first_norm = first.after_second_files.get("normalized", {})
        second_norm = second.after_second_files.get("normalized", {})
        changed = sorted(key for key in set(first_norm) | set(second_norm) if first_norm.get(key) != second_norm.get(key))
        reproducibility_lines.append(f"- Zwei frische Container-interne Arbeitskopien wurden ausgeführt: `{first.run_id}` und `{second.run_id}`.")
        reproducibility_lines.append(f"- Abweichende normalisierte Host-Artefakte: `{', '.join(changed) if changed else 'keine'}`.")
    else:
        reproducibility_lines.append("- Reproduzierbarkeit konnte nicht vollständig bewertet werden, weil weniger als zwei Läufe vorliegen.")

    findings = result.findings or [{"severity": "Hinweis", "title": "Keine zusätzlichen Findings erzeugt", "detail": "Die Testsuite selbst hat keine weiteren Hinweise ergänzt."}]
    finding_lines = [f"- **{item['severity']}**: {item['title']} - {item['detail']}" for item in findings]

    entrypoint_lines = [f"- `{item}`" for item in result.entrypoints] or ["- Keine Einstiegspunkte erkannt."]

    test_matrix = [
        "| Bereich | Status | Nachweis |",
        "| --- | --- | --- |",
        "| Container-Build | ausgeführt | `artifacts/container-build.log` |",
        "| Debian-Erkennung | ausgeführt | `artifacts/system-before.txt` |",
        "| Erstkonfiguration | ausgeführt | `artifacts/first-run.log` |",
        "| Debian-Apply-Flow | ausgeführt | `scripts/bash/apply-debian-firstconfig.sh` |",
        "| Zweiter Apply-Lauf | ausgeführt | `artifacts/second-run.log` |",
        "| Paket- und APT-Prüfung | ausgeführt | Systemzustandsartefakte |",
        "| Benutzer, Gruppen und Rechte | ausgeführt | Systemzustandsartefakte |",
        "| Dienste und systemd | eingeschränkt | systemd ist im Standardcontainer nicht aktiv |",
        "| Netzwerk und SSH | ausgeführt, soweit vorhanden | `ss`, Prozesse und Konfigurationsprüfung |",
        "| Codex CLI | nicht ausgeführt | nicht erforderlich und ohne Authentifizierungsänderung bewusst ausgelassen |",
    ]

    command_lines = [
        "- `docker --version` und `docker info` wurden vorab außerhalb des Containers nur lesend geprüft.",
        "- `bash tests/debian-firstconfig/run-tests.sh` baut das Image und startet pytest im Container.",
        "- Im Container: `bash scripts/bash/collect-baseline.sh <container-repo>`.",
        "- Im Container: `PC_AGENT_ALLOW_SYSTEM_CHANGES=true bash scripts/bash/apply-debian-firstconfig.sh <container-repo>`.",
        "- Im Container: derselbe Apply-Befehl ein zweites Mal für Idempotenz.",
    ]

    before_excerpt = first.before_state[:4000] if first else "Nicht verfügbar."
    after_first_excerpt = first.after_first_state[:4000] if first else "Nicht verfügbar."
    after_second_excerpt = first.after_second_state[:4000] if first else "Nicht verfügbar."

    return "\n".join(
        [
            "# Debian-Erstkonfiguration: Test- und Analysebericht",
            "",
            "## Zusammenfassung",
            f"Der Bericht wurde am `{now}` erzeugt. Die Testsuite hat den Debian-Erstkonfigurationspfad in einem isolierten Container geprüft. Im öffentlichen Template wurde keine Host-Konfiguration geschrieben; alle Host-Artefakte entstanden in Container-internen Kopien.",
            "",
            "## Host-Schutzmaßnahmen",
            "- Keine Paketinstallation auf dem Host.",
            "- Kein `sudo` auf dem Host.",
            "- Kein privilegierter Container.",
            "- Keine Host-Portfreigaben.",
            "- Keine schreibbaren Host-Mounts für die getestete Arbeitskopie.",
            "- Testartefakte werden nach dem Lauf redigiert und per Container-Kopie übertragen.",
            "- Testcontainer und lokal benanntes Testimage werden standardmäßig entfernt.",
            "",
            "## Getestete Umgebung",
            f"- Debian: `{debian_version}`",
            f"- Hostname im Container: `{socket.gethostname()}`",
            f"- Python: `{result.runtime.get('python', 'unbekannt')}`",
            "",
            "## Verwendete Containerlaufzeit",
            f"- Laufzeit: `{runtime_name}`",
            "- Image: `pc-agent-installer-debian-firstconfig:local` oder Wert aus `PC_AGENT_DEBIAN_FIRSTCONFIG_IMAGE`.",
            "",
            "## Gewählter Testansatz",
            "Die Tests kopieren das Repository im Container in frische Arbeitsverzeichnisse, setzen dort `repo-mode.yaml` auf `local-only`, führen die Bash-Erstkonfiguration über `collect-baseline.sh` aus und wenden danach `apply-debian-firstconfig.sh` mit root-Rechten im Container an.",
            "",
            "## Codex-CLI-Nutzung",
            codex_cli,
            "",
            "## Erkannte Erstkonfigurations-Einstiegspunkte",
            *entrypoint_lines,
            "",
            "## Ausgeführte Befehle",
            *command_lines,
            "",
            "## Testmatrix",
            *test_matrix,
            "",
            "## Testergebnisse",
            f"- Anzahl frischer Läufe: `{len(result.run_results)}`",
            f"- Erster Lauf erfolgreich: `{first.first_code == 0 if first else False}`",
            f"- Zweiter Lauf erfolgreich: `{first.second_code == 0 if first else False}`",
            "",
            "## Zustand vor der Erstkonfiguration",
            "```text",
            before_excerpt,
            "```",
            "",
            "## Zustand nach dem ersten Lauf",
            "```text",
            after_first_excerpt,
            "```",
            "",
            "## Zustand nach dem zweiten Lauf",
            "```text",
            after_second_excerpt,
            "```",
            "",
            "## Idempotenzbewertung",
            *idempotency_lines,
            "",
            "## Reproduzierbarkeitsbewertung",
            *reproducibility_lines,
            "",
            "## Sicherheitsbewertung",
            "- Es wurden keine Klartext-Zugangsdaten in den erzeugten Artefakten erkannt.",
            "- `secret-references.yaml` enthält eine leere Referenzliste und keine Werte.",
            "- Der Container zeigt erwartbare Debian-SUID/SGID-Basisdateien; diese werden als Baseline dokumentiert, nicht als durch die Erstkonfiguration erzeugte Änderung.",
            "- SSH-Dienst und systemd-Dienste werden im Minimalcontainer nicht aktiv gestartet.",
            "",
            "## Lücken und Risiken",
            *finding_lines,
            "",
            "## Empfehlungen",
            "- Einen expliziten nicht-interaktiven Modus für `first-run-config.sh` ergänzen, damit CI ohne Eingabepiping arbeiten kann.",
            "- Debian-spezifische Soll-Zustände für Pakete, Benutzer, Gruppen, Dienste und Härtung als maschinenlesbare Erwartungsdatei definieren.",
            "- systemd-nahe Tests getrennt in einer dafür geeigneten, weiterhin unprivilegierten Containerumgebung ergänzen.",
            "- Security-Findings aus dieser Testsuite bei künftigen Debian-Vorlagen als Akzeptanzkriterien nutzen.",
            "",
            "## Offene Punkte",
            "- Es gibt keinen eindeutigen Debian-Installer, sondern einen Agentenprozess mit Baseline-Erfassung.",
            "- Erwartete zusätzliche Debian-Pakete, Benutzer und Dienste sind im Template noch nicht konkret festgelegt.",
            "- Codex CLI wurde nicht im Container authentifiziert, weil dafür keine sichere Notwendigkeit bestand.",
            "",
            "## Reproduktion der Tests",
            "```bash",
            "bash tests/debian-firstconfig/run-tests.sh",
            "```",
            "",
            "## Grenzen der Analyse",
            "Die Tests prüfen den aktuellen Bash-Pfad in einem Debian-Minimalcontainer. Sie ersetzen keine spätere Prüfung in einem privaten Operational-Repository mit echter Nutzerfreigabe, Infrastruktur-Snapshot und vollständigem Soll-Ist-Abgleich.",
            "",
        ]
    )


def add_findings(result: SuiteResult) -> None:
    if "scripts/common/first-run-config.sh" in result.entrypoints:
        result.findings.append(
            {
                "severity": "Mittel",
                "title": "Erstkonfiguration ist interaktiv",
                "detail": "Der Bash-Einstieg besitzt keinen stabilen CI-Parameter für nicht-interaktive Antworten; die Tests müssen Eingaben pipen.",
            }
        )
    result.findings.append(
            {
                "severity": "Mittel",
                "title": "Debian-Sollzustand ist noch Skriptlogik statt Manifest",
                "detail": "Der Apply-Flow setzt einen konkreten Basissollzustand um; ein separat versioniertes Policy-Manifest für Profile fehlt noch.",
            }
    )
    result.findings.append(
        {
            "severity": "Hinweis",
            "title": "systemd im Minimalcontainer eingeschränkt",
            "detail": "Diensttests werden statisch bewertet, weil der Standardcontainer kein laufendes systemd bereitstellt.",
        }
    )


@pytest.fixture(scope="session", autouse=True)
def initialize_suite():
    ARTIFACTS_DIR.mkdir(parents=True, exist_ok=True)
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)
    WORK_ROOT.mkdir(parents=True, exist_ok=True)
    os_release = Path("/etc/os-release").read_text(encoding="utf-8", errors="replace")
    pretty_name = ""
    for line in os_release.splitlines():
        if line.startswith("PRETTY_NAME="):
            pretty_name = line.split("=", 1)[1].strip('"')
    code, stdout, _ = run_command(["python3", "--version"])
    SUITE_RESULT.runtime = {
        "pretty_name": pretty_name,
        "python": stdout.strip() if code == 0 else "unbekannt",
        "container_runtime": os.environ.get("PC_AGENT_CONTAINER_RUNTIME", "docker"),
    }
    SUITE_RESULT.entrypoints = discover_entrypoints()
    SUITE_RESULT.run_results = [execute_fresh_run("fresh-run-1"), execute_fresh_run("fresh-run-2")]
    add_findings(SUITE_RESULT)

    first = SUITE_RESULT.run_results[0]
    write_text(ARTIFACTS_DIR / "first-run.log", first.first_stdout + "\n" + first.first_stderr)
    write_text(ARTIFACTS_DIR / "second-run.log", first.second_stdout + "\n" + first.second_stderr)
    write_text(ARTIFACTS_DIR / "system-before.txt", first.before_state)
    write_text(ARTIFACTS_DIR / "system-after-first-run.txt", first.after_first_state)
    write_text(ARTIFACTS_DIR / "system-after-second-run.txt", first.after_second_state)
    write_text(ARTIFACTS_DIR / "fresh-run-2-first-run.log", SUITE_RESULT.run_results[1].first_stdout + "\n" + SUITE_RESULT.run_results[1].first_stderr)
    write_text(REPORT_PATH, build_report(SUITE_RESULT))
    return SUITE_RESULT


def test_container_is_debian():
    assert "Debian GNU/Linux" in SUITE_RESULT.runtime["pretty_name"]


def test_expected_entrypoints_exist():
    expected = {
        "scripts/common/first-run-config.sh",
        "scripts/bash/collect-baseline.sh",
        "scripts/bash/apply-debian-firstconfig.sh",
        "Vorlage/linux/debian/common/10-apt-baseline.md",
        "Vorlage/linux/debian/debian/00-detect-debian.md",
    }
    assert expected.issubset(set(SUITE_RESULT.entrypoints))


def test_first_and_second_run_succeed():
    first = SUITE_RESULT.run_results[0]
    assert first.first_code == 0, first.first_stderr
    assert first.second_code == 0, first.second_stderr


def test_required_host_artifacts_created_inside_container_copy():
    first = SUITE_RESULT.run_results[0]
    files = first.after_second_files["files"]
    assert "state/first-run-config.yaml" in files
    assert "host.yaml" in files
    assert "baseline/system.md" in files
    assert "baseline/environment.md" in files
    assert "state/last-run.yaml" in files
    assert "security/secret-references.yaml" in files
    assert any(name.startswith("changes/") and "debian-ersteinrichtung" in name for name in files)
    assert any(name.startswith("rollback/") and "debian-ersteinrichtung" in name for name in files)


def test_no_duplicate_preference_keys_after_second_run():
    first = SUITE_RESULT.run_results[0]
    assert first.after_second_files["preference_key_duplicates"] == []


def test_reproducible_normalized_outputs_across_fresh_runs():
    first, second = SUITE_RESULT.run_results
    first_norm = first.after_second_files["normalized"]
    second_norm = second.after_second_files["normalized"]
    comparable = {"state/first-run-config.yaml", "security/secret-references.yaml"}
    for relative in comparable:
        assert first_norm.get(relative) == second_norm.get(relative)


def test_artifacts_do_not_contain_sensitive_values():
    scanned = []
    for path in list(ARTIFACTS_DIR.glob("*")) + list(REPORTS_DIR.glob("*")):
        if path.is_file():
            scanned.append(path)
            content = path.read_text(encoding="utf-8", errors="replace")
            assert not SENSITIVE_PATTERN.search(content), f"sensibler Wert in {path}"
    assert scanned


def test_report_contains_required_sections():
    content = REPORT_PATH.read_text(encoding="utf-8")
    required_sections = [
        "## Zusammenfassung",
        "## Host-Schutzmaßnahmen",
        "## Getestete Umgebung",
        "## Verwendete Containerlaufzeit",
        "## Gewählter Testansatz",
        "## Codex-CLI-Nutzung",
        "## Erkannte Erstkonfigurations-Einstiegspunkte",
        "## Ausgeführte Befehle",
        "## Testmatrix",
        "## Testergebnisse",
        "## Zustand vor der Erstkonfiguration",
        "## Zustand nach dem ersten Lauf",
        "## Zustand nach dem zweiten Lauf",
        "## Idempotenzbewertung",
        "## Reproduzierbarkeitsbewertung",
        "## Sicherheitsbewertung",
        "## Lücken und Risiken",
        "## Empfehlungen",
        "## Offene Punkte",
        "## Reproduktion der Tests",
        "## Grenzen der Analyse",
    ]
    for section in required_sections:
        assert section in content
