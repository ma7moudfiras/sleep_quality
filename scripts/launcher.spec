# -*- mode: python ; coding: utf-8 -*-
# PyInstaller spec for the Sleep Quality App launcher.
# Build from the project ROOT directory:
#   pyinstaller --clean --noconfirm scripts/launcher.spec
#
# This produces a small windowed EXE (~5 MB) with no console window.
# The user double-clicks SleepQuality.exe to launch the whole app.

a = Analysis(
    ['scripts/launcher.py'],
    pathex=['.'],
    binaries=[],
    datas=[],
    hiddenimports=[],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[
        'numpy', 'scipy', 'pandas', 'sklearn', 'matplotlib',
        'tkinter', 'PIL', 'PyQt5', 'PyQt6',
    ],
    noarchive=False,
    optimize=1,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name='SleepQuality',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    # windowed=True / console=False → no CMD window ever appears
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    # icon='assets/app_icon.ico',  # Uncomment and add an icon file if desired
)
