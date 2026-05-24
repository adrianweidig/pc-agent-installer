[CmdletBinding()]
param([string]$OutputPath)

if (-not $OutputPath) { $OutputPath = Join-Path (Get-Location) 'collector-output.txt' }
$collectorOutput = & {
    Get-NetFirewallRule | Select-Object DisplayName,Enabled,Direction,Action,Profile
}
$collectorOutput | Out-File -FilePath $OutputPath -Encoding utf8
Write-Host "Erfasst: $OutputPath"
