@echo off
echo ================================================
echo HideProcess - Build Script
echo ================================================
echo.

set VCVARS="C:\Program Files\Microsoft Visual Studio\18\Professional\VC\Auxiliary\Build\vcvars64.bat"

if not exist %VCVARS% (
    set VCVARS="C:\Program Files (x86)\Microsoft Visual Studio\18\Professional\VC\Auxiliary\Build\vcvars64.bat"
)

if not exist %VCVARS% (
    echo [ERROR] Visual Studio 2022 not found!
    echo Please install Visual Studio 2022 with C++ workload.
    pause
    exit /b 1
)

echo [INFO] Setting up Visual Studio environment...
call %VCVARS%

echo.
echo [INFO] Building user-mode application (HideProcessApp.exe)...
cl.exe HideProcessApp.c /Fe:HideProcessApp.exe /nologo /W3 /D_WIN32_WINNT=0x0601 Advapi32.lib

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [SUCCESS] HideProcessApp.exe built successfully!
) else (
    echo.
    echo [ERROR] Build failed!
    pause
    exit /b 1
)

echo.
echo ================================================
echo Build complete!
echo Output: HideProcessApp.exe
echo ================================================