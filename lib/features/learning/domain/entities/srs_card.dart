/// Loại mục được lên lịch ôn tập. [ayah] — Sprint 10 (Revision Queue).
/// [lemma] — Sprint 13 Phase 2 (Flashcard, itemId = Lemma.id trực
/// tiếp, xem lib/features/lexicon/domain/entities/lemma.dart).
enum LearningItemType { ayah, lemma }

/// Trạng thái thẻ SRS, mô hình Anki-style (new/learning/review/lapsed).
/// 'new' là từ khoá dành riêng của Dart nên dùng [newCard] — ánh xạ
/// chuỗi lưu database qua [SrsCardStateCodec]/[srsCardStateFromDbValue].
enum SrsCardState { newCard, learning, review, lapsed }

extension SrsCardStateCodec on SrsCardState {
  String toDbValue() => switch (this) {
        SrsCardState.newCard => 'new',
        SrsCardState.learning => 'learning',
        SrsCardState.review => 'review',
        SrsCardState.lapsed => 'lapsed',
      };
}

SrsCardState srsCardStateFromDbValue(String value) => switch (value) {
      'new' => SrsCardState.newCard,
      'learning' => SrsCardState.learning,
      'review' => SrsCardState.review,
      'lapsed' => SrsCardState.lapsed,
      _ => SrsCardState.newCard,
    };

/// Một thẻ lịch ôn tập SRS (Sprint 10 — DR-2026-0005). Domain thuần —
/// không biết Drift.
class SrsCard {
  const SrsCard({
    required this.id,
    required this.itemType,
    required this.itemId,
    required this.easeFactor,
    required this.intervalDays,
    required this.repetitions,
    required this.dueDate,
    required this.state,
    required this.updatedAtMs,
  });

  final String id;
  final LearningItemType itemType;
  final int itemId;
  final double easeFactor;
  final int intervalDays;
  final int repetitions;

  /// Epoch ms UTC — thời điểm đến hạn ôn tập.
  final int dueDate;
  final SrsCardState state;

  /// Epoch ms UTC — lần ghi cuối cùng (tạo mới HOẶC applyReview ghi
  /// đè). Thêm ở Sprint 14 Phase 1 (Learning Analytics) — cột đã có
  /// sẵn trên bảng (SyncColumns.updatedAt), chỉ mới lộ ra tầng domain.
  /// KHÔNG phải lịch sử — mỗi lần ôn GHI ĐÈ giá trị cũ, không cộng dồn
  /// (xem LearningStatistics.reviewsToday để biết giới hạn khi dùng
  /// trường này cho thống kê).
  final int updatedAtMs;
}
