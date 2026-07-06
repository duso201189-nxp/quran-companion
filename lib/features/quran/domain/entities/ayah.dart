/// Entity Ayah — thuần Dart.
class Ayah {
  const Ayah({
    required this.id,
    required this.surahId,
    required this.ayahNumber,
    required this.textUthmani,
    this.juz,
    this.hizb,
    this.page,
    this.sajdah = false,
  });

  /// Đánh số toàn cục 1..6236.
  final int id;
  final int surahId;

  /// Số Ayah trong Surah.
  final int ayahNumber;
  final String textUthmani;
  final int? juz;
  final int? hizb;
  final int? page;

  /// Ayah có vị trí quỳ lạy (sajdah tilawah).
  final bool sajdah;
}
