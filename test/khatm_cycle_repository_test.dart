import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/features/khatm/data/khatm_cycle_repository_impl.dart';

void main() {
  late UserDatabase db;
  late KhatmCycleRepositoryImpl repo;
  var idCounter = 0;
  var fakeNow = 1000;

  setUp(() {
    db = UserDatabase(NativeDatabase.memory());
    idCounter = 0;
    fakeNow = 1000;
    repo = KhatmCycleRepositoryImpl(
      db,
      newId: () => 'cycle-${++idCounter}',
      nowMs: () => fakeNow,
    );
  });

  tearDown(() => db.close());

  test('startCycle: currentAyahId mặc định = 1, completedAt = null', () async {
    final id = await repo.startCycle(name: 'Ramadan 2026');
    final cycles = await repo.watchAllCycles().first;
    expect(cycles, hasLength(1));
    expect(cycles.single.id, id);
    expect(cycles.single.currentAyahId, 1);
    expect(cycles.single.completedAt, isNull);
    expect(cycles.single.isCompleted, isFalse);
  });

  test('watchAllCycles sắp mới bắt đầu nhất trước', () async {
    fakeNow = 1000;
    await repo.startCycle(name: 'Chu kỳ 1');
    fakeNow = 2000;
    await repo.startCycle(name: 'Chu kỳ 2');

    final cycles = await repo.watchAllCycles().first;
    expect(cycles.map((c) => c.name).toList(), ['Chu kỳ 2', 'Chu kỳ 1']);
  });

  test('watchActiveCycle: null khi chưa có chu kỳ nào', () async {
    expect(await repo.watchActiveCycle().first, isNull);
  });

  test(
      'watchActiveCycle: bỏ qua chu kỳ đã hoàn thành, lấy chu kỳ dở '
      'mới nhất', () async {
    fakeNow = 1000;
    final oldId = await repo.startCycle(name: 'Cũ');
    fakeNow = 2000;
    final activeId = await repo.startCycle(name: 'Đang đọc');

    fakeNow = 1500;
    await repo.completeCycle(oldId);

    final active = await repo.watchActiveCycle().first;
    expect(active, isNotNull);
    expect(active!.id, activeId);
  });

  test('updateProgress cập nhật currentAyahId', () async {
    final id = await repo.startCycle(name: 'Chu kỳ');
    await repo.updateProgress(id, 512);

    final cycles = await repo.watchAllCycles().first;
    expect(cycles.single.currentAyahId, 512);
  });

  test('completeCycle đặt completedAt, loại khỏi watchActiveCycle', () async {
    final id = await repo.startCycle(name: 'Chu kỳ');
    fakeNow = 5000;
    await repo.completeCycle(id);

    final cycles = await repo.watchAllCycles().first;
    expect(cycles.single.completedAt, 5000);
    expect(cycles.single.isCompleted, isTrue);
    expect(await repo.watchActiveCycle().first, isNull);
  });

  test('deleteCycle xóa mềm, loại khỏi watchAllCycles', () async {
    final id = await repo.startCycle(name: 'Chu kỳ');
    await repo.deleteCycle(id);

    expect(await repo.watchAllCycles().first, isEmpty);
  });
}
