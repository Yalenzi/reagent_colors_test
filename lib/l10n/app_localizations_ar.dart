// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get settings => 'الإعدادات';

  @override
  String get settingsTitleWithIcon => '⚙️ الإعدادات';

  @override
  String get errorLoadingSettings => 'خطأ في تحميل الإعدادات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get appearance => 'المظهر';

  @override
  String get theme => 'السمة';

  @override
  String get themeSubtitle => 'اختر السمة المفضلة لديك';

  @override
  String get lightTheme => 'فاتح';

  @override
  String get darkTheme => 'داكن';

  @override
  String get systemTheme => 'النظام';

  @override
  String get language => 'اللغة';

  @override
  String get appLanguage => 'لغة التطبيق';

  @override
  String get appLanguageSubtitle => 'اختر لغتك المفضلة';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get pushNotifications => 'الإشعارات';

  @override
  String get pushNotificationsSubtitle => 'تلقي إشعارات حول نتائج الاختبار';

  @override
  String get vibration => 'الاهتزاز';

  @override
  String get vibrationSubtitle => 'اهتزاز عند الإشعارات والتفاعلات';

  @override
  String get about => 'حول';

  @override
  String get developers => 'المطورون';

  @override
  String get developersSubtitle => 'تعرف على الفريق الذي يقف خلف هذا التطبيق';

  @override
  String get version => 'الإصدار';

  @override
  String get comingSoonTitle => '🚧 قريبا';

  @override
  String comingSoonContent(Object feature) {
    return 'سيتم تنفيذ وظيفة $feature قريبًا!';
  }

  @override
  String get ok => 'موافق';

  @override
  String get developersDialogTitle => 'المطورون';

  @override
  String get reagentTestingApp => 'تطبيق اختبار الكواشف';

  @override
  String get theDevelopers => '👨‍💻 المطورين';

  @override
  String get developerOneName => 'يوسف مسير العنزي';

  @override
  String get developerTwoName => 'محمد نفاع الرويلي';

  @override
  String get aboutTheApp => '🧪 حول التطبيق:';

  @override
  String get aboutTheAppContent =>
      'هذا التطبيق يساعد المستخدمين على اختبار المواد بأمان باستخدام الكواشف الكيميائية.';

  @override
  String get contact => '📧 للتواصل: ';

  @override
  String get reagentTesting => 'اختبار الكواشف';

  @override
  String get searchReagents => 'البحث في الكواشف...';

  @override
  String get clear => 'مسح';

  @override
  String get initializingReagentData => 'تهيئة بيانات الكواشف...';

  @override
  String get loadingReagents => 'تحميل الكواشف...';

  @override
  String get errorLoadingReagents => 'خطأ في تحميل الكواشف';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get noReagentsAvailable => 'لا توجد كواشف متاحة';

  @override
  String get unableToLoadReagentData =>
      'غير قادر على تحميل بيانات الكواشف من الملفات.\nيرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.';

  @override
  String get retryLoading => 'إعادة تحميل';

  @override
  String testing(Object reagentName) {
    return 'اختبار $reagentName';
  }

  @override
  String duration(Object duration) {
    return 'المدة: $duration دقيقة';
  }

  @override
  String get safetyLevel => 'مستوى الأمان';

  @override
  String get readyToStart => 'جاهز لبدء الاختبار';

  @override
  String get readyToStartDescription =>
      'يرجى التأكد من قراءة وفهم جميع تعليمات السلامة قبل المتابعة مع الاختبار.';

  @override
  String get testProcedure => 'إجراء الاختبار';

  @override
  String step(Object stepNumber) {
    return 'الخطوة $stepNumber';
  }

  @override
  String get reactionTimer => 'مؤقت التفاعل';

  @override
  String get startTimer => 'بدء المؤقت';

  @override
  String get stopTimer => 'إيقاف المؤقت';

  @override
  String get resetTimer => 'إعادة تعيين المؤقت';

  @override
  String get timerRunning => 'المؤقت يعمل';

  @override
  String get observedColor => 'اللون المُلاحظ';

  @override
  String get observedColorDescription =>
      'اختر اللون الذي لاحظته بعد إضافة الكاشف';

  @override
  String get tapColorInstruction => 'اضغط على اللون الذي يطابق ما لاحظته';

  @override
  String get testNotes => 'ملاحظات الاختبار';

  @override
  String get testNotesPlaceholder =>
      'أضف أي ملاحظات أو مشاهدات إضافية حول الاختبار...';

  @override
  String get completeTest => 'إكمال الاختبار';

  @override
  String get completeTestDescription => 'راجع ملاحظاتك وأكمل الاختبار';

  @override
  String get goBack => 'العودة';

  @override
  String get unknownState => 'حالة غير معروفة';

  @override
  String get safetyInformation => 'معلومات السلامة';

  @override
  String get chemicalComponents => 'المكونات الكيميائية';

  @override
  String get testInstructions => 'تعليمات الاختبار';

  @override
  String get safetyAcknowledgment => 'إقرار السلامة';

  @override
  String get safetyAcknowledgmentText =>
      'لقد قرأت وفهمت جميع تعليمات السلامة وسأتبع إجراءات السلامة المناسبة أثناء الاختبار.';

  @override
  String get startTest => 'بدء الاختبار';

  @override
  String get safetyAcknowledgmentRequired => 'مطلوب إقرار السلامة';

  @override
  String get equipment => 'المعدات المطلوبة';

  @override
  String get handlingProcedures => 'إجراءات التعامل';

  @override
  String get specificHazards => 'المخاطر المحددة';

  @override
  String get storage => 'متطلبات التخزين';

  @override
  String get testResults => 'نتائج الاختبار';

  @override
  String get testHistory => 'سجل الاختبارات';

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String error(Object message) {
    return 'خطأ: $message';
  }

  @override
  String get noTestResultsYet => 'لا توجد نتائج اختبار بعد';

  @override
  String get completeTestsToSeeHistory =>
      'أكمل بعض الاختبارات لرؤية تاريخك هنا';

  @override
  String get searchBySubstanceOrNotes => 'البحث بالمادة أو الملاحظات...';

  @override
  String get filterByReagent => 'تصفية بالكاشف:';

  @override
  String get all => 'الكل';

  @override
  String get totalTests => 'إجمالي الاختبارات';

  @override
  String get testsByReagent => 'الاختبارات بالكاشف';

  @override
  String get averageConfidence => 'متوسط الثقة';

  @override
  String get mostUsedReagent => 'الكاشف الأكثر استخداماً';

  @override
  String confidenceWithPercentage(Object confidence) {
    return 'الثقة: $confidence%';
  }

  @override
  String get possibleSubstances => 'المواد المحتملة';

  @override
  String get notes => 'الملاحظات';

  @override
  String get testResult => 'نتيجة الاختبار';

  @override
  String get reagent => 'الكاشف';

  @override
  String get observedColorLabel => 'اللون المُلاحظ';

  @override
  String get testDate => 'تاريخ الاختبار';

  @override
  String get deleteTestResult => 'حذف نتيجة الاختبار';

  @override
  String deleteConfirmation(Object reagentName) {
    return 'هل أنت متأكد من رغبتك في حذف نتيجة اختبار $reagentName هذه؟';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get refresh => 'تحديث';

  @override
  String get noTestHistory => 'لا توجد نتائج اختبار بعد';

  @override
  String get noTestHistoryDescription => 'أكمل بعض الاختبارات لرؤية سجلك هنا';

  @override
  String get deleteTest => 'حذف نتيجة الاختبار';

  @override
  String get deleteTestConfirmation =>
      'هل أنت متأكد من أنك تريد حذف نتيجة هذا الاختبار؟';

  @override
  String get loadingTestHistory => 'جاري تحميل سجل الاختبارات...';

  @override
  String get errorLoadingHistory => 'خطأ في تحميل سجل الاختبارات';

  @override
  String get testSummary => 'ملخص الاختبارات';

  @override
  String get uniqueReagents => 'الكواشف الفريدة';

  @override
  String get recentTests => 'الاختبارات الحديثة';

  @override
  String get confidence => 'الثقة';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get daysAgo => 'منذ أيام';

  @override
  String get syncToCloud => 'مزامنة مع السحابة';

  @override
  String get clearAllData => 'مسح جميع البيانات';

  @override
  String get syncingToCloud => 'مزامنة مع السحابة...';

  @override
  String get clearAllConfirmation =>
      'هل أنت متأكد من رغبتك في مسح جميع نتائج الاختبار؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get clearAll => 'مسح الكل';

  @override
  String get captureImage => 'التقاط صورة';

  @override
  String get captureImageDescription =>
      'التقط صورة لنتيجة اختبارك لتحليل الذكاء الاصطناعي';

  @override
  String get analyzeWithAI => 'تحليل بالذكاء الاصطناعي';

  @override
  String get aiAnalysis => 'تحليل الذكاء الاصطناعي';

  @override
  String get aiAnalysisResult => 'نتيجة تحليل الذكاء الاصطناعي';

  @override
  String get aiAnalysisError => 'خطأ في تحليل الذكاء الاصطناعي';

  @override
  String get retakePhoto => 'إعادة التقاط الصورة';

  @override
  String get analyzing => 'جاري التحليل...';

  @override
  String get aiSuggestion => 'اقتراح الذكاء الاصطناعي';

  @override
  String get confidenceLevel => 'مستوى الثقة';

  @override
  String get possibleMatches => 'التطابقات المحتملة';

  @override
  String get analysisNotes => 'ملاحظات التحليل';

  @override
  String get high => 'عالي';

  @override
  String get medium => 'متوسط';

  @override
  String get low => 'منخفض';

  @override
  String get extreme => 'خطر شديد';

  @override
  String get noColorChange => 'لا يوجد تغير في اللون';

  @override
  String get backToHome => 'العودة إلى الصفحة الرئيسية';

  @override
  String get unknownSubstance => 'مادة غير معروفة أو عينة غير نقية';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get fromGallery => 'من المعرض';

  @override
  String get uploadImageDescription =>
      'ارفع صورة لنتيجة اختبارك لتحليل الذكاء الاصطناعي';

  @override
  String get red => 'أحمر';

  @override
  String get darkRed => 'أحمر داكن';

  @override
  String get orange => 'برتقالي';

  @override
  String get redOrange => 'أحمر برتقالي';

  @override
  String get yellow => 'أصفر';

  @override
  String get lightYellow => 'أصفر فاتح';

  @override
  String get green => 'أخضر';

  @override
  String get paleGreen => 'أخضر شاحب';

  @override
  String get blue => 'أزرق';

  @override
  String get purple => 'بنفسجي';

  @override
  String get violet => 'بنفسج';

  @override
  String get magenta => 'أرجواني';

  @override
  String get pink => 'وردي';

  @override
  String get brown => 'بني';

  @override
  String get brownish => 'بني فاتح';

  @override
  String get black => 'أسود';

  @override
  String get grey => 'رمادي';

  @override
  String get lightBlue => 'أزرق فاتح';

  @override
  String get lightGreen => 'أخضر فاتح';

  @override
  String get darkBlue => 'أزرق داكن';

  @override
  String get darkGreen => 'أخضر داكن';

  @override
  String get olive => 'زيتوني';

  @override
  String get greenishBrown => 'بني مخضر';

  @override
  String get maroon => 'كستنائي';

  @override
  String get navy => 'أزرق حربي';

  @override
  String get teal => 'أزرق مخضر';

  @override
  String get clearNoChange => 'شفاف/لا تغيير';

  @override
  String get category => 'الفئة';

  @override
  String get primaryTests => 'الاختبارات الأساسية';

  @override
  String get secondaryTests => 'الاختبارات الثانوية';

  @override
  String get specializedTests => 'الاختبارات المتخصصة';

  @override
  String get laboratoryProfile => 'ملف المختبر';

  @override
  String get labAccess => 'دخول المختبر';

  @override
  String get joinLaboratory => 'الانضمام للمختبر';

  @override
  String get laboratoryTechnician => 'فني مختبر';

  @override
  String get verified => 'موثق';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get testingStatistics => 'إحصائيات الاختبارات';

  @override
  String get testsPerformed => 'الاختبارات المنجزة';

  @override
  String get reagentsUsed => 'الكواشف المستخدمة';

  @override
  String get successRate => 'معدل النجاح';

  @override
  String get labHours => 'ساعات المختبر';

  @override
  String get recentActivity => 'النشاط الأخير';

  @override
  String get hoursAgo => 'منذ ساعات';

  @override
  String get dayAgo => 'منذ يوم';

  @override
  String get safetyReminder => 'تذكير السلامة';

  @override
  String get safetyReminderText =>
      'ارتدي دائماً معدات الحماية عند التعامل مع الكواشف. تأكد من التهوية المناسبة واتبع بروتوكولات السلامة.';

  @override
  String get accountInformation => 'معلومات الحساب';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get memberSince => 'عضو منذ';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get welcomeBack => 'أهلاً بعودتك!';

  @override
  String get joinOurLab => 'انضم لمختبرنا';

  @override
  String get accessYourLab => 'ادخل إلى مختبر اختبار الكواشف الخاص بك';

  @override
  String get startYourJourney => 'ابدأ رحلتك في تحليل المواد';

  @override
  String get loginMode => 'تسجيل الدخول';

  @override
  String get registerMode => 'التسجيل';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get signInWithGoogle => 'تسجيل الدخول بجوجل';

  @override
  String get signUpWithGoogle => 'إنشاء حساب بجوجل';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get dontHaveLabAccess => 'ليس لديك وصول للمختبر؟';

  @override
  String get alreadyHaveLabAccess => 'لديك وصول للمختبر بالفعل؟';

  @override
  String get joinNow => 'انضم الآن';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get orContinueWith => 'أو تابع مع';

  @override
  String get emailAddress => 'عنوان البريد الإلكتروني';

  @override
  String get accessLaboratory => 'دخول المختبر';

  @override
  String get signingIn => 'جاري تسجيل الدخول...';

  @override
  String get creatingAccount => 'جاري إنشاء الحساب...';

  @override
  String get pleaseEnterUsername => 'يرجى إدخال اسم المستخدم';

  @override
  String get usernameMinLength => 'يجب أن يكون اسم المستخدم 3 أحرف على الأقل';

  @override
  String get usernameInvalidChars =>
      'يمكن أن يحتوي اسم المستخدم على أحرف وأرقام وشرطات سفلية فقط';

  @override
  String get pleaseEnterEmail => 'يرجى إدخال بريدك الإلكتروني';

  @override
  String get pleaseEnterValidEmail => 'يرجى إدخال عنوان بريد إلكتروني صحيح';

  @override
  String get pleaseEnterPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get passwordMinLength => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get pleaseConfirmPassword => 'يرجى تأكيد كلمة المرور';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';
}
