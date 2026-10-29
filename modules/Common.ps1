# Common.ps1 - shared helpers for the Win11 MinMax Toolkit.
# Dot-sourced by MinMax.ps1. This file makes no changes by itself.

$global:MinMaxLogFile = $null

function Initialize-MinMaxLog {
    param(
        [Parameter(Mandatory = $true)]
        [string]$LogDirectory
    )
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $global:MinMaxLogFile = Join-Path -Path $LogDirectory -ChildPath "MinMax-$stamp.log"
    New-Item -Path $global:MinMaxLogFile -ItemType File -Force | Out-Null
    return $global:MinMaxLogFile
}

function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [ValidateSet('Info', 'OK', 'Warn', 'Error')]
        [string]$Level = 'Info'
    )
    $line = '[{0}] [{1}] {2}' -f (Get-Date -Format 'HH:mm:ss'), $Level.ToUpper(), $Message
    switch ($Level) {
        'OK'    { Write-Host $line -ForegroundColor Green }
        'Warn'  { Write-Host $line -ForegroundColor Yellow }
        'Error' { Write-Host $line -ForegroundColor Red }
        default { Write-Host $line }
    }
    if ($global:MinMaxLogFile) {
        Add-Content -Path $global:MinMaxLogFile -Value $line -Encoding UTF8
    }
}

function Set-Reg {
    <#
    .SYNOPSIS
        Sets one registry value, creating the key first if needed.
        Always uses named parameters (house rule: New-ItemProperty is never
        called positionally).
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        $Value,

        [ValidateSet('DWord', 'String', 'Binary', 'QWord')]
        [string]$Type = 'DWord'
    )
    try {
        if (-not (Test-Path -Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }
        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
        Write-Log -Message "Set $Path\$Name = $Value ($Type)"
    }
    catch {
        Write-Log -Message "FAILED to set $Path\$Name : $($_.Exception.Message)" -Level Error
    }
}

function Remove-RegValue {
    <#
    .SYNOPSIS
        Removes one registry value so Windows falls back to its built-in
        default. Used by the Undo module.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Name
    )
    if (Test-Path -Path $Path) {
        Remove-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
        Write-Log -Message "Removed $Path\$Name (back to Windows default)"
    }
}

function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object -TypeName Security.Principal.WindowsPrincipal -ArgumentList $identity
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-IsWindows11 {
    $build = 0
    try {
        $cv = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name 'CurrentBuild'
        $build = [int]$cv.CurrentBuild
    }
    catch {
        $build = [int](Get-CimInstance -ClassName Win32_OperatingSystem).BuildNumber
    }
    return $build -ge 22000
}

function Get-HasBattery {
    # Desktops (and VMs) report no Win32_Battery instance. A UPS can show up
    # as a battery; that is fine - the toolkit then plays safe like a laptop.
    $battery = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue
    return ($null -ne $battery)
}
