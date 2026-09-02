# قرآني v1 — Package 0 Technical Baseline & Risk Spikes

## حالة الحزمة

- **الحزمة:** Package 0 — Technical Baseline & Risk Spikes
- **حالة الحزمة:** مفتوحة
- **الـSpike الحالي المكتمل:** P0-03 — Keystore + PIN
- **تاريخ اعتماد P0-01:** 2026-08-30
**تاريخ اعتماد P0-02:** 2026-08-30
**تاريخ اعتماد P0-03:** 2026-08-31
- **جهة الاعتماد:** صاحب المشروع

---

## P0-01 — Android Baseline

### الحالة

**PASS — معتمد ومغلق**

### الهدف

إثبات وجود مجموعة إصدارات متوافقة لـFlutter وDart وJava وGradle وAGP وAndroid SDK وminSdk، مع القدرة على بناء Debug APK وتثبيته وتشغيله على هاتف Android حقيقي.

### هوية تطبيق Android

- **Project name:** `qurani`
- **Application ID:** `com.amjadjihad.qurani`
- **Namespace:** `com.amjadjihad.qurani`

### الجهاز الحقيقي

- **الجهاز:** E11
- **نوع الجهاز:** هاتف حقيقي، وليس Emulator
- **النظام:** Android 12
- **API Level:** 31
- **المعمارية:** android-arm64

### إصدارات البيئة المثبتة

| المكوّن | الإصدار أو القيمة |
|---|---|
| نظام التطوير | Windows 10 Pro 64-bit، 22H2 |
| Flutter | 3.44.6 stable |
| Flutter framework revision | `ee80f08bbf97172ec030b8751ceab557177a34a6` |
| Flutter engine revision | `83675ed27633283e7fc296c8bca22e841224c096` |
| Dart | 3.12.2 stable |
| DevTools | 2.57.0 |
| Java Runtime | OpenJDK 21.0.10 |
| Gradle | 9.1.0 |
| Android Gradle Plugin | 9.0.1 |
| Kotlin Android Plugin | 2.3.20 |
| Java source/target compatibility | 17 |
| Kotlin JVM target | 17 |
| Android SDK toolchain | 36.0.0 |
| Installed Android platform | android-37.0 |
| Android build-tools | 36.0.0 |
| compileSdk | 36 |
| targetSdk | 36 |
| minSdk | 24 |
| NDK | 28.2.13676358 |

> ملاحظة: إصدار Kotlin 2.2.0 الظاهر داخل `gradlew --version` هو Kotlin المضمّن في Gradle، بينما إصدار Kotlin Android Plugin المستخدم لبناء المشروع هو 2.3.20.

### خطوات الإثبات المنفذة

1. التحقق من Git وFlutter وDart وJava وAndroid SDK.
2. تهيئة مستودع Git محلي على الفرع `main`.
3. إنشاء مشروع Flutter مخصص لـAndroid.
4. تثبيت Application ID الدائم: `com.amjadjihad.qurani`.
5. تنفيذ `flutter pub get`.
6. تنفيذ فحص التنسيق.
7. تنفيذ `flutter analyze`.
8. تنفيذ اختبارات Flutter.
9. بناء Debug APK.
10. توصيل هاتف E11 الحقيقي.
11. تثبيت Debug APK على الهاتف.
12. تشغيل التطبيق على الهاتف.
13. الضغط على زر الإضافة والتأكد من تغير العداد من 0 إلى 1.
14. تدقيق ملفات إعداد Android والإصدارات الناتجة فعليًا.

### النتائج

| الاختبار | النتيجة |
|---|---|
| Dependency resolution | PASS |
| Format check | PASS |
| Flutter analyze | PASS |
| Flutter tests | PASS |
| Debug APK build | PASS |
| APK installation on E11 | PASS |
| Application launch on E11 | PASS |
| Counter changed from 0 to 1 | PASS |
| Baseline configuration audit | PASS |

### دليل Debug APK

- **المسار:** `build/app/outputs/flutter-apk/app-debug.apk`
- **الحجم:** 146,210,246 بايت
- **SHA-256:** `BF4B4D370E538E432EE04CA73E2F686801EB3CDDF1EF44C0732650EF036A6B5D`

### المشكلات التي ظهرت أثناء الإثبات

لم يظهر مانع تقني في Android Baseline.

ظهر فشل توثيقي كاذب في أول Transcript لاختبار الهاتف، لأن التأكيد البصري لم يُدخل داخل الطرفية. كان تثبيت التطبيق وتشغيله ناجحين، ثم أكد صاحب المشروع مباشرة أن التطبيق فتح على هاتف E11 وأن العداد أصبح 1.

كما ظهر خطأ في نسخة أولى من أمر تدقيق المسارات أدى إلى محاولة قراءة المسار `a`. كان الخطأ في أمر التدقيق، وليس في مشروع قرآني، وصُحح الأمر ثم انتهى التدقيق بالعلامة:

`QURANI_P0_01_BASELINE_AUDIT_PART2_OK`

### الأدلة

- نجاح إنشاء Debug APK.
- العلامة: `QURANI_P0_01_DEBUG_APK_OK`.
- وجود ملف APK وحسابه ببصمة SHA-256.
- نجاح اكتشاف هاتف E11 كجهاز Android حقيقي ومدعوم.
- نجاح التثبيت والتشغيل ووجود عملية التطبيق.
- تأكيد صاحب المشروع بصريًا تغير العداد إلى 1.
- نجاح تدقيق إعدادات Gradle وAGP وSDK وminSdk.
- سجل Bootstrap: `C:\devl\qurani_p0_01_bootstrap_20260830_182403.log`.

### القرار النهائي

اعتمد صاحب المشروع نتيجة P0-01 بتاريخ 2026-08-30.

تم تثبيت Android Baseline بالقيم المسجلة أعلاه، ويُغلق P0-01 بحالة **PASS**.

لا يعني إغلاق P0-01 إغلاق Package 0. تبقى Package 0 مفتوحة حتى استكمال P0-02 إلى P0-07 وبقية أدلة وبوابة إغلاق الحزمة.

لا يُنشأ Commit أو Tag في هذه النقطة؛ وفق الخطة المعتمدة يكون Commit:

`chore(package0): establish qurani technical baseline`

والـTag:

`package-0-approved`

عند إغلاق Package 0 كاملة فقط.

---

## P0-02 — Encrypted SQLite

### الحالة

**PASS — معتمد ومغلق**

### تاريخ الاعتماد

**2026-08-30**

### جهة الاعتماد

**صاحب المشروع**

### الهدف

إثبات أن Drift يعمل فعليًا مع قاعدة SQLite مشفرة بواسطة SQLite3MultipleCiphers على Android حقيقي قبل بناء قاعدة بيانات Production التي ستعتمد عليها ميزات قرآني.

يشمل معيار الإثبات:

1. توفر SQLite3MultipleCiphers فعليًا داخل Runtime على Android.
2. اختيار ChaCha20 صراحة.
3. كتابة بيانات تجريبية وقراءتها عبر Drift.
4. إغلاق القاعدة وإعادة فتحها بالمفتاح الصحيح.
5. إثبات فشل الوصول عند استخدام مفتاح خاطئ عبر استعلام حقيقي.
6. فحص ملف قاعدة البيانات والتأكد من عدم ظهور النص التجريبي بصورته الخام.
7. تنفيذ الإثبات على هاتف Android حقيقي.

### التقنية والإصدارات المثبتة

