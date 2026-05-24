[CmdletBinding()]
param([string]$OutputPath = 'container-baseline.md')

try {
    $collectorOutput = & {
        kubectl config get-contexts
    }
    $collectorOutput | Out-File -FilePath $OutputPath -Encoding utf8
} catch {
    $_.Exception.Message | Out-File -FilePath $OutputPath -Encoding utf8
}
Write-Host "Erfasst: $OutputPath"
