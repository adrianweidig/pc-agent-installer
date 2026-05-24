[CmdletBinding()]
param()

$isWindowsHost = $IsWindows -or $env:OS -eq 'Windows_NT'
$result = [ordered]@{
    detected_at = (Get-Date).ToString('o')
    os = if ($isWindowsHost) { 'windows' } else { 'unknown' }
    environment = 'native'
    hostname = [System.Net.Dns]::GetHostName()
    architecture = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString()
    powershell = $PSVersionTable.PSVersion.ToString()
    admin = $false
    windows = $null
    wsl = $null
    hardware_profile = 'unknown'
}

if ($isWindowsHost) {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    $result.admin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    try {
        $os = Get-CimInstance Win32_OperatingSystem
        $cs = Get-CimInstance Win32_ComputerSystem
        $chassis = Get-CimInstance Win32_SystemEnclosure
        $isLaptop = @($chassis.ChassisTypes) | Where-Object { $_ -in @(8, 9, 10, 14, 30, 31, 32) }
        $result.windows = [ordered]@{
            caption = $os.Caption
            version = $os.Version
            build_number = $os.BuildNumber
            edition = $os.OperatingSystemSKU
            manufacturer = $cs.Manufacturer
            model = $cs.Model
        }
        $result.hardware_profile = if ($isLaptop) { 'laptop' } else { 'workstation' }
    } catch {}
    if (Get-Command wsl.exe -ErrorAction SilentlyContinue) {
        $wslRaw = ((& wsl.exe --list --verbose 2>$null) -join "`n").Replace([string][char]0, '')
        $result.wsl = $wslRaw
    }
}

$result | ConvertTo-Json -Depth 6
