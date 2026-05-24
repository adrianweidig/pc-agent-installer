[CmdletBinding()]
param([Parameter(ValueFromPipeline = $true)][string]$InputObject)

begin {
    . (Join-Path $PSScriptRoot '..\powershell\AgentInstaller.Common.ps1')
}
process {
    Protect-AgentSecretText -Text $InputObject
}
