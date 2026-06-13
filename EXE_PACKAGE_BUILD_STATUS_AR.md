# حالة بناء الحزمة التنفيذية

تم تجهيز المشروع بملفات بناء حزمة Windows EXE.

## ما تم تجهيزه

- سكربت بناء آلي: `scripts/build_release_windows.ps1`
- مشغل موحد: `release/Start_Sleep_Quality_App.bat`
- PyInstaller spec للـ Backend: `backend/sleep_quality_backend.spec`
- ملف تشغيل Backend: `backend/run_backend.py`
- دليل بناء عربي: `docs/BUILD_EXE_PACKAGE_GUIDE_AR.md`

## ملاحظة تنفيذية

بناء ملف `.exe` الفعلي يجب أن يتم على جهاز Windows يحتوي Flutter Windows toolchain وPython 3.12، لأن ملفات Windows التنفيذية لا تُبنى بشكل موثوق من بيئة Linux هذه.

الأمر المطلوب على جهازك:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/build_release_windows.ps1
```

بعد نجاحه ستحصل على:

```text
release_package/
SleepQuality_Windows_Release.zip
```
