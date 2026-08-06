import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/quiz/data/quiz_providers.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/quran/domain/entities/reciter.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/domain/repositories/quran_repository.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_position_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 6 Surah giả, mỗi Surah 3 Ayah kèm bản dịch — đủ dữ liệu cho cả 4
/// loại câu hỏi (cần >=4 Surah, >=2 Ayah/Surah, có bản dịch).
class _FakeQuranRepo implements QuranRepository {
  final List<Surah> surahs = [
    for (var s = 1; s <= 6; s++)
      Surah(
        id: s,
        nameArabic: 'ع$s',
        nameLatin: 'Surah-$s',
        nameVi: 'Chương $s',
        nameEn: 'Chapter $s',
        ayahCount: 3,
        revelationPlace: RevelationPlace.mecca,
        orderRevealed: s,
      ),
  ];

  @override
  Future<List<Surah>> getAllSurahs() async => surahs;

  @override
  Future<Surah?> getSurahById(int id) async =>
      surahs.where((s) => s.id == id).firstOrNull;

  @override
  Future<List<AyahContent>> getAyahsOfSurah(int surahId) async => [
        for (var n = 1; n <= 3; n++)
          AyahContent(
            ayah: Ayah(
              id: surahId * 100 + n,
              surahId: surahId,
              ayahNumber: n,
              textUthmani: 'ayah-$surahId-$n',
            ),
            texts: {'vi_main': 'dich-$surahId-$n'},
          ),
      ];

  @override
  Future<List<TranslationSource>> getEnabledSources() async => const [];
  @override
  Future<List<Reciter>> getEnabledReciters() async => const [];
  @override
  Future<String?> getMetaValue(String key) async => null;
  @override
  Future<List<AyahSearchResult>> searchAyahs(
    String query, {
    int limit = 40,
  }) async =>
      const [];
  @override
  Future<List<AyahSearchResult>> getAyahsByIds(List<int> ids) async => const [];
}

/// Dựng ProviderContainer với [prefs] tuỳ chỉnh — dùng cho nhóm test
/// Sprint 7.1 (Assessment Scoping) cần mô phỏng nhiều kịch bản lịch sử
/// đọc khác nhau (chưa đọc gì / đọc một phần / đọc hết), khác với
/// [container] dùng chung ở trên (luôn seed "đã đọc hết", cho các
/// nhóm test khác vốn không quan tâm scoping mà cần pool đầy đủ).
Future<ProviderContainer> _makeContainer(
  UserDatabase db, {
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [
      userDatabaseProvider.overrideWithValue(db),
      quranRepositoryProvider.overrideWithValue(_FakeQuranRepo()),
      sharedPreferencesProvider.overrideWithValue(sp),
    ],
  );
}

