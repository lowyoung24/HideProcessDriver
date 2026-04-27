# WDK Installation - Using standalone installer method
# Run as Administrator

$ErrorActionPreference = "Continue"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

Write-Log "WDK Standalone Installation"
Write-Log "=============================="

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Log "Please run as Administrator!" "ERROR"
    Write-Log "Right-click PowerShell and select 'Run as Administrator'"
    exit 1
}

Write-Log "Step 1: Checking system architecture..."
$arch = $env:PROCESSOR_ARCHITECTURE
Write-Log "Architecture: $arch"

# WDK standalone installers
$wdkVersions = @{
    "WDK 11" = "https://go.microsoft.com/fwlink/?linkid=2247978"
    "WDK 10" = "https://go.microsoft.com/fwlink/?linkid=615451"
}

$downloadedFile = "$env:TEMP\wdksetup.exe"

Write-Log "Step 2: Downloading WDK standalone installer..."
Write-Log "This may take several minutes depending on your connection..."

try {
    # Try WDK 11 first
    $url = $wdkVersions["WDK 11"]
    Write-Log "URL: $url"

    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($url, $downloadedFile)
    $webClient.Dispose()

    Write-Log "Download complete: $downloadedFile"

    $fileInfo = Get-Item $downloadedFile
    Write-Log "File size: $($fileInfo.Length) bytes"
} catch {
    Write-Log "Download failed: $_" "ERROR"
    Write-Log ""
    Write-Log "Manual installation required:"
    Write-Log "1. Open browser: https://docs.microsoft.com/en-us/windows-hardware/drivers/download-the-wdk"
    Write-Log "2. Download WDK for your Windows version"
    Write-Log "3. Run the installer"
    exit 1
}

Write-Log "Step 3: Running WDK installer..."
Write-Log "IMPORTANT: If a window opens, follow the installation prompts!"

# Check if it's a valid executable
try {
    $bytes = [System.IO.File]::ReadAllBytes($downloadedFile)
    if ($bytes[0] -eq 0x4D -and $bytes[1] -eq 0x5A) {
        Write-Log "Valid PE executable detected"
    } else {
        Write-Log "File is not a valid Windows executable" "ERROR"
        exit 1
    }
} catch {
    Write-Log "Could not verify executable" "WARNING"
}

Write-Log ""
Write-Log "=========================================="
Write-Log "To complete WDK installation:"
Write-Log "1. The WDK installer window should open"
Write-Log "2. Follow the installation wizard"
Write-Log "3. After installation, restart your PC"
Write-Log "4. Then run: build_all.bat"
Write-Log "=========================================="
Write-Log ""
Write-Log "Starting installer now..."

# Launch installer
Start-Process $downloadedFile

Write-Log "Installation started. Please complete the installation wizard."