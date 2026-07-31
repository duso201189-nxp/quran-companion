import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/user/user_database_providers.dart';
import '../../../core/logging/logging_providers.dart';
import '../domain/entities/ayah_annotation.dart';
import '../domain/repositories/user_content_repository.dart';
import '../presentation/reading/reading_controller.dart';
import 'user_content_repository_impl.dart';

final userContentRepositoryProvider = Provider<UserContentRepository>(
  (ref) => UserContentRepositoryImpl(
    ref.watch(userDatabaseProvider),
    ref.watch(loggerProvider),
  ),
);

/// Chú thích của mọi Ayah trong một Surah — cập nhật realtime.
final ayahAnnotationsProvider = StreamProvider.autoDispose
    .family<Map<int, AyahAnnotation>, int>((ref, surahId) async* {
  final reading = await ref.watch(surahReadingProvider(surahId).future);
  yield* ref.watch(userContentRepositoryProvider).watchAnnotationsForAyahs(
    [for (final a in reading.ayahs) a.ayah.id],
  );
});
