# MAYDAN — سجل المحاولات السابقة والأخطاء والدروس

هذه المعلومات مستخلصة من سجل العمل السابق، ويجب مطابقتها مع المستودعات والملفات الفعلية قبل اعتمادها كحالة راهنة.

## 1. المستودع القديم
- المستودع المعروف: `abdatimed28-dot/Maydan-` وكان Private وفق المعلومات المتاحة حينها.
- فرع العمل: `feature/maydan-redesign-localization`.
- commit معروف: `91d3a722955e70d124398f983138dd5b26c8f01e` — `Complete MAYDAN localization and responsive verification`.
- لا تفترض أنه المستودع الجديد، ولا تدفع إليه تغييرات دون طلب صريح.

## 2. تغييرات غير ملتزم بها في جلسة سابقة
- `lib/core/localization/app_strings.dart`
- `lib/features/projects/field_operations_page.dart`
- `lib/features/projects/projects_page.dart`
- `lib/features/shell/app_shell.dart`
- `test/localization_navigation_test.dart` (ملف جديد غير متعقب)

نسخ مؤقتة كانت في Codespaces:
- `/tmp/maydan-copilot-changes.patch`
- `/tmp/localization_navigation_test.dart`
- `/tmp/maydan-staged-changes.patch`

هذه مسارات مؤقتة وقد تكون اختفت عند إعادة إنشاء Codespace. لا تدّعِ استعادتها قبل فحصها فعلياً.

## 3. بيئة Flutter السابقة
في Codespace قيل إن Flutter SDK موجود في `~/development/flutter` وظهرت الإصدارات Flutter 3.47.9 وDart 3.13.7. نجح `flutter pub get` في إحدى الجلسات، وفحص `dart format` خمسة ملفات ولم يعدلها. لم تتوفر نتيجة نهائية مؤكدة لـ`flutter analyze`. أعد فحص كل ذلك في البيئة الجديدة ولا تعتمد الإصدارات القديمة كحقيقة حالية.

## 4. اختبارات فشلت
ظهر 67 اختباراً ناجحاً وثلاثة اختبارات فاشلة:
1. `system Back closes modal surfaces before leaving the section`
2. `root system Back asks before exiting`
3. `system Back returns from a section and avoids duplicate history`

في اثنين من الإخفاقات لم يجد الاختبار نصاً عربياً مثل `أغلق السجل`، وظهرت `Found 0 widgets with text`. لم يكن سجل الاختبار الثالث كاملاً.

**التشخيص غير محسوم:** لا يوجد دليل كافٍ على أن الفشل الثلاثي سببه اللغة وحدها. احتمال أن Locale الاختبار لم يكن مضبوطاً طُرح سابقاً لكنه لم يثبت.

### الدروس
- استخرج السجل الكامل لكل اختبار فاشل وشغّله منفرداً.
- افحص Locale التطبيق والاختبار قبل تعديل كود التنقل.
- اختبارات التنقل تستخدم `ValueKey` أو Semantics identifiers لا نصوصاً مترجمة.
- أنشئ اختبارات منفصلة للعربية والفرنسية والإنجليزية.
- لا تفرض العربية على كل الاختبارات ولا تغير Locale عالمياً لإخفاء المشكلة.
- لا تحذف اختباراً ولا تخفف توقعاته لمجرد جعل البناء أخضر.
- لا تعدّل `app_shell.dart` لمجرد أن Finder لم يجد نصاً عربياً.

## 5. مقتطف PopScope سابق — ليس حلاً مثبتاً
ظهر مقتطف قريب من:

```dart
return PopScope<Object?>(
  canPop: scaffoldKey.currentState?.isDrawerOpen ?? false,
  onPopInvokedWithResult: (didPop, _) {
    if (!didPop) unawaited(_handleSystemBack());
  },
  child: Scaffold(key: scaffoldKey, ...)
);
```

لا تنسخه على أنه صحيح. افحص دورة حياة `ScaffoldState`، وشرط `canPop`، وسلوك Drawer، و`onPopInvokedWithResult` في إصدار Flutter الحالي، ثم اختبر Dialog وBottom Sheet وDrawer والرجوع فعلياً.

## 6. سجل التنقل السابق
كان هناك `sectionHistory` وبعض الصفحات تبقى mounted، وكان `_handleSystemBack()` يعالج تاريخ الأقسام ثم الرجوع للرئيسية ثم تأكيد الخروج. هذه مجرد إشارات لمحاولة سابقة، وليست وصفاً مؤكداً للكود الحالي.

## 7. مشكلة ربط GitHub والحسابات
- أنشأ المستخدم حساب GitHub جديداً ببريد مختلف عن بريد ChatGPT.
- اختلاف البريد لا يمنع الربط؛ المهم أن يكون GitHub Connector مفوضاً إلى حساب GitHub الصحيح الذي يملك مستودع `Maydan` أو يملك وصولاً إليه.
- ظهرت في ChatGPT واجهة GitHub وأمثلة مهام مثل شرح المصادقة ومراجعة PR وتلخيص آخر سبعة أيام؛ هذا دليل على ظهور واجهة الموصل، لكنه ليس دليلاً كافياً على إتاحة المستودع الصحيح.
- استعلام قائمة المستودعات من حساب ChatGPT آخر أعاد قائمة فارغة. السبب غير محسوم؛ قد يكون الحساب المفوض مختلفاً أو إعداد إتاحة المستودعات غير مكتمل أو سبباً تقنياً آخر.
- على ChatGPT المتصل بالحساب الصحيح أن يتحقق من ظهور `Maydan` قبل أي تعديل. إذا لم يظهر، يتوقف ويعالج الربط بدلاً من التخمين.
- لا تشارك PAT أو OAuth secrets أو كلمات المرور في المحادثات.

## 8. مشروعات أخرى لا تخلطها مع MAYDAN
لدى المستخدم مشروعات أخرى مثل Insaf وRamatta وGHAYTAK. لا تنقل شيفراتها أو هويتها أو متطلباتها إلى MAYDAN تلقائياً. يمكن الاستفادة من دروس الجودة فقط ما لم يطلب المستخدم خلاف ذلك.
