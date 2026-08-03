/// Khoảng lặng sau lần người dùng TỰ cuộn gần nhất, trước khi màn hình
/// được phép cuộn theo audio trở lại.
///
/// 10 giây: đủ dài để đọc hết một Ayah dịch mà không bị kéo về, đủ ngắn
/// để việc tự cuộn quay lại trước khi người dùng kịp kết luận là nó
/// hỏng.
const Duration kPlaybackFollowGrace = Duration(seconds: 10);

/// `true` nếu màn hình đọc được phép cuộn theo Ayah đang phát.
///
/// Sprint F1 (Phase 4) — `DR-2026-0019` §7.3: quyết định "có bám theo
/// audio không" là một CHÍNH SÁCH, tức một hàm thuần của thời gian, chứ
/// không phải một nhánh `if` nằm lẫn giữa `ref.listen` và
/// `ItemScrollController`.
///
/// Vấn đề đang chữa: người dùng cuộn xuống đọc bản dịch, Ayah kế
/// chuyển, màn hình giật ngược về chỗ đang phát. Muốn đọc tiếp thì phải
/// cuộn lại — mỗi Ayah một lần.
///
/// [lastManualScrollAt] là `null` khi người dùng chưa tự cuộn lần nào
/// trong phiên đọc này. Đó là trường hợp thường gặp nhất và câu trả lời
/// là có — bám theo audio vẫn là mặc định.
///
/// Chính sách này KHÔNG khoá vĩnh viễn: hết [grace] thì tự cuộn quay
/// lại. Nhờ vậy không cần thêm nút "về chỗ đang phát", và người dùng
/// không thể tự đưa mình vào trạng thái kẹt mà không biết đường ra.
///
/// Đây chưa phải lời giải cấu trúc. Vòng lặp thật — audio vừa là nguồn
/// vừa là đích của vị trí cuộn — chỉ được cắt ở `DR-2026-0019` E3, khi
/// chiều đọc và chiều ghi của vị trí được tách hẳn. Cho tới lúc đó, một
/// khoảng lặng sau thao tác của người dùng là thay đổi nhỏ nhất mà an
/// toàn.
bool shouldFollowPlayback({
  required DateTime now,
  required DateTime? lastManualScrollAt,
  Duration grace = kPlaybackFollowGrace,
}) {
  if (lastManualScrollAt == null) return true;
  return now.difference(lastManualScrollAt) >= grace;
}
