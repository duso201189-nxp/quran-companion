import 'lexicon_entry.dart';

/// Gốc từ Ả Rập (جذر) — bộ 2-4 phụ âm mang nghĩa lõi mà nhiều Lemma
/// cùng chia sẻ (vd. ك-ت-ب sinh ra كتاب "sách", كاتب "người viết",
/// مكتبة "thư viện"...). Tầng cao nhất của phân cấp Lexicon (Sprint
/// 12 Phase 0.1 mục 3) — KHÔNG phải một trường phẳng trên Lemma như
/// sketch ban đầu (DATABASE.md cũ), mà là thực thể riêng để trả lời
/// "những từ nào khác cùng gốc với từ này?".
class Root implements LexiconEntry {
  const Root({
    required this.id,
    required this.radicals,
    this.meaningCore,
  });

  @override
  final int id;

  @override
  LexiconEntryType get type => LexiconEntryType.root;

  /// Các phụ âm gốc, vd 'ك ت ب'.
  final String radicals;

  /// Trường nghĩa lõi chung của cả họ từ (tuỳ chọn).
  final String? meaningCore;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Root &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          radicals == other.radicals &&
          meaningCore == other.meaningCore;

  @override
  int get hashCode => Object.hash(id, radicals, meaningCore);
}
