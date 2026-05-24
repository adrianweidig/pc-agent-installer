# Plattform-Erkennung

Windows wird über PowerShell, CIM und optionale WSL-Abfragen erkannt.

Linux wird primär über `/etc/os-release` erkannt und in Distributionsfamilien wie Debian, RHEL oder Arch einsortiert.

WSL wird über `/proc/version`, `/etc/os-release` und Windows-seitig optional über `wsl.exe --list --verbose` erkannt.

macOS wird über `uname`, `sw_vers` und verfügbare Systemwerkzeuge erkannt. Hostdaten werden auch dort nur in bestätigtem `operational`- oder `local-only`-Modus dokumentiert.
