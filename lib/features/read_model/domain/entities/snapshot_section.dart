/// Định danh 1 phần trong LearningSnapshot (Sprint 18 Phase 1) —
/// KHÔNG phải kiểu bọc dữ liệu chung (LearningSnapshot dùng TRƯỜNG
/// ĐẶT TÊN riêng cho từng phần — context/insights/dailyPlan/
/// smartSession — cùng kỷ luật LearningJourney/TutorContext, KHÔNG
/// gộp thành 1 danh sách kiểu chung vì 4 phần có KIỂU DỮ LIỆU khác
/// hẳn nhau, ép về 1 kiểu chung sẽ mất thông tin kiểu tĩnh). Enum này
/// tồn tại để tầng đọc TƯƠNG LAI (vd 1 API "cho tôi ĐÚNG phần X của
/// snapshot" hoặc ghi log/đo hiệu năng theo từng phần) có thể THAM
/// CHIẾU 1 phần cụ thể mà không cần biết kiểu Dart cụ thể của nó —
/// CHƯA có nơi nào dùng enum này ở phase "Foundation" này (không có
/// API chọn-lọc-phần nào được yêu cầu), khai báo trước để đặt tên
/// thống nhất cho 4 phần đã biết.
///
/// Domain thuần Dart — không phụ thuộc Flutter.
enum SnapshotSection {
  /// Ứng với LearningSnapshot.context (TutorContext).
  tutorContext,

  /// Ứng với LearningSnapshot.insights (List&lt;TutorInsight&gt;).
  tutorInsights,

  /// Ứng với LearningSnapshot.dailyPlan (DailyLearningPlan).
  dailyPlan,

  /// Ứng với LearningSnapshot.smartSession (SmartLearningSession).
  smartSession,
}
