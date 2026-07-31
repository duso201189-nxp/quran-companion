import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/database/app_database.dart';
import 'package:quran_companion/core/database/database_providers.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/features/flashcards/data/flashcard_providers.dart';
import 'package:quran_companion/features/lexicon/data/lexicon_providers.dart';

/// Sprint S2, D9 — flashcardRepositoryProvider/lexiconRepositoryProvider
/// (lớp DI thật sự lắp ráp *RepositoryImpl từ Provider khác, khác với
/// *RepositoryImpl chính nó — đã có test riêng qua constructor trực
/// tiếp) trước đó chưa từng được `container.read()` trong bất kỳ test
/// nào — chỉ có test gọi thẳng constructor Impl, bỏ qua hoàn toàn lớp
/// lắp dây Provider. Test này xác nhận việc lắp dây đó THẬT SỰ hoạt
/// động: đọc provider ra một repository dùng được, gọi 1 thao tác đọc
/// thật trên DB trong bộ nhớ, không lỗi.
void main() {
  test(
      'flashcardRepositoryProvider lắp đúng FlashcardRepositoryImpl trên '
      'UserDatabase thật (in-memory) — watchAllFlashcards() phát danh '
      'sách rỗng, không lỗi', () async {
    final db = UserDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [userDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final repo = container.read(flashcardRepositoryProvider);
    final flashcards = await repo.watchAllFlashcards().first;

    expect(flashcards, isEmpty);
  });

  test(
      'lexiconRepositoryProvider lắp đúng LexiconRepositoryImpl trên '
      'AppDatabase thật (in-memory) — getLemmaById() trả về null cho id '
      'không tồn tại, không lỗi', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final repo = container.read(lexiconRepositoryProvider);
    final lemma = await repo.getLemmaById(999999);

    expect(lemma, isNull);
  });
}
