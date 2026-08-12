import '../../../../core/quran/ayah_ordinal.dart';
import '../../../../core/quran/quran_address.dart';

/// Trạng thái vòng đời một cam kết học thuộc — Sprint 7.7a.
///
/// Cả ba đều là kế hoạch CÒN SỐNG: cả ba đều góp Ayah vào tập hợp lên
/// lịch Hifz. [paused] chỉ lọc bớt phần "đến hạn"; [completed] là một
/// cột mốc. Chỉ xoá mềm mới đưa kế hoạch ra khỏi tập hợp.
enum HifzPlanStatus { active, paused, completed }

extension HifzPlanStatusCodec on HifzPlanStatus {
  String toDbValue() => switch (this) {
        HifzPlanStatus.active => 'active',
        HifzPlanStatus.paused => 'paused',
        HifzPlanStatus.completed => 'completed',
      };
}

/// Chuỗi lạ -> [HifzPlanStatus.active]: cùng tinh thần phòng thủ với
/// `srsCardStateFromDbValue` — một dòng hỏng không được làm sập màn
/// hình, và "đang học" là mặc định ít gây hại nhất.
HifzPlanStatus hifzPlanStatusFromDbValue(String value) => switch (value) {
      'paused' => HifzPlanStatus.paused,
      'completed' => HifzPlanStatus.completed,
      _ => HifzPlanStatus.active,
    };

/// Một cam kết học thuộc MỘT ĐOẠN — Sprint 7.7a.
///
/// Nghĩa của một [HifzPlan] là "tôi cam kết học thuộc đoạn này", KHÔNG
/// phải "tôi đã thuộc đoạn này". Tiến trình thuộc từng Ayah nằm ở
/// `srs_cards(item_type='hifz')`; [status] chỉ nói về cam kết.
/// [HifzPlanStatus.completed] vì thế cũng không có nghĩa "mọi Ayah đã
/// thuộc" — nó chỉ là người dùng đánh dấu cam kết này đã xong.
class HifzPlan {
  const HifzPlan({
    required this.id,
    required this.ayahFrom,
    required this.ayahTo,
    required this.status,
    required this.startedAt,
    this.completedAt,
  });

  final String id;

  /// Ordinal Ayah TOÀN CỤC, 1..6236 — cùng hệ với `srs_cards.item_id`
  /// và `khatm_cycles.current_ayah_id`, KHÔNG phải chỉ số 0-based
  /// trong Surah như `study_sessions`.
  final int ayahFrom;
  final int ayahTo;

  final HifzPlanStatus status;
  final int startedAt;
  final int? completedAt;

  /// Số Ayah trong đoạn.
  int get ayahCount => ayahTo - ayahFrom + 1;

  /// Mọi ordinal Ayah thuộc đoạn này.
  ///
  /// Phép đếm số nguyên thuần — nhờ [ayahFrom]/[ayahTo] đã cùng hệ với
  /// `item_id`, không có bước quy đổi nào để sai.
  Iterable<int> get ayahOrdinals =>
      Iterable.generate(ayahCount, (i) => ayahFrom + i);

  /// Đầu đoạn dưới dạng địa chỉ; `null` nếu ordinal ngoài miền.
  QuranAddress? get fromAddress => AyahOrdinal.tryFromOrdinal(ayahFrom);

  /// Cuối đoạn dưới dạng địa chỉ; `null` nếu ordinal ngoài miền.
  QuranAddress? get toAddress => AyahOrdinal.tryFromOrdinal(ayahTo);

  /// Đoạn có hợp lệ không — `1 <= from <= to <= 6236`.
  ///
  /// Bất biến này do tầng repository bảo đảm khi GHI (không có CHECK ở
  /// database, cùng lý do không có FK: hai tệp SQLite riêng). Hàm này
  /// là nơi ĐỊNH NGHĨA nó, để cả repository lẫn test hỏi cùng một chỗ.
  static bool isValidRange(int from, int to) =>
      from >= 1 && to <= AyahOrdinal.totalAyahs && from <= to;
}
