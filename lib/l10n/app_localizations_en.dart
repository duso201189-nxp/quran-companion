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
  String get studyFlashcardsDesc => 'Memorize ayahs with two-sided cards';

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