| المكوّن | الإصدار / الإعداد |
|---|---|
| Drift | 2.34.3 |
| sqlite3 | 3.5.2 |
| path_provider | 2.1.6 |
| drift_dev | 2.34.5 |
| build_runner | 2.15.1 |
| integration_test | Flutter SDK |
| SQLite native source | sqlite3mc |
| Cipher | ChaCha20 |
| قاعدة الاختبار | Drift + NativeDatabase.createInBackground |
| نوع المفتاح في Spike | مفتاح خام تجريبي ثابت 256-bit |
| استخدام المفتاح | P0-02 فقط، وليس مفتاح Production |

### ملاحظة عن المفتاح

المفتاح المستخدم في P0-02 مفتاح ثابت تجريبي لإثبات التشفير فقط.

لا يمثل هذا المفتاح تصميم إدارة المفاتيح النهائي، ولا يمثل PIN، ولا يعتمد عليه Production.

إدارة مفاتيح Android Keystore وعلاقة PIN بالمفاتيح تقع ضمن P0-03، وليست ضمن نطاق P0-02.

### الجهاز الحقيقي

- **الجهاز:** E11
- **الشركة المصنعة:** LT_mobile
- **النظام:** Android 12
- **API Level:** 31
- **المعمارية:** android-arm64
- **Device ID وقت الاختبار:** LTMBE111LT035683

### خطوات الإثبات المنفذة

1. تثبيت الاعتماديات المعتمدة لـP0-02.
2. التحقق من الإصدارات الفعلية داخل pubspec.lock.
3. تفعيل SQLite3MultipleCiphers بواسطة Build Hook:
   `source: sqlite3mc`.
4. نجاح flutter analyze.
5. نجاح اختبارات Flutter الحالية.
6. بناء Debug APK بنجاح مع sqlite3mc.
7. إنشاء Spike Drift مستقل عن Production.
8. توليد كود Drift بواسطة build_runner.
9. نجاح تحليل كود Spike.
10. تشغيل Integration Test على هاتف E11 الحقيقي.
11. التحقق من توفر `PRAGMA cipher`.
12. اختيار `chacha20` صراحة.
13. إنشاء قاعدة SQLite مشفرة.
14. كتابة النص التجريبي وقراءته بنجاح.
15. إغلاق قاعدة البيانات.
16. إعادة فتحها بالمفتاح الصحيح وقراءة البيانات بنجاح.
17. محاولة فتحها بمفتاح خاطئ وتنفيذ استعلام حقيقي.
18. إثبات فشل المفتاح الخاطئ بخطأ SQLite.
19. قراءة بايتات ملف القاعدة مباشرة.
20. البحث عن النص التجريبي الخام داخل الملف.
21. إثبات عدم وجود النص الخام.
22. انتهاء Integration Test بنجاح كامل.

### النص التجريبي

`QURANI_P0_02_ENCRYPTION_SENTINEL_20260830`

### نتائج الإثبات

| الاختبار | النتيجة |
|---|---|
| SQLite3MultipleCiphers available | PASS |
| PRAGMA cipher available | PASS |
| Explicit ChaCha20 selection | PASS |
| Drift encrypted write | PASS |
| Drift encrypted read | PASS |
| Correct-key reopen | PASS |
| Correct-key data recovery | PASS |
| Wrong-key real query failure | PASS |
| Plaintext sentinel absent from database bytes | PASS |
| Android real-device integration test | PASS |

### علامات الإثبات المسجلة

`P0_02_CIPHER_AVAILABLE=PASS`

`P0_02_CIPHER_SELECTED=chacha20`

`P0_02_WRITE_READ=PASS`

`P0_02_CORRECT_KEY_REOPEN=PASS`

`P0_02_WRONG_KEY_QUERY_FAILURE=PASS`

`P0_02_RAW_SENTINEL_ABSENT=PASS`

`QURANI_P0_02_ENCRYPTED_SQLITE_PROOF_OK`

`QURANI_P0_02_REAL_DEVICE_PROOF_OK`

### دليل المفتاح الخاطئ

عند استخدام المفتاح الخاطئ ظهر فشل حقيقي من SQLite أثناء محاولة الوصول إلى قاعدة البيانات:

`SqliteException(26): file is not a database`

ظهر الخطأ أثناء استعلام فعلي، وبالتالي لم يعتمد الإثبات على مجرد تنفيذ `PRAGMA key`.

### ملف قاعدة الاختبار على Android

المسار وقت الاختبار:

`/data/user/0/com.amjadjihad.qurani/files/qurani_p0_spikes/p0_02_encrypted.sqlite`

حجم الملف وقت الإثبات:

`12288 bytes`

### المشكلات التي ظهرت أثناء P0-02

#### 1. build_runner 2.16.0

ظهر أثناء فحص التوافق أن build_runner 2.16.0 غير مناسب لمجموعة الاعتماديات والبيئة المثبتة بسبب تعارض dependency resolution.

تم فحص build_runner 2.15.1 بصورة مستقلة، ونجح حل الاعتماديات دون تعديل الملفات، ثم اعتمده صاحب المشروع لـP0-02.

النسخة المستخدمة فعليًا في الإثبات:

`build_runner 2.15.1`

#### 2. Project identity guard

فشل إصدار أول من حارس هوية المشروع رغم أن:

`name: qurani`

كان صحيحًا.

أثبت التشخيص أن pubspec.yaml سليم وأن البصمات لم تتغير، وأن سبب الفشل كان Regex غير مناسب لنهايات أسطر Windows CRLF.

تم تصحيح أمر الحماية دون تغيير هوية المشروع.

#### 3. تنزيل libsqlite3mc

فشل أول Android Build أثناء تنزيل:

`libsqlite3mc.arm64.android.so`

من GitHub Release Assets بسبب:

`HttpException: Connection closed while receiving data`

لم يتم تغيير أي إصدار أو إعداد بسبب هذا الفشل.

أعيد بناء Android فقط، ونجح تنزيل الأصل وبناء APK.

#### 4. Kotlin daemon

ظهرت أثناء بعض عمليات Android Build الرسالة:

`Failed connecting to the daemon in 4 retries`

لكنها لم تمنع Gradle من إكمال البناء، ولم تمنع تثبيت التطبيق أو تنفيذ Integration Test.

انتهى البناء والاختبار بنجاح، ولذلك تسجل الملاحظة حاليًا باعتبارها غير مانعة.

إذا تحولت مستقبلًا إلى فشل فعلي متكرر، تعالج في موضعها دون تغيير Baseline استباقيًا.

### سجلات التنفيذ

- Dependency gate:
  `C:\devl\qurani_p0_02_dependency_gate_fixed_20260830_215025.log`

- SQLite3MC Android build retry:
  `C:\devl\qurani_p0_02_sqlite3mc_build_retry_20260830_220603.log`

- Spike preparation:
  `C:\devl\qurani_p0_02_spike_prepare_20260830_231111.log`

- Real-device integration proof:
  `C:\devl\qurani_p0_02_real_device_20260830_232916.log`

### القرار النهائي

اعتمد صاحب المشروع نتيجة P0-02 بتاريخ 2026-08-30.

تم إثبات أن Drift + SQLite3MultipleCiphers + ChaCha20 يعمل فعليًا على Android الحقيقي، وأن قاعدة البيانات:

- تقبل الكتابة والقراءة بالمفتاح الصحيح.
- يعاد فتحها بالمفتاح الصحيح.
- تفشل عند الوصول إليها بمفتاح خاطئ.
- لا يظهر النص التجريبي الخام داخل ملف SQLite.

وبذلك يغلق P0-02 بحالة **PASS**.

لا يعني إغلاق P0-02 إغلاق Package 0.

تبقى Package 0 مفتوحة حتى استكمال بقية Spikes وبوابة إغلاق الحزمة.

