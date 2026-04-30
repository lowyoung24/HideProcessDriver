# Install Full WDK with Kernel Headers
# Run as Administrator

$ErrorActionPreference = "Continue"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

Write-Log "Installing Full Windows Driver Kit (WDK)"
Write-Log "========================================="

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Log "Please run as Administrator!" "ERROR"
    exit 1
}

$vsInstaller = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\setup.exe"

if (-not (Test-Path $vsInstaller)) {
    Write-Log "Visual Studio Installer not found!" "ERROR"
    exit 1
}

# Get VS instance info
$vsPath = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -property installationPath
Write-Log "VS Installation Path: $vsPath"

# WDK workload for VS 2022/2026
$wdkWorkload = "Microsoft.VisualStudio.Workload.Driver"

Write-Log "Installing WDK workload..."
Write-Log "Workload: $wdkWorkload"

$args = @(
    "modify",
    "--installPath", "`"$vsPath`"",
    "--add", $wdkWorkload,
    "--quiet",
    "--norestart"
)

Write-Log "Running: $vsInstaller $($args -join ' ')"

& $vsInstaller $args

if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 3010) {
    Write-Log "WDK workload installation initiated successfully!"
    Write-Log ""
    Write-Log "Please restart your computer after installation completes."
    Write-Log "After reboot, run: build_all.bat"
} else {
    Write-Log "WDK installation failed with exit code: $LASTEXITCODE" "ERROR"
    Write-Log ""
    Write-Log "Manual installation recommended:"
    Write-Log "1. Open Visual Studio Installer"
    Write-Log "2. Click 'Modify' on your VS installation"
    Write-Log "3. Search for 'Windows Driver Kit'"
    Write-Log "4. Check all WDK components"
    Write-Log "5. Click 'Modify' to install"
}

Write-Log "========================================="