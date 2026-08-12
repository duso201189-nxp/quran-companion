import '../../../core/quran/ayah_ordinal.dart';
import '../../../core/quran/quran_address.dart';

/// Kết quả kiểm khoảng Ayah người dùng nhập trên form tạo kế hoạch
/// Hifz — Sprint 7.7b-ii.
///
/// Tầng NHẬP LIỆU của form là Surah + số Ayah 1-based (điều người
/// dùng thực sự nghĩ tới), khác tầng LƯU TRỮ của
/// `HifzPlanRepository.createPlan` (ordinal toàn cục 1..6236, xem
/// Sprint 7.7a). Kiểm tra ở đây bổ khuyết đúng một việc repository
/// không tự làm được: biết ranh giới của MỘT Surah cụ thể — repository
/// chỉ biết miền chung 1..6236, không biết Surah 2 có 286 Ayah còn
/// Surah 114 chỉ có 6. `HifzPlanRepository.createPlan` giữ nguyên,
/// không đổi.
sealed class HifzRangeInput {
  const HifzRangeInput._();
}

/// Khoảng hợp lệ, đã quy đổi sẵn sang ordinal toàn cục — sẵn sàng đưa
/// thẳng vào `HifzPlanRepository.createPlan`.
final class HifzRangeValid extends HifzRangeInput {
  const HifzRangeValid({
    required this.ayahFromOrdinal,
    required this.ayahToOrdinal,
  }) : super._();

  final int ayahFromOrdinal;
  final int ayahToOrdinal;
}

/// Lý do một khoảng bị từ chối — tầng UI ánh xạ từng giá trị sang
/// đúng một thông báo lỗi hiển thị cạnh đúng trường nhập liên quan.
enum HifzRangeInvalidReason {
  ayahFromBelowOne,
  ayahToAboveSurahCount,
  ayahFromAfterAyahTo,
}

final class HifzRangeInvalid extends HifzRangeInput {
  const HifzRangeInvalid(this.reason) : super._();

  final HifzRangeInvalidReason reason;
}

/// Kiểm một khoảng Ayah trong PHẠM VI MỘT SURAH trước khi gọi
/// repository — thuần Dart, không Flutter/Riverpod/Drift, gọi được
/// trực tiếp từ test không cần dựng widget.
abstract final class HifzRangeInputValidator {
  static HifzRangeInput validate({
    required int surahId,
    required int surahAyahCount,
    required int ayahFrom,
    required int ayahTo,
  }) {
    if (ayahFrom < 1) {
      return const HifzRangeInvalid(HifzRangeInvalidReason.ayahFromBelowOne);
    }
    if (ayahTo > surahAyahCount) {
      return const HifzRangeInvalid(
        HifzRangeInvalidReason.ayahToAboveSurahCount,
      );
    }
    if (ayahFrom > ayahTo) {
      return const HifzRangeInvalid(
        HifzRangeInvalidReason.ayahFromAfterAyahTo,
      );
    }

    final fromOrdinal =
        AyahOrdinal.tryToOrdinal(QuranAddress.ayah(surahId, ayahFrom));
    final toOrdinal =
        AyahOrdinal.tryToOrdinal(QuranAddress.ayah(surahId, ayahTo));
    if (fromOrdinal == null || toOrdinal == null) {
      // Không nên xảy ra khi đã kiểm theo surahAyahCount ở trên (nghĩa
      // là surahAyahCount không khớp dữ liệu thật) — không đoán, không
      // ném lỗi: coi như "vượt số Ayah của Surah", cùng loại lỗi hợp
      // lý nhất cho tình huống này.
      return const HifzRangeInvalid(
        HifzRangeInvalidReason.ayahToAboveSurahCount,
      );
    }
    return HifzRangeValid(
      ayahFromOrdinal: fromOrdinal,
      ayahToOrdinal: toOrdinal,
    );
  }
}
