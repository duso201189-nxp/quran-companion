import 'package:flutter/material.dart';

import '../../../../shared/widgets/stat_card.dart';

/// Thẻ 1 nhận định AI Tutor (Sprint 15 Phase 2 mục 3) — thuần trình
/// bày, KHÔNG đọc provider/biết gì về TutorInsightKind (nhận sẵn
/// icon + nhãn + giá trị đã định dạng từ nơi gọi) — cùng nguyên tắc
/// GoalCard/AchievementCard.
///
/// Sprint 20 Phase 2, Task 3 — xác nhận cây widget của lớp này TRÙNG
/// KHỚP TỪNG DÒNG với `StatCard` (`lib/shared/widgets/stat_card.dart`,
/// nhánh `accented: false`) — giữ nguyên tên lớp/constructor này
/// (được `tutor_home_screen.dart` và `test/tutor_insight_card_test.dart`
/// phụ thuộc, không cần đổi) nhưng chuyển thân hàm sang GỌI LẠI
/// `StatCard` thay vì lặp lại cây widget — loại bỏ trùng lặp mà không
/// đổi API công khai/giao diện.
class TutorInsightCard extends StatelessWidget {
  const TutorInsightCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return StatCard(icon: icon, value: value, label: label);
  }
}
