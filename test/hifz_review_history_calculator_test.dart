import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/hifz/domain/hifz_review_history_calculator.dart';

/// Sprint D6.11 (DR-2026-0026, đã `accepted`) — hàm THUẦN tính lịch sử
/// ôn Hifz. Không Drift, không Riverpod: mọi luật ngày/tháng nằm ở đây
/// và được kiểm ở đây.
void main() {
  // Mốc cố định cho mọi phép kiểm — 15:30 ngày 16/08/2026 giờ địa
  // phương. Dùng giờ giữa ngày (không phải nửa đêm) để lộ ra bất kỳ
  // nhầm lẫn nào giữa "đầu ngày" và "thời điểm hiện tại".
  final now = DateTime(2026, 8, 16, 15, 30);

  int msOf(DateTime local) => local.toUtc().millisecondsSinceEpoch;

  group('computeHifzReviewHistory', () {
    test('không có sự kiện nào -> tổng 0 và đủ 7 mốc, mốc nào cũng 0',
        () async {
      final history =
          computeHifzReviewHistory(reviewedAtMs: const [], now: now);

      expect(history.totalReviewCount, 0);
      expect(history.recentDays, hasLength(7));
      expect(history.recentDays.every((d) => d.reviewCount == 0), isTrue);
    });

    test('một sự kiện hôm nay -> tổng 1, mốc CUỐI bằng 1, các mốc khác 0',
        () async {
      final history = computeHifzReviewHistory(
        reviewedAtMs: [msOf(DateTime(2026, 8, 16, 9))],
        now: now,
      );

      expect(history.totalReviewCount, 1);
      expect(history.recentDays.last.reviewCount, 1);
      expect(
        history.recentDays.take(6).every((d) => d.reviewCount == 0),
        isTrue,
      );
    });

    test('nhiều sự kiện CÙNG một ngày -> mốc đó đếm đủ cả', () async {
      final history = computeHifzReviewHistory(
        reviewedAtMs: [
          msOf(DateTime(2026, 8, 16, 6)),
          msOf(DateTime(2026, 8, 16, 12)),
          msOf(DateTime(2026, 8, 16, 23, 59)),
        ],
        now: now,
      );

      expect(history.totalReviewCount, 3);
      expect(history.recentDays.last.reviewCount, 3);
    });

    test('sự kiện rải nhiều ngày -> mỗi cái rơi đúng mốc của nó', () async {
      final history = computeHifzReviewHistory(
        reviewedAtMs: [
          msOf(DateTime(2026, 8, 10, 8)), // cũ nhất trong cửa sổ
          msOf(DateTime(2026, 8, 13, 8)),
          msOf(DateTime(2026, 8, 13, 20)),
          msOf(DateTime(2026, 8, 16, 8)), // hôm nay
        ],
        now: now,
      );

      expect(history.totalReviewCount, 4);
      final counts = [for (final d in history.recentDays) d.reviewCount];
      // 10/8 … 16/8 = 7 mốc: 1, 0, 0, 2, 0, 0, 1
      expect(counts, [1, 0, 0, 2, 0, 0, 1]);
    });

    test(
        'sự kiện CŨ HƠN cửa sổ vẫn vào tổng nhưng KHÔNG vào mốc nào — tổng '
        'KHÔNG bắt buộc bằng tổng 7 mốc', () async {
      final history = computeHifzReviewHistory(
        reviewedAtMs: [
          msOf(DateTime(2026, 1, 5, 8)), // rất cũ
          msOf(DateTime(2026, 8, 16, 8)), // hôm nay
        ],
        now: now,
      );

      expect(history.totalReviewCount, 2);
      final bucketSum =
          history.recentDays.fold<int>(0, (sum, d) => sum + d.reviewCount);
      expect(bucketSum, 1);
    });

    test('đúng nửa đêm địa phương thuộc về ngày BẮT ĐẦU, không phải ngày trước',
        () async {
      final history = computeHifzReviewHistory(
        reviewedAtMs: [msOf(DateTime(2026, 8, 16))], // 00:00 hôm nay
        now: now,
      );

      expect(history.recentDays.last.reviewCount, 1);
      expect(history.recentDays[5].reviewCount, 0); // ngày 15/8
    });

    test('trước nửa đêm 1 mili giây thuộc về NGÀY TRƯỚC', () async {
      final history = computeHifzReviewHistory(
        reviewedAtMs: [
          msOf(DateTime(2026, 8, 16)) - 1, // 23:59:59.999 ngày 15/8
        ],
        now: now,
      );

      expect(history.recentDays.last.reviewCount, 0); // hôm nay
      expect(history.recentDays[5].reviewCount, 1); // ngày 15/8
    });

    test('mốc sắp CŨ NHẤT TRƯỚC và luôn đúng 7 phần tử', () async {
      final history =
          computeHifzReviewHistory(reviewedAtMs: const [], now: now);

      expect(history.recentDays, hasLength(7));
      for (var i = 1; i < history.recentDays.length; i++) {
        expect(
          history.recentDays[i].dayStart
              .isAfter(history.recentDays[i - 1].dayStart),
          isTrue,
        );
      }
      expect(history.recentDays.first.dayStart, DateTime(2026, 8, 10));
      expect(history.recentDays.last.dayStart, DateTime(2026, 8, 16));
    });

    test('mọi dayStart là 00:00 giờ địa phương', () async {
      final history =
          computeHifzReviewHistory(reviewedAtMs: const [], now: now);

      for (final d in history.recentDays) {
        expect(d.dayStart.hour, 0);
        expect(d.dayStart.minute, 0);
        expect(d.dayStart.second, 0);
        expect(d.dayStart.millisecond, 0);
      }
    });

    test('cửa sổ tràn qua đầu tháng vẫn đúng (1/9 lùi về 26/8)', () async {
      final history = computeHifzReviewHistory(
        reviewedAtMs: const [],
        now: DateTime(2026, 9, 1, 10),
      );

      expect(history.recentDays.first.dayStart, DateTime(2026, 8, 26));
      expect(history.recentDays.last.dayStart, DateTime(2026, 9, 1));
    });

    test(
        '[now] được tôn trọng: cùng dữ liệu + [now] khác -> mốc khác (không '
        'đọc lén đồng hồ hệ thống)', () async {
      final events = [msOf(DateTime(2026, 8, 16, 8))];

      final asOfToday =
          computeHifzReviewHistory(reviewedAtMs: events, now: now);
      final asOfLater = computeHifzReviewHistory(
        reviewedAtMs: events,
        now: DateTime(2026, 8, 20, 15, 30),
      );

      expect(asOfToday.recentDays.last.reviewCount, 1);
      // 16/8 giờ nằm ở mốc thứ 3 của cửa sổ 14/8..20/8.
      expect(asOfLater.recentDays.last.reviewCount, 0);
      expect(asOfLater.recentDays[2].reviewCount, 1);
      // Tổng KHÔNG đổi theo [now] — chỉ phân bố đổi.
      expect(asOfToday.totalReviewCount, asOfLater.totalReviewCount);
    });

    test(
        'KHÔNG lọc theo grade: hàm chỉ nhận dấu thời gian, mọi lượt ôn có '
        'trọng số như nhau (đếm LƯỢT ÔN, không phải mức độ đúng)', () async {
      // Ba lượt cùng ngày — dù ở tầng dưới chúng là again/hard/easy thì
      // hàm này không hề biết và không được phép biết.
      final history = computeHifzReviewHistory(
        reviewedAtMs: [
          msOf(DateTime(2026, 8, 16, 7)),
          msOf(DateTime(2026, 8, 16, 8)),
          msOf(DateTime(2026, 8, 16, 9)),
        ],
        now: now,
      );

      expect(history.totalReviewCount, 3);
      expect(history.recentDays.last.reviewCount, 3);
    });
  });
}
