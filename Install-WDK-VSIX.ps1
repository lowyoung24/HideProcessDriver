# WDK Installation Script - Using vs_installer.exe method
# Run as Administrator

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

Write-Log "WDK Installation via Visual Studio Extension"
Write-Log "============================================"

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Log "Please run as Administrator!" "ERROR"
    exit 1
}

# WDK VSIX extension URL
$wdkVsixUrl = "https://go.microsoft.com/fwlink/?linkid=2257404"
$wdkVsixPath = "$env:TEMP\wdk.vsix"

Write-Log "Step 1: Downloading WDK Visual Studio Extension..."
Write-Log "URL: $wdkVsixUrl"

try {
    Invoke-WebRequest -Uri $wdkVsixUrl -OutFile $wdkVsixPath -UseBasicParsing
    Write-Log "Download complete: $wdkVsixPath"
} catch {
    Write-Log "Failed to download WDK VSIX: $_" "ERROR"
    exit 1
}

# Check if VSIX is valid
$fileInfo = Get-Item $wdkVsixPath
if ($fileInfo.Length -lt 1000) {
    Write-Log "Downloaded file is too small, might be an error page." "ERROR"
    exit 1
}

Write-Log "Step 2: Checking Visual Studio installation path..."

$vsWhere = "${env:ProgramFiles}\Microsoft Visual Studio\Installer\vswhere.exe"
if (-not (Test-Path $vsWhere)) {
    $vsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
}

if (Test-Path $vsWhere) {
    Write-Log "Found vswhere.exe at: $vsWhere"
} else {
    Write-Log "vswhere.exe not found" "ERROR"
}

Write-Log "Step 3: Installing WDK VSIX extension..."
Write-Log "Running: $wdkVsixPath"

# Try to install VSIX using VSIXInstaller
$vsixInstaller = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vsixinstaller.exe"
if (-not (Test-Path $vsixInstaller)) {
    $vsixInstaller = "${env:ProgramFiles}\Microsoft Visual Studio\Installer\vsixinstaller.exe"
}

if (Test-Path $vsixInstaller) {
    Write-Log "Found VSIXInstaller at: $vsixInstaller"

    # List all installed VS instances
    & $vsWhere -all | ForEach-Object {
        Write-Log "VS Instance: $_"
    }

    # Try to install for all instances
    & $vsixInstaller /a "$wdkVsixPath"
} else {
    Write-Log "VSIXInstaller not found. Please install WDK manually."
    Write-Log "Download WDK from: https://docs.microsoft.com/en-us/windows-hardware/drivers/download-the-wdk"
}

Write-Log "============================================"
Write-Log "After WDK is installed, run build_all.bat to compile the driver."
Write-Log "============================================"