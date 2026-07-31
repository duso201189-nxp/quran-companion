import 'lexicon_entry.dart';

/// Một nhãn hình thái-ngữ pháp gắn vào một WordInstance (thì/ngôi/
/// cách/giống/số...) — Sprint 12 Phase 0.1 mục 2. CỐ Ý tách khỏi
/// WordInstance thành thực thể riêng thay vì các cột phẳng: một
/// WordInstance mang NHIỀU nhãn đồng thời (vd. "ngôi 3, giống đực, số
/// ít, thì quá khứ" = 4 nhãn), tách riêng giữ mỗi nhãn tự truy vấn
/// được độc lập (vd. "mọi WordInstance ở thì quá khứ").
class GrammarFeature implements LexiconEntry {
  const GrammarFeature({
    required this.id,
    required this.wordInstanceId,
    required this.featureKey,
    required this.featureValue,
  });

  @override
  final int id;

  @override
  LexiconEntryType get type => LexiconEntryType.grammar;

  /// FK tới [WordInstance] mang nhãn này.
  final int wordInstanceId;

  /// Loại đặc trưng, vd 'tense', 'person', 'case', 'gender', 'number'.
  final String featureKey;

  /// Giá trị đặc trưng, vd 'past', '3rd', 'nominative', 'masculine'.
  final String featureValue;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GrammarFeature &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          wordInstanceId == other.wordInstanceId &&
          featureKey == other.featureKey &&
          featureValue == other.featureValue;

  @override
  int get hashCode => Object.hash(id, wordInstanceId, featureKey, featureValue);
}