لا يتم إنشاء Commit أو Tag في هذه النقطة؛ يتم Commit وTag عند إغلاق Package 0 كاملة وفق خطة التنفيذ المعتمدة.

---

## P0-03 — Keystore + PIN

### الحالة

**PASS — معتمد ومغلق**

### تاريخ الاعتماد

**2026-08-31**

### جهة الاعتماد

**صاحب المشروع**

### الهدف

إثبات Android Keystore + key wrapping + Argon2id + Benchmark على هاتف Android حقيقي قبل بناء الأمان المحلي Production.

### التقنية المثبتة

- `cryptography 2.9.0`
- Android Keystore native bridge بواسطة Kotlin + Flutter MethodChannel
- QuraniMasterKey: AES-256 / AES-GCM / non-exportable
- DatabaseKey: random independent 256-bit
- AudioKey: random independent 256-bit
- Inner wrapping: AES-256-GCM بواسطة PinKEK
- Outer wrapping: AES-256-GCM بواسطة QuraniMasterKey داخل Android Keystore

التفصيل الكامل مثبت في:

`docs/security_key_envelope_v1.md`

### Argon2id المعتمد

- Salt: 16 bytes
- Output: 32 bytes
- Memory: 19456 KiB / 19 MiB
- Iterations: 2
- Parallelism: 1

اعتمد صاحب المشروع هذه القيم بتاريخ 2026-08-31 بعد Benchmark على هاتف E11 الحقيقي، دون تخفيض.

### الجهاز الحقيقي

- LT_mobile E11
- Android 12
- API 31
- arm64-v8a
- Device ID وقت الاختبار: LTMBE111LT035683

### Benchmark

- Run 1: 1490 ms
- Run 2: 1294 ms
- Run 3: 1414 ms
- Run 4: 1542 ms
- Run 5: 1310 ms
- Median: 1414 ms
- Minimum: 1294 ms
- Maximum: 1542 ms

### نتائج الإثبات

- Android Keystore MasterKey: PASS
- MasterKey non-exportable: PASS
- Argon2id benchmark: PASS
- DatabaseKey / AudioKey independence: PASS
- DatabaseKey two-layer round-trip: PASS
- AudioKey two-layer round-trip: PASS
- Wrong PIN authenticated failure: PASS
- Outer AES-GCM tamper failure: PASS
- Android real-device integration test: PASS

### Evidence markers

`P0_03_KEYSTORE_MASTER_KEY=PASS`

`P0_03_KEY_NON_EXPORTABLE=PASS`

`P0_03_ARGON2_BENCHMARK=PASS`

`P0_03_INDEPENDENT_RANDOM_KEYS=PASS`

`P0_03_DATABASE_KEY_ROUNDTRIP=PASS`

`P0_03_AUDIO_KEY_ROUNDTRIP=PASS`

`P0_03_WRONG_PIN_FAILURE=PASS`

`P0_03_OUTER_TAMPER_FAILURE=PASS`

`QURANI_P0_03_KEYSTORE_PIN_PROOF_OK`

### فشل PIN الخاطئ

ظهر `SecretBoxAuthenticationError`، وبذلك ثبت أن PinKEK الخاطئ لا يجتاز authenticated decryption للطبقة الداخلية.

### فشل العبث بالطبقة الخارجية

ظهر `P0_03_KEYSTORE_ERROR` بعد تعديل ciphertext الخاص بالطبقة الخارجية، وبذلك ثبت أن العبث لا يمر بصمت.

### ملاحظات غير مانعة

- فشل حارس MainActivity الأول كان بسبب CRLF/LF؛ التشخيص أثبت `NORMALIZED_MATCH=True` و`STRUCTURAL_MATCH=True`.
- تم إصلاح analyzer lint بإزالة imports غير الضرورية واستخدام `debugPrint` دون تغيير المنطق الأمني.
- ظهرت رسالة Kotlin daemon عدة مرات، لكنها لم تمنع Android build أو تشغيل الاختبار.
- فشل فحص package presence الإضافي في PowerShell حدث بعد `All tests passed!` و`INTEGRATION_TEST_EXIT_CODE=0` بسبب استدعاء `.Trim()` على قيمة فارغة؛ لا يتعلق بإثبات P0-03.

### القرار النهائي

تم اعتماد P0-03 وقيم Argon2id بتاريخ 2026-08-31.

P0-03 مغلق بحالة PASS.

Package 0 ما تزال مفتوحة.

الـSpike التالي: `P0-04 — Long Audio Recording`.

لا Commit ولا Tag حتى إغلاق Package 0 كاملة.
## P0-04 — Long Audio Recording

### الحالة

**PASS — معتمد ومغلق**

### تاريخ الاعتماد

**2026-09-01**

### جهة الاعتماد

**صاحب المشروع**

### الهدف

إغلاق مخاطر التسجيل الصوتي الطويل على Android الحقيقي قبل بناء ميزة التسجيل Production، وإثبات:

- AAC-LC بالمواصفات المعمارية المطلوبة.
- الحفظ التدريجي على أجزاء مستقلة.
- Pause / Resume.
- الاستمرار في Home / Background.
- الاستمرار مع Screen-off ثم العودة.
- التعامل مع مقاطعة هاتفية حقيقية.
- بقاء المواد المحفوظة بعد موت/إنهاء العملية وإمكانية الاستعادة.
- تسجيل ضغط فعلي لا يقل عن 90 دقيقة وإنتاج M4A صالح.

### التقنية المثبتة

- Flutter package: `record 7.1.1`
- Encoder: AAC-LC
- Bitrate target: 64 kbps
- Sample rate: 44.1 kHz
- Channels: mono
- Stream format أثناء التسجيل: ADTS AAC
- Progressive checkpoint target: 1 MiB تقريبًا
- Final container: M4A
- Foreground Service native على Android بواسطة Kotlin
- Partial WakeLock أثناء التسجيل الطويل
- Native remux/validation بواسطة Android `MediaExtractor` / `MediaMuxer`
- ملفات الجلسة تحت مساحة التطبيق الخاصة `no_backup`
- لا يوجد حد أقصى زمني ثابت للتسجيل في قرار المنتج؛ إثبات P0-04 النهائي استُهدف له 90 دقيقة كاختبار ضغط.

### حدود هذا الـSpike

P0-04 يثبت مخاطر التسجيل الطويل والحفظ التدريجي والاستعادة فقط.

ملفات AAC وM4A في هذا الـSpike ليست مدمجة بعد مع تشفير AudioKey / AES-256-GCM المعتمد في المرحلة الخامسة.

لا يجوز اعتبار P0-04 دليلًا على تشفير ملفات الصوت Production.

تكامل تشفير الصوت Production يبقى ضمن الحزمة اللاحقة الخاصة بالأمان/الصوت حسب خطة التنفيذ.

### الجهاز الحقيقي

- LT_mobile E11
- Android 12
- API 31
- arm64-v8a
- ADB ظهر أثناء الاختبارات أحيانًا بالـserial `LTMBE111LT035683` وأحيانًا بدون serial ثابت.
- لذلك أثبتت الاختبارات أن الاستهداف الآمن على هذا الجهاز يجب أن يحل E11 ديناميكيًا بواسطة `model:E11` و`product:LT_mobile_E11` ثم يستخدم `transport_id` الحالي بدل الاعتماد على serial ثابت.

### Smoke proof على الجهاز الحقيقي

ثبتت رحلة التسجيل الأساسية:

