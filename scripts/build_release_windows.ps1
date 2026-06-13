# Sleep Quality App - Windows Release Builder
# Run from the project root on Windows PowerShell:
#   powershell -ExecutionPolicy Bypass -File scripts\build_release_windows.ps1
#
# Produces:
#   release_package/
#     SleepQuality.exe          <- Double-click launcher (no console window)
#     backend/                  <- Backend service files (~15 MB)
#     frontend/                 <- Flutter Windows app files
#     docs/                     <- Arabic user documentation
#     README.md
#   SleepQuality_Windows_Release.zip

$ErrorActionPreference = "Stop"

function Fail($Message) {
    Write-Host "[ERROR] $Message" -ForegroundColor Red
    exit 1
}

function Step($Message) {
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Assert-Command($CommandName, $FriendlyName) {
    if ($null -eq (Get-Command $CommandName -ErrorAction SilentlyContinue)) {
        Fail "$FriendlyName is not available in PATH. Install it before building."
    }
}

$Root        = Split-Path -Parent $PSScriptRoot
$Backend     = Join-Path $Root "backend"
$Frontend    = Join-Path $Root "frontend"
$Scripts     = Join-Path $Root "scripts"
$ReleaseRoot = Join-Path $Root "release_package"
$ReleaseZip  = Join-Path $Root "SleepQuality_Windows_Release.zip"
$AppPort     = "8010"
$ReleaseVenv = Join-Path $Backend ".venv_exe"

# ---------------------------------------------------------------------------
Step "Pre-flight checks"
# ---------------------------------------------------------------------------
$IsWindows = ($env:OS -eq "Windows_NT") -or ([System.Environment]::OSVersion.Platform -eq "Win32NT")
if (-not $IsWindows) {
    Fail "This builder must run on Windows. Flutter Windows and PyInstaller EXE builds are OS-specific."
}
Write-Host "Windows: $([System.Environment]::OSVersion.VersionString)"
Assert-Command "flutter" "Flutter SDK"
Assert-Command "py"      "Python Launcher (py.exe)"

Push-Location $Root
try {
    $py312 = py -3.12 --version 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) { Fail "Python 3.12 is required. Install it and try again." }
    Write-Host "Using $($py312.Trim())"

    $fd = flutter doctor 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) { Fail "flutter doctor failed. Fix reported issues first." }
} finally {
    Pop-Location
}

# ---------------------------------------------------------------------------
Step "Cleaning previous outputs"
# ---------------------------------------------------------------------------
Remove-Item -Recurse -Force $ReleaseRoot                          -ErrorAction SilentlyContinue
Remove-Item -Force          $ReleaseZip                           -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force (Join-Path $Backend "build")          -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force (Join-Path $Backend "dist")           -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force (Join-Path $Root    "build")          -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force (Join-Path $Root    "dist")           -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $ReleaseRoot | Out-Null

# ---------------------------------------------------------------------------
Step "Creating clean Python virtual environment for EXE build"
# ---------------------------------------------------------------------------
Push-Location $Backend
try {
    Remove-Item -Recurse -Force $ReleaseVenv -ErrorAction SilentlyContinue
    py -3.12 -m venv $ReleaseVenv
    . "$ReleaseVenv\Scripts\Activate.ps1"

    python -m pip install --upgrade pip setuptools wheel --quiet
    # Only 3 runtime deps now (no numpy/pandas/sklearn)
    pip install -r requirements.txt --quiet
    pip install pyinstaller==6.11.1 pyinstaller-hooks-contrib==2025.0 --quiet

    python -c "import fastapi, uvicorn; print('Deps OK: FastAPI', fastapi.__version__, '/ Uvicorn', uvicorn.__version__)"
    if ($LASTEXITCODE -ne 0) { Fail "Dependency check failed." }
} finally {
    Pop-Location
}

# ---------------------------------------------------------------------------
Step "Building backend EXE with PyInstaller  (~15 MB expected)"
# ---------------------------------------------------------------------------
Push-Location $Backend
try {
    pyinstaller --clean --noconfirm sleep_quality_backend.spec
    $backendExe = Join-Path $Backend "dist\sleep_quality_backend\sleep_quality_backend.exe"
    if (!(Test-Path $backendExe)) { Fail "Backend EXE not found at $backendExe" }
    $sizeMB = [math]::Round((Get-ChildItem -Recurse (Join-Path $Backend "dist\sleep_quality_backend") | Measure-Object -Property Length -Sum).Sum / 1MB, 1)
    Write-Host "Backend EXE folder size: $sizeMB MB"
} finally {
    Pop-Location
}

