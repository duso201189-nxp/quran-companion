import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/ai_tutor/presentation/tutor_home_screen.dart';
import '../features/analytics/presentation/progress_dashboard_screen.dart';
import '../features/flashcards/domain/entities/smart_deck_type.dart';
import '../features/flashcards/presentation/add_flashcard_screen.dart';
import '../features/flashcards/presentation/flashcard_browse_screen.dart';
import '../features/flashcards/presentation/flashcard_decks_screen.dart';
import '../features/flashcards/presentation/flashcard_review_screen.dart';
import '../features/flashcards/presentation/smart_deck_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/learning/presentation/review_session_screen.dart';
import '../features/learning_journey/presentation/learning_journey_screen.dart';
import '../features/learning_session/presentation/learning_session_screen.dart';
import '../features/library/presentation/collections/collections_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/quiz/presentation/quiz_session_screen.dart';
import '../features/quran/presentation/reading/reading_screen.dart';
import '../features/quran/presentation/surah_list_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/smart_learning/presentation/smart_learning_screen.dart';
import '../features/stats/presentation/stats_screen.dart';
import '../features/study/presentation/revision_queue_screen.dart';
import '../features/study/presentation/study_screen.dart';
import '../shared/widgets/app_scaffold.dart';

/// Tên route tập trung một chỗ — tránh gõ chuỗi rải rác trong code.
abstract final class AppRoutes {
  static const String home = '/home';
  static const String quran = '/quran';
  static const String study = '/study';
  static const String stats = '/stats';
  static const String profile = '/profile';

  /// Thư viện của tôi — màn hình push full-screen (không phải tab).
  static const String library = '/library';

  /// Bộ sưu tập Bookmark (Sprint 8 — DR-2026-0003 mục C) — push
  /// full-screen từ Thư viện của tôi, giống [library]/[search].
  static const String collections = '/collections';

  /// Ôn tập hằng ngày / Revision Queue (Sprint 9 — DR-2026-0004 mục
  /// 3) — push full-screen từ tab Học, giống [library]/[search]/
  /// [collections]. Không phải route lồng trong shell.
  static const String revisionQueue = '/revision-queue';

  /// Phiên ôn tập SM-2 (Sprint 10 Phase 3 — DR-2026-0005) — push
  /// full-screen từ tab Học, cùng mẫu với [revisionQueue]. Độc lập với
  /// Revision Queue (Quyết định 1): đây là phiên ôn có lịch trình
  /// (Scheduler), Revision Queue vẫn là danh sách phẳng không đổi.
  static const String reviewSession = '/review-session';

  /// Phiên Quiz (Sprint 10 Phase 4 — DR-2026-0005 mục 5) — push
  /// full-screen từ tab Học, cùng mẫu với [revisionQueue]/
  /// [reviewSession]. Câu hỏi sinh động mỗi phiên, không có route/màn
  /// hình "ngân hàng câu hỏi" riêng.
  static const String quizSession = '/quiz-session';

  /// Learning Session (Sprint 11 Phase 3) — push full-screen từ tab
  /// Học, MỘT route duy nhất cho toàn bộ phiên (LearningSessionScreen
  /// tự đổi thân màn hình theo hoạt động hiện tại) — không có route
  /// con nào cho từng hoạt động, đây là cách phiên không bao giờ đưa
  /// người dùng quay lại StudyScreen giữa chừng.
  static const String learningSession = '/learning-session';

  /// Tìm kiếm — màn hình push full-screen (không phải tab), giống
  /// [library]. Xem DR-2026-0002 mục 1.
  static const String search = '/search';

  /// Duyệt Flashcard (Sprint 13 Phase 3) — push full-screen từ tab
  /// Học, cùng mẫu [library]/[collections]. Điểm vào chính của UX
  /// Flashcard (danh sách, tìm kiếm/lọc, Smart Deck, nút Thêm).
  static const String flashcards = '/flashcards';

  /// Thêm Flashcard (từ Lemma/Root/Phrase) — push từ [flashcards].
  static const String addFlashcard = '/flashcards/add';

  /// Quản lý Deck Flashcard — push từ [flashcards], cùng mẫu
  /// [collections] (Bookmark) nhưng cho Flashcard.
  static const String flashcardDecks = '/flashcard-decks';

  /// Kết quả 1 Smart Deck (Sprint 13 Phase 3 mục 4) — push từ
  /// [flashcards], nhận SmartDeckType qua `extra` (không mã hoá vào
  /// path, tránh cần parse chuỗi -> enum ở nhiều nơi).
  static const String smartDeck = '/flashcards/smart-deck';

  /// Ôn Flashcard ĐỘC LẬP (không qua Learning Session) — cùng mẫu
  /// [reviewSession] đã có song song 2 lối vào (độc lập + lồng trong
  /// Learning Session). Dùng cho Onboarding "ôn thử ngay" và lối tắt
  /// từ [flashcards].
  static const String flashcardReview = '/flashcard-review';