- AAC-LC stream supported: PASS
- بدء التسجيل: PASS
- Progressive checkpoint: PASS
- Pause seal: PASS
- Resume إلى جزء جديد: PASS
- Final M4A validation: PASS
- MIME: `audio/mp4a-latm`
- Sample rate: 44100 Hz
- Channels: 1
- أحد الإثباتات النهائية القصيرة أعطى مدة تقارب 165.7 ثانية وثلاثة أجزاء.

Evidence marker:

`QURANI_P0_04_AUDIO_SMOKE_PROOF_OK`

### Home / Background / Screen-off

أثبت E11 بقاء نفس عملية التطبيق وForeground Service أثناء النقل إلى Home وإطفاء الشاشة الحقيقي.

تم اعتماد `dumpsys display` وحالة `mState=OFF` كدليل الشاشة، بعد إثبات أن `mWakefulness` وحده ليس مؤشرًا صالحًا على هذا الجهاز.

أثبتت بوابة الشاشة السابقة:

- Home / Background: PASS
- Screen-off فعلي: PASS
- Foreground Service survival: PASS
- العودة بعد إيقاظ الشاشة: PASS
- Final M4A صالح بعد الاختبار: PASS

Evidence marker:

`QURANI_P0_04_BACKGROUND_SCREEN_OFF_PROOF_OK`

### موت العملية والاستعادة

تم تسجيل جلسة حقيقية مع checkpoint محفوظ وmanifest غير مكتمل، ثم إنهاء العملية مع بقاء بيانات التطبيق.

بعد إعادة التشغيل بقيت:

- session pointer
- incomplete manifest
- sealed AAC parts

ثم نجح Recovery إلى M4A صالح.

إثبات الاستعادة:

- Recovered bytes: 1,219,312
- MIME: `audio/mp4a-latm`
- Sample rate: 44100 Hz
- Channels: 1
- Duration: 148,700,900 us
- Recovered part count: 2

كما أثبت external SIGTERM capability أن العملية يمكن إنهاؤها خارجيًا مع بقاء الحزمة وملف دليل الاستعادة.

Evidence markers:

`QURANI_P0_04_CRASH_RECOVERY_STANDALONE_PROOF_OK`

`QURANI_P0_04_PROCESS_DEATH_RECOVERY_PROOF_OK`

`P0_04_EXTERNAL_SIGTERM_PROCESS_DEATH_CAPABILITY=PASS`

### مقاطعة مكالمة هاتفية حقيقية

أثبت Probe أولي على `record 7.1.1` أن المكالمة الهاتفية الحقيقية على E11 تنتج:

`record -> pause -> record -> stop`

وثبت:

- system pause: PASS
- `isPaused()`: true قبل الاستئناف اليدوي
- manual `resume()`: PASS
- عودة حالة record: PASS
- عودة تدفق AAC بعد الاستئناف: PASS

كشف هذا الاختبار أن طبقة P0-04 الأصلية كانت تحتفظ بـ`_paused` محليًا دون مزامنة System Pause القادمة من `AudioRecorder`.

تم إصلاح ذلك بإضافة مزامنة حالة `AudioRecorder.onStateChanged()` مع حالة P0-04، وتسلسل انتقالات الحالة/الملفات حتى لا يحدث race بين الكتابة وإغلاق الجزء.

Core hash بعد الإصلاح:

`A67FF7C2FA47AA7E9B6DCD0F1D0B48A8643BA04C071CE8952E7311E307F4E99D`

ثم أعيد اختبار مكالمة حقيقية على `P004LongAudioSpike` نفسه، وثبت:

- `PAUSED_BEFORE_CORE_RESUME=true`
- sealed parts before resume: 1
- `CORE_RESUME_RETURNED=PASS`
- `PAUSED_AFTER_CORE_RESUME=false`
- part count after resume window: 2
- final sealed parts: 2
- final MIME: `audio/mp4a-latm`
- final sample rate: 44100 Hz
- final channels: 1
- final duration: 41,006,500 us

Evidence markers:

`QURANI_P0_04_REAL_PHONE_CALL_CORE_GATE_OK`

`P0_04_INTERRUPTION_SUB_GATE=PASS`

### اختبار الضغط 90 دقيقة

اختبار الضغط النهائي عمل على E11 الحقيقي ووصل إلى الدقيقة 91 مع ثبات نفس PID وظهور Foreground Service في المراقبة حتى الدقيقة 91.

ثبت أثناء الرحلة:

- Initial PID: 15627
- Home / Background: PASS
- Screen-off interval: 5402 seconds
- Pause / Resume cycle #1 قرب الدقيقة 30: PASS
- Pause / Resume cycle #2 قرب الدقيقة 60: PASS
- تقدم محفوظ عند الدقيقة 91:
  - parts: 45
  - sealedParts: 44
  - modeledBytes: 45,191,301
  - pause1Pass: true
  - pause2Pass: true
- بعد دخول finalization أصبحت الجلسة تحتوي 46 جزء AAC مختومًا.

### Race في Harness النهائي وكيف أُغلق

ظهر فشل ظاهري في مراقب PowerShell بعد الدقيقة 91:

`P004AudioForegroundService disappeared during the stress run.`

لم يكن هذا سقوطًا أثناء التسجيل.

السبب أن `P004LongAudioSpike.stopAndFinalize()` يوقف Foreground Service قبل اكتمال native remux وكتابة manifest بالحالة `completed`، بينما Harness الخارجي كان يعتبر اختفاء الخدمة فشلًا حتى لحظة ظهور `proof.txt`.

نتيجة ذلك أن Harness الخارجي عمل force-stop خلال finalization وترك:

- `final.combined.aac`: 45,685,205 bytes
- `final.m4a`: ملف جزئي 11,553,153 bytes
- manifest status: `finalizing`
- 46 ملف `part_XXXX.aac` جميعها sealed

تم رفض إعادة تسجيل 90 دقيقة لأن بيانات التسجيل الأصلية كانت كاملة ومحفوظة.

### Recovery النهائي لنفس جلسة الـ90 دقيقة

تمت الاستعادة من **46 ملف `part_XXXX.aac` فقط**.

تم استبعاد `final.combined.aac` عمدًا من مدخلات Recovery حتى لا يتكرر التسجيل، وتم الحفاظ على `final.m4a` الجزئي القديم كدليل دون الكتابة فوقه.

نتائج المصدر:

- Source part count: 46
- Source AAC bytes: 45,685,205
- Source AAC frames: 237,006
- Source duration from ADTS frames: 5,503,268,571 us
- جميع الأجزاء Frame-valid: PASS

نتائج M4A المستعاد:

- File: `recovered_90m_final.m4a`
- Bytes: 44,978,092
- MIME: `audio/mp4a-latm`
- Sample rate: 44100 Hz
- Channels: 1
- Remux duration: 5,503,279,300 us
- Independent validation duration: 5,503,279,300 us

المدة النهائية الصالحة تقارب 91 دقيقة و43 ثانية، وتتجاوز شرط إثبات 90 دقيقة.

Evidence markers:

`P0_04_90M_RUNTIME_REACHED_91_MINUTES=PASS`

`P0_04_90M_PID_STABLE_THROUGH_91_MINUTES=PASS`

`P0_04_90M_FGS_PRESENT_THROUGH_91_MINUTES=PASS`

`P0_04_90M_SCREEN_OFF_5402_SECONDS=PASS`

`P0_04_90M_46_SEALED_PARTS_SURVIVED=PASS`

`P0_04_90M_45685205_AAC_BYTES_SURVIVED=PASS`

`P0_04_90M_ONLY_PART_FILES_USED=PASS`

`P0_04_90M_ALL_46_PARTS_FRAME_VALID=PASS`

`P0_04_90M_SOURCE_DURATION_AT_LEAST_90_MIN=PASS`

