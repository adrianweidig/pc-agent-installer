[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Command,
    [switch]$Approved
)

$requiresApproval = $true
if ($requiresApproval -and -not $Approved) {
    throw 'apply-step benötigt explizite Freigabe per -Approved.'
}
Write-Host 'Führe apply-step aus:'
Write-Host $Command
Invoke-Expression $Command
