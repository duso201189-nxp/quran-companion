import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/quran/presentation/reading/reading_screen.dart';
import '../features/quran/presentation/surah_list_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/stats/presentation/stats_screen.dart';
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

  /// Tìm kiếm — màn hình push full-screen (không phải tab), giống
  /// [library]. Xem DR-2026-0002 mục 1.
  static const String search = '/search';

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

      // Trang đọc full-screen (nhảy từ Thư viện của tôi / ngoài shell).
      GoRoute(
        path: '/read/:id',
        builder: (context, state) =>
            ReadingScreen(surahId: _surahIdFrom(state)),
      ),
    ],
  );
});
