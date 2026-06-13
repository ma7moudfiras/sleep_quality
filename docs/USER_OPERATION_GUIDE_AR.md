# دليل تشغيل النظام

**اسم المشروع:** Sleep Quality Analyzer and Daily Energy Predictor  
**الغرض:** تسجيل بيانات النوم اليومية، تحليل أنماط النوم، التنبؤ بمستوى طاقة اليوم التالي، وتقديم مؤشرات ونصائح شخصية مبنية على البيانات.

---

## 1. مكونات النظام

النظام مكوّن من جزأين رئيسيين:

| الجزء | التقنية | الوظيفة |
|---|---|---|
| Frontend | Flutter Web / Android / Windows | واجهة المستخدم لإدخال البيانات، عرض التنبؤات، الرسوم، والتحليلات |
| Backend | Python + FastAPI | حفظ البيانات، تشغيل نموذج التعلم الآلي، وإرجاع النتائج عبر API |
| Database | SQLite | تخزين سجلات النوم والتغذية الراجعة |
| ML Model | scikit-learn Random Forest | توقع مستوى الطاقة: Low / Medium / High |

---

## 2. متطلبات التشغيل المحلية

قبل التشغيل تأكد من توفر التالي:

- Flutter SDK.
- Android Studio أو VS Code.
- Python 3.12 مفضل، لأن المشروع يستخدم pandas و scikit-learn.
- PowerShell على Windows.
- متصفح Chrome للتشغيل السريع.

> ملاحظة: تم اعتماد المنفذ `8010` افتراضيًا لأن المنفذ `8000` قد يكون محجوزًا على بعض أجهزة Windows.

---

## 3. تشغيل Backend

افتح PowerShell وانتقل إلى مجلد backend:

```powershell
cd C:\Users\DELL\StudioProjects\sleep_quality\backend
```

فعّل البيئة الافتراضية:

```powershell
.\.venv\Scripts\Activate.ps1
```

إذا لم تكن البيئة موجودة بعد:

```powershell
py -3.12 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
```

شغّل الخادم:

```powershell
uvicorn app.main:app --reload --host 127.0.0.1 --port 8010
```

بعد التشغيل افتح:

```text
http://127.0.0.1:8010/docs
```

لواجهة Swagger، أو:

```text
http://127.0.0.1:8010/app
```

لواجهة Backend المبسطة.

---

## 4. تشغيل Frontend على Chrome

افتح PowerShell جديد واترك نافذة Backend تعمل.

```powershell
cd C:\Users\DELL\StudioProjects\sleep_quality\frontend
flutter clean
flutter pub get
flutter analyze
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8010
```

إذا ظهرت الواجهة في Chrome، فالنظام يعمل محليًا.

---

## 5. تشغيل Frontend على Android Emulator

يجب أن يكون Backend يعمل على جهاز الكمبيوتر، ثم شغّل Flutter باستخدام عنوان المحاكي:

```powershell
cd C:\Users\DELL\StudioProjects\sleep_quality\frontend
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8010
```

استخدم `10.0.2.2` بدل `127.0.0.1` لأن المحاكي يعتبر `127.0.0.1` عنوانًا داخليًا له وليس لجهاز الكمبيوتر.

---

## 6. طريقة استخدام النظام من الواجهة

### 6.1 تسجيل بيانات النوم

افتح تبويب:

```text
Log
```

أدخل:

- تاريخ السجل.
- عدد ساعات النوم.
- وقت النوم.
- وقت الاستيقاظ.
- المزاج من 1 إلى 5.
- مستوى النشاط من 1 إلى 5.

ثم اضغط حفظ.

> النظام يمنع تكرار سجل لنفس التاريخ، لأن التصميم يعتمد سجل نوم واحد لكل يوم.

---

### 6.2 عرض التوقع

افتح تبويب:

```text
Predict
```

ستظهر النتيجة بصيغة:

```text
Low / Medium / High
```

مع:

- نسبة الثقة.
- نصيحة شخصية.
- شرح للأسباب التي أثرت على التوقع.
- حالة النموذج.

---

### 6.3 إدخال النتيجة الفعلية للطاقة

افتح تبويب:

```text
History
```

لكل سجل يمكنك اختيار:

```text
Low / Medium / High
```

وهذا يمثل مستوى الطاقة الحقيقي الذي شعرت به بعد ذلك اليوم. بعد الحفظ يستطيع النظام إعادة تدريب النموذج حتى يتعلم من بياناتك.

---

### 6.4 إعادة تدريب النموذج

يمكن إعادة التدريب من:

- زر Retrain داخل واجهة Flutter.
- أو من Swagger عبر:

```http
POST /retrain
```

كلما زادت السجلات المصنفة بـ `actual_energy_level` أصبح التوقع أكثر تخصيصًا.

