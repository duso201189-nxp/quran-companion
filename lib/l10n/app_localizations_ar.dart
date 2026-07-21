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
  String get homeLoading => 'جارٍ تحميل الشاشة الرئيسية…';

  @override
  String get homeTodaysVerseLoading => 'جارٍ تحميل آية اليوم…';

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
  String get studyFlashcardsDesc => 'احفظ مفردات القرآن ببطاقات ذات وجهين';

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
  String get studyProgress => 'التقدم';

  @override
  String get studyProgressDesc => 'إحصاءات وسجل ونصائح للتحسين';

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

  @override
  String get reviewGradeAgain => 'إعادة';

  @override
  String get reviewGradeHard => 'صعب';

  @override
  String get reviewGradeGood => 'جيد';

  @override
  String get reviewGradeEasy => 'سهل';

  @override
  String get reviewOpenInReading => 'فتح في القراءة';

  @override
  String get reviewSessionComplete => 'اكتملت الجلسة!';

  @override
  String get reviewSessionCompleteSubtitle =>
      'لا توجد بطاقات مستحقة للمراجعة الآن.';

  @override
  String get flashcardReviewTitle => 'البطاقات التعليمية';

  @override
  String get flashcardReviewComplete => 'اكتملت مراجعة البطاقات!';

  @override
  String get flashcardReviewCompleteSubtitle =>
      'لا توجد مفردات مستحقة للمراجعة الآن.';

  @override
  String get flashcardsTitle => 'البطاقات التعليمية';

  @override
  String get flashcardSearchHint => 'ابحث بالعربية أو النطق أو المعنى';

  @override
  String get flashcardAdd => 'إضافة';

  @override
  String get flashcardContentUnavailable => 'المحتوى غير متاح';

  @override
  String get flashcardMoveToDeck => 'نقل إلى مجموعة';

  @override
  String get flashcardRemove => 'إزالة البطاقة';

  @override
  String get flashcardNoDeck => 'بدون مجموعة';

  @override
  String get flashcardEmptyDeck => 'لا توجد بطاقات في هذه المجموعة بعد.';

  @override
  String get flashcardNoResults => 'لا توجد بطاقات مطابقة.';

  @override
  String get flashcardFilterAllDecks => 'كل المجموعات';

  @override
  String get flashcardFilterAllTypes => 'كل الأنواع';

  @override
  String get flashcardFilterAllStatus => 'كل الحالات';

  @override
  String get flashcardFilterDue => 'مستحق';

  @override
  String get flashcardFilterNew => 'جديد';

  @override
  String get flashcardFilterLearning => 'قيد التعلم';

  @override
  String get flashcardFilterReview => 'قيد المراجعة';

  @override
  String get flashcardFilterLapsed => 'منسي';

  @override
  String get flashcardOnboardingTitle => 'لا توجد بطاقات بعد';

  @override
  String get flashcardOnboardingBody =>
      'أضف أول بطاقة مفردات لبدء الحفظ بالتكرار المتباعد.';

  @override
  String get flashcardOnboardingCta => 'أضف أول بطاقة';

  @override
  String get flashcardOnboardingReviewNudge =>
      'تمت إضافة أول بطاقة! هل تريد مراجعتها الآن؟';

  @override
  String get flashcardOnboardingReviewCta => 'راجع الآن';

  @override
  String get flashcardDecksTitle => 'مجموعات البطاقات';

  @override
  String get flashcardDecksEmpty => 'لا توجد مجموعات بعد.';

  @override
  String get flashcardDecksCreate => 'إنشاء مجموعة';

  @override
  String get flashcardDecksRename => 'إعادة تسمية';

  @override
  String get flashcardDecksDelete => 'حذف';

  @override
  String get flashcardDecksDeleteConfirmTitle => 'حذف المجموعة؟';

  @override
  String get flashcardDecksDeleteConfirmBody =>
      'ستنتقل بطاقات هذه المجموعة إلى \"بدون مجموعة\" ولن يتم حذفها.';

  @override
  String get flashcardDeckNameHint => 'اسم المجموعة';

  @override
  String flashcardDeckItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بطاقة',
      one: 'بطاقة واحدة',
      zero: 'لا توجد بطاقات بعد',
    );
    return '$_temp0';
  }

  @override
  String get addFlashcardTitle => 'إضافة بطاقة';

  @override
  String get addFlashcardSourceLemma => 'مدخل معجمي';

  @override
  String get addFlashcardSourceRoot => 'جذر';

  @override
  String get addFlashcardSourcePhrase => 'عبارة';

  @override
  String get addFlashcardSourceNotAvailable =>
      'لا توجد بيانات قابلة للتصفح لهذا النوع بعد.';

  @override
  String get addFlashcardSearchHint => 'ابحث...';

  @override
  String get addFlashcardNoResults => 'لا توجد نتائج.';

  @override
  String get addFlashcardAdd => 'إضافة إلى البطاقات';

  @override
  String get smartDeckTodaysReview => 'مراجعة اليوم';

  @override
  String get smartDeckMostDifficult => 'الأصعب';

  @override
  String get smartDeckRecentlyLearned => 'تم تعلمها مؤخرًا';

  @override
  String get smartDeckWeakRoots => 'الجذور الضعيفة';

  @override
  String get smartDeckVerbForms => 'أوزان الفعل';

  @override
  String get smartDeckEmpty => 'لا توجد بطاقات في هذه المجموعة الذكية بعد.';

  @override
  String smartDeckVerbFormLabel(String form) {
    return 'الوزن $form';
  }

  @override
  String get progressDashboardTitle => 'التقدم';

  @override
  String get progressDashboardEmpty =>
      'لم تتم مراجعة أي بطاقة بعد — ستظهر الإحصاءات عند بدء التعلم.';

  @override
  String get progressDashboardHistory => 'سجل النشاط';

  @override
  String get progressDashboardHistoryEmpty =>
      'لا يوجد نشاط قراءة في هذه الفترة بعد.';

  @override
  String get progressDashboardInsights => 'نصائح للتحسين';

  @override
  String get progressDashboardOverview => 'نظرة عامة';

  @override
  String get progressDashboardLoading => 'جارٍ تحميل بيانات التقدم…';

  @override
  String get statCardsStudied => 'بطاقات تمت دراستها';

  @override
  String get statReviewsToday => 'مراجعات اليوم';

  @override
  String get statAccuracy => 'الدقة';

  @override
  String get statAverageEase => 'متوسط السهولة';

  @override
  String get statAverageInterval => 'متوسط الفاصل (أيام)';

  @override
  String get historyDaily => 'يوم';

  @override
  String get historyWeekly => 'أسبوع';

  @override
  String get historyMonthly => 'شهر';

  @override
  String get insightsWeakRoots => 'الجذور الضعيفة';

  @override
  String get insightsDifficultLemmas => 'الأصعب';

  @override
  String get insightsFrequentlyForgotten => 'يُنسى كثيرًا';

  @override
  String get insightsFastestImproving => 'الأسرع تحسنًا';

  @override
  String get insightsEmpty => 'لا توجد بيانات لهذا القسم بعد.';

  @override
  String get progressDashboardGoals => 'الأهداف';

  @override
  String get progressDashboardAchievements => 'الإنجازات';

  @override
  String get goalDailyStudyLabel => 'الدراسة اليومية';

  @override
  String get goalDailyReviewsLabel => 'المراجعة اليومية';

  @override
  String get goalWeeklyStudyLabel => 'الدراسة الأسبوعية';

  @override
  String goalReviewsProgress(int current, int target) {
    return '$current / $target مراجعات اليوم';
  }

  @override
  String goalWeeklyMinutesProgress(int current, int target) {
    return '$current / $target دقيقة هذا الأسبوع';
  }

  @override
  String get goalAchieved => 'تم تحقيقه';

  @override
  String get achievementFirstStudyTitle => 'أول جلسة دراسة';

  @override
  String get achievementTenCardsTitle => '10 بطاقات تمت دراستها';

  @override
  String get achievementHundredCardsTitle => '100 بطاقة تمت دراستها';

  @override
  String get achievementSevenDayStreakTitle => 'سلسلة 7 أيام';

  @override
  String get achievementThirtyDayStreakTitle => 'سلسلة 30 يومًا';

  @override
  String get achievementSharpMemoryTitle => 'ذاكرة حادة';

  @override
  String achievementProgressCards(int current, int target) {
    return '$current / $target بطاقات';
  }

  @override
  String achievementProgressDays(int current, int target) {
    return '$current / $target أيام';
  }

  @override
  String achievementProgressPercent(int current, int target) {
    return 'الدقة $current% / $target%';
  }

  @override
  String get achievementUnlocked => 'مفتوح';

  @override
  String get achievementLocked => 'مقفل';

  @override
  String get aiTutorTitle => 'المعلم الذكي';

  @override
  String get studyAiTutor => 'المعلم الذكي';

  @override
  String get studyAiTutorDesc => 'اقتراحات مخصّصة بناءً على تقدّمك';

  @override
  String get aiTutorSummaryTitle => 'نظرتك العامة';

  @override
  String get aiTutorSuggestionsTitle => 'اقتراحات';

  @override
  String get aiTutorInsightsTitle => 'ملاحظات';

  @override
  String get aiTutorSuggestionsEmpty =>
      'أنت متابع لكل شيء — لا يوجد ما يستدعي انتباهك الآن.';

  @override
  String get aiTutorLoading => 'جارٍ تحميل معلمك…';

  @override
  String get aiTutorPriorityHigh => 'أولوية عالية';

  @override
  String get aiTutorPriorityMedium => 'أولوية متوسطة';

  @override
  String get aiTutorPriorityLow => 'أولوية منخفضة';

  @override
  String get aiTutorSuggestionReviewDueTitle => 'راجع بطاقاتك المستحقة';

  @override
  String aiTutorSuggestionReviewDueDetail(int count) {
    return '$count بطاقة بانتظارك';
  }

  @override
  String get aiTutorSuggestionDailyStudyTitle => 'أكمل هدف الدراسة اليومي';

  @override
  String aiTutorSuggestionDailyStudyDetail(int count) {
    return 'تبقّى $count دقيقة اليوم';
  }

  @override
  String get aiTutorSuggestionDailyReviewTitle => 'أكمل هدف المراجعة اليومي';

  @override
  String aiTutorSuggestionDailyReviewDetail(int count) {
    return 'تبقّى $count مراجعة اليوم';
  }

  @override
  String get aiTutorSuggestionWeakRootsTitle => 'قوِّ جذورك الضعيفة';

  @override
  String aiTutorSuggestionWeakRootsDetail(int count) {
    return '$count جذر للمراجعة';
  }

  @override
  String get aiTutorSuggestionForgottenTitle =>
      'راجع البطاقات التي تُنسى كثيرًا';

  @override
  String aiTutorSuggestionForgottenDetail(int count) {
    return '$count بطاقة للمراجعة';
  }

  @override
  String get aiTutorSuggestionStreakTitle => 'حافظ على سلسلتك';

  @override
  String aiTutorSuggestionStreakDetail(int count) {
    return 'سلسلة $count يوم';
  }

  @override
  String get aiTutorInsightAchievementsUnlockedLabel => 'الإنجازات المفتوحة';

  @override
  String get aiTutorActionReviewNow => 'راجع الآن';

  @override
  String get aiTutorActionContinueLearning => 'متابعة التعلّم';

  @override
  String get aiTutorActionOpenWeakCards => 'فتح البطاقات الضعيفة';

  @override
  String get aiTutorActionOpenFlashcards => 'فتح البطاقات التعليمية';

  @override
  String get aiTutorJourneyEntryTitle => 'عرض رحلة التعلم الخاصة بك';

  @override
  String get aiTutorJourneyEntryDesc => 'اطّلع على خطة اليوم، خطوة بخطوة';

  @override
  String get learningJourneyTitle => 'رحلة التعلم';

  @override
  String get journeyHeaderTitle => 'خطة اليوم';

  @override
  String journeyStepCountLabel(int count) {
    return '$count خطوة مخطَّطة';
  }

  @override
  String get journeyProgressTitle => 'تقدّمك';

  @override
  String get journeyStepsTitle => 'الخطوات';

  @override
  String get learningJourneyEmpty =>
      'لا يوجد شيء مخطَّط لليوم — أنت متابع لكل شيء!';

  @override
  String get learningJourneyLoading => 'جارٍ تحميل رحلة التعلم الخاصة بك…';

  @override
  String journeyStepNumber(int number) {
    return 'الخطوة $number';
  }

  @override
  String get journeyEntrySmartLearningTitle => 'احصل على جلستك الذكية';

  @override
  String get journeyEntrySmartLearningDesc => 'توصية مخصّصة للحظة الحالية';

  @override
  String get smartLearningTitle => 'التعلّم الذكي';

  @override
  String get smartLearningHeaderTitle => 'جلستك الذكية';

  @override
  String smartLearningRecommendationCountLabel(int count) {
    return '$count توصية اليوم';
  }

  @override
  String get smartLearningRecommendedTitle => 'الجلسة الموصى بها';

  @override
  String get smartLearningOtherRecommendationsTitle => 'توصيات أخرى';

  @override
  String smartLearningRelatedStepsLabel(int count) {
    return '$count خطوة ذات صلة';
  }

  @override
  String get smartLearningEmpty =>
      'لا حاجة إلى جلسة ذكية الآن — أنت متابع لكل شيء!';

  @override
  String get smartLearningLoading => 'جارٍ تحميل جلستك الذكية…';

  @override
  String get smartLearningStrategyShortReview => 'مراجعة سريعة';

  @override
  String get smartLearningStrategyDeepStudy => 'دراسة معمّقة';

  @override
  String get smartLearningStrategyMemorization => 'حفظ';

  @override
  String get smartLearningStrategyRecovery => 'تعافٍ';

  @override
  String get quizCorrect => 'إجابة صحيحة!';

  @override
  String get quizIncorrect => 'إجابة غير صحيحة.';

  @override
  String get quizEmpty => 'لا يوجد محتوى كافٍ لإنشاء اختبار.';

  @override
  String quizQuestionProgress(int current, int total) {
    return 'سؤال $current/$total';
  }

  @override
  String quizScoreResult(int score, int total) {
    return 'نتيجتك $score/$total';
  }

  @override
  String get quizRetry => 'إعادة المحاولة';

  @override
  String get learningSessionStart => 'ابدأ جلسة التعلم';

  @override
  String get learningSummaryTitle => 'ملخص الجلسة';

  @override
  String learningSummaryReviewCount(int count) {
    return 'تمت مراجعة $count بطاقة';
  }

  @override
  String learningSummaryFlashcardCount(int count) {
    return 'تمت مراجعة $count كلمة';
  }

  @override
  String learningSummaryQuizScore(int score, int total) {
    return 'الاختبار: $score/$total';
  }

  @override
  String get learningSummaryDone => 'تم';

  @override
  String get learningSummaryStatusCompleted => 'مكتمل';

  @override
  String get learningSummaryActivitiesTitle => 'الأنشطة المكتملة';

  @override
  String get learningSummaryNotCompleted => 'لم يكتمل';
}
