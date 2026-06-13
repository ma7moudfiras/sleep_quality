# حالة Patch إصلاح NumPy للملف التنفيذي

تم تجهيز Patch لمعالجة فشل تشغيل Backend EXE الناتج عن:

```text
numpy: cannot load module more than once per process
```

## الملفات المعدلة

```text
backend/requirements.txt
backend/requirements-dev.txt
backend/run_backend.py
backend/sleep_quality_backend.spec
scripts/build_release_windows.ps1
docs/EXE_NUMPY_FIX_AR.md
```

## القرار الفني

يجب إعادة بناء نسخة EXE من الصفر بعد تطبيق هذا Patch، لأن النسخة الموجودة في `release_package` مبنية على بيئة قديمة وقد تحتوي NumPy غير مستقر مع PyInstaller.
