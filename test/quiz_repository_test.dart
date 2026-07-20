import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/features/quiz/data/quiz_repository_impl.dart';

void main() {
  late UserDatabase db;
  late QuizRepositoryImpl repo;
  var idCounter = 0;
  var fakeNow = 1000;

  setUp(() {
    db = UserDatabase(NativeDatabase.memory());
    idCounter = 0;
    fakeNow = 1000;
    repo = QuizRepositoryImpl(
      db,
      newId: () => 'quiz-${++idCounter}',
      nowMs: () => fakeNow,
    );
  });

  tearDown(() => db.close());

  test('saveResult trả về id và xuất hiện trong watchHistory', () async {
    final id = await repo.saveResult(quizType: 'mixed', score: 7, total: 10);

    final history = await repo.watchHistory().first;
    expect(history, hasLength(1));
    expect(history.single.id, id);
    expect(history.single.quizType, 'mixed');
    expect(history.single.score, 7);
    expect(history.single.total, 10);
    expect(history.single.surahId, isNull);
    expect(history.single.takenAt, 1000);
  });

  test('saveResult lưu đúng surahId khi truyền vào', () async {
    await repo.saveResult(quizType: 'mixed', surahId: 2, score: 3, total: 5);

    final history = await repo.watchHistory().first;
    expect(history.single.surahId, 2);
  });

  test('watchHistory: mới nhất trước', () async {
    fakeNow = 1000;
    await repo.saveResult(quizType: 'mixed', score: 1, total: 10);
    fakeNow = 2000;
    await repo.saveResult(quizType: 'mixed', score: 5, total: 10);
    fakeNow = 3000;
    await repo.saveResult(quizType: 'mixed', score: 10, total: 10);

    final history = await repo.watchHistory().first;
    expect(history.map((r) => r.score), [10, 5, 1]);
  });

  test('mỗi lần saveResult tạo id mới, không ghi đè lẫn nhau', () async {
    await repo.saveResult(quizType: 'mixed', score: 1, total: 10);
    await repo.saveResult(quizType: 'mixed', score: 2, total: 10);

    final history = await repo.watchHistory().first;
    expect(history, hasLength(2));
    expect(history.map((r) => r.id).toSet(), hasLength(2));
  });

  test('watchHistory phát lại khi có kết quả mới (reactive)', () async {
    final stream = repo.watchHistory();
    final future =
        stream.firstWhere((h) => h.length == 1).timeout(const Duration(seconds: 5));

    await repo.saveResult(quizType: 'mixed', score: 4, total: 10);
    final emitted = await future;
    expect(emitted.single.score, 4);
  });
}
