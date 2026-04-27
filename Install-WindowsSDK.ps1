# Install Windows SDK for Driver Development
# Run as Administrator

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

Write-Log "Installing Windows SDK for Driver Development"
Write-Log "============================================="

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

Write-Log "Found VS Installer: $vsInstaller"

# Get current VS instance path
$vsPath = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -property installationPath
Write-Log "VS Installation Path: $vsPath"

# Components needed for driver development
$components = @(
    "Microsoft.VisualStudio.Component.Windows11SDK.22000",
    "Microsoft.VisualStudio.Component.Windows11SDK.22621",
    "Microsoft.VisualStudio.Component.Windows10SDK.20348",
    "Microsoft.VisualStudio.Component.Windows10SDK"
)

Write-Log "Installing Windows SDK components..."
Write-Log "Components: $($components -join ', ')"

# Try to install each component
foreach ($component in $components) {
    Write-Log "Installing: $component"
    $args = @(
        "modify",
        "--installPath", "`"$vsPath`"",
        "--add", $component,
        "--quiet",
        "--norestart"
    )

    Write-Log "Running: $vsInstaller $($args -join ' ')"

    & $vsInstaller $args

    if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 3010) {
        Write-Log "Successfully installed: $component"
    } else {
        Write-Log "Failed to install: $component (Exit code: $LASTEXITCODE)" "WARNING"
    }
}

Write-Log "============================================="
Write-Log "Windows SDK installation completed!"
Write-Log ""
Write-Log "After installation, run:"
Write-Log "  build_all.bat"
Write-Log "============================================="