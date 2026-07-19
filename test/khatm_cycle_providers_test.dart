import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
  Stream<List<KhatmCycle>> watchAllCycles() => throw UnimplementedError();

  @override
  Stream<KhatmCycle?> watchActiveCycle() => Stream.value(_current);

  @override
  Future<void> updateProgress(String cycleId, int currentAyahId) =>
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

  test(
      'khatmProgressProvider đọc KhatmCycle.progressPercent — không tính '
      'lại công thức phần trăm', () async {
    const cycle = KhatmCycle(
      id: 'c1',
      name: 'Ramadan',
      startedAt: 1000,
      currentAyahId: 3118, // ~50% của 6236
    );
    fakeRepo.emitActive(cycle);
    // Chạm provider nguồn trước để stream có giá trị.
    await container.read(activeKhatmCycleProvider.future);

    final progress = container.read(khatmProgressProvider);
    expect(progress, cycle.progressPercent);
    expect(progress, closeTo(50.0, 0.1));
  });

  test('khatmProgressProvider = null khi không có chu kỳ đang mở', () async {
    fakeRepo.emitActive(null);
    await container.read(activeKhatmCycleProvider.future);

    expect(container.read(khatmProgressProvider), isNull);
  });
}
