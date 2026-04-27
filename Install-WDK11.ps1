# WDK Installation Script for Windows 11
# Run as Administrator

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

Write-Log "Windows Driver Kit (WDK) Installation Script for Windows 11"
Write-Log "===================================================="

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Log "Please run as Administrator!" "ERROR"
    exit 1
}

# WDK for Windows 11 23H2
$wdkUrl = "https://go.microsoft.com/fwlink/?linkid=2257245"
$wdkPath = "$env:TEMP\wdksetup.exe"

Write-Log "Step 1: Downloading Windows Driver Kit for Windows 11..."
Write-Log "URL: $wdkUrl"

try {
    Invoke-WebRequest -Uri $wdkUrl -OutFile $wdkPath -UseBasicParsing
    Write-Log "Download complete: $wdkPath"
} catch {
    Write-Log "Failed to download WDK: $_" "ERROR"
    Write-Log "Please manually download WDK from: https://docs.microsoft.com/en-us/windows-hardware/drivers/download-the-wdk"
    exit 1
}

Write-Log "Step 2: Installing Windows Driver Kit..."
Write-Log "Running WDK installer..."

# Run the installer interactively
& $wdkPath

Write-Log "WDK installation started. Please follow the on-screen instructions."
Write-Log "This may take several minutes to complete."

Write-Log "===================================================="
Write-Log "WDK installation process initiated!"
Write-Log ""
Write-Log "After installation, you can build the driver:"
Write-Log "  1. Open Command Prompt as Administrator"
Write-Log "  2. Navigate to project directory"
Write-Log "  3. Run: build_all.bat"
Write-Log "===================================================="