import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/learning/domain/entities/srs_card.dart';
import 'package:quran_companion/features/learning/domain/repositories/retention_event_source_repository.dart';
import 'package:quran_companion/features/learning/domain/retention_instrument.dart';
import 'package:quran_companion/features/learning/domain/scheduling_algorithm.dart';

/// Sprint D7.8 (DR-2026-0027, đã `accepted`) — Nhóm B: hàm thuần suy
/// dẫn quan sát ghi nhớ. Không database, không Riverpod: chỉ fixture
/// và `asOfMs` tường minh.
void main() {
  /// Một sự kiện nguồn với mặc định LIÊN TỤC ĐƯỢC: `after_*` của mặc
  /// định khớp `before_*` của mặc định, nên hai lần gọi liên tiếp chỉ
  /// đổi `reviewedAtMs` sẽ tự động liên tục — mỗi test chỉ phải nêu
  /// đúng cái nó muốn phá vỡ.
  RetentionSourceEvent event({
    required int reviewedAtMs,
    RetentionItemScope itemType = RetentionItemScope.hifz,
    int itemId = 10,
    String cardId = 'card-1',
    String gradeRaw = 'good',
    String algorithmId = 'sm2-v1',
    String beforeStateRaw = 'review',
    String afterStateRaw = 'review',
    int beforeRepetitions = 2,
    int afterRepetitions = 2,
    int beforeIntervalDays = 5,
    int afterIntervalDays = 5,
    int beforeDueDateMs = 700,
    int afterDueDateMs = 700,
  }) {
    return RetentionSourceEvent(
      itemType: itemType,
      itemId: itemId,
      cardId: cardId,
      reviewedAtMs: reviewedAtMs,
      gradeRaw: gradeRaw,
      algorithmId: algorithmId,
      beforeStateRaw: beforeStateRaw,
      afterStateRaw: afterStateRaw,
      beforeRepetitions: beforeRepetitions,
      afterRepetitions: afterRepetitions,
      beforeIntervalDays: beforeIntervalDays,
      afterIntervalDays: afterIntervalDays,
      beforeDueDateMs: beforeDueDateMs,
      afterDueDateMs: afterDueDateMs,
    );
  }

  // Mốc quan sát xa hơn MỌI fixture trong tệp này, để các test không
  // nói về `asOfMs` không vô tình chạm vào luật loại-sự-kiện-tương-lai.
  const farFuture = 9999999999999;

  // B1
  test('D7.8 đầu vào RỖNG -> không quan sát, không điểm gãy, bộ đếm 0', () {
    final d = deriveRetentionObservations(
      events: const [],
      asOfMs: farFuture,
    );

    expect(d.observations, isEmpty);
    expect(d.discontinuities, isEmpty);
    expect(d.eventsConsidered, 0);
    expect(d.eventsExcludedAsFuture, 0);
    expect(d.eventsExcludedAsIneligible, 0);
  });

  // B2
  test(
      'D7.8 MỘT sự kiện -> không quan sát nào; eventsConsidered == 1; không '
      'bịa ra gì cả', () {
    final d = deriveRetentionObservations(
      events: [event(reviewedAtMs: 1000)],
      asOfMs: farFuture,
    );

    expect(d.observations, isEmpty);
    expect(d.discontinuities, isEmpty);
    expect(d.eventsConsidered, 1);
    expect(d.eventsExcludedAsFuture, 0);
    expect(d.eventsExcludedAsIneligible, 0);
  });

  // B3
  test('D7.8 hai sự kiện LIÊN TỤC -> đúng một quan sát, elapsedMs = hiệu', () {
    final d = deriveRetentionObservations(
      events: [event(reviewedAtMs: 1000), event(reviewedAtMs: 9000)],
      asOfMs: farFuture,
    );

    expect(d.observations, hasLength(1));
    expect(d.discontinuities, isEmpty);
    final o = d.observations.single;
    expect(o.predecessorReviewedAtMs, 1000);
    expect(o.successorReviewedAtMs, 9000);
    expect(o.elapsedMs, 8000);
    expect(o.itemId, 10);
    expect(o.cardId, 'card-1');
  });

  // B4
  test(
      'D7.8 bốn sự kiện liên tục -> đúng BA quan sát, nối chuỗi theo thời gian',
      () {
    final d = deriveRetentionObservations(
      events: [
        event(reviewedAtMs: 1000),
        event(reviewedAtMs: 2000),
        event(reviewedAtMs: 4000),
        event(reviewedAtMs: 8000),
      ],
      asOfMs: farFuture,
    );

    expect(d.discontinuities, isEmpty);
    expect(
      [
        for (final o in d.observations)
          (o.predecessorReviewedAtMs, o.elapsedMs),
      ],
      [(1000, 1000), (2000, 2000), (4000, 4000)],
    );
  });

  // B5
  test('D7.8 item_id KHÁC nhau KHÔNG BAO GIỜ ghép cặp, dù kề nhau về thời gian',
      () {
    final d = deriveRetentionObservations(
      events: [
        event(reviewedAtMs: 1000, itemId: 10),
        event(reviewedAtMs: 1001, itemId: 11),
      ],
      asOfMs: farFuture,
    );

    expect(d.observations, isEmpty);
    expect(d.discontinuities, isEmpty);
    expect(d.eventsConsidered, 2);
  });

  // B6
  test(
      'D7.8 CÙNG ordinal nhưng khác itemType (ayah vs hifz) KHÔNG BAO GIỜ '
      'ghép cặp — hai lịch trình độc lập', () {
    final d = deriveRetentionObservations(
      events: [
        event(
          reviewedAtMs: 1000,
          itemType: RetentionItemScope.ayah,
          itemId: 10,
        ),
        event(
          reviewedAtMs: 2000,
          itemType: RetentionItemScope.hifz,
          itemId: 10,
        ),
      ],
      asOfMs: farFuture,
    );

    expect(d.observations, isEmpty);
    expect(d.discontinuities, isEmpty);
  });

  // B7
  test('D7.8 card_id LỆCH -> điểm gãy, không quan sát', () {
    final d = deriveRetentionObservations(
      events: [
        event(reviewedAtMs: 1000, cardId: 'card-1'),
        event(reviewedAtMs: 2000, cardId: 'card-2'),
      ],
      asOfMs: farFuture,
    );

    expect(d.observations, isEmpty);
    expect(d.discontinuities, hasLength(1));
    final gap = d.discontinuities.single;
    expect(gap.predecessorCardId, 'card-1');
    expect(gap.successorCardId, 'card-2');
  });

  // B8
  test('D7.8 after_state != before_state -> điểm gãy, không quan sát', () {
    final d = deriveRetentionObservations(
      events: [
        event(reviewedAtMs: 1000, afterStateRaw: 'review'),
        event(reviewedAtMs: 2000, beforeStateRaw: 'learning'),
      ],
      asOfMs: farFuture,
    );

    expect(d.observations, isEmpty);
    expect(d.discontinuities, hasLength(1));
  });

  // B9
  test('D7.8 after_repetitions != before_repetitions -> điểm gãy', () {
    final d = deriveRetentionObservations(
      events: [
        event(reviewedAtMs: 1000, afterRepetitions: 2),
        event(reviewedAtMs: 2000, beforeRepetitions: 7),
      ],
      asOfMs: farFuture,
    );

    expect(d.observations, isEmpty);
    expect(d.discontinuities, hasLength(1));
  });

  // B10
  test('D7.8 after_interval_days != before_interval_days -> điểm gãy', () {
    final d = deriveRetentionObservations(
      events: [
        event(reviewedAtMs: 1000, afterIntervalDays: 5),
        event(reviewedAtMs: 2000, beforeIntervalDays: 30),
      ],
      asOfMs: farFuture,
    );

    expect(d.observations, isEmpty);
    expect(d.discontinuities, hasLength(1));
  });

  // B11
  test('D7.8 after_due_date != before_due_date -> điểm gãy', () {
    final d = deriveRetentionObservations(
      events: [
        event(reviewedAtMs: 1000, afterDueDateMs: 700),
        event(reviewedAtMs: 2000, beforeDueDateMs: 12345),
      ],
      asOfMs: farFuture,
    );

    expect(d.observations, isEmpty);
    expect(d.discontinuities, hasLength(1));
  });

  // B12
  test(
      'D7.8 HỒI SINH-VÀ-RESET đầy đủ (thẻ đã lên review, sự kiện sau bắt đầu '
      'lại từ new/0/0) -> một điểm gãy, KHÔNG quan sát, dù CÙNG card_id', () {
    final d = deriveRetentionObservations(
      events: [
        // Thẻ đã tốt nghiệp: review, 4 lần lặp, chu kỳ 21 ngày.
        event(
          reviewedAtMs: 1000,
          afterStateRaw: 'review',
          afterRepetitions: 4,
          afterIntervalDays: 21,
          afterDueDateMs: 50000,
        ),
        // syncItemsForType hồi sinh ĐÚNG srs_cards.id cũ và reset về
        // initialState(): state='new', repetitions=0, intervalDays=0,
        // dueDate=now.
        event(
          reviewedAtMs: 90000,
          beforeStateRaw: 'new',
          beforeRepetitions: 0,
          beforeIntervalDays: 0,
          beforeDueDateMs: 90000,
        ),
      ],
      asOfMs: farFuture,
    );

    expect(d.observations, isEmpty);
    expect(d.discontinuities, hasLength(1));
    final gap = d.discontinuities.single;
    // CÙNG card_id ở hai bên: chung card_id KHÔNG phải là liên tục.
    expect(gap.predecessorCardId, 'card-1');
    expect(gap.successorCardId, 'card-1');
    // Điểm gãy mang đủ hai mốc để người đọc chẩn đoán định vị được.
    expect(gap.predecessorReviewedAtMs, 1000);
    expect(gap.successorReviewedAtMs, 90000);
    expect(gap.itemType, RetentionItemScope.hifz);
    expect(gap.itemId, 10);
  });

  // B13
  test(
      'D7.8 liên tục -> gãy -> liên tục: chuỗi nối lại, một điểm gãy và một '
      'quan sát ở MỖI bên', () {
    final d = deriveRetentionObservations(
      events: [
        event(reviewedAtMs: 1000),
        event(reviewedAtMs: 2000),
        // Gãy: thẻ bị thay định danh lập lịch.
        event(reviewedAtMs: 3000, beforeStateRaw: 'new'),
        event(reviewedAtMs: 4000),
      ],
      asOfMs: farFuture,
    );

    expect(d.discontinuities, hasLength(1));
    expect(d.discontinuities.single.predecessorReviewedAtMs, 2000);
    expect(
      [
        for (final o in d.observations)
          (o.predecessorReviewedAtMs, o.successorReviewedAtMs),
      ],
      [(1000, 2000), (3000, 4000)],
    );
  });

  // B14
  test(
      'D7.8 sự kiện có reviewedAtMs > asOfMs bị LOẠI HẲN và được đếm; phần '
      'còn lại vẫn ghép cặp đúng', () {
    final d = deriveRetentionObservations(
      events: [
        event(reviewedAtMs: 1000),
        event(reviewedAtMs: 2000),
        event(reviewedAtMs: 3000),
        event(reviewedAtMs: 4000),
      ],
      asOfMs: 2500,
    );

    expect(d.eventsConsidered, 4);
    expect(d.eventsExcludedAsFuture, 2);
    expect(d.eventsExcludedAsIneligible, 0);
    expect(d.observations, hasLength(1));
    expect(d.observations.single.successorReviewedAtMs, 2000);
  });

  // B15
  test('D7.8 sự kiện ĐÚNG BẰNG asOfMs được TÍNH VÀO (biên bao gồm)', () {
    final d = deriveRetentionObservations(
      events: [event(reviewedAtMs: 1000), event(reviewedAtMs: 2000)],
      asOfMs: 2000,
    );

    expect(d.eventsExcludedAsFuture, 0);
    expect(d.observations, hasLength(1));
    expect(d.observations.single.successorReviewedAtMs, 2000);
  });

  // B16
  test(
      'D7.8 TẤT ĐỊNH: cùng fixture với hai asOfMs khác nhau cho kết quả khác '
      'nhau nhưng đều đúng; cùng asOfMs cho kết quả y hệt qua nhiều lần gọi',
      () {
    final events = [
      event(reviewedAtMs: 1000),
      event(reviewedAtMs: 2000),
      event(reviewedAtMs: 3000),
    ];

    final early = deriveRetentionObservations(events: events, asOfMs: 2000);
    final later = deriveRetentionObservations(events: events, asOfMs: 3000);

    expect(early.observations, hasLength(1));
    expect(later.observations, hasLength(2));

    final again = deriveRetentionObservations(events: events, asOfMs: 2000);
    expect(
      [
        for (final o in again.observations)
          (o.predecessorReviewedAtMs, o.elapsedMs),
      ],
      [
        for (final o in early.observations)
          (o.predecessorReviewedAtMs, o.elapsedMs),
      ],
    );
    expect(again.eventsExcludedAsFuture, early.eventsExcludedAsFuture);
  });

  // B17
  test(
      'D7.8 hai sự kiện TRÙNG mili giây mà vẫn liên tục -> một quan sát với '
      'elapsedMs == 0, KHÔNG bị lọc bỏ', () {
    final d = deriveRetentionObservations(
      events: [event(reviewedAtMs: 5000), event(reviewedAtMs: 5000)],
      asOfMs: farFuture,
    );

    expect(d.observations, hasLength(1));
    expect(d.observations.single.elapsedMs, 0);
  });

  // B18
  test(
      'D7.8 thứ tự đầu vào được GIỮ NGUYÊN cho các mốc trùng nhau (sắp xếp '
      'ỔN ĐỊNH)', () {
    // Ba sự kiện cùng mốc, phân biệt bằng grade — nếu sắp xếp không ổn
    // định, thứ tự grade sẽ đổi.
    final d = deriveRetentionObservations(
      events: [
        event(reviewedAtMs: 5000, gradeRaw: 'again'),
        event(reviewedAtMs: 5000, gradeRaw: 'hard'),
        event(reviewedAtMs: 5000, gradeRaw: 'easy'),
      ],
      asOfMs: farFuture,
    );

    // Hai cặp kề nhau -> hai quan sát, grade kết quả theo đúng thứ tự
    // đầu vào của sự kiện SAU.
    expect(
      [for (final o in d.observations) o.outcomeGrade],
      [ReviewGrade.hard, ReviewGrade.easy],
    );
  });

  // B19
  test(
      'D7.8 ba mục đan xen trong CÙNG một danh sách -> gom nhóm đúng, không '
      'ghép chéo mục, thứ tự nhóm tất định', () {
    final d = deriveRetentionObservations(
      events: [
        event(reviewedAtMs: 1000, itemId: 20),
        event(reviewedAtMs: 1100, itemId: 10),
        event(
          reviewedAtMs: 1200,
          itemType: RetentionItemScope.ayah,
          itemId: 15,
        ),
        event(reviewedAtMs: 2000, itemId: 10),
        event(reviewedAtMs: 2100, itemId: 20),
        event(
          reviewedAtMs: 2200,
          itemType: RetentionItemScope.ayah,
          itemId: 15,
        ),
      ],
      asOfMs: farFuture,
    );

    expect(d.observations, hasLength(3));
    // Thứ tự nhóm: itemType theo chỉ số enum (ayah=0 trước hifz=1),
    // rồi itemId tăng dần.
    expect(
      [for (final o in d.observations) (o.itemType, o.itemId)],
      [
        (RetentionItemScope.ayah, 15),
        (RetentionItemScope.hifz, 10),
        (RetentionItemScope.hifz, 20),
      ],
    );
    // Không quan sát nào vắt qua hai mục khác nhau.
    for (final o in d.observations) {
      expect(o.successorReviewedAtMs - o.predecessorReviewedAtMs, o.elapsedMs);
    }
  });

  // B20
  test(
      'D7.8 outcomeGrade là grade THÔ của sự kiện SAU — again giữ nguyên là '
      'again, không thành boolean/trọng số/phần trăm', () {
    final d = deriveRetentionObservations(
      events: [
        event(reviewedAtMs: 1000, gradeRaw: 'easy'),
        event(reviewedAtMs: 2000, gradeRaw: 'again'),
      ],
      asOfMs: farFuture,
    );

    final o = d.observations.single;
    expect(o.outcomeGrade, ReviewGrade.again);
    expect(o.outcomeGrade, isA<ReviewGrade>());
  });

  // B21
  test(
      'D7.8 algorithm_id của HAI đầu giữ độc lập — quan sát vắt qua lần đổi '
      'thuật toán vẫn phát ra với cả hai id nguyên vẹn', () {
    final d = deriveRetentionObservations(
      events: [
        event(reviewedAtMs: 1000, algorithmId: 'sm2-v1'),
        event(reviewedAtMs: 2000, algorithmId: 'hifz-sm2-capped-v1'),
      ],
      asOfMs: farFuture,
    );

    final o = d.observations.single;
    expect(o.predecessorAlgorithmId, 'sm2-v1');
    expect(o.successorAlgorithmId, 'hifz-sm2-capped-v1');
  });

  // B22
  test(
      'D7.8 KHÔNG đọc đồng hồ ngầm: mã nguồn không chứa DateTime.now và chỉ '
      'import domain thuần; cùng fixture luôn cho cùng kết quả', () {
    final source = _readSource(
      'lib/features/learning/domain/retention_instrument.dart',
    );
    // Quét phần MÃ, bỏ chú thích: doc comment của tệp CÓ nhắc tên
    // `DateTime.now`/`dart:io` chính vì đang giải thích rằng chúng
    // không được dùng. Bất biến nói về mã, nên phép kiểm cũng vậy.
    final code = _codeOnly(source);

    expect(code, isNot(contains('DateTime.now')));
    expect(code, isNot(contains('package:flutter')));
    expect(code, isNot(contains('package:drift')));
    expect(code, isNot(contains('package:flutter_riverpod')));
    expect(code, isNot(contains('dart:io')));

    final imports = RegExp(r"^import\s+'([^']+)';", multiLine: true)
        .allMatches(source)
        .map((m) => m.group(1)!)
        .toList();
    expect(
      imports.toSet(),
      {
        'entities/retention_observation.dart',
        'entities/srs_card.dart',
        'repositories/retention_event_source_repository.dart',
        'scheduling_algorithm.dart',
      },
      reason: 'hàm thuần chỉ được biết domain của chính nó',
    );

    // Cùng đầu vào, cùng asOfMs -> cùng đầu ra, bất kể chạy lúc nào.
    final events = [event(reviewedAtMs: 1000), event(reviewedAtMs: 2000)];
    final a = deriveRetentionObservations(events: events, asOfMs: 5000);
    final b = deriveRetentionObservations(events: events, asOfMs: 5000);
    expect(a.observations.single.elapsedMs, b.observations.single.elapsedMs);
    expect(a.observations.single.elapsedMs, 1000);
  });

  // B23
  test(
      'D7.8 KHÔNG trường nào là điểm số/tỉ lệ/phần trăm/mức độ thuộc/chuỗi '
      'ngày/thứ hạng/chỉ tiêu trong thực thể kết quả', () {
    final source = _readSource(
      'lib/features/learning/domain/entities/retention_observation.dart',
    );
    final fields = RegExp(r'^\s{2}final\s+[\w<>, ?]+\s+(\w+);', multiLine: true)
        .allMatches(source)
        .map((m) => m.group(1)!)
        .toList();

    expect(fields, isNotEmpty);
    const forbidden = [
      'score',
      'rate',
      'percent',
      'percentage',
      'mastery',
      'streak',
      'rank',
      'ranking',
      'target',
      'accuracy',
      'retained',
      'level',
      'points',
    ];
    for (final field in fields) {
      final lower = field.toLowerCase();
      for (final word in forbidden) {
        expect(
          lower.contains(word),
          isFalse,
          reason: 'trường "$field" mang ngữ nghĩa "$word" — bị cấm',
        );
      }
    }

    // Ba bộ đếm và đúng hai danh sách; không có trường tổng hợp nào.
    expect(fields, contains('eventsConsidered'));
    expect(fields, contains('eventsExcludedAsFuture'));
    expect(fields, contains('eventsExcludedAsIneligible'));
    expect(fields, contains('observations'));
    expect(fields, contains('discontinuities'));
  });

  // B24
  test(
      'D7.8 gradeRaw lạ -> sự kiện KHÔNG hợp lệ, được đếm, KHÔNG ném lỗi, và '
      'mục khác vẫn suy dẫn bình thường', () {
    final d = deriveRetentionObservations(
      events: [
        event(reviewedAtMs: 1000, itemId: 10, gradeRaw: 'khong-ton-tai'),
        event(reviewedAtMs: 2000, itemId: 10),
        event(reviewedAtMs: 1000, itemId: 11),
        event(reviewedAtMs: 2000, itemId: 11),
      ],
      asOfMs: farFuture,
    );

    expect(d.eventsConsidered, 4);
    expect(d.eventsExcludedAsIneligible, 1);
    // Mục 10 chỉ còn một sự kiện hợp lệ -> không quan sát; mục 11 đủ
    // hai -> một quan sát.
    expect(d.observations, hasLength(1));
    expect(d.observations.single.itemId, 11);
  });

  // B25
  test(
      'D7.8 trạng thái lạ -> KHÔNG hợp lệ, được đếm, và ĐẶC BIỆT KHÔNG bị ép '
      'thành newCard', () {
    final d = deriveRetentionObservations(
      events: [
        // Nếu bị ép về 'new', sự kiện này sẽ trông như liên tục với
        // một tiền nhiệm có after_state='new'.
        event(reviewedAtMs: 2000, beforeStateRaw: 'trang-thai-la'),
        event(
          reviewedAtMs: 1000,
          afterStateRaw: 'new',
          afterRepetitions: 2,
          afterIntervalDays: 5,
          afterDueDateMs: 700,
        ),
      ],
      asOfMs: farFuture,
    );

    expect(d.eventsExcludedAsIneligible, 1);
    expect(d.observations, isEmpty);
    expect(d.discontinuities, isEmpty);

    // Cùng vậy với after_state lạ.
    final d2 = deriveRetentionObservations(
      events: [event(reviewedAtMs: 1000, afterStateRaw: 'trang-thai-la')],
      asOfMs: farFuture,
    );
    expect(d2.eventsExcludedAsIneligible, 1);
  });

  // B26
  test(
      'D7.8 kết quả rỗng TRUNG THỰC: mục chỉ toàn cặp bị loại cho danh sách '
      'điểm gãy KHÁC RỖNG — phân biệt được với mục không có sự kiện nào', () {
    final rejected = deriveRetentionObservations(
      events: [
        event(reviewedAtMs: 1000, cardId: 'card-1'),
        event(reviewedAtMs: 2000, cardId: 'card-2'),
      ],
      asOfMs: farFuture,
    );
    final absent = deriveRetentionObservations(
      events: const [],
      asOfMs: farFuture,
    );

    expect(rejected.observations, isEmpty);
    expect(absent.observations, isEmpty);

    // Hai kết quả rỗng KHÁC NHAU về bản chất, và bộ đếm nói ra điều đó.
    expect(rejected.discontinuities, hasLength(1));
    expect(rejected.eventsConsidered, 2);
    expect(absent.discontinuities, isEmpty);
    expect(absent.eventsConsidered, 0);
  });

  // B27
  test(
      'D7.8 khoảng đã trôi qua KHÔNG suy từ lịch: chu kỳ hẹn 10 ngày nhưng '
      'khoảng thật 60 ngày -> elapsedMs bằng 60 ngày', () {
    const dayMs = 86400000;
    const start = 1000000;
    final d = deriveRetentionObservations(
      events: [
        event(
          reviewedAtMs: start,
          afterIntervalDays: 10,
          afterDueDateMs: start + 10 * dayMs,
        ),
        event(
          reviewedAtMs: start + 60 * dayMs,
          beforeIntervalDays: 10,
          beforeDueDateMs: start + 10 * dayMs,
        ),
      ],
      asOfMs: farFuture,
    );

    final o = d.observations.single;
    expect(o.elapsedMs, 60 * dayMs);
    // Lịch đã hẹn vẫn được mang theo như XUẤT XỨ, không phải phép đo.
    expect(o.scheduledIntervalDays, 10);
    expect(o.scheduledDueDateMs, start + 10 * dayMs);
  });

  // B28
  test(
      'D7.8 scheduledIntervalDays/scheduledDueDateMs lấy từ after_* của TIỀN '
      'NHIỆM, không phải của sự kiện sau', () {
    final d = deriveRetentionObservations(
      events: [
        event(reviewedAtMs: 1000, afterIntervalDays: 5, afterDueDateMs: 700),
        event(
          reviewedAtMs: 2000,
          beforeIntervalDays: 5,
          beforeDueDateMs: 700,
          // Giá trị của sự kiện SAU cố tình khác hẳn.
          afterIntervalDays: 99,
          afterDueDateMs: 88888,
        ),
      ],
      asOfMs: farFuture,
    );

    final o = d.observations.single;
    expect(o.scheduledIntervalDays, 5);
    expect(o.scheduledDueDateMs, 700);
    expect(o.beforeState, SrsCardState.review);
    expect(o.afterState, SrsCardState.review);
  });
}

/// Đọc mã nguồn một tệp trong kho mã — cùng kỹ thuật fitness function
/// mà `test/repository_boundary_test.dart` đã dùng.
String _readSource(String relativePath) {
  final file = File(relativePath);
  if (!file.existsSync()) {
    fail('không tìm thấy $relativePath — test chạy sai thư mục gốc?');
  }
  return file.readAsStringSync();
}

/// Bỏ mọi chú thích khỏi mã nguồn, giữ nguyên số dòng.
///
/// Cần thiết vì các bất biến của D7.8 nói về MÃ: doc comment cố ý nêu
/// đích danh những thứ bị cấm (`DateTime.now`, `dart:io`...) để giải
/// thích vì sao chúng vắng mặt, nên quét cả chú thích sẽ báo động giả.
String _codeOnly(String source) {
  return source.split('\n').map((line) {
    final index = line.indexOf('//');
    return index == -1 ? line : line.substring(0, index);
  }).join('\n');
}
