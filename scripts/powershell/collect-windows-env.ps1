[CmdletBinding()]
param([string]$OutputPath)

if (-not $OutputPath) { $OutputPath = Join-Path (Get-Location) 'collector-output.txt' }
$collectorOutput = & {
    Get-ChildItem Env: | Sort-Object Name | ForEach-Object { "$($_.Name)=[REDACTED]" }
}
$collectorOutput | Out-File -FilePath $OutputPath -Encoding utf8
Write-Host "Erfasst: $OutputPath"
