import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../flashcards/domain/entities/smart_deck_type.dart';
import '../domain/entities/tutor_action.dart';

/// Thực thi 1 TutorAction bằng router CÓ SẴN (Sprint 15 Phase 3 mục
/// 4, TÁCH RA thành hàm dùng chung ở Sprint 16 Phase 2 để
/// LearningJourneyScreen dùng LẠI đúng logic điều hướng này, KHÔNG
/// tạo bản sao thứ 2 — đúng yêu cầu "No duplicated navigation logic")
/// — TÁI SỬ DỤNG ĐÚNG AppRoutes/context.push mọi màn hình khác dùng
/// (vd StudyScreen), KHÔNG có cơ chế điều hướng mới nào. Ánh xạ
/// [TutorActionDestination] (định danh trừu tượng, domain thuần) sang
/// đường dẫn route CỤ THỂ CHỈ diễn ra Ở ĐÂY — domain không biết
/// AppRoutes tồn tại (xem tutor_action.dart).
void executeTutorAction(BuildContext context, TutorAction action) {
  switch (action.destination) {
    case TutorActionDestination.reviewSession:
      context.push(AppRoutes.reviewSession);
    case TutorActionDestination.flashcards:
      context.push(AppRoutes.flashcards);
    case TutorActionDestination.weakCards:
      context.push(AppRoutes.smartDeck, extra: SmartDeckType.weakRoots);
    case TutorActionDestination.learningSession:
      context.push(AppRoutes.learningSession);
  }
}
