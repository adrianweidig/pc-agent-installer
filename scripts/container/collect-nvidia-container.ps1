[CmdletBinding()]
param([string]$OutputPath = 'container-baseline.md')

try {
    $collectorOutput = & {
        if (Get-Command nvidia-smi -ErrorAction SilentlyContinue) { nvidia-smi } elseif (Get-Command nvidia-ctk -ErrorAction SilentlyContinue) { nvidia-ctk --version } else { "NVIDIA Tooling nicht verfügbar" }
    }
    $collectorOutput | Out-File -FilePath $OutputPath -Encoding utf8
} catch {
    $_.Exception.Message | Out-File -FilePath $OutputPath -Encoding utf8
}
Write-Host "Erfasst: $OutputPath"
