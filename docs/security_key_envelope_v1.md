# قرآني v1 — Security Key Envelope v1

## حالة الوثيقة

- **الإصدار:** 1
- **الحالة:** معتمد كأساس تقني بعد إثبات P0-03
- **تاريخ الاعتماد:** 2026-08-31
- **المنصة:** Android
- **النطاق:** حماية `DatabaseKey` و`AudioKey` على الجهاز
- **خارج النطاق:** `BackupFileKey` وتنسيق `.qrb`؛ يعالجان في Package 10

## 1. الهدف

تثبيت شكل تغليف مفاتيح البيانات المحلي في قرآني v1 قبل تحويله إلى تنفيذ Production.

PIN ليس `DatabaseKey` ولا `AudioKey` ولا `QuraniMasterKey`.

## 2. هرم المفاتيح

PIN -> Argon2id + Salt -> PinKEK -> inner AES-256-GCM -> Android Keystore outer AES-256-GCM -> Stored KeyEnvelopeV1

وعند الفتح يعمل المسار بالعكس حتى استعادة `DatabaseKey` أو `AudioKey` بعد نجاح المصادقة والتحقق من السلامة.

## 3. المفاتيح

### DatabaseKey

- عشوائي مستقل.
- 256-bit / 32 bytes.
- يستخدم لقاعدة SQLite المشفرة.
- لا يخزن خاما بصورة دائمة.

### AudioKey

- عشوائي مستقل.
- 256-bit / 32 bytes.
- مستقل عن DatabaseKey.
- يستخدم لحماية الملفات الصوتية.
- لا يخزن خاما بصورة دائمة.

### PinKEK

يشتق من PIN بواسطة Argon2id.

الإعداد المعتمد بعد Benchmark على هاتف E11:

| العنصر | القيمة |
|---|---:|
| Salt | 16 bytes |
| Output | 32 bytes |
| Memory | 19456 KiB / 19 MiB |
| Iterations | 2 |
| Parallelism | 1 |

### QuraniMasterKey

- AES-256.
- ينشأ داخل Android Keystore.
- غير قابل للاستخراج.
- AES/GCM/NoPadding.
- لا يتطلب Biometric في v1.
- لا تحفظ مادته الخام في Dart أو SQLite أو ملفات التطبيق العادية.

## 4. KeyEnvelopeV1

الشكل المنطقي:

- `version = 1`
- `purpose = DatabaseKey | AudioKey`
- KDF metadata: Argon2id + salt + memory + iterations + parallelism + output size
- outer algorithm: AES-256-GCM باستخدام QuraniMasterKey داخل Android Keystore
- outer IV/ciphertext/authentication tag

الـplaintext المحمي في الطبقة الخارجية هو `InnerEnvelopeV1`، ويحتوي:

- `version = 1`
- `purpose = DatabaseKey | AudioKey`
- inner algorithm: AES-256-GCM
- nonce
- ciphertext
- authentication tag

الـplaintext داخل الطبقة الداخلية هو مفتاح بيانات واحد بطول 32 bytes فقط.

## 5. ترتيب التغليف

1. إنشاء DatabaseKey أو AudioKey عشوائيا 256-bit.
2. إنشاء Salt عشوائي 16-byte.
3. اشتقاق PinKEK من PIN بواسطة Argon2id بالقيم المسجلة في Envelope.
4. تشفير مفتاح البيانات بواسطة AES-256-GCM باستخدام PinKEK.
5. إنشاء InnerEnvelopeV1.
6. تشفير InnerEnvelope كاملا بواسطة QuraniMasterKey داخل Android Keystore باستخدام AES-GCM.
7. حفظ Envelope وmetadata فقط.
8. عدم حفظ المفاتيح الخام بصورة دائمة.

## 6. فك التغليف

1. قراءة KeyEnvelopeV1.
2. رفض أي version غير مدعوم.
3. استخدام QuraniMasterKey داخل Android Keystore للتحقق وفك الطبقة الخارجية.
4. التحقق من version وpurpose في InnerEnvelope.
5. اشتقاق PinKEK من PIN وSalt وKDF params المسجلة.
6. التحقق وفك الطبقة الداخلية بواسطة AES-GCM.
7. قبول الناتج فقط إذا كان 32 bytes.
8. إبقاء المفتاح الخام في الذاكرة فقط أثناء الحاجة في حالة UNLOCKED.

## 7. AAD

يجب أن تربط Associated Authenticated Data على الأقل:

- envelope version؛
- key purpose؛
- KDF algorithm؛
- KDF parameters؛
- salt أو تمثيله canonical عند الطبقة المناسبة.

لا يجوز قبول Envelope خاص بـDatabaseKey باعتباره AudioKey أو العكس.

الصيغة البايتية النهائية للـAAD في Production يجب أن تكون canonical وثابتة لكل Envelope version.

## 8. Versioning

- الإصدار الحالي: 1.
- كل Envelope يحمل version صريحا.
- version غير معروف يرفض.
- لا يوجد silent fallback.
- أي تغيير يكسر البنية أو AAD أو ترتيب الطبقات يتطلب Envelope version جديدا.
- الترقية لا تتم إلا بعد فك الإصدار القديم والتحقق منه بنجاح.

