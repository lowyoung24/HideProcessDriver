@echo off
echo ================================================
echo HideProcess Driver Build - VS 2026
echo ================================================
echo.

echo [INFO] Setting up Visual Studio 2022 environment...
call "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat"

echo.
echo [INFO] Building driver (Release x64)...
msbuild HideProcessMini.vcxproj /p:Configuration=Release /p:Platform=x64 /p:SpectreMitigation=false /t:Build

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [SUCCESS] Driver built successfully!
    echo [INFO] Output: x64\Release\HideProcess.sys
) else (
    echo.
    echo [ERROR] Build failed
)

echo.
pause