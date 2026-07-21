// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Qur\'an Companion';

  @override
  String get tabHome => 'Home';

  @override
  String get tabQuran => 'Qur\'an';

  @override
  String get tabStudy => 'Study';

  @override
  String get tabStats => 'Statistics';

  @override
  String get tabProfile => 'Profile';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get sectionLanguage => 'Language';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get profilePersonalInfo => 'Personal information';

  @override
  String get profileGoal => 'Learning goal';

  @override
  String get profileSync => 'Cloud sync';

  @override
  String comingInStep(int step) {
    return 'Coming in Step $step';
  }

  @override
  String get placeholderHome =>
      'Step 8 will build the learning dashboard: continue reading, today\'s progress, study streak, verse of the day.';

  @override
  String get placeholderQuran =>
      'Step 3 will show all 114 Surahs with search and Mecca / Madinah filters.';

  @override
  String get placeholderStudy =>
      'Step 9 will build Flashcards (Spaced Repetition) and Quizzes.';

  @override
  String get placeholderStats =>
      'Step 9 will show charts: study streak, total Ayahs, study time, daily journal.';

  @override
  String get searchSurahHint => 'Search Surah by name or number...';

  @override
  String get filterAll => 'All';

  @override
  String get revelationMecca => 'Mecca';

  @override
  String get revelationMadinah => 'Madinah';

  @override
  String surahAyahCount(int count) {
    return '$count verses';
  }

  @override
  String get errorLoadData => 'Could not load data. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get emptySearchResults => 'No Surah matches your search.';

  @override
  String get displaySettings => 'Display';

  @override
  String get readingFontSize => 'Arabic font size';

  @override
  String get showTransliteration => 'Transliteration';

  @override
  String get showVietnamese => 'Vietnamese translation';

  @override
  String get showEnglish => 'English translation';

  @override
  String get surahNotFound => 'This Surah was not found.';

  @override
  String get surahNoContent =>
      'No content for this Surah. Rebuild the data (docs/DATA_PIPELINE.md).';

  @override
  String ayahSemanticLabel(int number) {
    return 'Ayah $number';
  }

  @override
  String get sajdahAyah => 'Sajdah (prostration) ayah';

  @override
  String get focusMode => 'Focus mode';

  @override
  String get readingModeMushaf => 'Mushaf mode';

  @override
  String get readingModeList => 'List mode';

  @override
  String pageLabel(int number) {
    return 'Page $number';
  }

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get nextAyah => 'Next ayah';

  @override
  String get previousAyah => 'Previous ayah';

  @override
  String get repeatMode => 'Repeat mode';

  @override
  String get stopAudio => 'Stop audio';

  @override
  String get selectReciter => 'Select reciter';

  @override
  String get playFromHere => 'Play from this ayah';

  @override
  String get bookmarkLabel => 'Bookmark';

  @override
  String get statusLabel => 'Learning status';

  @override
  String get statusNone => 'Unread';

  @override
  String get statusLearning => 'Learning';

  @override
  String get statusLearned => 'Learned';

  @override
  String get statusReview => 'To review';

  @override
  String get noteLabel => 'Note';

  @override
  String get addNote => 'Add note';

  @override
  String get editNote => 'Edit note';

  @override
  String get noteHint => 'Supports **bold** and *italic*';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get copyAyah => 'Copy';

  @override
  String get shareAyah => 'Share';

  @override
  String get ayahCopied => 'Copied to clipboard';

  @override
  String get moreActions => 'More';

  @override
  String get continueReading => 'Continue reading';

  @override
  String get startReading => 'Start reading';

  @override
  String get todaysVerse => 'Today\'s verse';

  @override
  String get homeLoading => 'Loading your home screen…';

  @override
  String get homeTodaysVerseLoading => 'Loading today\'s verse…';

  @override
  String get dailyProgress => 'Daily progress';

  @override
  String get lastRead => 'Last read';

  @override
  String get quickAccess => 'Quick access';

  @override
  String get learningStreak => 'Learning streak';

  @override
  String streakDays(int count) {
    return '$count days';
  }

  @override
  String get recentSurahs => 'Recent Surahs';

  @override
  String get ayahsReadLabel => 'Ayahs read';

  @override
  String get minutesLabel => 'Minutes';

  @override
  String get myBookmarks => 'My bookmarks';

  @override
  String get studyFlashcards => 'Flashcards';

  @override
  String get studyFlashcardsDesc =>
      'Memorize Qur\'an vocabulary with two-sided cards';

  @override
  String get studySpaced => 'Spaced repetition';

  @override
  String get studySpacedDesc =>
      'Review right before you forget — remember longer';

  @override
  String get studyQuiz => 'Quiz';

  @override
  String get studyQuizDesc => 'Quick knowledge checks per Surah';

  @override
  String get studyDailyReview => 'Daily review';

  @override
  String get studyDailyReviewDesc => 'Ayahs due for review today';

  @override
  String get studyProgress => 'Progress';

  @override
  String get studyProgressDesc => 'Stats, history, and improvement tips';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get statsReadingDays => 'Reading days';

  @override
  String get statsAyahsRead => 'Ayahs read';

  @override
  String get statsMinutes => 'Minutes studied';

  @override
  String get statsCompletion => 'Qur\'an completion';

  @override
  String get statsCurrentStreak => 'Current streak';

  @override
  String get statsLongestStreak => 'Longest streak';

  @override
  String get statsWeeklyActivity => 'Last 7 days';

  @override
  String get statsNoData => 'Start reading to record statistics.';

  @override
  String get sectionAbout => 'About';

  @override
  String get aboutSources => 'Data sources';

  @override
  String get aboutSourcesDetail =>
      'Arabic text & translations: Tanzil.net · QuranEnc.com. Audio: EveryAyah.com. Font: KFGQPC (King Fahd Complex).';

  @override
  String get versionLabel => 'Version';

  @override
  String get audioError => 'Playback failed. Check your connection.';

  @override
  String get audioLoading => 'Loading audio...';

  @override
  String get favoriteLabel => 'Favorite';

  @override
  String get copyArabic => 'Copy Arabic';

  @override
  String get copyTranslation => 'Copy translation';

  @override
  String get searchResultsAyahs => 'Results in content';

  @override
  String get searchNoAyahResults => 'No matching ayahs found.';

  @override
  String get searchLabel => 'Search';

  @override
  String get searchAskLabel => 'Ask AI';

  @override
  String get searchQueryHint => 'Search the Qur\'an...';

  @override
  String get searchClearTooltip => 'Clear';

  @override
  String get searchScopeMyNotes => 'My notes';

  @override
  String get searchEmptyTitle => 'Find what you\'re looking for';

  @override
  String get searchEmptySubtitle =>
      'Type a Surah name, an ayah reference (e.g. 2:255), or a keyword.';

  @override
  String get searchEmptyRecentSectionTitle => 'Recent';

  @override
  String get searchEmptySuggestedSectionTitle => 'Suggested';

  @override
  String get searchLoadingLabel => 'Searching...';

  @override
  String get libraryTitle => 'My Library';

  @override
  String get libraryBookmarks => 'Bookmarks';

  @override
  String get libraryFavorites => 'Favorites';

  @override
  String get libraryNotes => 'Notes';

  @override
  String get libraryHighlights => 'Highlights';

  @override
  String get libraryEmptyBookmarks => 'No bookmarked ayahs yet.';

  @override
  String get libraryEmptyFavorites => 'No favorite ayahs yet.';

  @override
  String get libraryEmptyNotes => 'No notes yet.';

  @override
  String get libraryEmptyHighlights => 'No highlighted ayahs yet.';

  @override
  String get statsSessionsTitle => 'Reading Sessions';

  @override
  String get statsSessionsEmpty => 'No reading sessions logged yet.';

  @override
  String get statsTodayTitle => 'Today';

  @override
  String statsTodayMinutes(int count) {
    return '$count min';
  }

  @override
  String statsTodaySessionsCount(int count) {
    return '$count sessions';
  }

  @override
  String get khatmSectionTitle => 'Active Khatm';

  @override
  String get khatmEmpty => 'No active Khatm cycle.';

  @override
  String get khatmStart => 'Start Khatm';

  @override
  String get khatmDefaultName => 'My Khatm';

  @override
  String get khatmProgressLabel => 'Progress';

  @override
  String get khatmContinueReading => 'Continue reading';

  @override
  String khatmAyahPosition(int current, int total) {
    return 'Ayah $current / $total';
  }

  @override
  String get collectionsTitle => 'Collections';

  @override
  String get collectionsEmpty => 'No collections yet.';

  @override
  String get collectionsCreate => 'New collection';

  @override
  String get collectionsRename => 'Rename';

  @override
  String get collectionsDelete => 'Delete';

  @override
  String get collectionsDeleteConfirmTitle => 'Delete collection?';

  @override
  String get collectionsDeleteConfirmBody =>
      'Bookmarks stay, only the collection is removed.';

  @override
  String get collectionNameHint => 'Collection name';

  @override
  String get collectionEmojiHint => 'Emoji (optional)';

  @override
  String collectionItemCount(int count) {
    return '$count ayahs';
  }

  @override
  String get collectionAssignTitle => 'Add to collection';

  @override
  String get libraryOrganizeTooltip => 'Organize into collection';

  @override
  String get revisionQueueEmpty => 'No ayahs need review yet.';

  @override
  String get dailyGoalMinutesHint => 'Minutes per day';

  @override
  String get dailyGoalAyahsHint => 'Ayahs per day';

  @override
  String get dailyGoalNotSet => 'No goal set yet — tap to set one.';

  @override
  String dailyGoalMinutesProgress(int current, int target) {
    return '$current / $target min today';
  }

  @override
  String get reviewGradeAgain => 'Again';

  @override
  String get reviewGradeHard => 'Hard';

  @override
  String get reviewGradeGood => 'Good';

  @override
  String get reviewGradeEasy => 'Easy';

  @override
  String get reviewOpenInReading => 'Open in Reading';

  @override
  String get reviewSessionComplete => 'Session complete!';

  @override
  String get reviewSessionCompleteSubtitle =>
      'No cards are due for review right now.';

  @override
  String get flashcardReviewTitle => 'Flashcards';

  @override
  String get flashcardReviewComplete => 'Flashcards complete!';

  @override
  String get flashcardReviewCompleteSubtitle =>
      'No vocabulary is due for review right now.';

  @override
  String get flashcardsTitle => 'Flashcards';

  @override
  String get flashcardSearchHint =>
      'Search Arabic, transliteration, or meaning';

  @override
  String get flashcardAdd => 'Add';

  @override
  String get flashcardContentUnavailable => 'Content unavailable';

  @override
  String get flashcardMoveToDeck => 'Move to deck';

  @override
  String get flashcardRemove => 'Remove flashcard';

  @override
  String get flashcardNoDeck => 'No deck';

  @override
  String get flashcardEmptyDeck => 'This deck has no flashcards yet.';

  @override
  String get flashcardNoResults => 'No matching flashcards.';

  @override
  String get flashcardFilterAllDecks => 'All decks';

  @override
  String get flashcardFilterAllTypes => 'All types';

  @override
  String get flashcardFilterAllStatus => 'All statuses';

  @override
  String get flashcardFilterDue => 'Due';

  @override
  String get flashcardFilterNew => 'New';

  @override
  String get flashcardFilterLearning => 'Learning';

  @override
  String get flashcardFilterReview => 'Review';

  @override
  String get flashcardFilterLapsed => 'Lapsed';

  @override
  String get flashcardOnboardingTitle => 'No flashcards yet';

  @override
  String get flashcardOnboardingBody =>
      'Add your first vocabulary flashcard to start learning with spaced repetition.';

  @override
  String get flashcardOnboardingCta => 'Add your first flashcard';

  @override
  String get flashcardOnboardingReviewNudge =>
      'First flashcard added! Try reviewing it now?';

  @override
  String get flashcardOnboardingReviewCta => 'Review now';

  @override
  String get flashcardDecksTitle => 'Flashcard decks';

  @override
  String get flashcardDecksEmpty => 'No decks yet.';

  @override
  String get flashcardDecksCreate => 'Create deck';

  @override
  String get flashcardDecksRename => 'Rename';

  @override
  String get flashcardDecksDelete => 'Delete';

  @override
  String get flashcardDecksDeleteConfirmTitle => 'Delete deck?';

  @override
  String get flashcardDecksDeleteConfirmBody =>
      'Flashcards in this deck will move to \"No deck\" — they won\'t be deleted.';

  @override
  String get flashcardDeckNameHint => 'Deck name';

  @override
  String flashcardDeckItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
      zero: 'No cards yet',
    );
    return '$_temp0';
  }

  @override
  String get addFlashcardTitle => 'Add flashcard';

  @override
  String get addFlashcardSourceLemma => 'Lemma';

  @override
  String get addFlashcardSourceRoot => 'Root';

  @override
  String get addFlashcardSourcePhrase => 'Phrase';

  @override
  String get addFlashcardSourceNotAvailable =>
      'No browsable data for this type yet.';

  @override
  String get addFlashcardSearchHint => 'Search...';

  @override
  String get addFlashcardNoResults => 'No results found.';

  @override
  String get addFlashcardAdd => 'Add to flashcards';

  @override
  String get smartDeckTodaysReview => 'Today\'s Review';

  @override
  String get smartDeckMostDifficult => 'Most Difficult';

  @override
  String get smartDeckRecentlyLearned => 'Recently Learned';

  @override
  String get smartDeckWeakRoots => 'Weak Roots';

  @override
  String get smartDeckVerbForms => 'Verb Forms';

  @override
  String get smartDeckEmpty => 'No flashcards in this Smart Deck yet.';

  @override
  String smartDeckVerbFormLabel(String form) {
    return 'Form $form';
  }

  @override
  String get progressDashboardTitle => 'Progress';

  @override
  String get progressDashboardEmpty =>
      'No flashcards studied yet — stats will show up once you start learning.';

  @override
  String get progressDashboardHistory => 'Activity history';

  @override
  String get progressDashboardHistoryEmpty =>
      'No reading activity in this period yet.';

  @override
  String get progressDashboardInsights => 'Improvement tips';

  @override
  String get progressDashboardOverview => 'Overview';

  @override
  String get progressDashboardLoading => 'Loading progress data…';

  @override
  String get statCardsStudied => 'Cards studied';

  @override
  String get statReviewsToday => 'Reviews today';

  @override
  String get statAccuracy => 'Accuracy';

  @override
  String get statAverageEase => 'Average ease';

  @override
  String get statAverageInterval => 'Average interval (days)';

  @override
  String get historyDaily => 'Day';

  @override
  String get historyWeekly => 'Week';

  @override
  String get historyMonthly => 'Month';

  @override
  String get insightsWeakRoots => 'Weak roots';

  @override
  String get insightsDifficultLemmas => 'Most difficult';

  @override
  String get insightsFrequentlyForgotten => 'Frequently forgotten';

  @override
  String get insightsFastestImproving => 'Fastest improving';

  @override
  String get insightsEmpty => 'No data for this yet.';

  @override
  String get progressDashboardGoals => 'Goals';

  @override
  String get progressDashboardAchievements => 'Achievements';

  @override
  String get goalDailyStudyLabel => 'Daily study';

  @override
  String get goalDailyReviewsLabel => 'Daily reviews';

  @override
  String get goalWeeklyStudyLabel => 'Weekly study';

  @override
  String goalReviewsProgress(int current, int target) {
    return '$current / $target reviews today';
  }

  @override
  String goalWeeklyMinutesProgress(int current, int target) {
    return '$current / $target min this week';
  }

  @override
  String get goalAchieved => 'Achieved';

  @override
  String get achievementFirstStudyTitle => 'First study';

  @override
  String get achievementTenCardsTitle => '10 cards studied';

  @override
  String get achievementHundredCardsTitle => '100 cards studied';

  @override
  String get achievementSevenDayStreakTitle => '7-day streak';

  @override
  String get achievementThirtyDayStreakTitle => '30-day streak';

  @override
  String get achievementSharpMemoryTitle => 'Sharp memory';

  @override
  String achievementProgressCards(int current, int target) {
    return '$current / $target cards';
  }

  @override
  String achievementProgressDays(int current, int target) {
    return '$current / $target days';
  }

  @override
  String achievementProgressPercent(int current, int target) {
    return '$current% / $target% accuracy';
  }

  @override
  String get achievementUnlocked => 'Unlocked';

  @override
  String get achievementLocked => 'Locked';

  @override
  String get aiTutorTitle => 'AI Tutor';

  @override
  String get studyAiTutor => 'AI Tutor';

  @override
  String get studyAiTutorDesc =>
      'Personalized suggestions based on your progress';

  @override
  String get aiTutorSummaryTitle => 'Your overview';

  @override
  String get aiTutorSuggestionsTitle => 'Suggestions';

  @override
  String get aiTutorInsightsTitle => 'Insights';

  @override
  String get aiTutorSuggestionsEmpty =>
      'You\'re all caught up — nothing needs your attention right now.';

  @override
  String get aiTutorLoading => 'Loading your tutor…';

  @override
  String get aiTutorPriorityHigh => 'High priority';

  @override
  String get aiTutorPriorityMedium => 'Medium priority';

  @override
  String get aiTutorPriorityLow => 'Low priority';

  @override
  String get aiTutorSuggestionReviewDueTitle => 'Review your due cards';

  @override
  String aiTutorSuggestionReviewDueDetail(int count) {
    return '$count cards waiting';
  }

  @override
  String get aiTutorSuggestionDailyStudyTitle => 'Reach your daily study goal';

  @override
  String aiTutorSuggestionDailyStudyDetail(int count) {
    return '$count min left today';
  }

  @override
  String get aiTutorSuggestionDailyReviewTitle =>
      'Reach your daily review goal';

  @override
  String aiTutorSuggestionDailyReviewDetail(int count) {
    return '$count reviews left today';
  }

  @override
  String get aiTutorSuggestionWeakRootsTitle => 'Strengthen your weak roots';

  @override
  String aiTutorSuggestionWeakRootsDetail(int count) {
    return '$count roots to review';
  }

  @override
  String get aiTutorSuggestionForgottenTitle =>
      'Review frequently forgotten cards';

  @override
  String aiTutorSuggestionForgottenDetail(int count) {
    return '$count cards to revisit';
  }

  @override
  String get aiTutorSuggestionStreakTitle => 'Keep your streak alive';

  @override
  String aiTutorSuggestionStreakDetail(int count) {
    return '$count-day streak';
  }

  @override
  String get aiTutorInsightAchievementsUnlockedLabel => 'Achievements unlocked';

  @override
  String get aiTutorActionReviewNow => 'Review now';

  @override
  String get aiTutorActionContinueLearning => 'Continue learning';

  @override
  String get aiTutorActionOpenWeakCards => 'Open weak cards';

  @override
  String get aiTutorActionOpenFlashcards => 'Open flashcards';

  @override
  String get aiTutorJourneyEntryTitle => 'View your Learning Journey';

  @override
  String get aiTutorJourneyEntryDesc =>
      'See today\'s plan, ordered step by step';

  @override
  String get learningJourneyTitle => 'Learning Journey';

  @override
  String get journeyHeaderTitle => 'Today\'s plan';

  @override
  String journeyStepCountLabel(int count) {
    return '$count steps planned';
  }

  @override
  String get journeyProgressTitle => 'Your progress';

  @override
  String get journeyStepsTitle => 'Steps';

  @override
  String get learningJourneyEmpty =>
      'Nothing planned for today — you\'re all caught up!';

  @override
  String get learningJourneyLoading => 'Loading your learning journey…';

  @override
  String journeyStepNumber(int number) {
    return 'Step $number';
  }

  @override
  String get journeyEntrySmartLearningTitle => 'Get your Smart Session';

  @override
  String get journeyEntrySmartLearningDesc =>
      'A personalized recommendation for right now';

  @override
  String get smartLearningTitle => 'Smart Learning';

  @override
  String get smartLearningHeaderTitle => 'Your smart session';

  @override
  String smartLearningRecommendationCountLabel(int count) {
    return '$count recommendations today';
  }

  @override
  String get smartLearningRecommendedTitle => 'Recommended session';

  @override
  String get smartLearningOtherRecommendationsTitle => 'Other recommendations';

  @override
  String smartLearningRelatedStepsLabel(int count) {
    return '$count related steps';
  }

  @override
  String get smartLearningEmpty =>
      'No smart session needed right now — you\'re all caught up!';

  @override
  String get smartLearningLoading => 'Loading your smart session…';

  @override
  String get smartLearningStrategyShortReview => 'Short review';

  @override
  String get smartLearningStrategyDeepStudy => 'Deep study';

  @override
  String get smartLearningStrategyMemorization => 'Memorization';

  @override
  String get smartLearningStrategyRecovery => 'Recovery';

  @override
  String get quizCorrect => 'Correct!';

  @override
  String get quizIncorrect => 'Not quite.';

  @override
  String get quizEmpty => 'Not enough content to build a quiz.';

  @override
  String quizQuestionProgress(int current, int total) {
    return 'Question $current/$total';
  }

  @override
  String quizScoreResult(int score, int total) {
    return 'You scored $score/$total';
  }

  @override
  String get quizRetry => 'Retry';

  @override
  String get learningSessionStart => 'Start Learning Session';

  @override
  String get learningSummaryTitle => 'Session Summary';

  @override
  String learningSummaryReviewCount(int count) {
    return 'Reviewed $count cards';
  }

  @override
  String learningSummaryFlashcardCount(int count) {
    return 'Reviewed $count words';
  }

  @override
  String learningSummaryQuizScore(int score, int total) {
    return 'Quiz: $score/$total';
  }

  @override
  String get learningSummaryDone => 'Done';

  @override
  String get learningSummaryStatusCompleted => 'Completed';

  @override
  String get learningSummaryActivitiesTitle => 'Activities completed';

  @override
  String get learningSummaryNotCompleted => 'Not completed';
}
