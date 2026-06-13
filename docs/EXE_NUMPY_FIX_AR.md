# إصلاح مشكلة NumPy داخل نسخة PyInstaller

## المشكلة

ظهر الخطأ التالي عند تشغيل `sleep_quality_backend.exe`:

```text
ImportError: Unable to import required dependencies:
numpy: cannot load module more than once per process
```

## سبب التصحيح

الخطأ يحدث غالبًا عند وجود خليط غير مستقر من إصدارات NumPy/Pandas/Scikit-learn داخل بيئة البناء أو عند تجميع مكتبات NumPy الثنائية بشكل زائد داخل PyInstaller.

## ما تم تعديله

1. تثبيت NumPy على إصدار مستقر:

```text
numpy==1.26.4
```

2. تثبيت SciPy صراحة:

```text
scipy==1.15.2
```

3. استخدام بيئة بناء منفصلة ونظيفة:

```text
backend/.venv_exe
```

4. تعطيل UPX في PyInstaller لتقليل مشاكل ملفات `.pyd` الثنائية.

5. تقليل `hiddenimports` بدل جمع كل submodules من Pandas/Scikit-learn.

## طريقة الاستخدام

من جذر المشروع:

```powershell
Remove-Item -Recurse -Force backenduild, backend\dist, release_package, backend\.venv_exe -ErrorAction SilentlyContinue
powershell -ExecutionPolicy Bypass -File scripts/build_release_windows.ps1
```

ثم شغّل:

```powershell
cd release_packageackend
.\sleep_quality_backend.exe
```

وافتح:

```text
http://127.0.0.1:8010/health
```
