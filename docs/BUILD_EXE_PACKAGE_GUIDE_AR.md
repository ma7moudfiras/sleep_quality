# دليل بناء ملف Windows EXE

هذا الدليل يشرح طريقة تحويل مشروع **Sleep Quality Analyzer and Daily Energy Predictor** إلى حزمة تشغيل Windows محلية.

## 1. المتطلبات

قبل البناء تأكد من وجود:

- Windows 10/11.
- Flutter SDK مفعّل و `flutter doctor` بدون أخطاء.
- Visual Studio Desktop Development for C++ لتجميع Flutter Windows.
- Python 3.12.
- PowerShell.

> لا تستخدم Python 3.14 لهذا المشروع لأن بعض مكتبات ML مثل `scikit-learn==1.6.1` قد تفشل في التثبيت.

## 2. أمر البناء

من جذر المشروع:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/build_release_windows.ps1
```

## 3. مخرجات البناء

بعد النجاح ستجد:

```text
release_package/
├── backend/
│   ├── sleep_quality_backend.exe
│   └── data/
├── frontend/
│   └── ملف Flutter exe
├── docs/
├── Start_Sleep_Quality_App.bat
└── RUN_ME_FIRST.txt
```

وسيتم إنشاء ملف مضغوط:

```text
SleepQuality_Windows_Release.zip
```

## 4. التشغيل

افتح:

```text
release_package/Start_Sleep_Quality_App.bat
```

سيقوم الملف بـ:

1. تشغيل Backend على المنفذ `8010`.
2. انتظار جاهزية `/health`.
3. تشغيل تطبيق Flutter Windows.

إذا لم يفتح تطبيق Flutter، يمكن استخدام الواجهة الاحتياطية:

```text
http://127.0.0.1:8010/app
```

## 5. ملاحظات مهمة

- لا تحذف مجلد `backend/data` لأنه يحتوي قاعدة SQLite وملف نموذج ML.
- إذا كان المنفذ `8010` مشغولًا، أغلق البرنامج الآخر أو عدّل المنفذ في `Start_Sleep_Quality_App.bat` وملف بناء Flutter.
- عند نقل البرنامج لجهاز آخر، انقل مجلد `release_package` كاملًا أو استخدم ملف `SleepQuality_Windows_Release.zip`.