`P0_04_90M_RECOVERED_FINAL_M4A_VALID=PASS`

`QURANI_P0_04_90M_RECOVERY_PROOF_OK`

`QURANI_P0_04_90_MINUTE_STRESS_PROOF_OK`

`P0_04_90_MINUTE_STRESS_GATE=PASS`

### ملاحظات تشخيصية غير مانعة

- `flutter test` ليس مناسبًا لإثبات بقاء private app data بعد قتل تطبيق الاختبار؛ دورة حياة runner قد تزيل test package بعد موت العملية.
- `adb shell am crash` على E11 / API 31 أعاد exit code ناجحًا لكنه لم ينه PID، لذلك لم يُستخدم كدليل crash.
- `run-as ... kill -9` غير متاح لهذا السياق على Android 12 / SELinux، بينما SIGTERM الخارجي نجح.
- فشل sentinel preflight سابقًا كان بسبب shell redirection quoting وليس بسبب صلاحيات `run-as`.
- تغير/اختفاء ADB serial و`transport_id` أثناء الجلسات مشكلة استهداف tooling وليست فشلًا في التطبيق؛ تم اعتماد dynamic transport resolution في أدوات الاختبار.
- فشل أول محاولة 90 دقيقة قبل التسجيل كان `ForegroundServiceStartNotAllowedException` بسبب launch context غير المرئي على Android 12؛ أُعيد الإطلاق من حالة Awake/Unlocked/User-visible قبل بدء Foreground Service.
- فشل الـ90 دقيقة عند finalization كان Harness race كما هو موثق أعلاه؛ التسجيل نفسه وصل إلى ما بعد 90 دقيقة، وبقيت كل أجزائه قابلة للتحقق والاستعادة.

### ملفات التنفيذ والإثبات

- `lib/p0_spikes/p0_04_long_audio_spike.dart`
- `android/app/src/main/kotlin/com/amjadjihad/qurani/P004AudioBridge.kt`
- `android/app/src/main/kotlin/com/amjadjihad/qurani/P004AudioForegroundService.kt`
- `test/p0_04_adts_tools_test.dart`
- `integration_test/p0_04_audio_smoke_test.dart`
- `integration_test/p0_04_audio_crash_phase1_test.dart`
- `integration_test/p0_04_audio_crash_recovery_test.dart`
- `lib/p0_spikes/p0_04_crash_recovery_harness.dart`

### Hashes وقت الإغلاق

- `lib/p0_spikes/p0_04_long_audio_spike.dart`: `A67FF7C2FA47AA7E9B6DCD0F1D0B48A8643BA04C071CE8952E7311E307F4E99D`
- `android/app/src/main/kotlin/com/amjadjihad/qurani/P004AudioBridge.kt`: `E3FA586618D2529EBE8BB952A88F32D9D60EFC0645460BC9EA4D7BF7A3A8757B`
- `android/app/src/main/kotlin/com/amjadjihad/qurani/P004AudioForegroundService.kt`: `D38FEE853D50661669715B6582D6B5C0C6C5321991B324EDE2594345BF4C7F1D`
- `test/p0_04_adts_tools_test.dart`: `511E5D26D32D6806DD269DE2E16DF84AC8B2FCE0F763660738BE45FEECF0AAB8`
- `integration_test/p0_04_audio_smoke_test.dart`: `AD337D035855286C289DDD95405F9D571D92F5B25437E5CF94B26F7A11F7B314`
- `integration_test/p0_04_audio_crash_phase1_test.dart`: `9F8FFCD1A5179773EEC751D2CB42E75586CDDDB06895D3780E0989DECF268A3E`
- `integration_test/p0_04_audio_crash_recovery_test.dart`: `8CA99D815277A1B85C0E7C4A71D33A64A0CFDC37E1DDB031AEE43C8C498AF5A1`
- `lib/p0_spikes/p0_04_crash_recovery_harness.dart`: `9A9C8EC9F16E9B837456DF717FDDB74B8B6EBF44B72D58C3A55ECB0BD0A67A46`

### نتائج التحقق النهائي

- Flutter static analysis: PASS
- Flutter unit/widget tests: PASS
- AAC-LC / progressive save: PASS
- Pause / Resume: PASS
- Home / Background: PASS
- Screen-off / Return: PASS
- Real phone-call interruption: PASS
- Process-death saved-material recovery: PASS
- 90-minute stress: PASS
- Final M4A validity: PASS

### القرار النهائي

تم اعتماد P0-04 بتاريخ 2026-09-01.

P0-04 مغلق بحالة PASS.

لا يوجد تسجيل صوتي طويل آخر مطلوب لإغلاق P0-04.

Package 0 ما تزال مفتوحة.

الـSpike التالي: `P0-05 — Real Excel/PDF`.

لا Commit ولا Tag حتى إغلاق Package 0 كاملة.
## P0-05 — Real Excel/PDF

### الحالة

**PASS — معتمد ومغلق**

### تاريخ الاعتماد

**2026-09-01**

### جهة الاعتماد

**صاحب المشروع**

### الهدف

إغلاق مخاطر إنشاء ملفات Excel وPDF عربية حقيقية، وإعادة فتحها والتحقق منها برمجيًا، ثم فتحها فعليًا على هاتف Android حقيقي بتطبيقات خارجية مناسبة، قبل بناء تقارير المنتج Production.

### نطاق الـSpike

P0-05 يثبت تقنية التوليد والفتح والتحقق فقط.

لا يمثل هذا القسم تنفيذ Package 8 للتقارير الأسبوعية والشهرية، ولا يعتمد قالب التقرير النهائي أو منطق Snapshot أو كل حقول تقارير المنتج.

Excel يبقى الملف التشغيلي الأساسي، وPDF ملفًا إضافيًا حسب قرارات المراحل المعتمدة.

### المكتبات المثبتة

Dependencies:

- `excel_plus 2.15.0`
- `pdf 3.13.0`

Dev dependencies للتحقق:

- `dart_pdf_reader 2.2.0`
- `archive 4.0.9`

### خط PDF العربي

تم استخدام Amiri 1.003 كخط عربي خاص بالـSpike:

- `assets/p0_spikes/p0_05/fonts/Amiri-Regular.ttf`
- `assets/p0_spikes/p0_05/fonts/Amiri-Bold.ttf`
- `assets/p0_spikes/p0_05/fonts/OFL.txt`

هذه ليست موافقة على خط واجهة المنتج النهائي؛ هي فقط مادة موثوقة لإثبات Arabic PDF.

Hashes وقت الإغلاق:

- Amiri Regular: `F810BBD1448031169F237A0DE429300BF249D67739800EDC3A8587ABAED7FFB3`
- Amiri Bold: `85681CCFC5C6138FBC20961F846477CDB8BF6CD4FB3369FA214E2A5529B25530`
- OFL: `FF94EF6D8C295D7CD2C0D911C46A00788A1A3842F12144C30DF7A185FE1F2D62`

### Isolated dependency/file probe

قبل إدخال المكتبات إلى مشروع قرآني، تم تنفيذ Probe معزول خارج `qurani_mobile`.

ثبت:

- `excel_plus 2.15.0`: PASS
- `pdf 3.13.0`: PASS
- `dart_pdf_reader 2.2.0`: PASS
- إنشاء XLSX عربي: PASS
- إعادة فتح XLSX: PASS
- Arabic values round-trip: PASS
- RTL round-trip: PASS
- raw OOXML RTL flag: PASS
- raw OOXML Arabic content: PASS
- إنشاء PDF عربي: PASS
- PDF header/EOF: PASS
- إعادة فتح PDF بParser مستقل: PASS
- PDF page tree: PASS
- مشروع قرآني بقي دون تغيير أثناء الـProbe: PASS

