import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In vi, this message translates to:
  /// **'Qur\'an Companion'**
  String get appTitle;

  /// No description provided for @tabHome.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get tabHome;

  /// No description provided for @tabQuran.
  ///
  /// In vi, this message translates to:
  /// **'Qur\'an'**
  String get tabQuran;

  /// No description provided for @tabStudy.
  ///
  /// In vi, this message translates to:
  /// **'Học'**
  String get tabStudy;

  /// No description provided for @tabStats.
  ///
  /// In vi, this message translates to:
  /// **'Thống kê'**
  String get tabStats;

  /// No description provided for @tabProfile.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ'**
  String get tabProfile;

  /// No description provided for @sectionAppearance.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get sectionAppearance;

  /// No description provided for @sectionLanguage.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get sectionLanguage;

  /// No description provided for @themeLight.
  ///
  /// In vi, this message translates to:
  /// **'Sáng'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In vi, this message translates to:
  /// **'Hệ thống'**
  String get themeSystem;

  /// No description provided for @themeDark.
  ///
  /// In vi, this message translates to:
  /// **'Tối'**
  String get themeDark;

  /// No description provided for @languageVietnamese.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get languageVietnamese;

  /// No description provided for @languageEnglish.
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In vi, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin cá nhân'**
  String get profilePersonalInfo;

  /// No description provided for @profileGoal.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu học'**
  String get profileGoal;

  /// No description provided for @profileSync.
  ///
  /// In vi, this message translates to:
  /// **'Đồng bộ đám mây'**
  String get profileSync;

  /// No description provided for @comingInStep.
  ///
  /// In vi, this message translates to:
  /// **'Sẽ xây dựng ở Bước {step}'**
  String comingInStep(int step);

  /// No description provided for @placeholderHome.
  ///
  /// In vi, this message translates to:
  /// **'Bước 8 sẽ xây dựng Dashboard học tập: tiếp tục đọc, tiến độ hôm nay, chuỗi ngày học, câu Qur\'an trong ngày.'**
  String get placeholderHome;

  /// No description provided for @placeholderQuran.
  ///
  /// In vi, this message translates to:
  /// **'Bước 3 sẽ hiển thị danh sách 114 Surah với tìm kiếm và bộ lọc Mecca / Madinah.'**
  String get placeholderQuran;

  /// No description provided for @placeholderStudy.
  ///
  /// In vi, this message translates to:
  /// **'Bước 9 sẽ xây dựng Flashcard (Spaced Repetition) và Quiz.'**
  String get placeholderStudy;

  /// No description provided for @placeholderStats.
  ///
  /// In vi, this message translates to:
  /// **'Bước 9 sẽ hiển thị biểu đồ: chuỗi ngày học, tổng Ayah, thời gian học, nhật ký học.'**
  String get placeholderStats;

  /// No description provided for @searchSurahHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm Surah theo tên hoặc số...'**
  String get searchSurahHint;

  /// No description provided for @filterAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get filterAll;

  /// No description provided for @revelationMecca.
  ///
  /// In vi, this message translates to:
  /// **'Mecca'**
  String get revelationMecca;

  /// No description provided for @revelationMadinah.
  ///
  /// In vi, this message translates to:
  /// **'Madinah'**
  String get revelationMadinah;

  /// No description provided for @surahAyahCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} câu'**
  String surahAyahCount(int count);

  /// No description provided for @errorLoadData.
  ///
  /// In vi, this message translates to:
  /// **'Không tải được dữ liệu. Vui lòng thử lại.'**
  String get errorLoadData;

  /// No description provided for @retry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get retry;

  /// No description provided for @emptySearchResults.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy Surah nào phù hợp.'**
  String get emptySearchResults;

  /// No description provided for @displaySettings.
  ///
  /// In vi, this message translates to:
  /// **'Hiển thị'**
  String get displaySettings;

  /// No description provided for @readingFontSize.
  ///
  /// In vi, this message translates to:
  /// **'Cỡ chữ Ả Rập'**
  String get readingFontSize;

  /// No description provided for @showTransliteration.
  ///
  /// In vi, this message translates to:
  /// **'Phiên âm Latin'**
  String get showTransliteration;

  /// No description provided for @showVietnamese.
  ///
  /// In vi, this message translates to:
  /// **'Bản dịch tiếng Việt'**
  String get showVietnamese;

  /// No description provided for @showEnglish.
  ///
  /// In vi, this message translates to:
  /// **'Bản dịch tiếng Anh'**
  String get showEnglish;

  /// No description provided for @surahNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy Surah này.'**
  String get surahNotFound;

  /// No description provided for @surahNoContent.
  ///
  /// In vi, this message translates to:
  /// **'Surah chưa có nội dung. Hãy build lại dữ liệu (docs/DATA_PIPELINE.md).'**
  String get surahNoContent;

  /// No description provided for @ayahSemanticLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ayah {number}'**
  String ayahSemanticLabel(int number);

  /// No description provided for @sajdahAyah.
  ///
  /// In vi, this message translates to:
  /// **'Ayah có sajdah (quỳ lạy)'**
  String get sajdahAyah;

  /// No description provided for @focusMode.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ tập trung'**
  String get focusMode;

  /// No description provided for @readingModeMushaf.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ Mushaf'**
  String get readingModeMushaf;

  /// No description provided for @readingModeList.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ danh sách'**
  String get readingModeList;

  /// No description provided for @pageLabel.
  ///
  /// In vi, this message translates to:
  /// **'Trang {number}'**
  String pageLabel(int number);

  /// No description provided for @play.
  ///
  /// In vi, this message translates to:
  /// **'Phát'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In vi, this message translates to:
  /// **'Tạm dừng'**
  String get pause;

  /// No description provided for @nextAyah.
  ///
  /// In vi, this message translates to:
  /// **'Ayah kế'**
  String get nextAyah;

  /// No description provided for @previousAyah.
  ///
  /// In vi, this message translates to:
  /// **'Ayah trước'**
  String get previousAyah;

  /// No description provided for @repeatMode.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ lặp'**
  String get repeatMode;

  /// No description provided for @stopAudio.
  ///
  /// In vi, this message translates to:
  /// **'Dừng nghe'**
  String get stopAudio;

  /// No description provided for @selectReciter.
  ///
  /// In vi, this message translates to:
  /// **'Chọn Qari'**
  String get selectReciter;

  /// No description provided for @playFromHere.
  ///
  /// In vi, this message translates to:
  /// **'Nghe từ Ayah này'**
  String get playFromHere;

  /// No description provided for @bookmarkLabel.
  ///
  /// In vi, this message translates to:
  /// **'Bookmark'**
  String get bookmarkLabel;

  /// No description provided for @statusLabel.
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái học'**
  String get statusLabel;

  /// No description provided for @statusNone.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đọc'**
  String get statusNone;

  /// No description provided for @statusLearning.
  ///
  /// In vi, this message translates to:
  /// **'Đang học'**
  String get statusLearning;

  /// No description provided for @statusLearned.
  ///
  /// In vi, this message translates to:
  /// **'Đã học'**
  String get statusLearned;

  /// No description provided for @statusReview.
  ///
  /// In vi, this message translates to:
  /// **'Cần ôn'**
  String get statusReview;

  /// No description provided for @noteLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get noteLabel;

  /// No description provided for @addNote.
  ///
  /// In vi, this message translates to:
  /// **'Thêm ghi chú'**
  String get addNote;

  /// No description provided for @editNote.
  ///
  /// In vi, this message translates to:
  /// **'Sửa ghi chú'**
  String get editNote;

  /// No description provided for @noteHint.
  ///
  /// In vi, this message translates to:
  /// **'Hỗ trợ **đậm** và *nghiêng*'**
  String get noteHint;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @copyAyah.
  ///
  /// In vi, this message translates to:
  /// **'Sao chép'**
  String get copyAyah;

  /// No description provided for @shareAyah.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ'**
  String get shareAyah;

  /// No description provided for @ayahCopied.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép vào bộ nhớ tạm'**
  String get ayahCopied;

  /// No description provided for @moreActions.
  ///
  /// In vi, this message translates to:
  /// **'Thêm'**
  String get moreActions;

  /// No description provided for @continueReading.
  ///
  /// In vi, this message translates to:
  /// **'Đọc tiếp'**
  String get continueReading;

  /// No description provided for @startReading.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu đọc'**
  String get startReading;

  /// No description provided for @todaysVerse.
  ///
  /// In vi, this message translates to:
  /// **'Câu Qur\'an hôm nay'**
  String get todaysVerse;

  /// No description provided for @homeLoading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải trang chủ…'**
  String get homeLoading;

  /// No description provided for @homeTodaysVerseLoading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải câu Qur\'an hôm nay…'**
  String get homeTodaysVerseLoading;

  /// No description provided for @dailyProgress.
  ///
  /// In vi, this message translates to:
  /// **'Tiến độ hôm nay'**
  String get dailyProgress;

  /// No description provided for @lastRead.
  ///
  /// In vi, this message translates to:
  /// **'Đọc gần đây'**
  String get lastRead;

  /// No description provided for @quickAccess.
  ///
  /// In vi, this message translates to:
  /// **'Truy cập nhanh'**
  String get quickAccess;

  /// No description provided for @learningStreak.
  ///
  /// In vi, this message translates to:
  /// **'Chuỗi ngày học'**
  String get learningStreak;

  /// No description provided for @streakDays.
  ///
  /// In vi, this message translates to:
  /// **'{count} ngày'**
  String streakDays(int count);

  /// No description provided for @recentSurahs.
  ///
  /// In vi, this message translates to:
  /// **'Surah gần đây'**
  String get recentSurahs;

  /// No description provided for @ayahsReadLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ayah đã đọc'**
  String get ayahsReadLabel;

  /// No description provided for @minutesLabel.
  ///
  /// In vi, this message translates to:
  /// **'Phút học'**
  String get minutesLabel;

  /// No description provided for @myBookmarks.
  ///
  /// In vi, this message translates to:
  /// **'Bookmark của tôi'**
  String get myBookmarks;

  /// No description provided for @studyFlashcards.
  ///
  /// In vi, this message translates to:
  /// **'Flashcard'**
  String get studyFlashcards;

  /// No description provided for @studyFlashcardsDesc.
  ///
  /// In vi, this message translates to:
  /// **'Ghi nhớ từ vựng Qur\'an bằng thẻ hai mặt'**
  String get studyFlashcardsDesc;

  /// No description provided for @studySpaced.
  ///
  /// In vi, this message translates to:
  /// **'Lặp lại ngắt quãng'**
  String get studySpaced;

  /// No description provided for @studySpacedDesc.
  ///
  /// In vi, this message translates to:
  /// **'Ôn đúng lúc sắp quên — nhớ lâu hơn'**
  String get studySpacedDesc;

  /// No description provided for @studyQuiz.
  ///
  /// In vi, this message translates to:
  /// **'Trắc nghiệm'**
  String get studyQuiz;

  /// No description provided for @studyQuizDesc.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra nhanh kiến thức Surah'**
  String get studyQuizDesc;

  /// No description provided for @studyDailyReview.
  ///
  /// In vi, this message translates to:
  /// **'Ôn tập hằng ngày'**
  String get studyDailyReview;

  /// No description provided for @studyDailyReviewDesc.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách Ayah cần ôn hôm nay'**
  String get studyDailyReviewDesc;

  /// No description provided for @studyProgress.
  ///
  /// In vi, this message translates to:
  /// **'Tiến độ học tập'**
  String get studyProgress;

  /// No description provided for @studyProgressDesc.
  ///
  /// In vi, this message translates to:
  /// **'Số liệu, lịch sử và gợi ý cải thiện'**
  String get studyProgressDesc;

  /// No description provided for @comingSoon.
  ///
  /// In vi, this message translates to:
  /// **'Sắp ra mắt'**
  String get comingSoon;

  /// No description provided for @statsReadingDays.
  ///
  /// In vi, this message translates to:
  /// **'Ngày đọc'**
  String get statsReadingDays;

  /// No description provided for @statsAyahsRead.
  ///
  /// In vi, this message translates to:
  /// **'Ayah đã đọc'**
  String get statsAyahsRead;

  /// No description provided for @statsMinutes.
  ///
  /// In vi, this message translates to:
  /// **'Phút học'**
  String get statsMinutes;

  /// No description provided for @statsCompletion.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành Qur\'an'**
  String get statsCompletion;

  /// No description provided for @statsCurrentStreak.
  ///
  /// In vi, this message translates to:
  /// **'Chuỗi hiện tại'**
  String get statsCurrentStreak;

  /// No description provided for @statsLongestStreak.
  ///
  /// In vi, this message translates to:
  /// **'Chuỗi dài nhất'**
  String get statsLongestStreak;

  /// No description provided for @statsWeeklyActivity.
  ///
  /// In vi, this message translates to:
  /// **'Hoạt động 7 ngày qua'**
  String get statsWeeklyActivity;

  /// No description provided for @statsNoData.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu đọc để ghi nhận thống kê.'**
  String get statsNoData;

  /// No description provided for @sectionAbout.
  ///
  /// In vi, this message translates to:
  /// **'Giới thiệu'**
  String get sectionAbout;

  /// No description provided for @aboutSources.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn dữ liệu'**
  String get aboutSources;

  /// No description provided for @aboutSourcesDetail.
  ///
  /// In vi, this message translates to:
  /// **'Văn bản Ả Rập & bản dịch: Tanzil.net · QuranEnc.com. Audio: EveryAyah.com. Font: KFGQPC (King Fahd Complex).'**
  String get aboutSourcesDetail;

  /// No description provided for @versionLabel.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản'**
  String get versionLabel;

  /// No description provided for @audioError.
  ///
  /// In vi, this message translates to:
  /// **'Không phát được audio. Kiểm tra kết nối mạng.'**
  String get audioError;

  /// No description provided for @audioLoading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải audio...'**
  String get audioLoading;

  /// No description provided for @favoriteLabel.
  ///
  /// In vi, this message translates to:
  /// **'Yêu thích'**
  String get favoriteLabel;

  /// No description provided for @copyArabic.
  ///
  /// In vi, this message translates to:
  /// **'Sao chép chữ Ả Rập'**
  String get copyArabic;

  /// No description provided for @copyTranslation.
  ///
  /// In vi, this message translates to:
  /// **'Sao chép bản dịch'**
  String get copyTranslation;

  /// No description provided for @searchResultsAyahs.
  ///
  /// In vi, this message translates to:
  /// **'Kết quả trong nội dung'**
  String get searchResultsAyahs;

  /// No description provided for @searchNoAyahResults.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy Ayah nào phù hợp.'**
  String get searchNoAyahResults;

  /// No description provided for @searchLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm'**
  String get searchLabel;

  /// No description provided for @searchAskLabel.
  ///
  /// In vi, this message translates to:
  /// **'Hỏi AI'**
  String get searchAskLabel;

  /// No description provided for @searchQueryHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm trong Qur\'an...'**
  String get searchQueryHint;

  /// No description provided for @searchClearTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Xoá'**
  String get searchClearTooltip;

  /// No description provided for @searchScopeMyNotes.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú của tôi'**
  String get searchScopeMyNotes;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tìm điều bạn cần trong Qur\'an'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptySubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhập tên Surah, số Ayah (ví dụ 2:255), hoặc một từ khoá.'**
  String get searchEmptySubtitle;

  /// No description provided for @searchEmptyRecentSectionTitle.
  ///
  /// In vi, this message translates to:
  /// **'Gần đây'**
  String get searchEmptyRecentSectionTitle;

  /// No description provided for @searchEmptySuggestedSectionTitle.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý'**
  String get searchEmptySuggestedSectionTitle;

  /// No description provided for @searchLoadingLabel.
  ///
  /// In vi, this message translates to:
  /// **'Đang tìm kiếm...'**
  String get searchLoadingLabel;

  /// No description provided for @libraryTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thư viện của tôi'**
  String get libraryTitle;

  /// No description provided for @libraryBookmarks.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu'**
  String get libraryBookmarks;

  /// No description provided for @libraryFavorites.
  ///
  /// In vi, this message translates to:
  /// **'Yêu thích'**
  String get libraryFavorites;

  /// No description provided for @libraryNotes.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get libraryNotes;

  /// No description provided for @libraryHighlights.
  ///
  /// In vi, this message translates to:
  /// **'Tô màu'**
  String get libraryHighlights;

  /// No description provided for @libraryEmptyBookmarks.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có Ayah nào được lưu.'**
  String get libraryEmptyBookmarks;

  /// No description provided for @libraryEmptyFavorites.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có Ayah yêu thích nào.'**
  String get libraryEmptyFavorites;

  /// No description provided for @libraryEmptyNotes.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có ghi chú nào.'**
  String get libraryEmptyNotes;

  /// No description provided for @libraryEmptyHighlights.
  ///
  /// In vi, this message translates to:
  /// **'Chưa tô màu Ayah nào.'**
  String get libraryEmptyHighlights;

  /// No description provided for @statsSessionsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Phiên đọc'**
  String get statsSessionsTitle;

  /// No description provided for @statsSessionsEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có phiên đọc nào được ghi nhận.'**
  String get statsSessionsEmpty;

  /// No description provided for @statsTodayTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get statsTodayTitle;

  /// No description provided for @statsTodayMinutes.
  ///
  /// In vi, this message translates to:
  /// **'{count} phút'**
  String statsTodayMinutes(int count);

  /// No description provided for @statsTodaySessionsCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} phiên'**
  String statsTodaySessionsCount(int count);

  /// No description provided for @khatmSectionTitle.
  ///
  /// In vi, this message translates to:
  /// **'Khatm đang đọc'**
  String get khatmSectionTitle;

  /// No description provided for @khatmEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có chu kỳ Khatm nào đang đọc.'**
  String get khatmEmpty;

  /// No description provided for @khatmStart.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu Khatm'**
  String get khatmStart;

  /// No description provided for @khatmDefaultName.
  ///
  /// In vi, this message translates to:
  /// **'Khatm của tôi'**
  String get khatmDefaultName;

  /// No description provided for @khatmProgressLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tiến độ'**
  String get khatmProgressLabel;

  /// No description provided for @khatmContinueReading.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục đọc'**
  String get khatmContinueReading;

  /// No description provided for @khatmAyahPosition.
  ///
  /// In vi, this message translates to:
  /// **'Ayah {current} / {total}'**
  String khatmAyahPosition(int current, int total);

  /// No description provided for @collectionsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bộ sưu tập'**
  String get collectionsTitle;

  /// No description provided for @collectionsEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có bộ sưu tập nào.'**
  String get collectionsEmpty;

  /// No description provided for @collectionsCreate.
  ///
  /// In vi, this message translates to:
  /// **'Bộ sưu tập mới'**
  String get collectionsCreate;

  /// No description provided for @collectionsRename.
  ///
  /// In vi, this message translates to:
  /// **'Đổi tên'**
  String get collectionsRename;

  /// No description provided for @collectionsDelete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get collectionsDelete;

  /// No description provided for @collectionsDeleteConfirmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa bộ sưu tập?'**
  String get collectionsDeleteConfirmTitle;

  /// No description provided for @collectionsDeleteConfirmBody.
  ///
  /// In vi, this message translates to:
  /// **'Các Ayah đã lưu vẫn giữ nguyên, chỉ bộ sưu tập bị xóa.'**
  String get collectionsDeleteConfirmBody;

  /// No description provided for @collectionNameHint.
  ///
  /// In vi, this message translates to:
  /// **'Tên bộ sưu tập'**
  String get collectionNameHint;

  /// No description provided for @collectionEmojiHint.
  ///
  /// In vi, this message translates to:
  /// **'Biểu tượng (tùy chọn)'**
  String get collectionEmojiHint;

  /// No description provided for @collectionItemCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} Ayah'**
  String collectionItemCount(int count);

  /// No description provided for @collectionAssignTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thêm vào bộ sưu tập'**
  String get collectionAssignTitle;

  /// No description provided for @libraryOrganizeTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Sắp xếp vào bộ sưu tập'**
  String get libraryOrganizeTooltip;

  /// No description provided for @revisionQueueEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có Ayah nào cần ôn tập.'**
  String get revisionQueueEmpty;

  /// No description provided for @dailyGoalMinutesHint.
  ///
  /// In vi, this message translates to:
  /// **'Phút mỗi ngày'**
  String get dailyGoalMinutesHint;

  /// No description provided for @dailyGoalAyahsHint.
  ///
  /// In vi, this message translates to:
  /// **'Ayah mỗi ngày'**
  String get dailyGoalAyahsHint;

  /// No description provided for @dailyGoalNotSet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đặt mục tiêu — chạm để đặt.'**
  String get dailyGoalNotSet;

  /// No description provided for @dailyGoalMinutesProgress.
  ///
  /// In vi, this message translates to:
  /// **'{current} / {target} phút hôm nay'**
  String dailyGoalMinutesProgress(int current, int target);

  /// No description provided for @reviewGradeAgain.
  ///
  /// In vi, this message translates to:
  /// **'Quên'**
  String get reviewGradeAgain;

  /// No description provided for @reviewGradeHard.
  ///
  /// In vi, this message translates to:
  /// **'Khó'**
  String get reviewGradeHard;

  /// No description provided for @reviewGradeGood.
  ///
  /// In vi, this message translates to:
  /// **'Tốt'**
  String get reviewGradeGood;

  /// No description provided for @reviewGradeEasy.
  ///
  /// In vi, this message translates to:
  /// **'Dễ'**
  String get reviewGradeEasy;

  /// No description provided for @reviewOpenInReading.
  ///
  /// In vi, this message translates to:
  /// **'Mở trong Kinh'**
  String get reviewOpenInReading;

  /// No description provided for @reviewSessionComplete.
  ///
  /// In vi, this message translates to:
  /// **'Đã ôn xong!'**
  String get reviewSessionComplete;

  /// No description provided for @reviewSessionCompleteSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Không còn thẻ nào đến hạn ôn tập lúc này.'**
  String get reviewSessionCompleteSubtitle;

  /// No description provided for @flashcardReviewTitle.
  ///
  /// In vi, this message translates to:
  /// **'Flashcard'**
  String get flashcardReviewTitle;

  /// No description provided for @flashcardReviewComplete.
  ///
  /// In vi, this message translates to:
  /// **'Đã ôn xong Flashcard!'**
  String get flashcardReviewComplete;

  /// No description provided for @flashcardReviewCompleteSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Không còn từ vựng nào đến hạn ôn tập lúc này.'**
  String get flashcardReviewCompleteSubtitle;

  /// No description provided for @flashcardsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Flashcard'**
  String get flashcardsTitle;

  /// No description provided for @flashcardSearchHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm theo chữ Ả Rập, phiên âm hoặc nghĩa'**
  String get flashcardSearchHint;

  /// No description provided for @flashcardAdd.
  ///
  /// In vi, this message translates to:
  /// **'Thêm'**
  String get flashcardAdd;

  /// No description provided for @flashcardContentUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Không có nội dung'**
  String get flashcardContentUnavailable;

  /// No description provided for @flashcardMoveToDeck.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển sang deck'**
  String get flashcardMoveToDeck;

  /// No description provided for @flashcardRemove.
  ///
  /// In vi, this message translates to:
  /// **'Gỡ Flashcard'**
  String get flashcardRemove;

  /// No description provided for @flashcardNoDeck.
  ///
  /// In vi, this message translates to:
  /// **'Không deck'**
  String get flashcardNoDeck;

  /// No description provided for @flashcardEmptyDeck.
  ///
  /// In vi, this message translates to:
  /// **'Deck này chưa có Flashcard nào.'**
  String get flashcardEmptyDeck;

  /// No description provided for @flashcardNoResults.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy Flashcard phù hợp.'**
  String get flashcardNoResults;

  /// No description provided for @flashcardFilterAllDecks.
  ///
  /// In vi, this message translates to:
  /// **'Mọi deck'**
  String get flashcardFilterAllDecks;

  /// No description provided for @flashcardFilterAllTypes.
  ///
  /// In vi, this message translates to:
  /// **'Mọi loại'**
  String get flashcardFilterAllTypes;

  /// No description provided for @flashcardFilterAllStatus.
  ///
  /// In vi, this message translates to:
  /// **'Mọi trạng thái'**
  String get flashcardFilterAllStatus;

  /// No description provided for @flashcardFilterDue.
  ///
  /// In vi, this message translates to:
  /// **'Đến hạn'**
  String get flashcardFilterDue;

  /// No description provided for @flashcardFilterNew.
  ///
  /// In vi, this message translates to:
  /// **'Mới'**
  String get flashcardFilterNew;

  /// No description provided for @flashcardFilterLearning.
  ///
  /// In vi, this message translates to:
  /// **'Đang học'**
  String get flashcardFilterLearning;

  /// No description provided for @flashcardFilterReview.
  ///
  /// In vi, this message translates to:
  /// **'Đang ôn'**
  String get flashcardFilterReview;

  /// No description provided for @flashcardFilterLapsed.
  ///
  /// In vi, this message translates to:
  /// **'Quên'**
  String get flashcardFilterLapsed;

  /// No description provided for @flashcardOnboardingTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có Flashcard nào'**
  String get flashcardOnboardingTitle;

  /// No description provided for @flashcardOnboardingBody.
  ///
  /// In vi, this message translates to:
  /// **'Thêm từ vựng đầu tiên để bắt đầu ghi nhớ theo phương pháp lặp lại ngắt quãng.'**
  String get flashcardOnboardingBody;

  /// No description provided for @flashcardOnboardingCta.
  ///
  /// In vi, this message translates to:
  /// **'Thêm Flashcard đầu tiên'**
  String get flashcardOnboardingCta;

  /// No description provided for @flashcardOnboardingReviewNudge.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm Flashcard đầu tiên! Ôn thử ngay?'**
  String get flashcardOnboardingReviewNudge;

  /// No description provided for @flashcardOnboardingReviewCta.
  ///
  /// In vi, this message translates to:
  /// **'Ôn ngay'**
  String get flashcardOnboardingReviewCta;

  /// No description provided for @flashcardDecksTitle.
  ///
  /// In vi, this message translates to:
  /// **'Deck Flashcard'**
  String get flashcardDecksTitle;

  /// No description provided for @flashcardDecksEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có deck nào.'**
  String get flashcardDecksEmpty;

  /// No description provided for @flashcardDecksCreate.
  ///
  /// In vi, this message translates to:
  /// **'Tạo deck'**
  String get flashcardDecksCreate;

  /// No description provided for @flashcardDecksRename.
  ///
  /// In vi, this message translates to:
  /// **'Đổi tên'**
  String get flashcardDecksRename;

  /// No description provided for @flashcardDecksDelete.
  ///
  /// In vi, this message translates to:
  /// **'Xoá'**
  String get flashcardDecksDelete;

  /// No description provided for @flashcardDecksDeleteConfirmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xoá deck?'**
  String get flashcardDecksDeleteConfirmTitle;

  /// No description provided for @flashcardDecksDeleteConfirmBody.
  ///
  /// In vi, this message translates to:
  /// **'Flashcard trong deck này sẽ chuyển về \"Không deck\", không bị xoá.'**
  String get flashcardDecksDeleteConfirmBody;

  /// No description provided for @flashcardDeckNameHint.
  ///
  /// In vi, this message translates to:
  /// **'Tên deck'**
  String get flashcardDeckNameHint;

  /// No description provided for @flashcardDeckItemCount.
  ///
  /// In vi, this message translates to:
  /// **'{count, plural, =0{Chưa có thẻ} =1{1 thẻ} other{{count} thẻ}}'**
  String flashcardDeckItemCount(int count);

  /// No description provided for @addFlashcardTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thêm Flashcard'**
  String get addFlashcardTitle;

  /// No description provided for @addFlashcardSourceLemma.
  ///
  /// In vi, this message translates to:
  /// **'Từ điển'**
  String get addFlashcardSourceLemma;

  /// No description provided for @addFlashcardSourceRoot.
  ///
  /// In vi, this message translates to:
  /// **'Gốc từ'**
  String get addFlashcardSourceRoot;

  /// No description provided for @addFlashcardSourcePhrase.
  ///
  /// In vi, this message translates to:
  /// **'Cụm từ'**
  String get addFlashcardSourcePhrase;

  /// No description provided for @addFlashcardSourceNotAvailable.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu để duyệt/tìm cho loại này.'**
  String get addFlashcardSourceNotAvailable;

  /// No description provided for @addFlashcardSearchHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm...'**
  String get addFlashcardSearchHint;

  /// No description provided for @addFlashcardNoResults.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy kết quả.'**
  String get addFlashcardNoResults;

  /// No description provided for @addFlashcardAdd.
  ///
  /// In vi, this message translates to:
  /// **'Thêm vào Flashcard'**
  String get addFlashcardAdd;

  /// No description provided for @smartDeckTodaysReview.
  ///
  /// In vi, this message translates to:
  /// **'Ôn hôm nay'**
  String get smartDeckTodaysReview;

  /// No description provided for @smartDeckMostDifficult.
  ///
  /// In vi, this message translates to:
  /// **'Khó nhất'**
  String get smartDeckMostDifficult;

  /// No description provided for @smartDeckRecentlyLearned.
  ///
  /// In vi, this message translates to:
  /// **'Mới học xong'**
  String get smartDeckRecentlyLearned;

  /// No description provided for @smartDeckWeakRoots.
  ///
  /// In vi, this message translates to:
  /// **'Gốc từ yếu'**
  String get smartDeckWeakRoots;

  /// No description provided for @smartDeckVerbForms.
  ///
  /// In vi, this message translates to:
  /// **'Theo thể động từ'**
  String get smartDeckVerbForms;

  /// No description provided for @smartDeckEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có Flashcard nào trong Smart Deck này.'**
  String get smartDeckEmpty;

  /// No description provided for @smartDeckVerbFormLabel.
  ///
  /// In vi, this message translates to:
  /// **'Thể {form}'**
  String smartDeckVerbFormLabel(String form);

  /// No description provided for @progressDashboardTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tiến độ học tập'**
  String get progressDashboardTitle;

  /// No description provided for @progressDashboardEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có Flashcard nào được ôn — số liệu sẽ hiện ra khi bạn bắt đầu học.'**
  String get progressDashboardEmpty;

  /// No description provided for @progressDashboardHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử hoạt động'**
  String get progressDashboardHistory;

  /// No description provided for @progressDashboardHistoryEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có hoạt động đọc trong khoảng thời gian này.'**
  String get progressDashboardHistoryEmpty;

  /// No description provided for @progressDashboardInsights.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý cải thiện'**
  String get progressDashboardInsights;

  /// No description provided for @progressDashboardOverview.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quan'**
  String get progressDashboardOverview;

  /// No description provided for @progressDashboardLoading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải số liệu tiến độ…'**
  String get progressDashboardLoading;

  /// No description provided for @statCardsStudied.
  ///
  /// In vi, this message translates to:
  /// **'Thẻ đã học'**
  String get statCardsStudied;

  /// No description provided for @statReviewsToday.
  ///
  /// In vi, this message translates to:
  /// **'Lượt ôn hôm nay'**
  String get statReviewsToday;

  /// No description provided for @statAccuracy.
  ///
  /// In vi, this message translates to:
  /// **'Độ chính xác'**
  String get statAccuracy;

  /// No description provided for @statAverageEase.
  ///
  /// In vi, this message translates to:
  /// **'Độ dễ trung bình'**
  String get statAverageEase;

  /// No description provided for @statAverageInterval.
  ///
  /// In vi, this message translates to:
  /// **'Chu kỳ trung bình (ngày)'**
  String get statAverageInterval;

  /// No description provided for @historyDaily.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get historyDaily;

  /// No description provided for @historyWeekly.
  ///
  /// In vi, this message translates to:
  /// **'Tuần'**
  String get historyWeekly;

  /// No description provided for @historyMonthly.
  ///
  /// In vi, this message translates to:
  /// **'Tháng'**
  String get historyMonthly;

  /// No description provided for @insightsWeakRoots.
  ///
  /// In vi, this message translates to:
  /// **'Gốc từ yếu'**
  String get insightsWeakRoots;

  /// No description provided for @insightsDifficultLemmas.
  ///
  /// In vi, this message translates to:
  /// **'Từ khó nhất'**
  String get insightsDifficultLemmas;

  /// No description provided for @insightsFrequentlyForgotten.
  ///
  /// In vi, this message translates to:
  /// **'Hay quên'**
  String get insightsFrequentlyForgotten;

  /// No description provided for @insightsFastestImproving.
  ///
  /// In vi, this message translates to:
  /// **'Tiến bộ nhanh nhất'**
  String get insightsFastestImproving;

  /// No description provided for @insightsEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu cho mục này.'**
  String get insightsEmpty;

  /// No description provided for @progressDashboardGoals.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu'**
  String get progressDashboardGoals;

  /// No description provided for @progressDashboardAchievements.
  ///
  /// In vi, this message translates to:
  /// **'Thành tựu'**
  String get progressDashboardAchievements;

  /// No description provided for @goalDailyStudyLabel.
  ///
  /// In vi, this message translates to:
  /// **'Học mỗi ngày'**
  String get goalDailyStudyLabel;

  /// No description provided for @goalDailyReviewsLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ôn mỗi ngày'**
  String get goalDailyReviewsLabel;

  /// No description provided for @goalWeeklyStudyLabel.
  ///
  /// In vi, this message translates to:
  /// **'Học mỗi tuần'**
  String get goalWeeklyStudyLabel;

  /// No description provided for @goalReviewsProgress.
  ///
  /// In vi, this message translates to:
  /// **'{current} / {target} lượt ôn hôm nay'**
  String goalReviewsProgress(int current, int target);

  /// No description provided for @goalWeeklyMinutesProgress.
  ///
  /// In vi, this message translates to:
  /// **'{current} / {target} phút tuần này'**
  String goalWeeklyMinutesProgress(int current, int target);

  /// No description provided for @goalAchieved.
  ///
  /// In vi, this message translates to:
  /// **'Đã đạt'**
  String get goalAchieved;

  /// No description provided for @achievementFirstStudyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Buổi học đầu tiên'**
  String get achievementFirstStudyTitle;

  /// No description provided for @achievementTenCardsTitle.
  ///
  /// In vi, this message translates to:
  /// **'10 thẻ đã học'**
  String get achievementTenCardsTitle;

  /// No description provided for @achievementHundredCardsTitle.
  ///
  /// In vi, this message translates to:
  /// **'100 thẻ đã học'**
  String get achievementHundredCardsTitle;

  /// No description provided for @achievementSevenDayStreakTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chuỗi 7 ngày'**
  String get achievementSevenDayStreakTitle;

  /// No description provided for @achievementThirtyDayStreakTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chuỗi 30 ngày'**
  String get achievementThirtyDayStreakTitle;

  /// No description provided for @achievementSharpMemoryTitle.
  ///
  /// In vi, this message translates to:
  /// **'Trí nhớ sắc bén'**
  String get achievementSharpMemoryTitle;

  /// No description provided for @achievementProgressCards.
  ///
  /// In vi, this message translates to:
  /// **'{current} / {target} thẻ'**
  String achievementProgressCards(int current, int target);

  /// No description provided for @achievementProgressDays.
  ///
  /// In vi, this message translates to:
  /// **'{current} / {target} ngày'**
  String achievementProgressDays(int current, int target);

  /// No description provided for @achievementProgressPercent.
  ///
  /// In vi, this message translates to:
  /// **'Độ chính xác {current}% / {target}%'**
  String achievementProgressPercent(int current, int target);

  /// No description provided for @achievementUnlocked.
  ///
  /// In vi, this message translates to:
  /// **'Đã mở khoá'**
  String get achievementUnlocked;

  /// No description provided for @achievementLocked.
  ///
  /// In vi, this message translates to:
  /// **'Chưa mở khoá'**
  String get achievementLocked;

  /// No description provided for @aiTutorTitle.
  ///
  /// In vi, this message translates to:
  /// **'Gia sư AI'**
  String get aiTutorTitle;

  /// No description provided for @studyAiTutor.
  ///
  /// In vi, this message translates to:
  /// **'Gia sư AI'**
  String get studyAiTutor;

  /// No description provided for @studyAiTutorDesc.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý riêng dựa trên tiến độ học tập của bạn'**
  String get studyAiTutorDesc;

  /// No description provided for @aiTutorSummaryTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quan của bạn'**
  String get aiTutorSummaryTitle;

  /// No description provided for @aiTutorSuggestionsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý'**
  String get aiTutorSuggestionsTitle;

  /// No description provided for @aiTutorInsightsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhận định'**
  String get aiTutorInsightsTitle;

  /// No description provided for @aiTutorSuggestionsEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã theo kịp mọi thứ — hiện chưa có gì cần chú ý.'**
  String get aiTutorSuggestionsEmpty;

  /// No description provided for @aiTutorLoading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải gia sư của bạn…'**
  String get aiTutorLoading;

  /// No description provided for @aiTutorPriorityHigh.
  ///
  /// In vi, this message translates to:
  /// **'Ưu tiên cao'**
  String get aiTutorPriorityHigh;

  /// No description provided for @aiTutorPriorityMedium.
  ///
  /// In vi, this message translates to:
  /// **'Ưu tiên trung bình'**
  String get aiTutorPriorityMedium;

  /// No description provided for @aiTutorPriorityLow.
  ///
  /// In vi, this message translates to:
  /// **'Ưu tiên thấp'**
  String get aiTutorPriorityLow;

  /// No description provided for @aiTutorSuggestionReviewDueTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ôn các thẻ đến hạn'**
  String get aiTutorSuggestionReviewDueTitle;

  /// No description provided for @aiTutorSuggestionReviewDueDetail.
  ///
  /// In vi, this message translates to:
  /// **'{count} thẻ đang chờ'**
  String aiTutorSuggestionReviewDueDetail(int count);

  /// No description provided for @aiTutorSuggestionDailyStudyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành mục tiêu học hôm nay'**
  String get aiTutorSuggestionDailyStudyTitle;

  /// No description provided for @aiTutorSuggestionDailyStudyDetail.
  ///
  /// In vi, this message translates to:
  /// **'Còn {count} phút hôm nay'**
  String aiTutorSuggestionDailyStudyDetail(int count);

  /// No description provided for @aiTutorSuggestionDailyReviewTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành mục tiêu ôn hôm nay'**
  String get aiTutorSuggestionDailyReviewTitle;

  /// No description provided for @aiTutorSuggestionDailyReviewDetail.
  ///
  /// In vi, this message translates to:
  /// **'Còn {count} lượt ôn hôm nay'**
  String aiTutorSuggestionDailyReviewDetail(int count);

  /// No description provided for @aiTutorSuggestionWeakRootsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Củng cố gốc từ yếu'**
  String get aiTutorSuggestionWeakRootsTitle;

  /// No description provided for @aiTutorSuggestionWeakRootsDetail.
  ///
  /// In vi, this message translates to:
  /// **'{count} gốc từ cần ôn'**
  String aiTutorSuggestionWeakRootsDetail(int count);

  /// No description provided for @aiTutorSuggestionForgottenTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ôn lại các thẻ hay quên'**
  String get aiTutorSuggestionForgottenTitle;

  /// No description provided for @aiTutorSuggestionForgottenDetail.
  ///
  /// In vi, this message translates to:
  /// **'{count} thẻ cần xem lại'**
  String aiTutorSuggestionForgottenDetail(int count);

  /// No description provided for @aiTutorSuggestionStreakTitle.
  ///
  /// In vi, this message translates to:
  /// **'Giữ chuỗi ngày đọc'**
  String get aiTutorSuggestionStreakTitle;

  /// No description provided for @aiTutorSuggestionStreakDetail.
  ///
  /// In vi, this message translates to:
  /// **'Chuỗi {count} ngày'**
  String aiTutorSuggestionStreakDetail(int count);

  /// No description provided for @aiTutorInsightAchievementsUnlockedLabel.
  ///
  /// In vi, this message translates to:
  /// **'Thành tựu đã mở khoá'**
  String get aiTutorInsightAchievementsUnlockedLabel;

  /// No description provided for @aiTutorActionReviewNow.
  ///
  /// In vi, this message translates to:
  /// **'Ôn ngay'**
  String get aiTutorActionReviewNow;

  /// No description provided for @aiTutorActionContinueLearning.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục học'**
  String get aiTutorActionContinueLearning;

  /// No description provided for @aiTutorActionOpenWeakCards.
  ///
  /// In vi, this message translates to:
  /// **'Mở thẻ yếu'**
  String get aiTutorActionOpenWeakCards;

  /// No description provided for @aiTutorActionOpenFlashcards.
  ///
  /// In vi, this message translates to:
  /// **'Mở Flashcard'**
  String get aiTutorActionOpenFlashcards;

  /// No description provided for @aiTutorJourneyEntryTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xem Hành trình học tập'**
  String get aiTutorJourneyEntryTitle;

  /// No description provided for @aiTutorJourneyEntryDesc.
  ///
  /// In vi, this message translates to:
  /// **'Xem kế hoạch hôm nay, từng bước theo thứ tự'**
  String get aiTutorJourneyEntryDesc;

  /// No description provided for @learningJourneyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hành trình học tập'**
  String get learningJourneyTitle;

  /// No description provided for @journeyHeaderTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kế hoạch hôm nay'**
  String get journeyHeaderTitle;

  /// No description provided for @journeyStepCountLabel.
  ///
  /// In vi, this message translates to:
  /// **'{count} bước đã lên kế hoạch'**
  String journeyStepCountLabel(int count);

  /// No description provided for @journeyProgressTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tiến độ của bạn'**
  String get journeyProgressTitle;

  /// No description provided for @journeyStepsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Các bước'**
  String get journeyStepsTitle;

  /// No description provided for @learningJourneyEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có gì cho hôm nay — bạn đã theo kịp mọi thứ!'**
  String get learningJourneyEmpty;

  /// No description provided for @learningJourneyLoading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải hành trình học tập của bạn…'**
  String get learningJourneyLoading;

  /// No description provided for @journeyStepNumber.
  ///
  /// In vi, this message translates to:
  /// **'Bước {number}'**
  String journeyStepNumber(int number);

  /// No description provided for @journeyEntrySmartLearningTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhận phiên học thông minh'**
  String get journeyEntrySmartLearningTitle;

  /// No description provided for @journeyEntrySmartLearningDesc.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý riêng cho ngay bây giờ'**
  String get journeyEntrySmartLearningDesc;

  /// No description provided for @smartLearningTitle.
  ///
  /// In vi, this message translates to:
  /// **'Học thông minh'**
  String get smartLearningTitle;

  /// No description provided for @smartLearningHeaderTitle.
  ///
  /// In vi, this message translates to:
  /// **'Phiên học thông minh của bạn'**
  String get smartLearningHeaderTitle;

  /// No description provided for @smartLearningRecommendationCountLabel.
  ///
  /// In vi, this message translates to:
  /// **'{count} đề xuất hôm nay'**
  String smartLearningRecommendationCountLabel(int count);

  /// No description provided for @smartLearningRecommendedTitle.
  ///
  /// In vi, this message translates to:
  /// **'Phiên học được đề xuất'**
  String get smartLearningRecommendedTitle;

  /// No description provided for @smartLearningOtherRecommendationsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đề xuất khác'**
  String get smartLearningOtherRecommendationsTitle;

  /// No description provided for @smartLearningRelatedStepsLabel.
  ///
  /// In vi, this message translates to:
  /// **'{count} bước liên quan'**
  String smartLearningRelatedStepsLabel(int count);

  /// No description provided for @smartLearningEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Hiện chưa cần phiên học thông minh nào — bạn đã theo kịp mọi thứ!'**
  String get smartLearningEmpty;

  /// No description provided for @smartLearningLoading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải phiên học thông minh của bạn…'**
  String get smartLearningLoading;

  /// No description provided for @smartLearningStrategyShortReview.
  ///
  /// In vi, this message translates to:
  /// **'Ôn nhanh'**
  String get smartLearningStrategyShortReview;

  /// No description provided for @smartLearningStrategyDeepStudy.
  ///
  /// In vi, this message translates to:
  /// **'Học sâu'**
  String get smartLearningStrategyDeepStudy;

  /// No description provided for @smartLearningStrategyMemorization.
  ///
  /// In vi, this message translates to:
  /// **'Ghi nhớ'**
  String get smartLearningStrategyMemorization;

  /// No description provided for @smartLearningStrategyRecovery.
  ///
  /// In vi, this message translates to:
  /// **'Phục hồi'**
  String get smartLearningStrategyRecovery;

  /// No description provided for @quizCorrect.
  ///
  /// In vi, this message translates to:
  /// **'Chính xác!'**
  String get quizCorrect;

  /// No description provided for @quizIncorrect.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đúng.'**
  String get quizIncorrect;

  /// No description provided for @quizEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Không đủ nội dung để tạo câu hỏi.'**
  String get quizEmpty;

  /// No description provided for @quizQuestionProgress.
  ///
  /// In vi, this message translates to:
  /// **'Câu {current}/{total}'**
  String quizQuestionProgress(int current, int total);

  /// No description provided for @quizScoreResult.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đạt {score}/{total} điểm'**
  String quizScoreResult(int score, int total);

  /// No description provided for @quizRetry.
  ///
  /// In vi, this message translates to:
  /// **'Làm lại'**
  String get quizRetry;

  /// No description provided for @learningSessionStart.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu buổi học'**
  String get learningSessionStart;

  /// No description provided for @learningSummaryTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tóm tắt buổi học'**
  String get learningSummaryTitle;

  /// No description provided for @learningSummaryReviewCount.
  ///
  /// In vi, this message translates to:
  /// **'Đã ôn {count} thẻ'**
  String learningSummaryReviewCount(int count);

  /// No description provided for @learningSummaryFlashcardCount.
  ///
  /// In vi, this message translates to:
  /// **'Đã ôn {count} từ vựng'**
  String learningSummaryFlashcardCount(int count);

  /// No description provided for @learningSummaryQuizScore.
  ///
  /// In vi, this message translates to:
  /// **'Trắc nghiệm: {score}/{total} điểm'**
  String learningSummaryQuizScore(int score, int total);

  /// No description provided for @learningSummaryDone.
  ///
  /// In vi, this message translates to:
  /// **'Xong'**
  String get learningSummaryDone;

  /// No description provided for @learningSummaryStatusCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành'**
  String get learningSummaryStatusCompleted;

  /// No description provided for @learningSummaryActivitiesTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hoạt động đã hoàn thành'**
  String get learningSummaryActivitiesTitle;

  /// No description provided for @learningSummaryNotCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Chưa hoàn thành'**
  String get learningSummaryNotCompleted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