# ---------------------------------------------------------------------------
Step "Building launcher EXE (windowed, no console)"
# ---------------------------------------------------------------------------
Push-Location $Root
try {
    pyinstaller --clean --noconfirm scripts\launcher.spec
    $launcherExe = Join-Path $Root "dist\SleepQuality.exe"
    if (!(Test-Path $launcherExe)) { Fail "Launcher EXE not found at $launcherExe" }
    $launcherMB = [math]::Round((Get-Item $launcherExe).Length / 1MB, 1)
    Write-Host "Launcher EXE size: $launcherMB MB"
} finally {
    Pop-Location
}

# ---------------------------------------------------------------------------
Step "Building Flutter Windows app"
# ---------------------------------------------------------------------------
Push-Location $Frontend
try {
    if (!(Test-Path "windows")) {
        flutter config --enable-windows-desktop
        flutter create --platforms=windows .
    }

    flutter clean
    flutter pub get
    flutter analyze
    if ($LASTEXITCODE -ne 0) { Fail "flutter analyze failed. Fix issues before release." }

    flutter build windows --release --dart-define=API_BASE_URL=http://127.0.0.1:$AppPort
    if ($LASTEXITCODE -ne 0) { Fail "Flutter Windows build failed." }

    $flutterRelease = Join-Path $Frontend "build\windows\x64\runner\Release"
    if (!(Test-Path $flutterRelease)) { Fail "Flutter release folder not found." }
    $frontendExe = Get-ChildItem $flutterRelease -Filter *.exe | Select-Object -First 1
    if ($null -eq $frontendExe) { Fail "No Flutter EXE found in $flutterRelease" }
    Write-Host "Flutter EXE: $($frontendExe.Name)"
} finally {
    Pop-Location
}

# ---------------------------------------------------------------------------
Step "Assembling release package"
# ---------------------------------------------------------------------------
# Backend service files
Copy-Item -Recurse (Join-Path $Backend "dist\sleep_quality_backend") (Join-Path $ReleaseRoot "backend")

# Flutter app files
Copy-Item -Recurse (Join-Path $Frontend "build\windows\x64\runner\Release") (Join-Path $ReleaseRoot "frontend")

# Launcher EXE — the main entry point the user double-clicks
Copy-Item (Join-Path $Root "dist\SleepQuality.exe") (Join-Path $ReleaseRoot "SleepQuality.exe")

# Fallback BAT launcher (for diagnostics / no-console troubleshooting)
Copy-Item (Join-Path $Root "release\Start_Sleep_Quality_App.bat") (Join-Path $ReleaseRoot "Start_Sleep_Quality_App.bat")

# Documentation
$DocsTarget = Join-Path $ReleaseRoot "docs"
New-Item -ItemType Directory -Force $DocsTarget | Out-Null
if (Test-Path (Join-Path $Root "docs")) {
    Copy-Item -Recurse (Join-Path $Root "docs\*") $DocsTarget -ErrorAction SilentlyContinue
}
Copy-Item (Join-Path $Root "README.md")                    (Join-Path $ReleaseRoot "README.md")                    -ErrorAction SilentlyContinue
Copy-Item (Join-Path $Root "PROJECT_DOCUMENTATION_AR.md")  (Join-Path $ReleaseRoot "PROJECT_DOCUMENTATION_AR.md")  -ErrorAction SilentlyContinue
Copy-Item (Join-Path $Root "KNOWN_LIMITATIONS.md")         (Join-Path $ReleaseRoot "KNOWN_LIMITATIONS.md")         -ErrorAction SilentlyContinue

# ---------------------------------------------------------------------------
Step "Creating release ZIP"
# ---------------------------------------------------------------------------
Compress-Archive -Path (Join-Path $ReleaseRoot "*") -DestinationPath $ReleaseZip -Force

$totalMB = [math]::Round((Get-ChildItem -Recurse $ReleaseRoot | Measure-Object -Property Length -Sum).Sum / 1MB, 1)

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  Release built successfully!" -ForegroundColor Green
Write-Host "  Total package size: $totalMB MB" -ForegroundColor Green
Write-Host "========================================`n"
Write-Host "Package folder : $ReleaseRoot"
Write-Host "ZIP archive    : $ReleaseZip"
Write-Host "`nTo launch the app, the user double-clicks:" -ForegroundColor Yellow
Write-Host "  $ReleaseRoot\SleepQuality.exe"
