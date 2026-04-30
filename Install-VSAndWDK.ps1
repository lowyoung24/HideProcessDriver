# Visual Studio 2022 + WDK Installation Script
# Run as Administrator

param(
    [switch]$SkipWDK
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

Write-Log "Visual Studio 2022 + WDK Installation Script"
Write-Log "============================================="

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Log "Please run as Administrator!" "ERROR"
    exit 1
}

# VS2022 Community Download URL
$vsInstallerUrl = "https://aka.ms/vs/17/release/vs_community.exe"
$vsInstallerPath = "$env:TEMP\vs_community_installer.exe"

Write-Log "Step 1: Downloading Visual Studio 2022 Installer..."
Write-Log "URL: $vsInstallerUrl"

try {
    Invoke-WebRequest -Uri $vsInstallerUrl -OutFile $vsInstallerPath -UseBasicParsing
    Write-Log "Download complete: $vsInstallerPath"
} catch {
    Write-Log "Failed to download VS Installer: $_" "ERROR"
    exit 1
}

# VS2022 Workloads for Driver Development
$workloads = @(
    "Microsoft.VisualStudio.Workload.ManagedDesktop",
    "Microsoft.VisualStudio.Workload.NativeDesktop",
    "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
    "Microsoft.VisualStudio.Component.Windows11SDK.22000",
    "Microsoft.VisualStudio.Component.VC.CoreIde"
)

$workloadStr = ($workloads | ForEach-Object { "--add $_" }) -join " "

Write-Log "Step 2: Installing Visual Studio 2022 with Driver Development workload..."
Write-Log "Workloads: $($workloads -join ', ')"

$installArgs = "--quiet --norestart --force --wait $workloadStr"

Write-Log "Running: $vsInstallerPath $installArgs"

& $vsInstallerPath $installArgs

if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 3010) {
    Write-Log "Visual Studio installed successfully!"
} else {
    Write-Log "Visual Studio installation failed with exit code: $LASTEXITCODE" "ERROR"
    exit 1
}

if ($SkipWDK) {
    Write-Log "Skipping WDK installation (--SkipWDK specified)"
} else {
    Write-Log "Step 3: Downloading Windows Driver Kit (WDK)..."
    $wdkUrl = "https://go.microsoft.com/fwlink/?linkid=2247978"
    $wdkPath = "$env:TEMP\wdk_installer.exe"

    try {
        Invoke-WebRequest -Uri $wdkUrl -OutFile $wdkPath -UseBasicParsing
        Write-Log "WDK downloaded: $wdkPath"
    } catch {
        Write-Log "Failed to download WDK: $_" "ERROR"
        Write-Log "Please manually download WDK from: https://docs.microsoft.com/en-us/windows-hardware/drivers/download-the-wdk"
    }

    Write-Log "Installing WDK..."
    & $wdkPath /quiet /norestart

    Write-Log "WDK installation started. This may take several minutes..."
}

Write-Log "============================================="
Write-Log "Installation process initiated!"
Write-Log "Please restart your computer if prompted."
Write-Log ""
Write-Log "After reboot, verify installation:"
Write-Log "  1. Open Visual Studio"
Write-Log "  2. Check Tools > Get Tools and Features"
Write-Log "  3. Confirm 'Desktop development with C++' is installed"
if (-not $SkipWDK) {
    Write-Log "  4. Confirm Windows Driver Kit is installed"
}
Write-Log "============================================="