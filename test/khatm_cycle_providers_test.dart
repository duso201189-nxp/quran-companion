import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/quran/quran_address.dart';
import 'package:quran_companion/features/khatm/data/khatm_cycle_providers.dart';
import 'package:quran_companion/features/khatm/domain/entities/khatm_cycle.dart';
import 'package:quran_companion/features/khatm/domain/repositories/khatm_cycle_repository.dart';

/// [watchActiveCycle] trả về [Stream.value] mới mỗi lần subscribe —
/// giống hành vi thật của Drift `.watch()` (phát trạng thái hiện tại
/// ngay khi có subscriber mới), tránh lỗi mất sự kiện của
/// StreamController.broadcast khi subscriber đến sau (autoDispose
/// chỉ subscribe khi có ai read/watch).
class _FakeKhatmCycleRepository implements KhatmCycleRepository {
  KhatmCycle? _current;

  void emitActive(KhatmCycle? cycle) => _current = cycle;

  @override
  Future<String> startCycle({required String name, String? targetDate}) =>
      throw UnimplementedError();

  @override
  Stream<List<KhatmCycle>> watchAllCycles() =>
      Stream.value(_current == null ? [] : [_current!]);

  @override
  Stream<KhatmCycle?> watchActiveCycle() => Stream.value(_current);

  @override
  Future<void> updateProgress(String cycleId, QuranAddress address) =>
      throw UnimplementedError();

  @override
  Future<void> completeCycle(String cycleId) => throw UnimplementedError();

  @override
  Future<void> deleteCycle(String cycleId) => throw UnimplementedError();
}

void main() {
  late _FakeKhatmCycleRepository fakeRepo;
  late ProviderContainer container;

  setUp(() {
    fakeRepo = _FakeKhatmCycleRepository();
    container = ProviderContainer(
      overrides: [
        khatmCycleRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('activeKhatmCycleProvider: null khi không có chu kỳ đang mở', () async {
    fakeRepo.emitActive(null);
    expect(await container.read(activeKhatmCycleProvider.future), isNull);
  });

  test('activeKhatmCycleProvider phát lại đúng chu kỳ từ repository', () async {
    const cycle = KhatmCycle(
      id: 'c1',
      name: 'Ramadan',
      startedAt: 1000,
      currentAyahId: 100,
    );
    fakeRepo.emitActive(cycle);

    final result = await container.read(activeKhatmCycleProvider.future);
    expect(result, isNotNull);
    expect(result!.name, 'Ramadan');
    expect(result.currentAyahId, 100);
  });

  test('latestKhatmCycleProvider: null khi không có chu kỳ nào', () async {
    fakeRepo.emitActive(null);
    expect(await container.read(latestKhatmCycleProvider.future), isNull);
  });

  test(
      'latestKhatmCycleProvider: trả về chu kỳ ĐÃ HOÀN THÀNH — đây chính '
      'là lý do Sprint 5.1 Finding 3 cần một provider riêng, không mở '
      'rộng activeKhatmCycleProvider (provider đó cố ý loại chu kỳ đã '
      'hoàn thành ngay ở tầng repository thật — xem doc comment tại '
      'định nghĩa của nó)', () async {
    const cycle = KhatmCycle(
      id: 'c1',
      name: 'Ramadan',
      startedAt: 1000,
      currentAyahId: 6236,
      completedAt: 2000,
    );
    fakeRepo.emitActive(cycle);

    final result = await container.read(latestKhatmCycleProvider.future);
    expect(result, isNotNull);
    expect(result!.id, 'c1');
    expect(result.isCompleted, isTrue);
  });

  test(
      'latestKhatmCycleProvider: trả về chu kỳ đang đọc dở y hệt '
      'activeKhatmCycleProvider khi chưa hoàn thành', () async {
    const cycle = KhatmCycle(
      id: 'c1',
      name: 'Ramadan',
      startedAt: 1000,
      currentAyahId: 100,
    );
    fakeRepo.emitActive(cycle);

    final result = await container.read(latestKhatmCycleProvider.future);
    expect(result, isNotNull);
    expect(result!.name, 'Ramadan');
    expect(result.currentAyahId, 100);
    expect(result.isCompleted, isFalse);
  });
}
