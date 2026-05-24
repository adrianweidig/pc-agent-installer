[CmdletBinding()]
param([string]$OutputPath)

if (-not $OutputPath) { $OutputPath = Join-Path (Get-Location) 'collector-output.txt' }
$collectorOutput = & {
    if (Get-Command winget -ErrorAction SilentlyContinue) { winget export --accept-source-agreements --output "$OutputPath" } else { "winget nicht verfügbar" }
}
$collectorOutput | Out-File -FilePath $OutputPath -Encoding utf8
Write-Host "Erfasst: $OutputPath"
