@echo off
setlocal EnableExtensions
cd /d "%~dp0"

REM ReactedHQ WinPatch Rapid Triage Kit — Double Click Launcher
REM - Runs RUN_ME_FIRST.ps1
REM - Requests Admin via UAC for best results (if canceled, runs limited)

net session >nul 2>&1
if %errorlevel%==0 goto RUN

echo.
echo ==============================
echo  Requesting Administrator...
echo  (Recommended for best results)
echo ==============================
echo.

powershell -NoProfile -Command "Start-Process -FilePath cmd.exe -ArgumentList '/c','\"%~f0\"' -Verb RunAs" >nul 2>&1

REM If UAC was accepted, the elevated process is now running and we can exit.
REM If UAC was canceled/failed, continue in limited mode.
echo.
echo UAC was canceled or failed. Running in LIMITED (non-admin) mode.
echo Some checks/exports may be skipped. You can rerun as admin anytime.
echo.

:RUN
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0RUN_ME_FIRST.ps1"
echo.
echo Done. If you need help, email deemmanymg@gmail.com and attach support_bundle.zip if possible.
echo.
echo.
echo Output folder is printed by the tool and copied to clipboard.
echo Report will open automatically when ready.
echo.
pause
endlocal
