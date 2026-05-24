[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Template,
    [Parameter(Mandatory = $true)][string]$Destination
)

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw 'GitHub CLI gh ist nicht verfügbar.'
}

gh repo create $Destination --template $Template --private --clone
