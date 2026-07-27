import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/logging/logging_providers.dart';
import '../domain/entities/lemma.dart';
import '../domain/repositories/lexicon_repository.dart';
import 'lexicon_repository_impl.dart';

/// DI cho LexiconRepository (Sprint 13 Phase 2 — Sprint 12 Phase 2 cố
/// ý chưa thêm provider nào, xem lexicon_repository_impl.dart). Trên
/// AppDatabase (nhóm A) — cùng mẫu appDatabaseProvider dùng ở mọi
/// repository nhóm A khác.
final lexiconRepositoryProvider = Provider<LexiconRepository>(
  (ref) => LexiconRepositoryImpl(
    ref.watch(appDatabaseProvider),
    ref.watch(loggerProvider),
  ),
);

/// Tìm Lemma theo từ khoá (Sprint 13 Phase 3 — Add Flashcard flow).
/// family theo chuỗi query — Riverpod tự cache theo từng chuỗi gõ,
/// autoDispose dọn khi không còn ai xem.
final lemmaSearchProvider =
    FutureProvider.autoDispose.family<List<Lemma>, String>(
  (ref, query) => ref.watch(lexiconRepositoryProvider).searchLemmas(
        query: query,
      ),
);