Evidence marker:

`QURANI_P0_05_ISOLATED_ARABIC_FILE_PROBE_OK`

### التنفيذ داخل مشروع قرآني

ملفات الـSpike:

- `lib/p0_spikes/p0_05_real_excel_pdf_spike.dart`
- `test/p0_05_real_excel_pdf_test.dart`

Hashes وقت الإغلاق:

- P0-05 source: `530C7DCA46C0C67699327865B1532A8BB4A20E726347BA30926954B35CAE7ECE`
- P0-05 test: `E427477DA8B716C5611AC65F0FC5B171D72248E26E65D69A8B18C0C8B0ECD91D`

### Excel الحقيقي داخل المشروع

تم إنشاء XLSX حقيقي يتضمن:

- Sheet عربية باسم `تقرير`
- `isRTL = true`
- عنوان `تقرير قرآني التجريبي`
- أعمدة عربية: `اسم الطالب` و`الإنجاز` و`الحضور`
- بيانات عربية فعلية
- قيمة رقمية فعلية `12.5`

ثم تم:

- كتابة XLSX كملف حقيقي على القرص: PASS
- إعادة قراءته من القرص: PASS
- إعادة فتحه بواسطة `Excel.decodeBytes`: PASS
- التحقق من اسم الورقة: PASS
- التحقق من `isRTL`: PASS
- التحقق من النصوص العربية: PASS
- التحقق من القيمة الرقمية: PASS
- فحص OOXML الخام والتأكد من `rightToLeft`: PASS
- فحص OOXML الخام والتأكد من النص العربي: PASS

Evidence markers:

`P0_05_PROJECT_XLSX_PROGRAMMATIC_REOPEN=PASS`

`P0_05_PROJECT_XLSX_ARABIC_VALUES_ROUNDTRIP=PASS`

`P0_05_PROJECT_XLSX_RTL_ROUNDTRIP=PASS`

`P0_05_PROJECT_XLSX_RAW_OOXML_RTL=PASS`

`P0_05_PROJECT_XLSX_RAW_OOXML_ARABIC=PASS`

### PDF الحقيقي داخل المشروع

تم إنشاء PDF عربي حقيقي باستخدام Amiri Regular/Bold واتجاه RTL.

ثم تم:

- كتابة PDF كملف حقيقي على القرص: PASS
- التحقق من `%PDF-`: PASS
- التحقق من `%%EOF`: PASS
- إعادة قراءته من القرص: PASS
- إعادة فتحه بواسطة `dart_pdf_reader`: PASS
- التحقق من وجود Page Tree وصفحة فعلية: PASS

Evidence markers:

`P0_05_PROJECT_PDF_PROGRAMMATIC_REOPEN=PASS`

`P0_05_PROJECT_PDF_PAGE_TREE_VALID=PASS`

`P0_05_PROJECT_PDF_ARABIC_AMIRI_BUILD=PASS`

`QURANI_P0_05_PROJECT_GENERATE_REOPEN_PROOF_OK`

### ملاحظة حول SHA256 للملفات المولدة

ملفا XLSX وPDF الناتجان عن الاختبار يمكن أن تتغير بصمتهما البايتية بين عمليتي توليد متتاليتين بسبب metadata/تفاصيل serialization داخل ZIP/PDF.

لذلك لم يتم اعتماد SHA ثابت للملف المولد كهوية منطقية دائمة.

في بوابة Android تم التقاط SHA256 للنسخة المحلية الحالية مباشرة قبل الإرسال إلى الهاتف، ثم مقارنة البصمة نفسها على E11 بعد `adb push`.

هذه هي المقارنة الصحيحة لإثبات أن الملف المفتوح على الهاتف هو نفس البايتات التي تم التحقق منها محليًا.

### الجهاز الحقيقي وAndroid staging

الجهاز:

- LT_mobile E11
- Android 12
- API 31

تم نسخ الملفات التي تم التحقق منها إلى `Download` على E11 بواسطة ADB كأداة اختبار فقط.

هذا النقل لا يمثل تنفيذ P0-06 SAF/Files.

البصمات في بوابة Android النهائية:

- XLSX local/remote SHA256:
  `49917FB107A74446473681F875826E51653F68BA648D7FFD75EA075B518F6D52`
- PDF local/remote SHA256:
  `66EAC6EF2E804C2D46AB12BF88336B44F9235D878EFF2289A50B014C886942CC`

ثبت:

`P0_05_ANDROID_STAGED_XLSX_HASH_MATCH=PASS`

`P0_05_ANDROID_STAGED_PDF_HASH_MATCH=PASS`

`P0_05_ANDROID_FILES_STAGED_WITH_IDENTICAL_HASHES=PASS`

### تطبيقات Android الفعلية

فحص Android Package Manager أثبت وجود:

Excel:

`com.microsoft.office.excel/.excelMainActivity`

PDF:

`com.google.android.apps.docs/com.google.android.apps.viewer.PdfViewerActivity`

كما ظهر Android Resolver لأن أكثر من تطبيق يدعم كل MIME.

### فتح XLSX فعليًا على E11

محاولة إطلاق `content://com.android.externalstorage.documents/...` مباشرة من ADB shell أعطت:

`java.lang.SecurityException: UID 2000 does not have permission`

هذا قيد في صلاحيات shell/URI grant، وليس فشلًا في XLSX أو Microsoft Excel.

لم تتم إضافة FileProvider أو SAF workaround داخل P0-05، لأن ذلك سيخلط نطاق P0-05 مع P0-06.

تم بدلًا من ذلك فتح نفس الملف الموجود في Downloads يدويًا من Android Files باستخدام Microsoft Excel.

أكد صاحب المشروع بصريًا:

- اسم الورقة `تقرير`: PASS
- RTL: PASS
- العنوان العربي: PASS
- الأعمدة العربية: PASS
- `أحمد محمد — 12.5 — حاضر`: PASS
- `محمد علي — 10 — غائب بعذر`: PASS
- العربية متصلة وسليمة وغير مشوهة: PASS

Evidence marker:

`P0_05_ANDROID_XLSX_REAL_APP_OPEN=PASS`

### فتح PDF فعليًا على E11

تم فتح نفس PDF الحقيقي الموجود في Downloads باستخدام تطبيق PDF فعلي على E11.

أكد صاحب المشروع بصريًا نجاح فتح الملف والعرض العربي.

Evidence marker:

`P0_05_ANDROID_PDF_REAL_APP_OPEN=PASS`

### نتائج التحقق النهائي

- Isolated dependency/file probe: PASS
- Project dependency gate: PASS
- Arabic font asset gate: PASS
- XLSX generation: PASS
- XLSX programmatic reopen: PASS
- XLSX Arabic round-trip: PASS
- XLSX RTL round-trip: PASS
- XLSX raw OOXML validation: PASS
- PDF generation: PASS
- PDF programmatic reopen: PASS
- PDF page tree validation: PASS
- E11 staged-file hash equality: PASS
- Microsoft Excel real-app open: PASS
- Android PDF real-app open: PASS
- Flutter static analysis: PASS
- Flutter unit/widget tests: PASS

### القرار النهائي

تم اعتماد P0-05 بتاريخ 2026-09-01.

P0-05 مغلق بحالة PASS.

Package 0 ما تزال مفتوحة.

الـSpike التالي: `P0-06 — SAF/Files`.

لا Commit ولا Tag حتى إغلاق Package 0 كاملة.
<!-- P0-06-CLOSURE-2026-09-02 -->
## P0-06 — SAF / Files — PASS

