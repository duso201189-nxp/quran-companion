import 'lexicon_entry.dart';

/// Một biến thể hình thái/khuôn phái sinh (وزن) cụ thể của một Lemma
/// (Sprint 12 Phase 0.1 mục 3) — tầng GIỮA Lemma và WordInstance.
/// Trả lời "khuôn/thể động từ nào sinh ra dạng này?", trong khi
/// WordInstance trả lời "chỗ nào trong Qur'an dùng đúng dạng đã biến
/// đổi này?". Lemma không mang thông tin thể/khuôn — đó là lý do
/// Lexeme tồn tại như một tầng riêng, không gộp vào Lemma.
class Lexeme implements LexiconEntry {
  const Lexeme({
    required this.id,
    required this.lemmaId,
    this.formPattern,
    this.partOfSpeechDetail,
  });

  @override
  final int id;

  @override
  LexiconEntryType get type => LexiconEntryType.lexeme;

  /// FK tới [Lemma] mà Lexeme này là một biến thể của.
  final int lemmaId;

  /// Khuôn/thể phái sinh, vd 'Form I', 'فَعَلَ'.
  final String? formPattern;

  /// Chi tiết loại từ hơn Lemma.posTag, vd 'động từ, thể I, gốc quá
  /// khứ'.
  final String? partOfSpeechDetail;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Lexeme &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          lemmaId == other.lemmaId &&
          formPattern == other.formPattern &&
          partOfSpeechDetail == other.partOfSpeechDetail;

  @override
  int get hashCode => Object.hash(id, lemmaId, formPattern, partOfSpeechDetail);
}
