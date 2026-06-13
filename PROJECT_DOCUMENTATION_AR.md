# ملفات التوثيق العربية للمشروع

تمت إضافة ملفات توثيق عربية إلى المشروع لتسهيل التشغيل والعرض والتسليم.

## الملفات

| الملف | المحتوى |
|---|---|
| `docs/USER_OPERATION_GUIDE_AR.md` | دليل تشغيل النظام خطوة بخطوة |
| `docs/PROGRAM_FEATURES_AR.md` | مميزات البرنامج ووظائفه |

## روابط التشغيل الأساسية

بعد تشغيل Backend على المنفذ `8010`:

```text
Swagger: http://127.0.0.1:8010/docs
Backend UI: http://127.0.0.1:8010/app
System Status: http://127.0.0.1:8010/system-status
```

## أوامر التشغيل المختصرة

Backend:

```powershell
cd backend
.\.venv\Scripts\Activate.ps1
uvicorn app.main:app --reload --host 127.0.0.1 --port 8010
```

Frontend Web:

```powershell
cd frontend
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8010
```
