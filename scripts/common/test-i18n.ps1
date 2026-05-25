[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'i18n.ps1')

if ((Resolve-AgentLanguage) -ne 'de') { throw 'Default language must be German.' }
if ((Resolve-AgentLanguage -ExplicitLanguage 'en-US' -ConfigLanguage 'de') -ne 'en') { throw 'Explicit language must win over config language.' }
if ((Resolve-AgentLanguage -ConfigLanguage 'en_GB') -ne 'en') { throw 'Configured English language was not detected.' }
if ((Get-AgentText -Key 'allow_update_maintenance' -Language 'de') -notmatch 'prüfen') { throw 'German UTF-8 umlaut text was not preserved.' }
if ((Get-AgentText -Key 'allow_update_maintenance' -Language 'en') -notmatch 'Check operating system') { throw 'English translation was not returned.' }
if ((Get-AgentText -Key 'missing_test_key' -Language 'en') -ne 'missing_test_key') { throw 'Missing keys must fall back to the key name.' }

Write-Host 'test-i18n.ps1 erfolgreich.'
