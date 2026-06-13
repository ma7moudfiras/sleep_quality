# إصلاح سكربت بناء ملف EXE — Windows Detection Fix

## المشكلة
عند تشغيل:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/build_release_windows.ps1
```

ظهر الخطأ:

```text
[ERROR] This release builder must be run on Windows because Flutter Windows and PyInstaller Windows EXE builds are OS-specific.
```

رغم أن الجهاز يعمل بنظام Windows.

## السبب
النسخة السابقة من السكربت اعتمدت على المتغير `$IsWindows`، وهذا المتغير قد لا يكون معرفًا في Windows PowerShell 5.x. عند عدم تعريفه، تعامل السكربت مع الجهاز كأنه ليس Windows.

## الإصلاح
تم تعديل الفحص ليعتمد على:

```powershell
$env:OS -eq "Windows_NT"
```

ومعلومات النظام من:

```powershell
[System.Environment]::OSVersion.Platform
```

وبذلك يعمل السكربت على Windows PowerShell وPowerShell 7+.

## أمر التشغيل
من جذر المشروع:

```powershell
cd C:\Users\DELL\StudioProjects\sleep_quality
powershell -ExecutionPolicy Bypass -File scripts/build_release_windows.ps1
```
