/// Loại mục nội dung ngôn ngữ học trong Lexicon (Sprint 12 Phase
/// 0.1 mục 2/3). Tổng quát hoá có chủ đích — thêm loại mục mới (vd.
/// idiom, tafsir note) chỉ cần thêm 1 giá trị enum + 1 lớp implement
/// [LexiconEntry] + nhóm phương thức tương ứng trên
/// `LexiconRepository`, KHÔNG sửa các loại đã có.
///
/// Synonym/Antonym CỐ Ý không có mặt ở đây — đó là QUAN HỆ giữa 2
/// Lemma (xem [LexiconRelation]), không phải một loại nội dung độc
/// lập có dữ liệu riêng.
enum LexiconEntryType { lemma, root, lexeme, morphology, grammar, phrase }

/// Giao diện chung mọi thực thể nội dung Lexicon implement — cho phép
/// giải quyết tổng quát qua (type, id) khi nơi gọi chỉ biết cặp này
/// (vd. Flashcard.lexiconEntryId, hoặc gợi ý từ AI Tutor sau này) mà
/// không cần biết trước là loại cụ thể nào.
///
/// Thuần Dart — không phụ thuộc Flutter/Riverpod/Drift.
abstract interface class LexiconEntry {
  int get id;
  LexiconEntryType get type;
}
