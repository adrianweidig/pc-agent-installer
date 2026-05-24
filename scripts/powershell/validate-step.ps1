[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Command,
    [switch]$Approved
)

$requiresApproval = $false
if ($requiresApproval -and -not $Approved) {
    throw 'validate-step benötigt explizite Freigabe per -Approved.'
}
Write-Host 'Führe validate-step aus:'
Write-Host $Command
Invoke-Expression $Command
