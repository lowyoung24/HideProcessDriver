@echo off
echo ================================================
echo HideProcess Driver Build - VS 2026 Edition
echo ================================================
echo.

echo [INFO] Checking Visual Studio 2022 installation...

set VS2022_PATH=
if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional" (
    set VS2022_PATH=C:\Program Files\Microsoft Visual Studio\2022\Professional
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Community" (
    set VS2022_PATH=C:\Program Files\Microsoft Visual Studio\2022\Community
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise" (
    set VS2022_PATH=C:\Program Files\Microsoft Visual Studio\2022\Enterprise
)

if "%VS2022_PATH%"=="" (
    echo [ERROR] Visual Studio 2022 not found!
    echo [HINT] Please install Visual Studio 2022 with:
    echo        - Desktop development with C++ workload
    echo        - Windows 11 SDK
    echo        - Then install WDK
    echo.
    echo Alternatively, use VS 2026 with WDK Preview if available.
    pause
    exit /b 1
)

echo [INFO] Found VS 2022 at: %VS2022_PATH%
echo.

echo [INFO] Setting up environment...
call "%VS2022_PATH%\VC\Auxiliary\Build\vcvars64.bat"

echo.
echo [INFO] Building driver (Release x64)...
msbuild HideProcessMini.vcxproj /p:Configuration=Release /p:Platform=x64 /p:SpectreMitigation=false /t:Build

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [SUCCESS] Driver built successfully!
    echo [INFO] Output: x64\Release\HideProcess.sys
    echo.
    echo [NEXT STEPS]
    echo   1. Install driver (as Admin):
    echo      sc create HideProcess type= kernel binPath= ^<path^>\HideProcess.sys
    echo      sc start HideProcess
    echo   2. Use HideProcessApp.exe to hide processes:
    echo      HideProcessApp.exe ^<PID^>
) else (
    echo.
    echo [ERROR] Driver build failed!
    echo [HINTS]
    echo   - Make sure WDK 10.0.26100 is installed
    echo   - Make sure Windows SDK 10.0.26100 is installed
    echo   - Check that ntifs.h is in: C:\Program Files ^(x86^)\Windows Kits\10\Include\10.0.26100.0\km\
)

echo.
echo ================================================
pause