---

### 6.5 عرض التحليلات

افتح تبويب:

```text
Insights
```

ستجد:

- Sleep Consistency Score.
- Sleep Debt.
- Weekly Report.
- Streaks.
- Model Personalization Level.
- توصية ذكية مبنية على البيانات.

---

### 6.6 عرض الرسوم البيانية

افتح تبويب:

```text
Charts
```

يعرض النظام:

- Sleep Trend.
- Energy Trend.
- Mood Trend.
- Activity Trend.

---

### 6.7 تجربة السيناريوهات الافتراضية

افتح تبويب:

```text
What-if
```

جرّب تغيير ساعات النوم أو وقت النوم أو النشاط وشاهد كيف يتغير توقع الطاقة.

مثال:

```text
Current prediction: Medium
If sleep_hours = 8: High
```

---

### 6.8 حالة النظام

افتح تبويب:

```text
System Status
```

يعرض:

- حالة اتصال Backend.
- حالة قاعدة البيانات.
- حالة ملف النموذج.
- عدد السجلات.
- مستوى تخصيص النموذج.

---

### 6.9 معلومات المشروع

افتح تبويب:

```text
About
```

يعرض وصف المشروع والتقنيات والخصائص الرئيسية.

---

## 7. اختبار النظام من Swagger

افتح:

```text
http://127.0.0.1:8010/docs
```

### 7.1 إضافة سجل

استخدم:

```http
POST /log
```

مثال:

```json
{
  "log_date": "2026-06-11",
  "sleep_hours": 7.5,
  "bedtime_hour": 23,
  "wake_hour": 6.5,
  "mood": 4,
  "activity_level": 3,
  "actual_energy_level": "High"
}
```

### 7.2 عرض السجلات

```http
GET /logs
```

### 7.3 التنبؤ

```http
GET /predict
```

### 7.4 تحديث التغذية الراجعة

```http
PATCH /logs/{log_id}/feedback
```

مثال:

```json
{
  "actual_energy_level": "Medium",
  "auto_retrain": true
}
```

### 7.5 إعادة التدريب

```http
POST /retrain
```

### 7.6 التحليلات

```http
GET /insights
GET /weekly-report
POST /what-if
GET /system-status
```

---

## 8. مشاكل متوقعة وحلولها

| المشكلة | السبب | الحل |
|---|---|---|
| `Python was not found` | Python غير مضاف إلى PATH | استخدم `py` أو ثبت Python 3.12 وفعل Add to PATH |
| فشل تثبيت scikit-learn | استخدام Python 3.14 | استخدم Python 3.12 |
| `WinError 10013` | المنفذ محجوز أو ممنوع | استخدم port 8010 أو 8080 |
| Flutter لا يتصل بالـ API | رابط API خاطئ | Chrome يستخدم `127.0.0.1`، والمحاكي يستخدم `10.0.2.2` |
| `409 Conflict` عند POST /log | يوجد سجل بنفس التاريخ | غيّر التاريخ أو حدّث السجل الموجود |
| `flutter analyze` يعرض info فقط | تحذيرات غير مانعة | يمكن التشغيل طالما لا توجد error |

---

## 9. تجهيز APK Android

يفضل رفع Backend على Render أولًا، ثم بناء APK برابط Backend:

```powershell
cd C:\Users\DELL\StudioProjects\sleep_quality\frontend
flutter build apk --release --dart-define=API_BASE_URL=https://YOUR-BACKEND.onrender.com
```

الناتج:

```text
frontend\build\app\outputs\flutter-apk\app-release.apk
```

---

## 10. تجهيز Windows EXE

### 10.1 بناء Flutter Windows

```powershell
cd C:\Users\DELL\StudioProjects\sleep_quality\frontend
flutter build windows --release --dart-define=API_BASE_URL=http://127.0.0.1:8010
```

الناتج:

```text
frontend\build\windows\x64\runner\Release
```

### 10.2 بناء Backend EXE

```powershell
cd C:\Users\DELL\StudioProjects\sleep_quality\backend
.\.venv\Scripts\Activate.ps1
pip install -r requirements-dev.txt
pyinstaller sleep_quality_backend.spec
```

الناتج:

```text
backend\dist\sleep_quality_backend
```

### 10.3 تشغيل الاثنين معًا

استخدم ملف:

```text
release\Start_Sleep_Quality_App.bat
```

---

## 11. ملاحظات مهمة

- النظام ليس أداة طبية ولا يعطي تشخيصًا صحيًا.
- التنبؤات تعليمية وتحليلية مبنية على البيانات المدخلة.
- جودة التوقع تتحسن مع كثرة السجلات وإضافة `actual_energy_level`.
- يفضل إدخال بيانات عدة أيام للحصول على تحليلات أكثر معنى.
