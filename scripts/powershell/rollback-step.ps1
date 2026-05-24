[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Command,
    [switch]$Approved
)

$requiresApproval = $true
if ($requiresApproval -and -not $Approved) {
    throw 'rollback-step benötigt explizite Freigabe per -Approved.'
}
Write-Host 'Führe rollback-step aus:'
Write-Host $Command
Invoke-Expression $Command
