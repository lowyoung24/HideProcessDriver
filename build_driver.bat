@echo off
echo ================================================
echo HideProcess Driver - Build Script
echo ================================================
echo.

set MSBUILD_PATH="C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"

echo [INFO] Checking for Windows Driver Kit (WDK)...
if not exist %MSBUILD_PATH% (
    echo [ERROR] MSBuild not found at %MSBUILD_PATH%
    echo [HINT] Please install Visual Studio 2022 with WDK workload.
    pause
    exit /b 1
)

echo.
echo [INFO] Building driver (Release x64)...
%MSBUILD_PATH% ObRegisterCallbacks.vcxproj /p:Configuration=Release /p:Platform=x64 /p:SpectreMitigation=false /t:Build

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [SUCCESS] Driver built successfully!
    echo [INFO] Output: x64\Release\HideProcess.sys
) else (
    echo.
    echo [ERROR] Driver build failed!
    echo [HINT] Make sure Windows Driver Kit (WDK) is installed.
    pause
    exit /b 1
)

echo.
echo ================================================
echo Driver build complete!
echo Output: x64\Release\HideProcess.sys
echo ================================================