void main() {
  late UserDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = UserDatabase(NativeDatabase.memory());
    // Sprint 7.1 — quizContentPoolProvider giờ chỉ dựng pool từ những
    // gì ReadingPositionStore ghi nhận là đã đọc tới (xem doc comment
    // tại định nghĩa provider). Các nhóm test PHÍA DƯỚI (sinh câu hỏi,
    // chấm điểm, lưu kết quả, restart) không quan tâm scoping — chúng
    // cần một pool đầy đủ để kiểm đúng phần việc của MÌNH, nên seed
    // "đã đọc hết cả 6 Surah giả" làm mặc định ở đây. Nhóm
    // `quizContentPoolProvider` bên dưới tự dựng container RIÊNG với
    // các kịch bản đọc khác nhau qua [_makeContainer], không dùng
    // container mặc định này.
    container = await _makeContainer(
      db,
      prefs: {
        for (var s = 1; s <= 6; s++) ReadingPositionStore.posKey(s): 2,
      },
    );
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  group('quizContentPoolProvider — Sprint 7.1 (Assessment Scoping)', () {
    test(
        'đã đọc hết cả 6 Surah giả -> pool gồm đủ 6 Surah, mỗi Surah '
        'đủ 3 Ayah (không còn chọn ngẫu nhiên/không điều kiện như '
        'trước Sprint 7.1)', () async {
      final pool = await container.read(quizContentPoolProvider.future);
      expect(pool.surahs, hasLength(6));
      expect(pool.surahs.every((g) => g.ayahs.length == 3), isTrue);
    });

    test('máy mới cài (chưa đọc gì) -> pool rỗng, KHÔNG có Surah nào',
        () async {
      final freshDb = UserDatabase(NativeDatabase.memory());
      final freshContainer = await _makeContainer(freshDb);
      addTearDown(() {
        freshContainer.dispose();
        freshDb.close();
      });

      final pool = await freshContainer.read(quizContentPoolProvider.future);
      expect(pool.surahs, isEmpty);
    });

    test(
        'chỉ đọc MỘT Surah, nửa chừng -> pool chỉ có đúng Surah đó, chỉ '
        'gồm các Ayah ĐÃ đọc tới, không có Ayah phía sau', () async {
      final partialDb = UserDatabase(NativeDatabase.memory());
      // posKey(2) = 0 -> đã đọc tới chỉ số 0 (0-based) = Ayah số 1
      // (1-based) của Surah 2 — chưa đọc Ayah 2/3 của Surah đó.
      final partialContainer = await _makeContainer(
        partialDb,
        prefs: {ReadingPositionStore.posKey(2): 0},
      );
      addTearDown(() {
        partialContainer.dispose();
        partialDb.close();
      });

      final pool = await partialContainer.read(quizContentPoolProvider.future);
      expect(pool.surahs, hasLength(1));
      expect(pool.surahs.single.surahId, 2);
      expect(pool.surahs.single.ayahs, hasLength(1));
      expect(pool.surahs.single.ayahs.single.ayahNumber, 1);
    });

    test(
        'đọc nhiều Surah tới độ sâu khác nhau -> pool phản ánh ĐÚNG '
        'từng Surah, Surah chưa từng mở KHÔNG xuất hiện dù nằm giữa '
        'các Surah đã đọc', () async {
      final mixedDb = UserDatabase(NativeDatabase.memory());
      final mixedContainer = await _makeContainer(
        mixedDb,
        prefs: {
          ReadingPositionStore.posKey(1): 2, // đọc hết Surah 1 (3 Ayah)
          // Surah 2: cố ý KHÔNG seed -> chưa từng mở.
          ReadingPositionStore.posKey(3): 1, // đọc tới Ayah 1-2 của Surah 3
        },
      );
      addTearDown(() {
        mixedContainer.dispose();
        mixedDb.close();
      });

      final pool = await mixedContainer.read(quizContentPoolProvider.future);
      expect(pool.surahs, hasLength(2));

      final surah1 = pool.surahs.firstWhere((g) => g.surahId == 1);
      expect(surah1.ayahs, hasLength(3));

      final surah3 = pool.surahs.firstWhere((g) => g.surahId == 3);
      expect(surah3.ayahs.map((a) => a.ayahNumber), [1, 2]);

      expect(pool.surahs.any((g) => g.surahId == 2), isFalse);
    });
  });

  group('quizSessionControllerProvider — sinh câu hỏi (question generation)',
      () {
    test('build() tự sinh đủ questionCount câu hỏi khi pool đủ dữ liệu',
        () async {
      final session =
          await container.read(quizSessionControllerProvider.future);
      expect(session.questions, hasLength(10));
      expect(session.currentIndex, 0);
      expect(session.score, 0);
      expect(session.isComplete, isFalse);
    });
  });

  group('quizSessionControllerProvider — scoring', () {
    test('answer() với đáp án đúng: score +1, chuyển câu tiếp theo ngay',
        () async {
      final session =
          await container.read(quizSessionControllerProvider.future);
      final firstQuestion = session.questions.first;

      final correct = await container
          .read(quizSessionControllerProvider.notifier)
          .answer(firstQuestion.correctOptionIndex);

      expect(correct, isTrue);
      final updated = container.read(quizSessionControllerProvider).value!;
      expect(updated.score, 1);
      expect(updated.currentIndex, 1);
    });

    test('answer() với đáp án sai: score không đổi, vẫn chuyển câu tiếp theo',
        () async {
      final session =
          await container.read(quizSessionControllerProvider.future);
      final firstQuestion = session.questions.first;
      final wrongIndex = (firstQuestion.correctOptionIndex + 1) % 4;

      final correct = await container
          .read(quizSessionControllerProvider.notifier)
          .answer(wrongIndex);

      expect(correct, isFalse);
      final updated = container.read(quizSessionControllerProvider).value!;
      expect(updated.score, 0);
      expect(updated.currentIndex, 1);
    });
  });

  group('quizSessionControllerProvider — hoàn thành phiên + persistence', () {
    test(
        'trả lời hết câu hỏi -> isComplete=true và lưu đúng kết quả qua '
        'QuizRepository', () async {
      var session = await container.read(quizSessionControllerProvider.future);
      final total = session.questions.length;
      final notifier = container.read(quizSessionControllerProvider.notifier);

      var expectedScore = 0;
      for (var i = 0; i < total; i++) {
        final q = session.questions[i];
        final correct = await notifier.answer(q.correctOptionIndex);
        if (correct) expectedScore++;
        session = container.read(quizSessionControllerProvider).value!;
      }

      expect(session.isComplete, isTrue);
      expect(session.score, expectedScore);
      // Mọi đáp án đều đúng (correctOptionIndex) -> điểm tuyệt đối.
      expect(expectedScore, total);

      final history =
          await container.read(quizRepositoryProvider).watchHistory().first;
      expect(history, hasLength(1));
      expect(history.single.quizType, 'mixed');
      expect(history.single.score, total);
      expect(history.single.total, total);
      expect(history.single.surahId, isNull);
    });

    test(
        'answer() sau khi đã hoàn thành phiên -> không làm gì, không lưu '
        'thêm lần nữa', () async {
      var session = await container.read(quizSessionControllerProvider.future);
      final total = session.questions.length;
      final notifier = container.read(quizSessionControllerProvider.notifier);

      for (var i = 0; i < total; i++) {
        session =
            container.read(quizSessionControllerProvider).value ?? session;
        final q = session.questions[i];
        await notifier.answer(q.correctOptionIndex);
        session = container.read(quizSessionControllerProvider).value!;
      }
      expect(session.isComplete, isTrue);

      final resultAfterDone = await notifier.answer(0);
      expect(resultAfterDone, isFalse);

      final history =
          await container.read(quizRepositoryProvider).watchHistory().first;
      expect(history, hasLength(1), reason: 'không lưu kết quả 2 lần');
    });
  });

  group('quizSessionControllerProvider — restart', () {
    test(
        'restart() sinh phiên mới: currentIndex/score về 0, isComplete = '
        'false', () async {
      final notifier = container.read(quizSessionControllerProvider.notifier);
      await container.read(quizSessionControllerProvider.future);

      await notifier.restart();

      final restarted = container.read(quizSessionControllerProvider).value!;
      expect(restarted.currentIndex, 0);
      expect(restarted.score, 0);
      expect(restarted.isComplete, isFalse);
      expect(restarted.questions, isNotEmpty);
    });
  });
}
