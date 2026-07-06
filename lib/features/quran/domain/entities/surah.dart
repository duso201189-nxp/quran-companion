/// Nơi mặc khải của Surah.
enum RevelationPlace { mecca, madinah }

/// Entity Surah — thuần Dart, không phụ thuộc Drift/Flutter.
class Surah {
  const Surah({
    required this.id,
    required this.nameArabic,
    required this.nameLatin,
    required this.nameVi,
    required this.nameEn,
    required this.ayahCount,
    required this.revelationPlace,
    required this.orderRevealed,
  });

  final int id;
  final String nameArabic;
  final String nameLatin;
  final String nameVi;
  final String nameEn;
  final int ayahCount;
  final RevelationPlace revelationPlace;
  final int orderRevealed;
}
