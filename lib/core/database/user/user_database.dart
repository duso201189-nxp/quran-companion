import 'package:drift/drift.dart';

import 'user_tables.dart';

part 'user_database.g.dart';

/// Database dữ liệu NGƯỜI DÙNG — file riêng biệt hoàn toàn với
/// database nội dung Qur'an: cập nhật nội dung không bao giờ đụng
/// dữ liệu học (DATABASE.md §migration).
@DriftDatabase(
  tables: [
    Bookmarks,
    Highlights,
    Notes,
    Favorites,
    AyahStatuses,
    StudySessions,
    KhatmCycles,
    BookmarkCollections,
    SrsCards,
    QuizResults,
  ],
)
class UserDatabase extends _$UserDatabase {
  UserDatabase(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        // Nâng cấp schema: CHỈ ADDITIVE (thêm bảng/cột), đi từng
        // bước v(n) -> v(n+1); mỗi bước kèm test migration với dữ
        // liệu mẫu. KHÔNG BAO GIỜ drop dữ liệu người dùng.
        onUpgrade: (m, from, to) async {
          // v2: bảng favorites (Sprint 2 — hành động Yêu thích).
          if (from < 2) {
            await m.createTable(favorites);
          }
          // v3: Sprint 8 Phase 1 (DR-2026-0003) — study_sessions,
          // khatm_cycles, bookmark_collections + cột collection_id
          // trên bookmarks. Không có bảng streaks (tính trên truy
          // vấn từ study_sessions) và không có srs_cards/profiles
          // (ngoài phạm vi Sprint 8) — xem DR-2026-0003.
          if (from < 3) {
            await m.createTable(studySessions);
            await m.createTable(khatmCycles);
            await m.createTable(bookmarkCollections);
            await m.addColumn(bookmarks, bookmarks.collectionId);
          }
          // v4: Sprint 10 Phase 1 (DR-2026-0005) — srs_cards. KHÔNG
          // backfill từ ayah_statuses.status='review' lúc migration;
          // đồng bộ tự phục hồi khi đọc (xem
          // SchedulerRepository.syncWithReviewQueue).
          if (from < 4) {
            await m.createTable(srsCards);
          }
          // v5: Sprint 10 Phase 4 (DR-2026-0005 mục 5) — quiz_results.
          // Chỉ lưu kết quả, không có Question Bank (câu hỏi sinh động
          // từ nhóm A mỗi phiên).
          if (from < 5) {
            await m.createTable(quizResults);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