### الهدف
إثبات مسار Android Storage Access Framework المطلوب في المعمارية المعتمدة قبل بناء تدفقات النسخ الاحتياطي والتصدير والتقارير الإنتاجية.

### خط الأساس التنفيذي
- تم تنفيذ SAF على Android Native عبر Flutter `MethodChannel` باسم `qurani/p0_06_saf`، من دون إضافة dependency جديدة لاختيار الملفات.
- يستخدم Android `Intent.ACTION_CREATE_DOCUMENT` مع `CATEGORY_OPENABLE` واسم الملف وMIME المناسبين.
- تتم الكتابة عبر `ContentResolver.openOutputStream(...)`.
- بعد الحفظ يعاد فتح نفس URI عبر `ContentResolver.openInputStream(...)`، ثم تتم مقارنة عدد البايتات وSHA-256 قبل قبول `status=saved`.
- إلغاء المستخدم للـpicker يعاد كـ`status=cancelled` ولا يعامل كنجاح كاذب.
- لا توجد صلاحيات تخزين شاملة: لا `MANAGE_EXTERNAL_STORAGE` ولا `READ_EXTERNAL_STORAGE` ولا `WRITE_EXTERNAL_STORAGE` ولا `READ_MEDIA_*`.
- ملف `.qrb` في هذا الـSpike هو probe تقني فقط ويحمل صراحة `NOT_PRODUCTION_QRB_FORMAT`؛ وهو ليس صيغة النسخة الاحتياطية المشفرة الإنتاجية.

### التحقق الآلي
- `flutter analyze --no-pub`: PASS.
- الاختبار الموجّه `test/p0_06_saf_spike_test.dart`: PASS.
- كامل `flutter test --no-pub`: PASS.
- بناء Android debug harness: PASS.
- بقيت dependencies وManifest والملفات المعتمدة السابقة تحت حراسة SHA-256، ولم يضف P0-06 صلاحية تخزين عامة أو dependency جديدة.

### قبول الجهاز الحقيقي
- الجهاز: LT_mobile E11.
- Android: 12.
- API: 31.
- حفظ `report.xlsx` الحقيقي عبر SAF: PASS.
- حفظ probe تجريبي باسم `qurani_p0_06_probe.qrb` عبر SAF: PASS.
- معيار P0-06 المعتمد هو وجهة SAF يختارها المستخدم ضمن `Documents/Downloads`؛ وفي اختبار القبول اختار المستخدم `Downloads` للملفين، وهذا يحقق المعيار.
- `report.xlsx`: 4232 bytes، SHA-256 `6BABCB6EF01C2378F949A45FF4EF8CBF5827CFB091F56131417842A2DB788E89`.
- `qurani_p0_06_probe.qrb`: 91 bytes، SHA-256 `01BA48F5BC32B7F72E16DB75C1A14919C90805E2F908206675AFA3753D3F1E0B`.
- للملفين: native write -> `ContentResolver` reopen -> تطابق البايتات وSHA-256: PASS.
- استخدم ADB pull كأداة تحقق اختبارية فقط، وتطابق SHA-256 على الكمبيوتر مع SHA-256 الذي أثبته التطبيق عبر SAF للملفين.
- اختبار إلغاء المستخدم: PASS (`status=cancelled`)، ولم ينشأ ملف `qurani_p0_06_cancel_probe.qrb`.
- فشل استعلام DocumentsProvider مباشرة من ADB shell بسبب صلاحية UID 2000 ليس فشلًا في SAF داخل التطبيق؛ القبول يعتمد على URI الممنوح للتطبيق، وإعادة الفتح داخل التطبيق، والتحقق المستقل من الملف الناتج.

### ملفات الـSpike الثابتة
- `android/app/src/main/kotlin/com/amjadjihad/qurani/MainActivity.kt`: `331AA8C2E1B298856C68278FFADAA566E62FC298132D3B294373E612258F1199`
- `android/app/src/main/kotlin/com/amjadjihad/qurani/P006SafBridge.kt`: `55822C7836F4B85751BDF96ED1BEA05E16E6919437BDFA6A8C9A85C088B38F51`
- `lib/p0_spikes/p0_06_saf_spike.dart`: `4546BCD81F63F18E7749F0995DA718512C7A4C907D7E6387D52219A0AA9FAED7`
- `lib/p0_spikes/p0_06_saf_harness.dart`: `1D70BE34F2E81AD0D9A4C45AF2B1CD6E2F3602658C9181B8A3AA3D807BE5B86B`
- `test/p0_06_saf_spike_test.dart`: `94987347253CEA489C5208AB0159C038D2DE9EE25ACDC4810D4A3A0932B91491`

### الأدلة
- Final real-device log SHA-256: `87B0F64DC897A6086C653634D5A18EA9C52277E09881414F88F01310C2EBEA21`
- Final internal SAF proof SHA-256: `3E9AFE82BB9E2371A8288A428AD67CA0A70A928991C87D4E0F6BCAA8ADE91AA1`
- الأدلة النهائية تتضمن:
  - `P0_06_REAL_DEVICE_SAF_SAVE_GATE=PASS`
  - `P0_06_CONTENT_RESOLVER_ROUND_TRIP=PASS`
  - `P0_06_USER_CANCELLATION=PASS`
  - `P0_06_NO_BROAD_STORAGE_PERMISSION=PASS`

### القرار النهائي
تم قبول وإغلاق P0-06 رسميًا بتاريخ 2026-09-02.

P0-06 مغلق بحالة PASS.

Package 0 ما تزال مفتوحة.

الـSpike التالي: `P0-07 — External Shares`.

لا Commit ولا Tag حتى إغلاق Package 0 كاملة.

<!-- P0-07-CLOSURE-2026-09-02 -->
## P0-07 — External Sharing — PASS

### الهدف
إثبات استراتيجية المشاركة الخارجية المعتمدة على Android قبل بناء ميزات Production التي تعتمد عليها: مشاركة ملف خاص عبر `FileProvider` إلى imo، فتح WhatsApp عبر Intent، فتح SMS composer عبر Intent، التحقق من العودة إلى قرآني، ومنع كشف مساحة التطبيق الخاصة.

### البيئة والجهاز
- بيئة التنفيذ: نفس Technical Baseline المعتمد في P0-01؛ لم يغيّر P0-07 إصدارات Flutter/Dart/Java/Gradle أو dependencies.
- الجهاز الحقيقي: LT_mobile E11.
- Android: 12.
- API: 31.

### القرار التنفيذي
- Android Native bridge عبر Flutter `MethodChannel` باسم `qurani/p0_07_external_sharing`.
- لم تتم إضافة dependency جديدة للمشاركة.
- imo وWhatsApp يستخدمان Android share chooser بدل تثبيت package identifier كقرار Product دائم داخل Dart.
- SMS يستخدم `Intent.ACTION_SENDTO` مع `smsto:`، ولا توجد صلاحية `SEND_SMS`.
- تم التقاط `EXTRA_CHOSEN_COMPONENT` لإثبات التطبيق الذي اختاره المستخدم فعليًا في Spike.
- تم تتبع `onPause/onResume` لإثبات العودة إلى قرآني بعد الانتقال للتطبيق الخارجي.

