/// Phân loại nguồn gốc lỗi (Sprint 19 Phase 1) — dùng để nhóm
/// AppFailure theo TẦNG kỹ thuật phát sinh, KHÔNG phải theo tính năng
/// (feature). Đúng 4 nhóm mà Task 2 liệt kê — không thêm nhóm nào
/// khác ở phase này (vd "network" chưa cần, "No networking").
enum FailureCategory {
  /// Lỗi từ Drift/SQLite (đọc/ghi Group A hoặc Group B database).
  database,

  /// Lỗi phân tích dữ liệu (vd JSON/định dạng không hợp lệ).
  parsing,

  /// Lỗi hệ thống file/bộ nhớ cục bộ (vd cache audio, SharedPreferences).
  storage,

  /// Mọi lỗi không rơi vào 3 nhóm trên — luôn có 1 nhóm hứng được,
  /// không bao giờ để lỗi "không phân loại".
  unexpected,
}
