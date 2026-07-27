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
  String get profileGoal => 'Mục tiêu học';

  @override
  String get profileSync => 'Đồng bộ đám mây';

  @override
  String comingInStep(int step) {
    return 'Sẽ xây dựng ở Bước $step';
  }

  @override
  String get placeholderHome =>
      'Bước 8 sẽ xây dựng Dashboard học tập: tiếp tục đọc, tiến độ hôm nay, chuỗi ngày học, câu Qur\'an trong ngày.';

  @override
  String get placeholderQuran =>
      'Bước 3 sẽ hiển thị danh sách 114 Surah với tìm kiếm và bộ lọc Mecca / Madinah.';

  @override
  String get placeholderStudy =>
      'Bước 9 sẽ xây dựng Flashcard (Spaced Repetition) và Quiz.';

  @override
  String get placeholderStats =>
      'Bước 9 sẽ hiển thị biểu đồ: chuỗi ngày học, tổng Ayah, thời gian học, nhật ký học.';

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
  String get displaySettings => 'Hiển thị';

  @override
  String get readingFontSize => 'Cỡ chữ Ả Rập';

  @override
  String get showTransliteration => 'Phiên âm Latin';

  @override
  String get showVietnamese => 'Bản dịch tiếng Việt';

  @override
  String get showEnglish => 'Bản dịch tiếng Anh';

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
  String get dailyProgress => 'Tiến độ hôm nay';

  @override
  String get lastRead => 'Đọc gần đây';

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
  String get minutesLabel => 'Phút học';

  @override
  String get myBookmarks => 'Bookmark của tôi';

  @override
  String get studyFlashcards => 'Flashcard';

  @override
  String get studyFlashcardsDesc => 'Ghi nhớ Ayah bằng thẻ hai mặt';

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
  String get comingSoon => 'Sắp ra mắt';

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
      'Văn bản Ả Rập & bản dịch: Tanzil.net · QuranEnc.com. Audio: EveryAyah.com. Font: KFGQPC (King Fahd Complex).';

  @override
  String get versionLabel => 'Phiên bản';

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
  String get searchResultsAyahs => 'Kết quả trong nội dung';

  @override
  String get searchNoAyahResults => 'Không tìm thấy Ayah nào phù hợp.';

  @override
  String get searchLabel => 'Tìm kiếm';

  @override
  String get searchAskLabel => 'Hỏi AI';

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
  String get searchEmptyRecentSectionTitle => 'Gần đây';

  @override
  String get searchEmptySuggestedSectionTitle => 'Gợi ý';

  @override
  String get searchLoadingLabel => 'Đang tìm kiếm...';

  @override
  String get libraryTitle => 'Thư viện của tôi';

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
}
