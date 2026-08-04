import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/logging/console_logger.dart';
import 'package:quran_companion/core/quran/ayah_ordinal.dart';
import 'package:quran_companion/core/quran/quran_address.dart';
import 'package:quran_companion/features/khatm/data/khatm_cycle_repository_impl.dart';
import 'package:quran_companion/features/khatm/domain/entities/khatm_cycle.dart';

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
      const ConsoleLogger(),
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

  test(
      'updateProgress: biên nhận QuranAddress, lưu xuống ordinal '
      'giống hệt trước Sprint SF3', () async {
    final id = await repo.startCycle(name: 'Chu kỳ');
    // 512 là ordinal đã dùng ở test này trước SF3 — An-Nisa 4:19 (tra
    // bằng chính phép quy đổi để test không tự tay đoán số).
    final address = AyahOrdinal.tryFromOrdinal(512)!;
    expect(address, QuranAddress.ayah(4, 19));

    await repo.updateProgress(id, address);

    final cycles = await repo.watchAllCycles().first;
    // Biểu diễn trên đĩa KHÔNG đổi: vẫn là int ordinal 512.
    expect(cycles.single.currentAyahId, 512);
    // Đọc lại qua biên cũng round-trip đúng.
    expect(cycles.single.currentAddress, address);
  });

  test(
      'updateProgress: mức Surah là no-op — KHÔNG ném lỗi, KHÔNG ghi '
      'đè bằng Ayah đầu của Surah', () async {
    final id = await repo.startCycle(name: 'Chu kỳ');

    await expectLater(
      repo.updateProgress(id, QuranAddress.surah(2)),
      completes,
    );

    final cycles = await repo.watchAllCycles().first;
    // Vẫn là giá trị mặc định lúc startCycle — không bị đổi ngữ nghĩa
    // lặng lẽ thành "2:1".
    expect(cycles.single.currentAyahId, 1);
  });

  test(
      'updateProgress: địa chỉ đúng dạng nhưng không tồn tại là '
      'no-op', () async {
    final id = await repo.startCycle(name: 'Chu kỳ');

    // Al-Baqarah chỉ có 286 Ayah.
    await expectLater(
      repo.updateProgress(id, QuranAddress.ayah(2, 999)),
      completes,
    );

    final cycles = await repo.watchAllCycles().first;
    expect(cycles.single.currentAyahId, 1);
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

  group('KhatmCycle.currentAddress (đơn vị, không cần database)', () {
    test('quy đổi đúng currentAyahId hợp lệ', () {
      const cycle = KhatmCycle(
        id: 'c',
        name: 'x',
        startedAt: 0,
        currentAyahId: 1,
      );
      expect(cycle.currentAddress, QuranAddress.ayah(1, 1));
    });

    test(
        'null khi currentAyahId ngoài miền — repository không bao giờ '
        'tạo ra giá trị này, nhưng getter vẫn phải an toàn nếu có', () {
      const corrupted = KhatmCycle(
        id: 'c',
        name: 'x',
        startedAt: 0,
        currentAyahId: 0,
      );
      expect(corrupted.currentAddress, isNull);
    });
  });

  /// Sprint SF-Khatm — tiến độ Khatm là hành trình TUẦN TỰ.
  ///
  /// Đây là luật sản phẩm, không phải chi tiết của trang đọc: nó sống
  /// trên chính thực thể, và test được mà không cần widget lẫn database.
  group('KhatmCycle.isExtendedBy (đơn vị, luật tuần tự)', () {
    /// Chu kỳ có biên đặt đúng tại [address].
    KhatmCycle cycleAt(QuranAddress address) => KhatmCycle(
          id: 'c',
          name: 'x',
          startedAt: 0,
          currentAyahId: AyahOrdinal.tryToOrdinal(address)!,
        );

    test('đọc tiếp trong cùng Surah -> nối tiếp', () {
      expect(
        cycleAt(QuranAddress.ayah(2, 50)).isExtendedBy(
          from: QuranAddress.ayah(2, 50),
          to: QuranAddress.ayah(2, 80),
        ),
        isTrue,
      );
    });

    test('vượt ranh giới Surah (biên 1:7 -> phiên bắt đầu 2:1) là ĐỌC TIẾP',
        () {
      // Chỗ này chính là lý do có `+ 1`: hết Al-Fatihah rồi sang
      // Al-Baqarah là hành trình liền mạch, không phải nhảy cóc.
      expect(
        cycleAt(QuranAddress.ayah(1, 7)).isExtendedBy(
          from: QuranAddress.ayah(2, 1),
          to: QuranAddress.ayah(2, 5),
        ),
        isTrue,
      );
    });

    test('đọc lại một đoạn đã qua rồi đi tiếp -> vẫn nối tiếp', () {
      expect(
        cycleAt(QuranAddress.ayah(2, 50)).isExtendedBy(
          from: QuranAddress.ayah(2, 40),
          to: QuranAddress.ayah(2, 80),
        ),
        isTrue,
      );
    });

    test('NHẢY sang Surah khác -> KHÔNG tính (đây là luật của B2)', () {
      // Đang ở 2:50 mà đọc Al-Kahf: đó là đọc thật, có vào
      // study_sessions, nhưng không phải hành trình Khatm này. Mô hình
      // B1 (đơn điệu) sẽ nhảy tiến độ lên ~34% ở đây.
      expect(
        cycleAt(QuranAddress.ayah(2, 50)).isExtendedBy(
          from: QuranAddress.ayah(18, 1),
          to: QuranAddress.ayah(18, 110),
        ),
        isFalse,
      );
    });

    test('bỏ cách một quãng NGAY TRONG cùng Surah -> KHÔNG tính', () {
      // 2:51..2:99 chưa đọc thì biên không được nhảy tới 2:120.
      expect(
        cycleAt(QuranAddress.ayah(2, 50)).isExtendedBy(
          from: QuranAddress.ayah(2, 100),
          to: QuranAddress.ayah(2, 120),
        ),
        isFalse,
      );
    });

    test('đọc lại phần đã qua -> KHÔNG kéo tiến độ TỤT lại', () {
      expect(
        cycleAt(QuranAddress.ayah(2, 50)).isExtendedBy(
          from: QuranAddress.ayah(1, 1),
          to: QuranAddress.ayah(1, 7),
        ),
        isFalse,
      );
    });

    test('phiên đứng yên đúng tại biên -> KHÔNG có gì để đẩy xa', () {
      expect(
        cycleAt(QuranAddress.ayah(2, 50)).isExtendedBy(
          from: QuranAddress.ayah(2, 50),
          to: QuranAddress.ayah(2, 50),
        ),
        isFalse,
      );
    });

    test('địa chỉ không quy đổi được -> false, KHÔNG ném', () {
      final cycle = cycleAt(QuranAddress.ayah(2, 50));
      // Mức Surah và Ayah không tồn tại: cả hai đều không có ordinal.
      expect(
        () => cycle.isExtendedBy(
          from: QuranAddress.surah(2),
          to: QuranAddress.ayah(2, 80),
        ),
        returnsNormally,
      );
      expect(
        cycle.isExtendedBy(
          from: QuranAddress.surah(2),
          to: QuranAddress.ayah(2, 80),
        ),
        isFalse,
      );
      expect(
        cycle.isExtendedBy(
          from: QuranAddress.ayah(2, 60),
          to: QuranAddress.ayah(2, 999),
        ),
        isFalse,
      );
    });
  });
}
