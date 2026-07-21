import '../../smart_learning/domain/entities/smart_learning_session.dart';
import 'entities/learning_snapshot.dart';
import 'entities/snapshot_timestamp.dart';

/// Hàm THUẦN dựng LearningSnapshot từ SmartLearningSession ĐÃ CÓ SẴN
/// (tham số truyền vào, không tự truy vấn) — cùng kỷ luật với mọi
/// Calculator thuần trong dự án (vd smart_learning_session_generator.dart,
/// daily_learning_plan_generator.dart): tách khỏi Repository để test
/// trực tiếp không cần DB/provider.
///
/// KHÔNG tính toán gì — CHỈ trích xuất lại (không sao chép/rút gọn)
/// [session] và [session.journey] (context/insights/todayPlan) thành
/// LearningSnapshot — đúng yêu cầu "Do not recompute analytics. Reuse
/// existing outputs from lower layers." [session] TỰ NÓ đã là 1 trong
/// 4 trường của LearningSnapshot (smartSession) — snapshot không phải
/// "session cộng thêm gì đó", mà là "session ĐÃ CÓ SẴN, nhìn từ góc
/// độ đọc, kèm 3 phần khác nó vốn đã mang theo qua .journey".
LearningSnapshot computeLearningSnapshot(
  SmartLearningSession session,
  DateTime generatedAt,
) {
  return LearningSnapshot(
    timestamp: SnapshotTimestamp(generatedAt),
    context: session.journey.context,
    insights: session.journey.insights,
    dailyPlan: session.journey.todayPlan,
    smartSession: session,
  );
}