### FileProvider والأمان
- authority: `com.amjadjihad.qurani.p007.fileprovider`.
- `android:exported="false"`.
- `android:grantUriPermissions="true"`.
- URI التجريبي كان `content://` وليس `file://`.
- المسار المسموح في `p0_07_file_paths.xml` هو `cache-path` محصور في `p0_07_share/` فقط.
- لا `root-path` ولا `files-path` ولا external broad path.
- grant القراءة مؤقت عبر `FLAG_GRANT_READ_URI_PERMISSION`.
- لا `READ_CONTACTS` ولا `WRITE_CONTACTS`.
- لا `MANAGE_EXTERNAL_STORAGE` ولا `READ_EXTERNAL_STORAGE` ولا `WRITE_EXTERNAL_STORAGE`.
- لا `QUERY_ALL_PACKAGES`.
- probe المشاركة حُذف بعد الاختبار، وثبت عدم بقاء `cache/p0_07_share`.

### نتائج الجهاز الحقيقي
- imo/FileProvider: PASS.
- التطبيق المختار فعليًا: `com.imo.android.imoim`.
- WhatsApp Intent: PASS.
- التطبيق المختار فعليًا: `com.whatsapp`.
- SMS composer عبر `ACTION_SENDTO + smsto:`: PASS.
- لم يتم إرسال ملف أو رسالة أو SMS فعليًا أثناء Spike.
- العودة إلى قرآني بعد imo: PASS.
- العودة إلى قرآني بعد WhatsApp: PASS.
- العودة إلى قرآني بعد SMS: PASS.
- تنظيف cache المشاركة: PASS.

### probe المشاركة
- الاسم: `p0_07_imo_probe.txt`.
- الحجم: 80 bytes.
- SHA-256: `DEF91F3D9EADBC206AA4718CF04E10E8B3F73B7618730ABC6C13474D7A9110E8`.
- المحتوى ثابت ومخصص للـSpike فقط، ويتضمن `NO_PRIVATE_SPACE_EXPOSURE`.
- هذا probe ليس ملفًا إنتاجيًا ولا تقريرًا ولا نسخة احتياطية.

### الملفات الثابتة
- `android/app/src/main/AndroidManifest.xml`: `4EDDB2D2F30AE808612507610C5F72B8CC3A036CEEB203E01961B15BEA048BF6`
- `android/app/src/main/kotlin/com/amjadjihad/qurani/MainActivity.kt`: `48D3AF3ACC1C65F25AD787CB9B7A6C040237943D0925FBA65926113BB4C6F3C4`
- `android/app/src/main/kotlin/com/amjadjihad/qurani/P007ExternalSharingBridge.kt`: `CC8CF24FCCBE389C88E29AF8CAE6966345BB2A2190251A1E3E95A2AA3B48EAB9`
- `android/app/src/main/kotlin/com/amjadjihad/qurani/P007ChooserReceiver.kt`: `8365940330CD07FDC1F8E256AB415117C1FE8E8DD3C8322DC9EE2B55617041DF`
- `android/app/src/main/res/xml/p0_07_file_paths.xml`: `D64A407C17BB968E46A01D2D69E609ADD138B79C572AA1FB67EFFDFEB85ABFA9`
- `lib/p0_spikes/p0_07_external_sharing_spike.dart`: `43A47D60D9CEC36F96952EC7EA00C60DC3A3BD3D1871DB30FC4A699F5D73B743`
- `lib/p0_spikes/p0_07_external_sharing_harness.dart`: `CC224D4BE56812B1D677072E03D8E0F5698A8FFB005DBDF077D9CE0F5EA1A09C`
- `test/p0_07_external_sharing_test.dart`: `259CBF3A89F358C85E27435FE5F350BDAFEBF067A63E15A54FE65A9074CED2CC`

### الأدلة
- Final real-device verification log SHA-256: `9E030802BA32CFE2A7A2C5AD176E82A800469886A58A0C0FF18AC947FFC247AB`
- Final internal proof SHA-256: `53AAB7DEC23738C09D18E831A81DBBF9467C0439935838D53CAAC42995AF1274`
- Successful full-suite diagnostic log SHA-256: `7210324C34FD19360DA2E24E56C769F542289FDD9CC2C59BB4255471F23841F3`
- Successful full-suite output SHA-256: `1C37A90BF10C9DABFCC1FFEF0E3951987330C1162CD127E2D2A3178B9EAF1F82`
- الأدلة النهائية تتضمن:
  - `P0_07_REAL_DEVICE_EXTERNAL_SHARING_GATE=PASS`
  - `P0_07_IMO_FILEPROVIDER_REAL_DEVICE=PASS`
  - `P0_07_WHATSAPP_REAL_DEVICE=PASS`
  - `P0_07_SMS_INTENT_REAL_DEVICE=PASS`
  - `P0_07_RETURN_TO_APP_REAL_DEVICE=PASS`
  - `P0_07_PRIVATE_SPACE_NOT_EXPOSED=PASS`
  - `P0_07_SHARE_CACHE_CLEANUP_REAL_DEVICE=PASS`
  - `FULL_TEST_EXIT_CODE=0`
  - `P0_07_FULL_SUITE_REPRODUCTION=PASS`

### المشكلات والقرارات أثناء الإثبات
- الفحص الأول للـReceiver اعتمد خطأ على `Receiver Resolver Table`؛ تم تصحيح أداة القبول فقط، لأن Receiver صريح بلا intent-filter ولا يلزم أن يظهر في ذلك الجدول.
- محاولة مقارنة probe بعد أن كان المستخدم قد نفذ Cleanup قرأت رسالة خطأ `cat` بدل الملف المحذوف؛ لم يعاد الاختبار الخارجي، بل تم التحقق من SHA-256 المسجل قبل الحذف مقابل البايتات الثابتة في المصدر، ثم التحقق مستقلًا من أن cache محذوف فعلًا.
- في أول محاولة توثيق/إغلاق ظهر `flutter test` بخروج 1 من دون تفاصيل محفوظة؛ تم rollback للوثيقة، ثم أعيد كامل الاختبار في Diagnostic مستقل بنفس SHA256 للملفات ونجح بخروج 0، مع إثبات عدم تغير أي ملف. لذلك لم يلزم تعديل الكود.

### القرار النهائي
تم قبول وإغلاق P0-07 رسميًا بتاريخ 2026-09-02.

P0-07 مغلق بحالة PASS.

بهذا اكتملت Spikes التقنية P0-01 إلى P0-07.

Package 0 لم تغلق بعد في هذه الخطوة؛ بقيت بوابة Git النهائية للحزمة: مراجعة حالة المستودع، التحقق النهائي، Commit وTag نظيفان حسب الخطة المعتمدة.

لا Commit ولا Tag داخل هذه الخطوة.

<!-- PACKAGE-0-PRE-GIT-READINESS-2026-09-02 -->
## Package 0 — Pre-Git Closure Readiness

الحالة: **TECHNICAL GATES PASS — PENDING FINAL GIT GATE**

المتحقق قبل بوابة Git النهائية:
- Android baseline: PASS.
- Encrypted DB: PASS.
- Keystore + PIN: PASS.
- Argon2id benchmark: PASS.
- Long audio: PASS.
- Excel real file: PASS.
- PDF real file: PASS.
- SAF save: PASS.
- SMS / WhatsApp / imo: PASS.
- Android real-device evidence: PASS.
- ADRs/evidence documentation: موجودة.
- `docs/security_key_envelope_v1.md`: محفوظة ضمن baseline الأمني.
- Full Flutter test suite: PASS في آخر Diagnostic مستقل مع ثبات SHA256 للملفات.

المتبقي لإغلاق Package 0 رسميًا:
1. final repository diff/status review.
2. final format/analyze/tests evidence review.
3. إنشاء Commit المعتمد: `chore(package0): establish qurani technical baseline`.
4. إنشاء Tag المعتمد: `package-0-approved`.
5. التحقق من Git clean بعد Commit/Tag.

Package 0 تبقى OPEN حتى نجاح هذه البوابة النهائية.
