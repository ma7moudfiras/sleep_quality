@echo off
setlocal EnableExtensions EnableDelayedExpansion

set APP_PORT=8010
set BASE_DIR=%~dp0
set BACKEND_DIR=%BASE_DIR%backend
set FRONTEND_DIR=%BASE_DIR%frontend
set BACKEND_EXE=%BACKEND_DIR%\sleep_quality_backend.exe

if not exist "%BACKEND_EXE%" (
  echo [ERROR] Backend executable was not found:
  echo %BACKEND_EXE%
  pause
  exit /b 1
)

echo Starting Sleep Quality backend on port %APP_PORT%...
cd /d "%BACKEND_DIR%"
start "Sleep Quality Backend" "%BACKEND_EXE%"

echo Waiting for backend health check...
powershell -NoProfile -ExecutionPolicy Bypass -Command "for ($i=0; $i -lt 30; $i++) { try { $r = Invoke-WebRequest -UseBasicParsing http://127.0.0.1:%APP_PORT%/health -TimeoutSec 1; if ($r.StatusCode -eq 200) { exit 0 } } catch {}; Start-Sleep -Seconds 1 }; exit 1"
if errorlevel 1 (
  echo [WARNING] Backend did not respond to health check yet.
  echo You can still try opening the backend UI manually:
  echo http://127.0.0.1:%APP_PORT%/app
  pause
) else (
  echo Backend is ready.
)

set FRONTEND_EXE=
for %%F in ("%FRONTEND_DIR%\*.exe") do (
  set FRONTEND_EXE=%%~fF
  goto :found_frontend
)

:found_frontend
if not defined FRONTEND_EXE (
  echo [WARNING] Flutter frontend executable was not found.
  echo Opening backend web UI instead...
  start "Sleep Quality Backend UI" "http://127.0.0.1:%APP_PORT%/app"
  exit /b 0
)

echo Starting Flutter Windows app...
cd /d "%FRONTEND_DIR%"
start "Sleep Quality App" "%FRONTEND_EXE%"

echo.
echo If the desktop app does not open, use:
echo http://127.0.0.1:%APP_PORT%/app
echo.
endlocal
