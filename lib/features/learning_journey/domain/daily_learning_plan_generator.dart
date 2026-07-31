import '../../ai_tutor/domain/entities/tutor_suggestion.dart';
import 'entities/daily_learning_plan.dart';
import 'entities/journey_step.dart';

/// Hàm THUẦN sắp xếp TutorSuggestion ĐÃ CÓ SẴN (tham số truyền vào,
/// không tự truy vấn) thành 1 DailyLearningPlan có thứ tự — cùng kỷ
/// luật với mọi Calculator thuần trong dự án (vd
/// tutor_suggestion_generator.dart, learning_goal_calculator.dart):
/// tách khỏi Repository để test trực tiếp không cần DB/provider.
///
/// QUY TẮC XẾP HẠNG (rule-based, KHÔNG AI — đúng yêu cầu "Rule-based
/// only. No AI model"): sắp theo TutorSuggestionPriority
/// (high -> medium -> low), GIỮ NGUYÊN thứ tự tương đối giữa các gợi
/// ý CÙNG mức ưu tiên (sort ổn định của Dart `List.sort` không đảm
/// bảo ổn định — dùng thuật toán merge thủ công bên dưới để đảm bảo
/// ổn định thật sự, tránh thứ tự "nhảy" ngẫu nhiên giữa các lần gọi
/// với cùng input). KHÔNG tính lại priority — priority đã có sẵn từ
/// TutorSuggestion (AI Tutor, Sprint 15), ở đây chỉ SO SÁNH để sắp
/// xếp, không suy ra priority mới.
DailyLearningPlan computeDailyLearningPlan(
  List<TutorSuggestion> suggestions,
  DateTime date,
) {
  final ordered = _stableSortByPriority(suggestions);
  final steps = [
    for (var i = 0; i < ordered.length; i++)
      JourneyStep(order: i, suggestion: ordered[i]),
  ];
  return DailyLearningPlan(
    date: DateTime(date.year, date.month, date.day),
    steps: steps,
  );
}

int _priorityRank(TutorSuggestionPriority p) => switch (p) {
      TutorSuggestionPriority.high => 0,
      TutorSuggestionPriority.medium => 1,
      TutorSuggestionPriority.low => 2,
    };

/// Sắp xếp ỔN ĐỊNH theo hạng ưu tiên — giữ nguyên thứ tự ban đầu giữa
/// các phần tử có CÙNG hạng (khác `List.sort`, không cam kết ổn
/// định). Gộp bằng cách nhóm theo hạng rồi nối lại, thay vì so sánh
/// trực tiếp qua sort — đơn giản, không cần thư viện ngoài.
List<TutorSuggestion> _stableSortByPriority(List<TutorSuggestion> input) {
  final byRank = <int, List<TutorSuggestion>>{};
  for (final s in input) {
    byRank.putIfAbsent(_priorityRank(s.priority), () => []).add(s);
  }
  final ranks = byRank.keys.toList()..sort();
  return [for (final r in ranks) ...byRank[r]!];
}
