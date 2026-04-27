# WDK Installation Script
# Run as Administrator

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

Write-Log "Windows Driver Kit (WDK) Installation Script"
Write-Log "============================================="

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Log "Please run as Administrator!" "ERROR"
    exit 1
}

# WDK Download URL (Windows 11 22H2)
$wdkUrl = "https://go.microsoft.com/fwlink/?linkid=2247978"
$wdkPath = "$env:TEMP\wdk_installer.exe"

Write-Log "Step 1: Downloading Windows Driver Kit..."
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
Write-Log "Running: $wdkPath /quiet /norestart"

& $wdkPath /quiet /norestart

Write-Log "WDK installation started. This may take several minutes..."
Write-Log "Please wait for the installation to complete."

# Check if WDK is installed
Write-Log "Step 3: Verifying WDK installation..."

$wdkIncludePath = "C:\Program Files (x86)\Windows Kits\10\Include"

if (Test-Path $wdkIncludePath) {
    $ntifsPath = Join-Path $wdkIncludePath "10.0.22621.0\km\ntifs.h"
    if (Test-Path $ntifsPath) {
        Write-Log "WDK installation verified!" "SUCCESS"
        Write-Log "Found ntifs.h at: $ntifsPath"
    } else {
        Write-Log "WDK installed but ntifs.h not found. Please check installation." "WARNING"
    }
} else {
    Write-Log "WDK installation path not found. Installation may have failed." "ERROR"
}

Write-Log "============================================="
Write-Log "WDK installation process initiated!"
Write-Log ""
Write-Log "After installation, you can build the driver:"
Write-Log "  1. Open Command Prompt as Administrator"
Write-Log "  2. Navigate to project directory"
Write-Log "  3. Run: build_all.bat"
Write-Log "============================================="