## 9. قواعد الفشل

### PIN خاطئ

قد تنجح الطبقة الخارجية لأن PIN ليس مفتاح Android Keystore، لكن inner AES-GCM authentication يجب أن تفشل بسبب PinKEK الخاطئ. لا يعاد مفتاح جزئي.

### Outer envelope معدل أو تالف

Android Keystore AES-GCM authentication يجب أن تفشل. لا تعالج الطبقة الداخلية بعد فشل outer authentication.

### Inner envelope معدل أو تالف

AEAD authentication أو metadata validation يجب أن تفشل. لا يوجد fallback غير موثق.

### QuraniMasterKey مفقود

إذا كان Envelope موجودا ومفتاح Keystore غير متوفر، لا ينشأ MasterKey جديد بصمت ثم يعتبر Envelope القديم صالحا. تعامل الحالة كمسار Security/Recovery وفق الحزمة المعتمدة لاحقا.

### KDF metadata غير صالحة

يرفض Envelope. لا تستخدم قيم افتراضية صامتة.

## 10. حالة LOCKED

عند LOCKED:

- يغلق اتصال قاعدة البيانات قدر الإمكان.
- تزال DatabaseKey وAudioKey وPinKEK المكشوفة من حالة التطبيق.
- لا يعاد فتح الموارد المحمية إلا بعد نجاح المصادقة.
- لا يعتمد الأمان على إخفاء الواجهة فقط.

## 11. تغيير PIN

تغيير PIN يعيد تغليف DatabaseKey وAudioKey ولا يفرض إعادة تشفير قاعدة البيانات كاملة أو جميع الملفات الصوتية.

المسار الآمن:

1. فتح Envelope الحالي بالـPIN الصحيح.
2. استعادة مفاتيح البيانات مؤقتا.
3. إنشاء Salt جديد واشتقاق PinKEK جديد.
4. إنشاء Envelopes مرشحة جديدة.
5. التحقق من إمكانية فك المرشحات.
6. نشرها بصورة آمنة.
7. حذف النسخ القديمة فقط بعد نجاح النشر.

## 12. Crash-safe rewrap

المبدأ:

old valid envelope -> create candidate -> verify candidate -> safe replace -> new valid envelope

لا يحذف Envelope القديم قبل إثبات أن المرشح الجديد قابل للفك. يجب أن يبقى إصدار صالح واحد على الأقل إذا حدث Crash قبل النشر النهائي.

## 13. LocalSecurityStore

مواد الأمان المطلوبة قبل فتح SQLite لا تعتمد على SQLite المشفرة نفسها.

يمكن أن يحتوي LocalSecurityStore في Production على:

- PIN verifier؛
- KDF salt/parameters؛
- retry/lock state؛
- setup/security state؛
- wrapped key envelopes.

ولا يحتوي على PIN الخام أو PinKEK الخام أو DatabaseKey الخام أو AudioKey الخام.

## 14. إثبات P0-03 على Android الحقيقي

الجهاز:

- LT_mobile E11
- Android 12
- API 31
- arm64-v8a
- Device ID وقت الاختبار: LTMBE111LT035683

تم إثبات:

- Android Keystore MasterKey: PASS
- MasterKey non-exportable: PASS
- Argon2id derivation/benchmark: PASS
- DatabaseKey وAudioKey مستقلان: PASS
- DatabaseKey two-layer round-trip: PASS
- AudioKey two-layer round-trip: PASS
- Wrong PIN authenticated failure: PASS
- Outer AES-GCM tamper failure: PASS

علامة الإثبات:

`QURANI_P0_03_KEYSTORE_PIN_PROOF_OK`

## 15. Argon2id Benchmark — E11

| Run | الوقت |
|---|---:|
| 1 | 1490 ms |
| 2 | 1294 ms |
| 3 | 1414 ms |
| 4 | 1542 ms |
| 5 | 1310 ms |

- **Median:** 1414 ms
- **Minimum:** 1294 ms
- **Maximum:** 1542 ms

قرار صاحب المشروع بتاريخ 2026-08-31:

**اعتماد 19 MiB / t=2 / p=1 / output 32 bytes دون تخفيض.**

## 16. حدود P0-03

P0-03 أثبت اللبنات الأمنية فقط، ولا يعني اكتمال شاشة PIN أو retry policy أو auto-lock أو process-restart lock أو forgot-PIN أو PIN-change UI أو setup crash-safe الكامل أو Backup/Restore.

هذه تنفذ في حزمها المحددة في خطة المشروع.

## 17. القرار النهائي

تم اعتماد Security Key Envelope v1 كأساس أمني تقني لقرآني v1 بعد نجاح P0-03 على هاتف Android حقيقي.

- PinKEK = Argon2id(PIN, Salt, versioned params).
- DatabaseKey = random independent 256-bit.
- AudioKey = random independent 256-bit.
- Inner wrapping = AES-256-GCM بواسطة PinKEK.
- Outer wrapping = AES-256-GCM بواسطة QuraniMasterKey داخل Android Keystore.
- لا تخزن المفاتيح الخام بصورة دائمة.
- Envelope versioning إلزامي.
- فشل AEAD أو Keystore أو version أو integrity لا يتجاوز بصمت.