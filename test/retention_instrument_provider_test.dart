import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/features/learning/data/retention_event_source_repository_impl.dart';
import 'package:quran_companion/features/learning/data/retention_instrument_providers.dart';
import 'package:quran_companion/features/learning/domain/repositories/retention_event_source_repository.dart';
import 'package:quran_companion/features/learning/domain/retention_instrument.dart';
import 'package:quran_companion/features/learning/domain/scheduling_algorithm.dart';

/// Sprint D7.8 (DR-2026-0027, đã `accepted`) — Nhóm C: nối dây
/// provider, ghép chuỗi đầu-cuối, và CỔNG NGỦ ĐÔNG.
///
/// Công cụ này CỐ Ý chưa có nơi tiêu thụ nào trong production
/// (DR-2026-0027 §"Dormant-consumer property"). Vì thế TEST CHÍNH LÀ
/// NƠI GỌI THẬT: mọi trừu tượng mới đều phải có một nơi gọi thật, kể
/// cả khi nó cố ý chưa có nơi gọi production nào.
void main() {
  late UserDatabase db;
  var eventCounter = 0;

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [userDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<void> seedEvent({
    required String itemType,
    required int itemId,
    required int reviewedAt,
    String cardId = 'card-1',
    String grade = 'good',
    String beforeState = 'review',
    String afterState = 'review',
    int beforeRepetitions = 2,
    int afterRepetitions = 2,
    int beforeIntervalDays = 5,
    int afterIntervalDays = 5,
    int beforeDueDate = 700,
    int afterDueDate = 700,
  }) async {
    await db.into(db.reviewEvents).insert(
          ReviewEventsCompanion.insert(
            id: 'evt-${++eventCounter}',
            updatedAt: reviewedAt,
            cardId: cardId,
            itemType: itemType,
            itemId: itemId,
            reviewedAt: reviewedAt,
            grade: grade,
            algorithmId: 'sm2-v1',
            beforeState: beforeState,
            beforeRepetitions: beforeRepetitions,
            beforeIntervalDays: beforeIntervalDays,
            beforeEaseFactor: 2.5,
            beforeDueDate: beforeDueDate,
            afterState: afterState,
            afterRepetitions: afterRepetitions,
            afterIntervalDays: afterIntervalDays,
            afterEaseFactor: 2.5,
            afterDueDate: afterDueDate,
          ),
        );
  }

  setUp(() {
    eventCounter = 0;
    db = UserDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  // C1
  test(
      'D7.8 retentionEventSourceRepositoryProvider phân giải ra Impl với '
      'UserDatabase đã override', () async {
    final container = makeContainer();

    final repo = container.read(retentionEventSourceRepositoryProvider);

    expect(repo, isA<RetentionEventSourceRepositoryImpl>());
    expect(repo, isA<RetentionEventSourceRepository>());

    // Thật sự nói chuyện với database đã override, không phải một
    // database khác.
    await seedEvent(itemType: 'hifz', itemId: 10, reviewedAt: 1000);
    final events = await repo.eventsForItems(
      itemType: RetentionItemScope.hifz,
      itemIds: const {10},
    );
    expect(events, hasLength(1));
  });

  // C2
  test(
      'D7.8 đọc lại trong CÙNG một container trả về ĐÚNG một thể hiện '
      '(Provider thường, không autoDispose)', () {
    final container = makeContainer();

    final first = container.read(retentionEventSourceRepositoryProvider);
    final second = container.read(retentionEventSourceRepositoryProvider);

    expect(identical(first, second), isTrue);
  });

  // C3
  test(
      'D7.8 ĐẦU-CUỐI: gieo sự kiện ayah và hifz -> đọc qua provider -> suy '
      'dẫn -> quan sát đúng, HAI phạm vi tách biệt qua hai lần gọi', () async {
    // hifz/ordinal 10: hai sự kiện liên tục, cách nhau 8000 ms.
    await seedEvent(itemType: 'hifz', itemId: 10, reviewedAt: 1000);
    await seedEvent(itemType: 'hifz', itemId: 10, reviewedAt: 9000);
    // ayah/ordinal 10: CÙNG ordinal, hai sự kiện liên tục, cách 3000 ms.
    await seedEvent(
      itemType: 'ayah',
      itemId: 10,
      reviewedAt: 2000,
      cardId: 'card-ayah',
    );
    await seedEvent(
      itemType: 'ayah',
      itemId: 10,
      reviewedAt: 5000,
      cardId: 'card-ayah',
    );

    final container = makeContainer();
    final repo = container.read(retentionEventSourceRepositoryProvider);

    final hifzEvents = await repo.eventsForItems(
      itemType: RetentionItemScope.hifz,
      itemIds: const {10},
    );
    final ayahEvents = await repo.eventsForItems(
      itemType: RetentionItemScope.ayah,
      itemIds: const {10},
    );

    final hifz = deriveRetentionObservations(
      events: hifzEvents,
      asOfMs: 1000000,
    );
    final ayah = deriveRetentionObservations(
      events: ayahEvents,
      asOfMs: 1000000,
    );

    expect(hifz.observations, hasLength(1));
    expect(hifz.observations.single.elapsedMs, 8000);
    expect(hifz.observations.single.itemType, RetentionItemScope.hifz);
    expect(hifz.observations.single.outcomeGrade, ReviewGrade.good);

    expect(ayah.observations, hasLength(1));
    expect(ayah.observations.single.elapsedMs, 3000);
    expect(ayah.observations.single.itemType, RetentionItemScope.ayah);

    // Hai phạm vi KHÔNG trộn vào nhau: mỗi lần gọi chỉ thấy loại của
    // chính nó.
    expect(hifzEvents, hasLength(2));
    expect(ayahEvents, hasLength(2));
  });

  // C4
  test(
      'D7.8 CỔNG NGỦ ĐÔNG: không tệp nào dưới lib/ ngoài năm tệp D7.8 import '
      'bất kỳ tệp D7.8 nào', () {
    const d7_8Files = {
      'lib/features/learning/domain/entities/retention_observation.dart',
      'lib/features/learning/domain/repositories/'
          'retention_event_source_repository.dart',
      'lib/features/learning/domain/retention_instrument.dart',
      'lib/features/learning/data/retention_event_source_repository_impl.dart',
      'lib/features/learning/data/retention_instrument_providers.dart',
    };

    // Khớp theo TÊN TỆP để bắt được mọi dạng đường dẫn tương đối
    // ('../domain/...', './retention_...', 'package:quran_companion/...').
    const d7_8Basenames = [
      'retention_observation.dart',
      'retention_event_source_repository.dart',
      'retention_instrument.dart',
      'retention_event_source_repository_impl.dart',
      'retention_instrument_providers.dart',
    ];

    final libDir = Directory('lib');
    expect(
      libDir.existsSync(),
      isTrue,
      reason: 'không thấy thư mục lib/ — test chạy sai thư mục gốc?',
    );

    final offenders = <String>[];
    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File) continue;
      if (!entity.path.endsWith('.dart')) continue;

      final normalized = entity.path.replaceAll(r'\', '/');
      if (d7_8Files.contains(normalized)) continue;

      final source = entity.readAsStringSync();
      for (final import in RegExp(r"^import\s+'([^']+)';", multiLine: true)
          .allMatches(source)
          .map((m) => m.group(1)!)) {
        for (final basename in d7_8Basenames) {
          // `endsWith` trên tên tệp đầy đủ: tránh khớp nhầm
          // 'retention_instrument.dart' với
          // 'retention_instrument_providers.dart'.
          if (import.endsWith('/$basename') || import == basename) {
            offenders.add('$normalized -> $import');
          }
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: '\n\nD7.8 CỐ Ý chưa có nơi tiêu thụ production nào '
          '(DR-2026-0027 §"Dormant-consumer property").\n'
          'Các import sau đã tạo ra một nơi gọi chưa được uỷ quyền:\n\n'
          '${offenders.join('\n')}\n\n'
          'Một nơi tiêu thụ cần đường quản trị riêng của nó TRƯỚC — và '
          'nếu là nơi tiêu thụ Analytics thì phải qua cổng năm-yếu-tố '
          'của DR-2026-0025.\n',
    );
  });

  // C5
  test(
      'D7.8 tệp provider lộ ra ĐÚNG MỘT provider — không provider dẫn xuất '
      'nào được thêm lặng lẽ (quyết định A1)', () {
    final source = File(
      'lib/features/learning/data/retention_instrument_providers.dart',
    ).readAsStringSync();

    final declarations = RegExp(r'^final\s+(\w+)\s*=', multiLine: true)
        .allMatches(source)
        .map((m) => m.group(1)!)
        .toList();

    expect(declarations, ['retentionEventSourceRepositoryProvider']);

    // Quét phần MÃ, bỏ chú thích: doc comment của tệp CÓ nhắc tên
    // `deriveRetentionObservations`/`DateTime.now` chính vì đang giải
    // thích vì sao không có provider dẫn xuất nào ở đây.
    final code = source.split('\n').map((line) {
      final index = line.indexOf('//');
      return index == -1 ? line : line.substring(0, index);
    }).join('\n');

    // Không có dạng provider dẫn xuất/đọc đồng hồ nào ở tầng ghép nối.
    for (final forbidden in [
      'FutureProvider',
      'StreamProvider',
      'StateProvider',
      'NotifierProvider',
      'DateTime.now',
      'deriveRetentionObservations',
    ]) {
      expect(
        code,
        isNot(contains(forbidden)),
        reason: 'tệp provider chỉ được tiêm phụ thuộc, không được chứa '
            '$forbidden',
      );
    }
  });
}
