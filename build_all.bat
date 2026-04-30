@echo off
echo ================================================
echo HideProcess - Complete Build Script
echo ================================================
echo.

echo [STEP 1] Building user-mode application...
call build_app.bat
echo.

echo [STEP 2] Building kernel driver...
call build_driver.bat
echo.

echo ================================================
echo Build Summary:
echo   - HideProcessApp.exe (user-mode app)
echo   - HideProcess.sys (kernel driver)
echo ================================================
echo.
echo [NOTE] To use:
echo   1. Install driver (as Administrator):
echo      sc create HideProcess type= kernel binPath= C:\Windows\System32\drivers\HideProcess.sys
echo      sc start HideProcess
echo   2. Hide a process:
echo      HideProcessApp.exe ^<PID^>
echo ================================================
pause