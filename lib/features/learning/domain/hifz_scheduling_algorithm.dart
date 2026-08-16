import 'entities/srs_card.dart';
import 'scheduling_algorithm.dart';

/// Lịch ôn cho học thuộc (Hifz) — Sprint 7.7a.
///
/// Là SM-2 y hệt, THÊM ĐÚNG MỘT luật: khoảng cách ôn không bao giờ
/// vượt [maxIntervalDays]. Mọi thứ khác — ánh xạ chất lượng 0/3/4/5,
/// công thức ease, sàn ease 1.3, bậc 1 → 6 → nhân ease, cách xử lý
/// trả lời sai, tập trạng thái — giữ nguyên của SM-2.
///
/// ## Vì sao chặn trần, và vì sao chỉ chặn trần
///
/// SM-2 để khoảng cách lớn vô hạn: 1 → 6 → 15 → 38 → 94 → 234 → 586
/// ngày. Với văn bản đã thuộc, im lặng gần hai năm là chính cái quên
/// mà Hiến pháp Study §2 cảnh báo ("giữ lại, chứ không phải thu nạp,
/// mới là phần việc lâu dài và khó hơn") và §10 yêu cầu chống lại
/// ("ôn tập tăng cường, lâu dài, GIỮ phần đã thuộc"). Trần biến bậc
/// thang thành 1 → 6 → 15 → 30 → 30 → …: ở trạng thái ổn định là
/// khoảng 12 lần ôn/năm thay vì ~2 — tăng cường thật sự, bằng ĐÚNG
/// MỘT hằng số thay vì bịa ra bốn cái.
///
/// Không đổi ease, không đổi bậc 6 ngày, không thêm cơ chế quá hạn hay
/// lặp trong ngày: mỗi thứ đó là một hằng số nữa không có căn cứ nào
/// trong dự án này để chọn.
///
/// ## Vì sao chép lại SM-2 thay vì tham số hoá nó
///
/// [SM2SchedulingAlgorithm] là `const` với hằng số `static const`, và
/// hành vi của nó phải giữ NGUYÊN từng chi tiết cho thẻ 'ayah'/'lemma'
/// đang tồn tại. Một lớp riêng khiến điều đó đúng theo cấu trúc: không
/// có đường nào để thay đổi bên Hifz chạm tới lịch ôn tập thường.
/// Trùng lặp một ít số học ease là cái giá có chủ ý cho bảo đảm đó.
///
/// Thuần Dart — không import Flutter/Riverpod/Drift/SQLite.
class HifzSchedulingAlgorithm implements SchedulingAlgorithm {
  const HifzSchedulingAlgorithm();

  /// Trần khoảng cách ôn, tính bằng ngày.
  ///
  /// 30 ngày khớp vòng ôn *manzil* cổ điển (một Juz mỗi ngày, trọn bộ
  /// trong một tháng) — chọn một chu kỳ có thật trong truyền thống học
  /// thuộc thay vì một con số tự nghĩ ra.
  static const int maxIntervalDays = 30;

  static const double _defaultEaseFactor = 2.5;
  static const double _minEaseFactor = 1.3;

  /// Sprint D6.6 §11 — xem doc comment [SchedulingAlgorithm.algorithmId].
  /// 'capped' đúng tên luật DUY NHẤT khác SM-2 gốc: chặn trần
  /// [maxIntervalDays]. Đổi hằng số này (vd trần khác 30) PHẢI tăng
  /// hậu tố -vN.
  @override
  String get algorithmId => 'hifz-sm2-capped-v1';

  @override
  SchedulingInput initialState() => (
        easeFactor: _defaultEaseFactor,
        intervalDays: 0,
        repetitions: 0,
        state: SrsCardState.newCard,
      );

  @override
  SchedulingResult review({
    required SchedulingInput current,
    required ReviewGrade grade,
    required DateTime now,
  }) {
    final quality = _qualityOf(grade);

    var repetitions = current.repetitions;
    var intervalDays = current.intervalDays;

    if (quality < 3) {
      repetitions = 0;
      intervalDays = 1;
    } else {
      if (repetitions == 0) {
        intervalDays = 1;
      } else if (repetitions == 1) {
        intervalDays = 6;
      } else {
        intervalDays = (intervalDays * current.easeFactor).round();
      }
      repetitions += 1;
    }

    var easeFactor = current.easeFactor +
        (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (easeFactor < _minEaseFactor) easeFactor = _minEaseFactor;

    // Luật DUY NHẤT khác SM-2. Đặt SAU mọi phép tính để không có nhánh
    // nào thoát được nó. Dùng `min` chứ không phải "chỉ chặn khi tăng":
    // một khoảng cách đã lớn hơn trần (dữ liệu lệch, đổi trần về sau)
    // phải được kéo về miền, không được giữ nguyên.
    if (intervalDays > maxIntervalDays) intervalDays = maxIntervalDays;

    final wasGraduated = current.state == SrsCardState.review ||
        current.state == SrsCardState.lapsed;
    final nextState = quality < 3
        ? (wasGraduated ? SrsCardState.lapsed : SrsCardState.learning)
        : SrsCardState.review;

    return (
      easeFactor: easeFactor,
      intervalDays: intervalDays,
      repetitions: repetitions,
      state: nextState,
      dueDate: now.add(Duration(days: intervalDays)),
    );
  }

  static int _qualityOf(ReviewGrade grade) => switch (grade) {
        ReviewGrade.again => 0,
        ReviewGrade.hard => 3,
        ReviewGrade.good => 4,
        ReviewGrade.easy => 5,
      };
}
