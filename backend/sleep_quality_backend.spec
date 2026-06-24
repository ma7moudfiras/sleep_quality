# -*- mode: python ; coding: utf-8 -*-
# PyInstaller spec for Sleep Quality Analyzer backend.
# Build from backend directory:
#   pyinstaller --clean --noconfirm sleep_quality_backend.spec
#
# No NumPy/Pandas/SciKit-Learn — the ML is pure Python k-NN.
# Expected EXE size: ~15 MB (vs ~200 MB with the old ML stack).

from PyInstaller.utils.hooks import collect_submodules

hiddenimports = []
hiddenimports += collect_submodules('app')
hiddenimports += [
    'uvicorn.logging',
    'uvicorn.loops',
    'uvicorn.loops.auto',
    'uvicorn.protocols',
    'uvicorn.protocols.http',
    'uvicorn.protocols.http.auto',
    'uvicorn.protocols.websockets',
    'uvicorn.protocols.websockets.auto',
    'uvicorn.lifespan',
    'uvicorn.lifespan.on',
]

datas = [
    ('data', 'data'),
    ('app/static', 'app/static'),
]

excludes = [
    'numpy', 'scipy', 'pandas', 'sklearn', 'joblib', 'threadpoolctl',
    'matplotlib', 'IPython', 'jupyter', 'notebook', 'pytest',
    'tkinter', 'PIL', 'PyQt5', 'PyQt6', 'PySide2', 'PySide6',
]

a = Analysis(
    ['run_backend.py'],
    pathex=['.'],
    binaries=[],
    datas=datas,
    hiddenimports=hiddenimports,
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=excludes,
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='sleep_quality_backend',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
coll = COLLECT(
    exe,
    a.binaries,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='sleep_quality_backend',
)
