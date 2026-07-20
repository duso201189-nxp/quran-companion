// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'رفيق القرآن';

  @override
  String get tabHome => 'الرئيسية';

  @override
  String get tabQuran => 'القرآن';

  @override
  String get tabStudy => 'التعلّم';

  @override
  String get tabStats => 'الإحصائيات';

  @override
  String get tabProfile => 'الملف الشخصي';

  @override
  String get sectionAppearance => 'المظهر';

  @override
  String get sectionLanguage => 'اللغة';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeDark => 'داكن';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get profilePersonalInfo => 'المعلومات الشخصية';

  @override
  String get profileGoal => 'هدف التعلم';

  @override
  String get profileSync => 'المزامنة السحابية';

  @override
  String comingInStep(int step) {
    return 'سيتم بناؤه في الخطوة $step';
  }

  @override
  String get placeholderHome =>
      'الخطوة 8 ستبني لوحة التعلم: متابعة القراءة، تقدم اليوم، سلسلة الأيام، آية اليوم.';

  @override
  String get placeholderQuran =>
      'الخطوة 3 ستعرض 114 سورة مع البحث والتصفية (مكية / مدنية).';

  @override
  String get placeholderStudy =>
      'الخطوة 9 ستبني البطاقات التعليمية (التكرار المتباعد) والاختبارات.';

  @override
  String get placeholderStats =>
      'الخطوة 9 ستعرض الرسوم البيانية: سلسلة الأيام، مجموع الآيات، وقت الدراسة، اليوميات.';

  @override
  String get searchSurahHint => 'ابحث عن سورة بالاسم أو الرقم...';

  @override
  String get filterAll => 'الكل';

  @override
  String get revelationMecca => 'مكية';

  @override
  String get revelationMadinah => 'مدنية';

  @override
  String surahAyahCount(int count) {
    return '$count آية';
  }

  @override
  String get errorLoadData => 'تعذر تحميل البيانات. حاول مرة أخرى.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get emptySearchResults => 'لا توجد سورة مطابقة للبحث.';

  @override
  String get displaySettings => 'العرض';

  @override
  String get readingFontSize => 'حجم الخط العربي';

  @override
  String get showTransliteration => 'النقل الصوتي';

  @override
  String get showVietnamese => 'الترجمة الفيتنامية';

  @override
  String get showEnglish => 'الترجمة الإنجليزية';

  @override
  String get surahNotFound => 'لم يتم العثور على هذه السورة.';

  @override
  String get surahNoContent => 'لا يوجد محتوى لهذه السورة.';

  @override
  String ayahSemanticLabel(int number) {
    return 'الآية $number';
  }

  @override
  String get sajdahAyah => 'آية سجدة';

  @override
  String get focusMode => 'وضع التركيز';

  @override
  String get readingModeMushaf => 'وضع المصحف';

  @override
  String get readingModeList => 'وضع القائمة';

  @override
  String pageLabel(int number) {
    return 'صفحة $number';
  }

  @override
  String get play => 'تشغيل';

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get nextAyah => 'الآية التالية';

  @override
  String get previousAyah => 'الآية السابقة';

  @override
  String get repeatMode => 'وضع التكرار';

  @override
  String get stopAudio => 'إيقاف الصوت';

  @override
  String get selectReciter => 'اختر القارئ';

  @override
  String get playFromHere => 'التشغيل من هذه الآية';

  @override
  String get bookmarkLabel => 'إشارة مرجعية';

  @override
  String get statusLabel => 'حالة التعلم';

  @override
  String get statusNone => 'غير مقروءة';

  @override
  String get statusLearning => 'قيد التعلم';

  @override
  String get statusLearned => 'تم تعلمها';

  @override
  String get statusReview => 'للمراجعة';

  @override
  String get noteLabel => 'ملاحظة';

  @override
  String get addNote => 'إضافة ملاحظة';

  @override
  String get editNote => 'تعديل الملاحظة';

  @override
  String get noteHint => 'يدعم **غامق** و *مائل*';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get copyAyah => 'نسخ';

  @override
  String get shareAyah => 'مشاركة';

  @override
  String get ayahCopied => 'تم النسخ إلى الحافظة';

  @override
  String get moreActions => 'المزيد';

  @override
  String get continueReading => 'متابعة القراءة';

  @override
  String get startReading => 'ابدأ القراءة';

  @override
  String get todaysVerse => 'آية اليوم';

  @override
  String get dailyProgress => 'تقدم اليوم';

  @override
  String get lastRead => 'آخر قراءة';

  @override
  String get quickAccess => 'وصول سريع';

  @override
  String get learningStreak => 'سلسلة أيام التعلم';

  @override
  String streakDays(int count) {
    return '$count يوم';
  }

  @override
  String get recentSurahs => 'السور الأخيرة';

  @override
  String get ayahsReadLabel => 'آيات مقروءة';

  @override
  String get minutesLabel => 'دقائق';

  @override
  String get myBookmarks => 'علاماتي المرجعية';

  @override
  String get studyFlashcards => 'بطاقات تعليمية';

  @override
  String get studyFlashcardsDesc => 'احفظ الآيات ببطاقات ذات وجهين';

  @override
  String get studySpaced => 'تكرار متباعد';

  @override
  String get studySpacedDesc => 'راجع قبل النسيان — تذكر أطول';

  @override
  String get studyQuiz => 'اختبار';

  @override
  String get studyQuizDesc => 'اختبارات سريعة لكل سورة';

  @override
  String get studyDailyReview => 'مراجعة يومية';

  @override
  String get studyDailyReviewDesc => 'آيات مستحقة للمراجعة اليوم';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get statsReadingDays => 'أيام القراءة';

  @override
  String get statsAyahsRead => 'الآيات المقروءة';

  @override
  String get statsMinutes => 'دقائق الدراسة';

  @override
  String get statsCompletion => 'إتمام القرآن';

  @override
  String get statsCurrentStreak => 'السلسلة الحالية';

  @override
  String get statsLongestStreak => 'أطول سلسلة';

  @override
  String get statsWeeklyActivity => 'آخر ٧ أيام';

  @override
  String get statsNoData => 'ابدأ القراءة لتسجيل الإحصاءات.';

  @override
  String get sectionAbout => 'حول';

  @override
  String get aboutSources => 'مصادر البيانات';

  @override
  String get aboutSourcesDetail =>
      'النص العربي والترجمات: Tanzil.net · QuranEnc.com. الصوت: EveryAyah.com. الخط: مجمع الملك فهد.';

  @override
  String get versionLabel => 'الإصدار';

  @override
  String get audioError => 'تعذر التشغيل. تحقق من الاتصال.';

  @override
  String get audioLoading => 'جارٍ تحميل الصوت...';

  @override
  String get favoriteLabel => 'المفضلة';

  @override
  String get copyArabic => 'نسخ النص العربي';

  @override
  String get copyTranslation => 'نسخ الترجمة';

  @override
  String get searchResultsAyahs => 'نتائج في المحتوى';

  @override
  String get searchNoAyahResults => 'لا توجد آيات مطابقة.';

  @override
  String get searchLabel => 'بحث';

  @override
  String get searchAskLabel => 'اسأل الذكاء الاصطناعي';

  @override
  String get searchQueryHint => 'ابحث في القرآن...';

  @override
  String get searchClearTooltip => 'مسح';

  @override
  String get searchScopeMyNotes => 'ملاحظاتي';

  @override
  String get searchEmptyTitle => 'ابحث عمّا تريده في القرآن';

  @override
  String get searchEmptySubtitle =>
      'اكتب اسم سورة، رقم آية (مثل 2:255)، أو كلمة مفتاحية.';

  @override
  String get searchEmptyRecentSectionTitle => 'الأخيرة';

  @override
  String get searchEmptySuggestedSectionTitle => 'مقترح';

  @override
  String get searchLoadingLabel => 'جارٍ البحث...';

  @override
  String get libraryTitle => 'مكتبتي';

  @override
  String get libraryBookmarks => 'المحفوظة';

  @override
  String get libraryFavorites => 'المفضلة';

  @override
  String get libraryNotes => 'الملاحظات';

  @override
  String get libraryHighlights => 'التظليل';

  @override
  String get libraryEmptyBookmarks => 'لا آيات محفوظة بعد.';

  @override
  String get libraryEmptyFavorites => 'لا آيات مفضلة بعد.';

  @override
  String get libraryEmptyNotes => 'لا ملاحظات بعد.';

  @override
  String get libraryEmptyHighlights => 'لا آيات مظللة بعد.';

  @override
  String get statsSessionsTitle => 'جلسات القراءة';

  @override
  String get statsSessionsEmpty => 'لا توجد جلسات قراءة مسجلة بعد.';

  @override
  String get statsTodayTitle => 'اليوم';

  @override
  String statsTodayMinutes(int count) {
    return '$count دقيقة';
  }

  @override
  String statsTodaySessionsCount(int count) {
    return '$count جلسة';
  }

  @override
  String get khatmSectionTitle => 'ختمة نشطة';

  @override
  String get khatmEmpty => 'لا توجد ختمة نشطة.';

  @override
  String get khatmStart => 'ابدأ ختمة';

  @override
  String get khatmDefaultName => 'ختمتي';

  @override
  String get khatmProgressLabel => 'التقدم';

  @override
  String get khatmContinueReading => 'متابعة القراءة';

  @override
  String khatmAyahPosition(int current, int total) {
    return 'الآية $current / $total';
  }

  @override
  String get collectionsTitle => 'المجموعات';

  @override
  String get collectionsEmpty => 'لا توجد مجموعات بعد.';

  @override
  String get collectionsCreate => 'مجموعة جديدة';

  @override
  String get collectionsRename => 'إعادة تسمية';

  @override
  String get collectionsDelete => 'حذف';

  @override
  String get collectionsDeleteConfirmTitle => 'حذف المجموعة؟';

  @override
  String get collectionsDeleteConfirmBody =>
      'تبقى الإشارات المرجعية، وتُحذف المجموعة فقط.';

  @override
  String get collectionNameHint => 'اسم المجموعة';

  @override
  String get collectionEmojiHint => 'رمز تعبيري (اختياري)';

  @override
  String collectionItemCount(int count) {
    return '$count آية';
  }

  @override
  String get collectionAssignTitle => 'إضافة إلى مجموعة';

  @override
  String get libraryOrganizeTooltip => 'تنظيم ضمن مجموعة';

  @override
  String get revisionQueueEmpty => 'لا توجد آيات بحاجة للمراجعة بعد.';

  @override
  String get dailyGoalMinutesHint => 'دقائق في اليوم';

  @override
  String get dailyGoalAyahsHint => 'آيات في اليوم';

  @override
  String get dailyGoalNotSet => 'لم يتم تعيين هدف بعد — اضغط للتعيين.';

  @override
  String dailyGoalMinutesProgress(int current, int target) {
    return '$current / $target دقيقة اليوم';
  }
}
