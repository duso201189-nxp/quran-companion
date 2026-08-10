import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/quran/data/retention_seeding_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sprint 7.3 (Automatic Retention Seeding) — cùng mẫu
/// test/daily_goal_store_test.dart (Notifier tự đọc lại lúc build(),
/// ghi bền qua SharedPreferences).
Future<ProviderContainer> _container({
  Map<String, Object> prefs = const {},
  int Function()? nowMs,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sp),
      if (nowMs != null)
        retentionSeedingActivationProvider.overrideWith(
          () => RetentionSeedingActivation(nowMs: nowMs),
        ),
    ],
  );
}

void main() {
  test(
      'chưa có mốc nào lưu -> build() ghi thời điểm hiện tại (qua nowMs '
      'tiêm được) và trả đúng giá trị đó', () async {
    final c = await _container(nowMs: () => 12345);
    addTearDown(c.dispose);

    final activatedAtMs = c.read(retentionSeedingActivationProvider);

    expect(activatedAtMs, 12345);
  });

  test('mốc đã lưu từ trước -> build() đọc lại đúng giá trị cũ, KHÔNG ghi đè',
      () async {
    final c = await _container(
      prefs: {RetentionSeedingActivation.key: 999},
      nowMs: () => 555555, // nếu bị gọi nghĩa là đã ghi đè sai
    );
    addTearDown(c.dispose);

    final activatedAtMs = c.read(retentionSeedingActivationProvider);

    expect(activatedAtMs, 999);
  });

  test(
      'container mới (mô phỏng app khởi động lại, cùng prefs) đọc lại '
      'đúng mốc đã ghi ở lần chạy trước -> ổn định qua các lần khởi động',
      () async {
    final c1 = await _container(nowMs: () => 42);
    final first = c1.read(retentionSeedingActivationProvider);
    c1.dispose();

    final sp = await SharedPreferences.getInstance();
    final c2 = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(sp)],
    );
    addTearDown(c2.dispose);

    final second = c2.read(retentionSeedingActivationProvider);
    expect(second, first);
    expect(second, 42);
  });

  test(
      'đọc nhiều lần trong cùng 1 container -> luôn cùng 1 giá trị (không '
      'ghi lại mỗi lần đọc)', () async {
    var calls = 0;
    final c = await _container(
      nowMs: () {
        calls++;
        return 1000 + calls;
      },
    );
    addTearDown(c.dispose);

    final a = c.read(retentionSeedingActivationProvider);
    final b = c.read(retentionSeedingActivationProvider);

    expect(a, b);
    expect(
      calls,
      1,
      reason: 'nowMs() chỉ gọi đúng 1 lần — build() chỉ '
          'chạy 1 lần cho mỗi ProviderContainer, không phải mỗi lần đọc',
    );
  });

  test(
      'không có nowMs tiêm -> mặc định dùng thời gian thực (đồng hồ hệ '
      'thống), giá trị nằm trong khoảng hợp lý quanh "bây giờ"', () async {
    final before = DateTime.now().toUtc().millisecondsSinceEpoch;
    final c = await _container();
    addTearDown(c.dispose);

    final activatedAtMs = c.read(retentionSeedingActivationProvider);
    final after = DateTime.now().toUtc().millisecondsSinceEpoch;

    expect(activatedAtMs, greaterThanOrEqualTo(before));
    expect(activatedAtMs, lessThanOrEqualTo(after));
  });

  group(
      'ensureActivated — sửa lỗi kiểm chứng cuối Sprint 7.3 (kích hoạt lúc '
      'khởi động app, không đợi lần đầu vào Revision/Study)', () {
    test(
        '1+2: gọi ensureActivated TRỰC TIẾP (mô phỏng main() trước '
        'runApp/trước khi bất kỳ Provider nào tồn tại) -> mốc được ghi '
        'và đọc lại được ngay từ SharedPreferences, không cần đi qua '
        'ProviderContainer', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final activatedAtMs =
          RetentionSeedingActivation.ensureActivated(prefs, nowMs: () => 7000);

      expect(activatedAtMs, 7000);
      expect(prefs.getInt(RetentionSeedingActivation.key), 7000);
    });

    test(
        '5: gọi ensureActivated lần 2 với nowMs khác -> KHÔNG ghi đè, vẫn '
        'trả lại giá trị của lần gọi đầu (idempotent qua nhiều lần gọi, '
        'không chỉ qua nhiều lần build())', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final first =
          RetentionSeedingActivation.ensureActivated(prefs, nowMs: () => 100);
      final second = RetentionSeedingActivation.ensureActivated(
        prefs,
        nowMs: () => 999999, // nếu bị dùng nghĩa là đã ghi đè sai
      );

      expect(first, 100);
      expect(second, 100);
      expect(prefs.getInt(RetentionSeedingActivation.key), 100);
    });

    test(
        '1+2+5 (quan trọng nhất — chứng minh sửa lỗi kích hoạt lúc khởi '
        'động): main() gọi ensureActivated() TRƯỚC khi ProviderContainer '
        'tồn tại -> khi Provider sau đó được đọc lần đầu (mô phỏng người '
        'dùng vào Revision Queue/Study nhiều "ngày" sau), nó trả lại '
        'ĐÚNG mốc đã ghi lúc khởi động — KHÔNG tính lại "bây giờ" lúc '
        'được đọc lần đầu (đây chính là hành vi SAI trước khi sửa)', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Bước 1 — mô phỏng chính xác dòng mới trong main.dart: gọi
      // ensureActivated() ngay sau khi có SharedPreferences, TRƯỚC
      // runApp/trước khi ProviderScope hay bất kỳ Provider nào build().
      const startupTimeMs = 5000;
      RetentionSeedingActivation.ensureActivated(
        prefs,
        nowMs: () => startupTimeMs,
      );

      // Bước 2 — "vài ngày sau", người dùng lần đầu vào một màn hình
      // có watch retentionSeedingActivationProvider (Revision Queue,
      // Review Session, Learning Session). nowMs ở ĐÂY cố tình khác hẳn
      // startupTimeMs — nếu Provider tính lại "bây giờ" thay vì đọc lại
      // giá trị đã ghi ở Bước 1, test này sẽ thất bại.
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          retentionSeedingActivationProvider.overrideWith(
            () => RetentionSeedingActivation(nowMs: () => 999999999),
          ),
        ],
      );
      addTearDown(container.dispose);

      final activatedAtMs = container.read(retentionSeedingActivationProvider);

      expect(
        activatedAtMs,
        startupTimeMs,
        reason: 'Provider phải đọc lại mốc đã ghi lúc "khởi động app" '
            '(Bước 1), không phải tính "bây giờ" tại thời điểm nó được '
            'đọc lần đầu bởi một màn hình Revision/Study.',
      );
    });
  });
}
