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
  /// **'Ghi nhớ Ayah bằng thẻ hai mặt'**
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