  /// Bảng điều khiển Tiến độ học tập (Sprint 14 Phase 1) — push
  /// full-screen từ tab Học, cùng mẫu [flashcards]/[revisionQueue].
  static const String progressDashboard = '/progress-dashboard';

  /// AI Tutor (Sprint 15 Phase 2) — push full-screen từ tab Học, cùng
  /// mẫu [progressDashboard]. Chỉ trình bày, không AI/mạng thật (xem
  /// AITutorRepositoryImpl, Sprint 15 Phase 1).
  static const String aiTutor = '/ai-tutor';

  /// Learning Journey (Sprint 16 Phase 2) — push từ [aiTutor] (lối
  /// vào duy nhất ở phase này, xem TutorHomeScreen._JourneyEntryCard),
  /// cùng mẫu [progressDashboard]/[aiTutor].
  static const String learningJourney = '/learning-journey';

  /// Smart Learning (Sprint 17 Phase 2) — push từ [learningJourney]
  /// (lối vào duy nhất ở phase này, xem
  /// LearningJourneyScreen._SmartLearningEntryCard), cùng mẫu
  /// [progressDashboard]/[aiTutor]/[learningJourney].
  static const String smartLearning = '/smart-learning';

  /// Trang đọc trong tab Qur'an (giữ thanh điều hướng): /quran/surah/2
  static String surahReading(int surahId) => '/quran/surah/$surahId';

  /// Trang đọc full-screen cho nơi gọi NGOÀI vỏ tab (vd Thư viện của
  /// tôi): /read/2. Không dùng nhánh shell nên tránh xung đột khi
  /// push chồng route top-level.
  static String read(int surahId) => '/read/$surahId';
}

/// Parse surahId an toàn từ path ('abc'/'0' -> 0 -> SurahNotFound).
int _surahIdFrom(GoRouterState state) =>
    int.tryParse(state.pathParameters['id'] ?? '') ?? 0;

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      // StatefulShellRoute giữ trạng thái riêng của từng tab
      // (vị trí cuộn, màn hình con...) khi chuyển qua lại.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.quran,
                builder: (context, state) => const SurahListScreen(),
                routes: [
                  GoRoute(
                    path: 'surah/:id',
                    builder: (context, state) {
                      // Deep link id hỏng ('abc', '0') -> surahId 0,
                      // ReadingScreen hiển thị SurahNotFound thay vì crash.
                      final id =
                          int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                      return ReadingScreen(surahId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.study,
                builder: (context, state) => const StudyScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.stats,
                builder: (context, state) => const StatsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Thư viện của tôi: route top-level, push đè lên vỏ 5 tab
      // (full-screen kèm nút quay lại) — không thêm tab thứ 6.
      GoRoute(
        path: AppRoutes.library,
        builder: (context, state) => const LibraryScreen(),
      ),

      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),

      GoRoute(
        path: AppRoutes.collections,
        builder: (context, state) => const CollectionsScreen(),
      ),

      GoRoute(
        path: AppRoutes.flashcards,
        builder: (context, state) => const FlashcardBrowseScreen(),
      ),

      GoRoute(
        path: AppRoutes.addFlashcard,
        builder: (context, state) => const AddFlashcardScreen(),
      ),

      GoRoute(
        path: AppRoutes.flashcardDecks,
        builder: (context, state) => const FlashcardDecksScreen(),
      ),

      GoRoute(
        path: AppRoutes.smartDeck,
        builder: (context, state) =>
            SmartDeckScreen(type: state.extra! as SmartDeckType),
      ),

      GoRoute(
        path: AppRoutes.flashcardReview,
        builder: (context, state) => const FlashcardReviewScreen(),
      ),

      GoRoute(
        path: AppRoutes.progressDashboard,
        builder: (context, state) => const ProgressDashboardScreen(),
      ),

      GoRoute(
        path: AppRoutes.aiTutor,
        builder: (context, state) => const TutorHomeScreen(),
      ),

      GoRoute(
        path: AppRoutes.learningJourney,
        builder: (context, state) => const LearningJourneyScreen(),
      ),

      GoRoute(
        path: AppRoutes.smartLearning,
        builder: (context, state) => const SmartLearningScreen(),
      ),

      GoRoute(
        path: AppRoutes.revisionQueue,
        builder: (context, state) => const RevisionQueueScreen(),
      ),

      GoRoute(
        path: AppRoutes.reviewSession,
        builder: (context, state) => const ReviewSessionScreen(),
      ),

      GoRoute(
        path: AppRoutes.quizSession,
        builder: (context, state) => const QuizSessionScreen(),
      ),

      GoRoute(
        path: AppRoutes.learningSession,
        builder: (context, state) => const LearningSessionScreen(),
      ),

      // Trang đọc full-screen (nhảy từ Thư viện của tôi / ngoài shell).
      GoRoute(
        path: '/read/:id',
        builder: (context, state) =>
            ReadingScreen(surahId: _surahIdFrom(state)),
      ),
    ],
  );
});
