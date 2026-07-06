import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../domain/repositories/quran_repository.dart';
import 'quran_repository_impl.dart';

final quranRepositoryProvider = Provider<QuranRepository>(
  (ref) => QuranRepositoryImpl(ref.watch(appDatabaseProvider)),
);
