import 'dart:math';

/// Gộp 1 đáp án đúng + danh sách nhiễu thành mảng lựa chọn đã xáo
/// trộn, kèm chỉ số đáp án đúng sau khi xáo (Sprint S2 — Quality &
/// Polish, D7) — trích ra từ 2 dòng lặp lại Y HỆT ở cả 4
/// QuestionGenerator (`[correct, ...decoys]..shuffle(random)` rồi
/// `options.indexOf(correct)`), phần DUY NHẤT thật sự giống nhau giữa
/// 4 generator — cách CHỌN [decoys] vẫn khác nhau hoàn toàn ở mỗi
/// generator (Surah nào, Ayah nào, có bản dịch hay không...), hàm này
/// không đụng tới phần đó.
///
/// Nhận đúng [decoys] đã chọn sẵn — không tự giới hạn số lượng, để
/// mỗi generator tự quyết định bao nhiêu nhiễu là đủ (hiện tại luôn
/// truyền đúng 3, nhưng hàm này không áp đặt con số đó).
///
/// KHÔNG đổi thứ tự/số lần gọi [random] so với trước khi trích ra —
/// mỗi generator vẫn tự shuffle/chọn decoy TRƯỚC khi gọi hàm này, hàm
/// này chỉ gọi `random` đúng 1 lần (`..shuffle(random)`), giống hệt
/// dòng code cũ nó thay thế — hành vi tất định (cùng seed -> cùng kết
/// quả) không đổi.
({List<String> options, int correctOptionIndex}) buildShuffledOptions(
  String correct,
  List<String> decoys,
  Random random,
) {
  final options = [correct, ...decoys]..shuffle(random);
  return (options: options, correctOptionIndex: options.indexOf(correct));
}
