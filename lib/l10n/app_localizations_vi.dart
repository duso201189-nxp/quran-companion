// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Qur\'an Companion';

  @override
  String get tabHome => 'Trang chủ';

  @override
  String get tabQuran => 'Qur\'an';

  @override
  String get tabStudy => 'Học';

  @override
  String get tabStats => 'Thống kê';

  @override
  String get tabProfile => 'Hồ sơ';

  @override
  String get sectionAppearance => 'Giao diện';

  @override
  String get sectionLanguage => 'Ngôn ngữ';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeSystem => 'Hệ thống';

  @override
  String get themeDark => 'Tối';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get profilePersonalInfo => 'Thông tin cá nhân';

  @override
  String get profileGoal => 'Mục tiêu hằng ngày';

  @override
  String get profileSync => 'Đồng bộ đám mây';

  @override
  String get searchSurahHint => 'Tìm Surah theo tên hoặc số...';

  @override
  String get filterAll => 'Tất cả';

  @override
  String get revelationMecca => 'Mecca';

  @override
  String get revelationMadinah => 'Madinah';

  @override
  String surahAyahCount(int count) {
    return '$count câu';
  }

  @override
  String get errorLoadData => 'Không tải được dữ liệu. Vui lòng thử lại.';

  @override
  String get retry => 'Thử lại';

  @override
  String get emptySearchResults => 'Không tìm thấy Surah nào phù hợp.';

  @override
  String get surahListLoading => 'Đang tải danh sách Surah…';

  @override
  String get displaySettings => 'Hiển thị';

  @override
  String get readingFontSize => 'Cỡ chữ Ả Rập';

  @override
  String get readingModeLabel => 'Chế độ đọc';

  @override
  String get readingLayersLabel => 'Lớp hỗ trợ đọc';

  @override
  String get jumpToAyahTitle => 'Chuyển tới Ayah';

  @override
  String get jumpToAyahSurahLabel => 'Surah';

  @override
  String get jumpToAyahNumberLabel => 'Số câu';

  @override
  String jumpToAyahRange(int max) {
    return '1–$max';
  }

  @override
  String get jumpToAyahAction => 'Chuyển tới';

  @override
  String get jumpToAyahListModeOnly =>
      'Chuyển tới Ayah hiện chỉ dùng được ở chế độ Danh sách.';

  @override
  String readingProgressPosition(int current, int total) {
    return 'Ayah $current / $total';
  }

  @override
  String readingProgressSemantics(int current, int total, int percent) {
    return 'Ayah $current trên $total, $percent%';
  }

  @override
  String get surahNotFound => 'Không tìm thấy Surah này.';

  @override
  String get surahNoContent =>
      'Surah chưa có nội dung. Hãy build lại dữ liệu (docs/DATA_PIPELINE.md).';

  @override
  String ayahSemanticLabel(int number) {
    return 'Ayah $number';
  }

  @override
  String get sajdahAyah => 'Ayah có sajdah (quỳ lạy)';

  @override
  String get focusMode => 'Chế độ tập trung';

  @override
  String get readingModeMushaf => 'Chế độ Mushaf';

  @override
  String get readingModeList => 'Chế độ danh sách';

  @override
  String pageLabel(int number) {
    return 'Trang $number';
  }

  @override
  String get play => 'Phát';

  @override
  String get pause => 'Tạm dừng';

  @override
  String get nextAyah => 'Ayah kế';

  @override
  String get previousAyah => 'Ayah trước';

  @override
  String get repeatMode => 'Chế độ lặp';

  @override
  String get stopAudio => 'Dừng nghe';

  @override
  String get selectReciter => 'Chọn Qari';

  @override
  String get playFromHere => 'Nghe từ Ayah này';

  @override
  String get nowPlaying => 'Đang phát';

  @override
  String get studyWorkspaceTitle => 'Nghiên cứu';

  @override
  String get studyTafsirTitle => 'Chú giải (Tafsir)';

  @override
  String get studyOpenWorkspace => 'Nghiên cứu Ayah';

  @override
  String get openReadingScreen => 'Mở trang đọc';

  @override
  String get bookmarkLabel => 'Bookmark';

  @override
  String get statusLabel => 'Trạng thái học';

  @override
  String get statusNone => 'Chưa đọc';

  @override
  String get statusLearning => 'Đang học';

  @override
  String get statusLearned => 'Đã học';

  @override
  String get statusReview => 'Cần ôn';

  @override
  String get noteLabel => 'Ghi chú';

  @override
  String get addNote => 'Thêm ghi chú';

  @override
  String get editNote => 'Sửa ghi chú';

  @override
  String get noteHint => 'Hỗ trợ **đậm** và *nghiêng*';

  @override
  String get save => 'Lưu';

  @override
  String get cancel => 'Hủy';

  @override
  String get copyAyah => 'Sao chép';

  @override
  String get shareAyah => 'Chia sẻ';

  @override
  String get ayahCopied => 'Đã sao chép vào bộ nhớ tạm';

  @override
  String get moreActions => 'Thêm';

  @override
  String get continueReading => 'Đọc tiếp';

  @override
  String get startReading => 'Bắt đầu đọc';

  @override
  String get todaysVerse => 'Câu Qur\'an hôm nay';

  @override
  String get homeLoading => 'Đang tải trang chủ…';

  @override
  String get homeTodaysVerseLoading => 'Đang tải câu Qur\'an hôm nay…';

  @override
  String get dailyProgress => 'Tiến độ hôm nay';

  @override
  String get quickAccess => 'Truy cập nhanh';

  @override
  String get learningStreak => 'Chuỗi ngày học';

  @override
  String streakDays(int count) {
    return '$count ngày';
  }

  @override
  String get recentSurahs => 'Surah gần đây';

  @override
  String get ayahsReadLabel => 'Ayah đã đọc';

  @override
  String get studyFlashcards => 'Flashcard';

  @override
  String get studyFlashcardsDesc => 'Ghi nhớ từ vựng Qur\'an bằng thẻ hai mặt';

  @override
  String get studySpaced => 'Lặp lại ngắt quãng';

  @override
  String get studySpacedDesc => 'Ôn đúng lúc sắp quên — nhớ lâu hơn';

  @override
  String get studyQuiz => 'Trắc nghiệm';

  @override
  String get studyQuizDesc => 'Kiểm tra nhanh kiến thức Surah';

  @override
  String get studyDailyReview => 'Ôn tập hằng ngày';

  @override
  String get studyDailyReviewDesc => 'Danh sách Ayah cần ôn hôm nay';

  @override
  String get studyProgress => 'Tiến độ học tập';

  @override
  String get studyProgressDesc => 'Số liệu, lịch sử và gợi ý cải thiện';

  @override
  String get statsReadingDays => 'Ngày đọc';

  @override
  String get statsAyahsRead => 'Ayah đã đọc';

  @override
  String get statsMinutes => 'Phút học';

  @override
  String get statsCompletion => 'Hoàn thành Qur\'an';

  @override
  String get statsCurrentStreak => 'Chuỗi hiện tại';

  @override
  String get statsLongestStreak => 'Chuỗi dài nhất';

  @override
  String get statsWeeklyActivity => 'Hoạt động 7 ngày qua';

  @override
  String get statsNoData => 'Bắt đầu đọc để ghi nhận thống kê.';

  @override
  String get sectionAbout => 'Giới thiệu';

  @override
  String get aboutSources => 'Nguồn dữ liệu';

  @override
  String get aboutSourcesDetail =>
      'Bản quyền, giấy phép và địa chỉ của mọi nguồn nội dung.';

  @override
  String get profileGoalFixed =>
      'Cố định 15 phút đọc mỗi ngày. Chưa đổi được trong bản này.';

  @override
  String get profileNotAvailableYet => 'Chưa có trong bản này.';

  @override
  String get profileSyncNotAvailable =>
      'Chưa có trong bản này. Mọi dữ liệu của bạn chỉ nằm trên máy này.';

  @override
  String get versionLabel => 'Phiên bản';

  @override
  String get attributionTitle => 'Nguồn & Ghi nguồn';

  @override
  String get attributionIntro =>
      'Văn bản Qur\'an, phiên âm, bản dịch, chú giải và bản thu trong ứng dụng đến từ các nguồn dưới đây. Mỗi nguồn thuộc bản quyền của tác giả hoặc nhà phát hành tương ứng và được sử dụng theo giấy phép ghi kèm.';

  @override
  String get attributionKindQuranText => 'Văn bản Qur\'an';

  @override
  String get attributionKindTransliteration => 'Phiên âm';

  @override
  String get attributionKindTranslation => 'Bản dịch';

  @override
  String get attributionKindTafsir => 'Chú giải (Tafsir)';

  @override
  String get attributionKindAudio => 'Bản thu (Qari)';

  @override
  String get attributionAuthor => 'Tác giả';

  @override
  String get attributionLanguage => 'Ngôn ngữ';

  @override
  String get attributionLicense => 'Giấy phép';

  @override
  String get attributionSourceUrl => 'Địa chỉ nguồn';

  @override
  String get attributionUpdated => 'Cập nhật';

  @override
  String get attributionCopyUrl => 'Sao chép địa chỉ';

  @override
  String get attributionUrlCopied => 'Đã sao chép địa chỉ nguồn';

  @override
  String get attributionDataVersion => 'Phiên bản dữ liệu';

  @override
  String get attributionSoftwareLicenses => 'Giấy phép phần mềm & phông chữ';

  @override
  String get attributionSoftwareLicensesDetail =>
      'Giấy phép của các thư viện mã nguồn mở và của bốn phông chữ đóng gói kèm.';

  @override
  String get attributionEmpty => 'Bản dữ liệu này chưa mô tả nguồn nào.';

  @override
  String get audioError => 'Không phát được audio. Kiểm tra kết nối mạng.';

  @override
  String get audioLoading => 'Đang tải audio...';

  @override
  String get favoriteLabel => 'Yêu thích';

  @override
  String get copyArabic => 'Sao chép chữ Ả Rập';

  @override
  String get copyTranslation => 'Sao chép bản dịch';

  @override
  String get ayahHighlightLabel => 'Tô màu';

  @override
  String get searchResultsAyahs => 'Kết quả trong nội dung';

  @override
  String get searchResultsSurahs => 'Surah';

  @override
  String get searchNoResults => 'Không tìm thấy kết quả nào.';

  @override
  String get searchNoAyahResults => 'Không tìm thấy Ayah nào phù hợp.';

  @override
  String get searchLabel => 'Tìm kiếm';

  @override
  String get searchQueryHint => 'Tìm kiếm trong Qur\'an...';

  @override
  String get searchClearTooltip => 'Xoá';

  @override
  String get searchScopeMyNotes => 'Ghi chú của tôi';

  @override
  String get searchEmptyTitle => 'Tìm điều bạn cần trong Qur\'an';

  @override
  String get searchEmptySubtitle =>
      'Nhập tên Surah, số Ayah (ví dụ 2:255), hoặc một từ khoá.';

  @override
  String get searchLoadingLabel => 'Đang tìm kiếm...';

  @override
  String get libraryTitle => 'Thư viện của tôi';

  @override
  String get libraryLoading => 'Đang tải thư viện…';

  @override
  String get libraryBookmarks => 'Đã lưu';

  @override
  String get libraryFavorites => 'Yêu thích';

  @override
  String get libraryNotes => 'Ghi chú';

  @override
  String get libraryHighlights => 'Tô màu';

  @override
  String get libraryEmptyBookmarks => 'Chưa có Ayah nào được lưu.';

  @override
  String get libraryEmptyFavorites => 'Chưa có Ayah yêu thích nào.';

  @override
  String get libraryEmptyNotes => 'Chưa có ghi chú nào.';

  @override
  String get libraryEmptyHighlights => 'Chưa tô màu Ayah nào.';

  @override
  String get statsSessionsTitle => 'Phiên đọc';

  @override
  String get statsSessionsEmpty => 'Chưa có phiên đọc nào được ghi nhận.';

  @override
  String get statsTodayTitle => 'Hôm nay';

  @override
  String statsTodayMinutes(int count) {
    return '$count phút';
  }

  @override
  String statsTodaySessionsCount(int count) {
    return '$count phiên';
  }

  @override
  String get khatmSectionTitle => 'Khatm đang đọc';

  @override
  String get khatmEmpty => 'Chưa có chu kỳ Khatm nào đang đọc.';

  @override
  String get khatmStart => 'Bắt đầu Khatm';

  @override
  String get khatmDefaultName => 'Khatm của tôi';

  @override
  String get khatmProgressLabel => 'Tiến độ';

  @override
  String get khatmContinueReading => 'Tiếp tục đọc';

  @override
  String khatmAyahPosition(int current, int total) {
    return 'Ayah $current / $total';
  }

  @override
  String get collectionsTitle => 'Bộ sưu tập';

  @override
  String get collectionsLoading => 'Đang tải bộ sưu tập…';

  @override
  String get collectionsEmpty => 'Chưa có bộ sưu tập nào.';

  @override
  String get collectionsCreate => 'Bộ sưu tập mới';

  @override
  String get collectionsRename => 'Đổi tên';

  @override
  String get collectionsDelete => 'Xóa';

  @override
  String get collectionsDeleteConfirmTitle => 'Xóa bộ sưu tập?';

  @override
  String get collectionsDeleteConfirmBody =>
      'Các Ayah đã lưu vẫn giữ nguyên, chỉ bộ sưu tập bị xóa.';

  @override
  String get collectionNameHint => 'Tên bộ sưu tập';

  @override
  String get collectionEmojiHint => 'Biểu tượng (tùy chọn)';

  @override
  String collectionItemCount(int count) {
    return '$count Ayah';
  }

  @override
  String get collectionAssignTitle => 'Thêm vào bộ sưu tập';

  @override
  String get libraryOrganizeTooltip => 'Sắp xếp vào bộ sưu tập';

  @override
  String get revisionQueueEmpty => 'Chưa có Ayah nào cần ôn tập.';

  @override
  String get dailyGoalMinutesHint => 'Phút mỗi ngày';

  @override
  String get dailyGoalAyahsHint => 'Ayah mỗi ngày';

  @override
  String get dailyGoalNotSet => 'Chưa đặt mục tiêu — chạm để đặt.';

  @override
  String dailyGoalMinutesProgress(int current, int target) {
    return '$current / $target phút hôm nay';
  }

  @override
  String get reviewGradeAgain => 'Quên';

  @override
  String get reviewGradeHard => 'Khó';

  @override
  String get reviewGradeGood => 'Tốt';

  @override
  String get reviewGradeEasy => 'Dễ';

  @override
  String get reviewOpenInReading => 'Mở trong Kinh';

  @override
  String get reviewSessionLoading => 'Đang tải phiên ôn tập…';

  @override
  String get reviewSessionComplete => 'Đã ôn xong!';

  @override
  String get reviewSessionCompleteSubtitle =>
      'Không còn thẻ nào đến hạn ôn tập lúc này.';

  @override
  String get flashcardReviewTitle => 'Flashcard';

  @override
  String get flashcardReviewComplete => 'Đã ôn xong Flashcard!';

  @override
  String get flashcardReviewCompleteSubtitle =>
      'Không còn từ vựng nào đến hạn ôn tập lúc này.';

  @override
  String get flashcardReviewLoading => 'Đang tải Flashcard…';

  @override
  String get flashcardsTitle => 'Flashcard';

  @override
  String get flashcardsLoading => 'Đang tải Flashcard…';

  @override
  String get flashcardSearchHint => 'Tìm theo chữ Ả Rập, phiên âm hoặc nghĩa';

  @override
  String get flashcardAdd => 'Thêm';

  @override
  String get flashcardContentUnavailable => 'Không có nội dung';

  @override
  String get flashcardMoveToDeck => 'Chuyển sang deck';

  @override
  String get flashcardMoveToDeckLoading => 'Đang tải danh sách deck…';

  @override
  String get flashcardRemove => 'Gỡ Flashcard';

  @override
  String get flashcardNoDeck => 'Không deck';

  @override
  String get flashcardEmptyDeck => 'Deck này chưa có Flashcard nào.';

  @override
  String get flashcardNoResults => 'Không tìm thấy Flashcard phù hợp.';

  @override
  String get flashcardFilterAllDecks => 'Mọi deck';

  @override
  String get flashcardFilterAllTypes => 'Mọi loại';

  @override
  String get flashcardFilterAllStatus => 'Mọi trạng thái';

  @override
  String get flashcardFilterDue => 'Đến hạn';

  @override
  String get flashcardFilterNew => 'Mới';

  @override
  String get flashcardFilterLearning => 'Đang học';

  @override
  String get flashcardFilterReview => 'Đang ôn';

  @override
  String get flashcardFilterLapsed => 'Quên';

  @override
  String get flashcardOnboardingTitle => 'Chưa có Flashcard nào';

  @override
  String get flashcardOnboardingBody =>
      'Thêm từ vựng đầu tiên để bắt đầu ghi nhớ theo phương pháp lặp lại ngắt quãng.';

  @override
  String get flashcardOnboardingCta => 'Thêm Flashcard đầu tiên';

  @override
  String get flashcardOnboardingReviewNudge =>
      'Đã thêm Flashcard đầu tiên! Ôn thử ngay?';

  @override
  String get flashcardOnboardingReviewCta => 'Ôn ngay';

  @override
  String get flashcardDecksTitle => 'Deck Flashcard';

  @override
  String get flashcardDecksLoading => 'Đang tải deck…';

  @override
  String get flashcardDecksEmpty => 'Chưa có deck nào.';

  @override
  String get flashcardDecksCreate => 'Tạo deck';

  @override
  String get flashcardDecksRename => 'Đổi tên';

  @override
  String get flashcardDecksDelete => 'Xoá';

  @override
  String get flashcardDecksDeleteConfirmTitle => 'Xoá deck?';

  @override
  String get flashcardDecksDeleteConfirmBody =>
      'Flashcard trong deck này sẽ chuyển về \"Không deck\", không bị xoá.';

  @override
  String get flashcardDeckNameHint => 'Tên deck';

  @override
  String flashcardDeckItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ',
      one: '1 thẻ',
      zero: 'Chưa có thẻ',
    );
    return '$_temp0';
  }

  @override
  String get addFlashcardTitle => 'Thêm Flashcard';

  @override
  String get addFlashcardLoading => 'Đang tìm kiếm...';

  @override
  String get addFlashcardSourceLemma => 'Từ điển';

  @override
  String get addFlashcardSourceRoot => 'Gốc từ';

  @override
  String get addFlashcardSourcePhrase => 'Cụm từ';

  @override
  String get addFlashcardSourceNotAvailable =>
      'Chưa có dữ liệu để duyệt/tìm cho loại này.';

  @override
  String get addFlashcardSearchHint => 'Tìm kiếm...';

  @override
  String get addFlashcardNoResults => 'Không tìm thấy kết quả.';

  @override
  String get addFlashcardAdd => 'Thêm vào Flashcard';

  @override
  String get smartDeckTodaysReview => 'Ôn hôm nay';

  @override
  String get smartDeckMostDifficult => 'Khó nhất';

  @override
  String get smartDeckRecentlyLearned => 'Mới học xong';

  @override
  String get smartDeckWeakRoots => 'Gốc từ yếu';

  @override
  String get smartDeckVerbForms => 'Theo thể động từ';

  @override
  String get smartDeckEmpty => 'Chưa có Flashcard nào trong Smart Deck này.';

  @override
  String get smartDeckLoading => 'Đang tải Smart Deck…';

  @override
  String smartDeckVerbFormLabel(String form) {
    return 'Thể $form';
  }

  @override
  String get progressDashboardTitle => 'Tiến độ học tập';

  @override
  String get progressDashboardEmpty =>
      'Chưa có Flashcard nào được ôn — số liệu sẽ hiện ra khi bạn bắt đầu học.';

  @override
  String get progressDashboardHistory => 'Lịch sử hoạt động';

  @override
  String get progressDashboardHistoryEmpty =>
      'Chưa có hoạt động đọc trong khoảng thời gian này.';

  @override
  String get progressDashboardInsights => 'Gợi ý cải thiện';

  @override
  String get progressDashboardOverview => 'Tổng quan';

  @override
  String get progressDashboardLoading => 'Đang tải số liệu tiến độ…';

  @override
  String get statCardsStudied => 'Thẻ đã học';

  @override
  String get statReviewsToday => 'Lượt ôn hôm nay';

  @override
  String get statAccuracy => 'Độ chính xác';

  @override
  String get statAverageEase => 'Độ dễ trung bình';

  @override
  String get statAverageInterval => 'Chu kỳ trung bình (ngày)';

  @override
  String get historyDaily => 'Ngày';

  @override
  String get historyWeekly => 'Tuần';

  @override
  String get historyMonthly => 'Tháng';

  @override
  String get insightsWeakRoots => 'Gốc từ yếu';

  @override
  String get insightsDifficultLemmas => 'Từ khó nhất';

  @override
  String get insightsFrequentlyForgotten => 'Hay quên';

  @override
  String get insightsFastestImproving => 'Tiến bộ nhanh nhất';

  @override
  String get insightsEmpty => 'Chưa có dữ liệu cho mục này.';

  @override
  String get progressDashboardGoals => 'Mục tiêu';

  @override
  String get progressDashboardAchievements => 'Thành tựu';

  @override
  String get goalDailyStudyLabel => 'Học mỗi ngày';

  @override
  String get goalDailyReviewsLabel => 'Ôn mỗi ngày';

  @override
  String get goalWeeklyStudyLabel => 'Học mỗi tuần';

  @override
  String goalReviewsProgress(int current, int target) {
    return '$current / $target lượt ôn hôm nay';
  }

  @override
  String goalWeeklyMinutesProgress(int current, int target) {
    return '$current / $target phút tuần này';
  }

  @override
  String get goalAchieved => 'Đã đạt';

  @override
  String get achievementFirstStudyTitle => 'Buổi học đầu tiên';

  @override
  String get achievementTenCardsTitle => '10 thẻ đã học';

  @override
  String get achievementHundredCardsTitle => '100 thẻ đã học';

  @override
  String get achievementSevenDayStreakTitle => 'Chuỗi 7 ngày';

  @override
  String get achievementThirtyDayStreakTitle => 'Chuỗi 30 ngày';

  @override
  String get achievementSharpMemoryTitle => 'Trí nhớ sắc bén';

  @override
  String achievementProgressCards(int current, int target) {
    return '$current / $target thẻ';
  }

  @override
  String achievementProgressDays(int current, int target) {
    return '$current / $target ngày';
  }

  @override
  String achievementProgressPercent(int current, int target) {
    return 'Độ chính xác $current% / $target%';
  }

  @override
  String get achievementUnlocked => 'Đã mở khoá';

  @override
  String get achievementLocked => 'Chưa mở khoá';

  @override
  String get studyCoachTitle => 'Gợi ý học tập';

  @override
  String get studyCoachTile => 'Gợi ý học tập';

  @override
  String get studyCoachTileDesc =>
      'Gợi ý riêng dựa trên tiến độ học tập của bạn';

  @override
  String get studyCoachSummaryTitle => 'Tổng quan của bạn';

  @override
  String get studyCoachSuggestionsTitle => 'Gợi ý';

  @override
  String get studyCoachInsightsTitle => 'Nhận định';

  @override
  String get studyCoachSuggestionsEmpty =>
      'Bạn đã theo kịp mọi thứ — hiện chưa có gì cần chú ý.';

  @override
  String get studyCoachLoading => 'Đang tải gợi ý…';

  @override
  String get studyCoachPriorityHigh => 'Ưu tiên cao';

  @override
  String get studyCoachPriorityMedium => 'Ưu tiên trung bình';

  @override
  String get studyCoachPriorityLow => 'Ưu tiên thấp';

  @override
  String get studyCoachSuggestionReviewDueTitle => 'Ôn các thẻ đến hạn';

  @override
  String studyCoachSuggestionReviewDueDetail(int count) {
    return '$count thẻ đang chờ';
  }

  @override
  String get studyCoachSuggestionDailyStudyTitle =>
      'Hoàn thành mục tiêu học hôm nay';

  @override
  String studyCoachSuggestionDailyStudyDetail(int count) {
    return 'Còn $count phút hôm nay';
  }

  @override
  String get studyCoachSuggestionDailyReviewTitle =>
      'Hoàn thành mục tiêu ôn hôm nay';

  @override
  String studyCoachSuggestionDailyReviewDetail(int count) {
    return 'Còn $count lượt ôn hôm nay';
  }

  @override
  String get studyCoachSuggestionWeakRootsTitle => 'Củng cố gốc từ yếu';

  @override
  String studyCoachSuggestionWeakRootsDetail(int count) {
    return '$count gốc từ cần ôn';
  }

  @override
  String get studyCoachSuggestionForgottenTitle => 'Ôn lại các thẻ hay quên';

  @override
  String studyCoachSuggestionForgottenDetail(int count) {
    return '$count thẻ cần xem lại';
  }

  @override
  String get studyCoachSuggestionStreakTitle => 'Giữ chuỗi ngày đọc';

  @override
  String studyCoachSuggestionStreakDetail(int count) {
    return 'Chuỗi $count ngày';
  }

  @override
  String get studyCoachInsightAchievementsUnlockedLabel =>
      'Thành tựu đã mở khoá';

  @override
  String get studyCoachActionReviewNow => 'Ôn ngay';

  @override
  String get studyCoachActionContinueLearning => 'Tiếp tục học';

  @override
  String get studyCoachActionOpenWeakCards => 'Mở thẻ yếu';

  @override
  String get studyCoachActionOpenFlashcards => 'Mở Flashcard';

  @override
  String get studyCoachJourneyEntryTitle => 'Xem Hành trình học tập';

  @override
  String get studyCoachJourneyEntryDesc =>
      'Xem kế hoạch hôm nay, từng bước theo thứ tự';

  @override
  String get learningJourneyTitle => 'Hành trình học tập';

  @override
  String get journeyHeaderTitle => 'Kế hoạch hôm nay';

  @override
  String journeyStepCountLabel(int count) {
    return '$count bước đã lên kế hoạch';
  }

  @override
  String get journeyProgressTitle => 'Tiến độ của bạn';

  @override
  String get journeyStepsTitle => 'Các bước';

  @override
  String get learningJourneyEmpty =>
      'Chưa có gì cho hôm nay — bạn đã theo kịp mọi thứ!';

  @override
  String get learningJourneyLoading => 'Đang tải hành trình học tập của bạn…';

  @override
  String journeyStepNumber(int number) {
    return 'Bước $number';
  }

  @override
  String get journeyEntrySmartLearningTitle => 'Nhận phiên học thông minh';

  @override
  String get journeyEntrySmartLearningDesc => 'Gợi ý riêng cho ngay bây giờ';

  @override
  String get smartLearningTitle => 'Học thông minh';

  @override
  String get smartLearningHeaderTitle => 'Phiên học thông minh của bạn';

  @override
  String smartLearningRecommendationCountLabel(int count) {
    return '$count đề xuất hôm nay';
  }

  @override
  String get smartLearningRecommendedTitle => 'Phiên học được đề xuất';

  @override
  String get smartLearningOtherRecommendationsTitle => 'Đề xuất khác';

  @override
  String smartLearningRelatedStepsLabel(int count) {
    return '$count bước liên quan';
  }

  @override
  String get smartLearningEmpty =>
      'Hiện chưa cần phiên học thông minh nào — bạn đã theo kịp mọi thứ!';

  @override
  String get smartLearningLoading => 'Đang tải phiên học thông minh của bạn…';

  @override
  String get smartLearningStrategyShortReview => 'Ôn nhanh';

  @override
  String get smartLearningStrategyDeepStudy => 'Học sâu';

  @override
  String get smartLearningStrategyMemorization => 'Ghi nhớ';

  @override
  String get smartLearningStrategyRecovery => 'Phục hồi';

  @override
  String get quizCorrect => 'Chính xác!';

  @override
  String get quizIncorrect => 'Chưa đúng.';

  @override
  String get quizSessionLoading => 'Đang tải câu hỏi…';

  @override
  String get quizEmpty => 'Không đủ nội dung để tạo câu hỏi.';

  @override
  String quizQuestionProgress(int current, int total) {
    return 'Câu $current/$total';
  }

  @override
  String quizScoreResult(int score, int total) {
    return 'Bạn đạt $score/$total điểm';
  }

  @override
  String get quizRetry => 'Làm lại';

  @override
  String get learningSessionStart => 'Bắt đầu buổi học';

  @override
  String get learningSessionLoading => 'Đang chuẩn bị buổi học…';

  @override
  String get learningSummaryTitle => 'Tóm tắt buổi học';

  @override
  String learningSummaryReviewCount(int count) {
    return 'Đã ôn $count thẻ';
  }

  @override
  String learningSummaryFlashcardCount(int count) {
    return 'Đã ôn $count từ vựng';
  }

  @override
  String learningSummaryQuizScore(int score, int total) {
    return 'Trắc nghiệm: $score/$total điểm';
  }

  @override
  String get learningSummaryDone => 'Xong';

  @override
  String get learningSummaryStatusCompleted => 'Hoàn thành';

  @override
  String get learningSummaryActivitiesTitle => 'Hoạt động đã hoàn thành';

  @override
  String get learningSummaryNotCompleted => 'Chưa hoàn thành';
}
