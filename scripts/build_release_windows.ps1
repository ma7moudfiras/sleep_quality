# Sleep Quality Analyzer - Windows EXE Release Builder
# Run from the project root on Windows PowerShell:
#   powershell -ExecutionPolicy Bypass -File scripts/build_release_windows.ps1

$ErrorActionPreference = "Stop"

function Fail($Message) {
    Write-Host "[ERROR] $Message" -ForegroundColor Red
    exit 1
}

function Step($Message) {
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Assert-Command($CommandName, $FriendlyName) {
    $cmd = Get-Command $CommandName -ErrorAction SilentlyContinue
    if ($null -eq $cmd) {
        Fail "$FriendlyName is not available in PATH. Install/configure it before building."
    }
}

$Root = Split-Path -Parent $PSScriptRoot
$Backend = Join-Path $Root "backend"
$Frontend = Join-Path $Root "frontend"
$ReleaseRoot = Join-Path $Root "release_package"
$ReleaseZip = Join-Path $Root "SleepQuality_Windows_Release.zip"
$AppPort = "8010"
$ReleaseVenv = Join-Path $Backend ".venv_exe"

Step "Pre-flight checks"
$IsWindowsHost = ($env:OS -eq "Windows_NT") -or ([System.Environment]::OSVersion.Platform -eq "Win32NT")
if (-not $IsWindowsHost) {
    Fail "This release builder must be run on Windows because Flutter Windows and PyInstaller Windows EXE builds are OS-specific."
}
Write-Host "Windows host detected: $([System.Environment]::OSVersion.VersionString)"
Assert-Command "flutter" "Flutter SDK"
Assert-Command "py" "Python Launcher"

Push-Location $Root
try {
    $flutterDoctor = flutter doctor 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) { Fail "flutter doctor failed. Run flutter doctor and fix reported issues." }

    $py312 = py -3.12 --version 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) { Fail "Python 3.12 is required. Install Python 3.12 and try again." }
    Write-Host "Using $($py312.Trim())"
}
finally {
    Pop-Location
}

Step "Cleaning previous release outputs"
Remove-Item -Recurse -Force $ReleaseRoot -ErrorAction SilentlyContinue
Remove-Item -Force $ReleaseZip -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force (Join-Path $Backend "build"), (Join-Path $Backend "dist") -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $ReleaseRoot | Out-Null

Step "Building backend executable with PyInstaller"
Push-Location $Backend
try {
    # Use a dedicated clean release venv to avoid stale NumPy/Pandas/Scikit binary mixes.
    Remove-Item -Recurse -Force $ReleaseVenv -ErrorAction SilentlyContinue
    py -3.12 -m venv $ReleaseVenv
    . "$ReleaseVenv\Scripts\Activate.ps1"

    python -m pip install --upgrade pip setuptools wheel
    pip install --only-binary=:all: -r requirements.txt
    pip install -r requirements-dev.txt

    python -c "import sys, numpy, pandas, sklearn; print('Release Python:', sys.version); print('NumPy:', numpy.__version__); print('Pandas:', pandas.__version__); print('Scikit-learn:', sklearn.__version__)"
    if ($LASTEXITCODE -ne 0) { Fail "Python ML dependency import check failed before PyInstaller build." }

    pyinstaller --clean --noconfirm sleep_quality_backend.spec

    $backendDist = Join-Path $Backend "dist\sleep_quality_backend"
    $backendExe = Join-Path $backendDist "sleep_quality_backend.exe"
    if (!(Test-Path $backendExe)) {
        Fail "Backend EXE was not generated at $backendExe"
    }
}
finally {
    Pop-Location
}

Step "Building Flutter Windows executable"
Push-Location $Frontend
try {
    if (!(Test-Path "windows")) {
        flutter config --enable-windows-desktop
        flutter create --platforms=windows .
        if (Test-Path "test\widget_test.dart") {
            Remove-Item "test\widget_test.dart" -Force
        }
    }

    flutter clean
    flutter pub get
    flutter analyze
    if ($LASTEXITCODE -ne 0) { Fail "flutter analyze failed. Fix issues before release." }

    flutter build windows --release --dart-define=API_BASE_URL=http://127.0.0.1:$AppPort

    $flutterRelease = Join-Path $Frontend "build\windows\x64\runner\Release"
    if (!(Test-Path $flutterRelease)) {
        Fail "Flutter Windows release folder was not generated."
    }
    $frontendExe = Get-ChildItem $flutterRelease -Filter *.exe | Select-Object -First 1
    if ($null -eq $frontendExe) {
        Fail "No Flutter frontend EXE found in $flutterRelease"
    }
    Write-Host "Detected frontend EXE: $($frontendExe.Name)"
}
finally {
    Pop-Location
}

Step "Assembling portable release package"
Copy-Item -Recurse (Join-Path $Backend "dist\sleep_quality_backend") (Join-Path $ReleaseRoot "backend")
Copy-Item -Recurse (Join-Path $Frontend "build\windows\x64\runner\Release") (Join-Path $ReleaseRoot "frontend")
Copy-Item (Join-Path $Root "release\Start_Sleep_Quality_App.bat") (Join-Path $ReleaseRoot "Start_Sleep_Quality_App.bat")

$DocsTarget = Join-Path $ReleaseRoot "docs"
New-Item -ItemType Directory -Force $DocsTarget | Out-Null
if (Test-Path (Join-Path $Root "docs")) {
    Copy-Item -Recurse (Join-Path $Root "docs\*") $DocsTarget -ErrorAction SilentlyContinue
}
Copy-Item (Join-Path $Root "README.md") (Join-Path $ReleaseRoot "README.md") -ErrorAction SilentlyContinue
Copy-Item (Join-Path $Root "PROJECT_DOCUMENTATION_AR.md") (Join-Path $ReleaseRoot "PROJECT_DOCUMENTATION_AR.md") -ErrorAction SilentlyContinue

Step "Creating release zip"
Compress-Archive -Path (Join-Path $ReleaseRoot "*") -DestinationPath $ReleaseZip -Force

Write-Host "`nRelease package created successfully:" -ForegroundColor Green
Write-Host "  $ReleaseRoot"
Write-Host "  $ReleaseZip"
Write-Host "`nRun:" -ForegroundColor Yellow
Write-Host "  $ReleaseRoot\Start_Sleep_Quality_App.bat"
