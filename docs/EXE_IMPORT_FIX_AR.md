# تصحيح خطأ استيراد app.main داخل Backend EXE

## الخطأ

```text
ERROR: Error loading ASGI app. Could not import module "app.main".
```

## السبب

كان ملف التشغيل يستخدم:

```python
uvicorn.run("app.main:app", ...)
```

وهذا استيراد نصي ديناميكي. PyInstaller لا يكتشفه دائمًا أثناء البناء، لذلك لا يضمّن `app.main` داخل الحزمة التنفيذية.

## التصحيح

تم تعديل `backend/run_backend.py` ليعمل باستيراد مباشر:

```python
from app.main import app
uvicorn.run(app, ...)
```

كما تم تحديث `backend/sleep_quality_backend.spec` لإضافة hidden imports وبيانات `app` و `data`.

## إعادة البناء

من جذر المشروع:

```powershell
cd C:\Users\DELL\StudioProjects\sleep_quality
Remove-Item -Recurse -Force backend\build, backend\dist -ErrorAction SilentlyContinue
powershell -ExecutionPolicy Bypass -File scripts/build_release_windows.ps1
```

أو من داخل backend مباشرة:

```powershell
cd C:\Users\DELL\StudioProjects\sleep_quality\backend
.\.venv\Scripts\Activate.ps1
Remove-Item -Recurse -Force build, dist -ErrorAction SilentlyContinue
pyinstaller --clean sleep_quality_backend.spec
.\dist\sleep_quality_backend\sleep_quality_backend.exe
```
