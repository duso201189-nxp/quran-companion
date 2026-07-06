/// Một kết quả tìm kiếm toàn văn trong nội dung Qur'an.
class AyahSearchResult {
  const AyahSearchResult({
    required this.ayahId,
    required this.surahId,
    required this.ayahNumber,
    required this.surahNameLatin,
    required this.arabic,
    this.translation,
  });

  /// Id toàn cục 1..6236.
  final int ayahId;
  final int surahId;
  final int ayahNumber;
  final String surahNameLatin;

  /// Văn bản Uthmani đầy đủ tashkeel (hiển thị).
  final String arabic;

  /// Bản dịch ưu tiên (vi rồi en) — null nếu thiếu.
  final String? translation;
}
