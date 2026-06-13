# -*- mode: python ; coding: utf-8 -*-
# PyInstaller spec for Sleep Quality Analyzer backend.
# Build from backend directory:
#   pyinstaller --clean --noconfirm sleep_quality_backend.spec

from PyInstaller.utils.hooks import collect_data_files, collect_submodules

# Keep hidden imports targeted. Over-collecting full pandas/sklearn submodule trees can
# duplicate NumPy binary extensions in some Windows builds.
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
    'sklearn.ensemble._forest',
    'sklearn.tree._classes',
    'sklearn.tree._tree',
    'sklearn.preprocessing._data',
    'sklearn.pipeline',
    'sklearn.utils._typedefs',
    'sklearn.utils._heap',
    'sklearn.utils._sorting',
    'sklearn.utils._vector_sentinel',
    'sklearn.neighbors._partition_nodes',
    'pandas._libs.tslibs.timedeltas',
    'pandas._libs.tslibs.np_datetime',
    'pandas._libs.tslibs.nattype',
    'pandas._libs.tslibs.base',
]

datas = []
datas += [('data', 'data')]
datas += [('app/static', 'app/static')]
datas += collect_data_files('sklearn', include_py_files=False)
datas += collect_data_files('pandas', include_py_files=False)

excludes = [
    'matplotlib', 'IPython', 'jupyter', 'notebook', 'pytest', 'tkinter',
    'PIL.ImageQt', 'PyQt5', 'PyQt6', 'PySide2', 'PySide6',
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
    upx=False,
    console=True,
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
    upx=False,
    upx_exclude=[],
    name='sleep_quality_backend',
)
