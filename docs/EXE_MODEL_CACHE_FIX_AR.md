# إصلاح فشل Backend EXE بسبب ملف نموذج قديم

## المشكلة

ظهر الخطأ:

```text
ModuleNotFoundError: No module named 'numpy._core'
```

السبب أن ملف `sleep_energy_model.joblib` الموجود في مجلد البيانات قد يكون محفوظًا بإصدار NumPy مختلف عن إصدار بيئة الـ EXE.

## الإصلاح

تم تعديل Backend بحيث:

1. لا ينسخ نموذجًا قديمًا تلقائيًا إلى runtime data.
2. إذا فشل تحميل النموذج، ينقله إلى ملف احتياطي باسم `sleep_energy_model.invalid_*.joblib`.
3. يعيد تدريب النموذج تلقائيًا من seed dataset وبيانات المستخدم المصنّفة.

## أوامر إعادة البناء

```powershell
cd C:\Users\DELL\StudioProjects\sleep_quality
Remove-Item -Recurse -Force backend\build, backend\dist, release_package, backend\.venv_exe -ErrorAction SilentlyContinue
powershell -ExecutionPolicy Bypass -File scripts/build_release_windows.ps1
```

## اختبار Backend EXE

```powershell
cd C:\Users\DELL\StudioProjects\sleep_quality\release_package\backend
.\sleep_quality_backend.exe
```

ثم افتح:

```text
http://127.0.0.1:8010/health
```
