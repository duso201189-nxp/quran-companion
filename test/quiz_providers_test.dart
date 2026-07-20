import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/features/quiz/data/quiz_providers.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/quran/domain/entities/reciter.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/domain/repositories/quran_repository.dart';

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
  Future<List<AyahSearchResult>> getAyahsByIds(List<int> ids) async =>
      const [];
}

void main() {
  late UserDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = UserDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        userDatabaseProvider.overrideWithValue(db),
        quranRepositoryProvider.overrideWithValue(_FakeQuranRepo()),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  group('quizContentPoolProvider', () {
    test('nạp đủ 6 Surah từ QuranRepository (nhóm A), không nhân bản '
        'lưu trữ', () async {
      final pool = await container.read(quizContentPoolProvider.future);
      expect(pool.surahs, hasLength(6));
      expect(pool.surahs.every((g) => g.ayahs.length == 3), isTrue);
    });
  });

  group('quizSessionControllerProvider — sinh câu hỏi (question generation)',
      () {
    test('build() tự sinh đủ questionCount câu hỏi khi pool đủ dữ liệu',
        () async {
      final session = await container.read(quizSessionControllerProvider.future);
      expect(session.questions, hasLength(10));
      expect(session.currentIndex, 0);
      expect(session.score, 0);
      expect(session.isComplete, isFalse);
    });
  });

  group('quizSessionControllerProvider — scoring', () {
    test('answer() với đáp án đúng: score +1, chuyển câu tiếp theo ngay',
        () async {
      final session = await container.read(quizSessionControllerProvider.future);
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
      final session = await container.read(quizSessionControllerProvider.future);
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
    test('trả lời hết câu hỏi -> isComplete=true và lưu đúng kết quả qua '
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

    test('answer() sau khi đã hoàn thành phiên -> không làm gì, không lưu '
        'thêm lần nữa', () async {
      var session = await container.read(quizSessionControllerProvider.future);
      final total = session.questions.length;
      final notifier = container.read(quizSessionControllerProvider.notifier);

      for (var i = 0; i < total; i++) {
        session = container.read(quizSessionControllerProvider).value ?? session;
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
    test('restart() sinh phiên mới: currentIndex/score về 0, isComplete = '
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
