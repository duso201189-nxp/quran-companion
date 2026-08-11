import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/quran/data/user_content_providers.dart';
import 'package:quran_companion/features/study/data/boundary_completion_store.dart';
import 'package:quran_companion/features/study/data/surah_revision_target_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sprint 7.4 — dấu hoàn thành (SharedPreferences, DR-2026-0023 mục 7)
/// và phép thu hẹp phạm vi ôn tập ở tầng Provider (mục 8).
Future<ProviderContainer> _container({
  Map<String, Object> prefs = const {},
  List<Override> extra = const [],
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sp),
      ...extra,
    ],
  );
}

void main() {
  group('BoundaryCompletionController — dấu hoàn thành', () {
    test('lần đọc trọn đầu tiên ghi dấu và dựng lời mời', () async {
      final container = await _container();
      addTearDown(container.dispose);
      final controller = container.read(boundaryCompletionProvider.notifier);

      expect(container.read(boundaryCompletionProvider), isNull);

      await controller.markSurahCompleted(1);

      expect(container.read(boundaryCompletionProvider), 1);
      expect(controller.wasInvitedFor(1), isTrue);
    });

    test('đọc trọn lần hai KHÔNG mời lại — dấu vĩnh viễn chặn', () async {
      final container = await _container();
      addTearDown(container.dispose);
      final controller = container.read(boundaryCompletionProvider.notifier);

      await controller.markSurahCompleted(1);
      await controller.dismiss();
      expect(container.read(boundaryCompletionProvider), isNull);

      // Đọc lại Surah đã xong -> không dựng lời mời mới.
      await controller.markSurahCompleted(1);
      expect(container.read(boundaryCompletionProvider), isNull);
    });

    test('bỏ qua lời mời GIỮ dấu vĩnh viễn — bỏ qua là dứt khoát', () async {
      final container = await _container();
      addTearDown(container.dispose);
      final controller = container.read(boundaryCompletionProvider.notifier);

      await controller.markSurahCompleted(3);
      await controller.dismiss();

      expect(container.read(boundaryCompletionProvider), isNull);
      expect(controller.wasInvitedFor(3), isTrue);
    });

    test('mỗi Surah có dấu riêng, không dùng chung', () async {
      final container = await _container();
      addTearDown(container.dispose);
      final controller = container.read(boundaryCompletionProvider.notifier);

      await controller.markSurahCompleted(1);
      expect(controller.wasInvitedFor(1), isTrue);
      expect(controller.wasInvitedFor(2), isFalse);

      await controller.markSurahCompleted(2);
      expect(controller.wasInvitedFor(2), isTrue);
      // Surah mới nhất là lời mời đang treo.
      expect(container.read(boundaryCompletionProvider), 2);
    });

    test('dấu đã có sẵn trên đĩa -> đọc lại đúng lời mời đang treo', () async {
      final container = await _container(
        prefs: {BoundaryCompletionController.pendingKey: 5},
      );
      addTearDown(container.dispose);

      expect(container.read(boundaryCompletionProvider), 5);
    });
  });

  group('Chính sách lời mời — MỘT lời mời, cái mới nhất thắng', () {
    test(
        'A xong rồi B xong trước khi mở màn hình Học: B thay chỗ A, A vẫn '
        'được đánh dấu vĩnh viễn và KHÔNG bao giờ mời lại', () async {
      final container = await _container();
      addTearDown(container.dispose);
      final controller = container.read(boundaryCompletionProvider.notifier);

      await controller.markSurahCompleted(1); // A
      expect(container.read(boundaryCompletionProvider), 1);

      await controller.markSurahCompleted(2); // B — chưa ai xem lời mời A
      expect(
        container.read(boundaryCompletionProvider),
        2,
        reason: 'Lời mời đang treo phải là Surah mới nhất',
      );

      // A mất lời mời, nhưng dấu hoàn thành của A còn nguyên.
      expect(controller.wasInvitedFor(1), isTrue);
      expect(controller.wasInvitedFor(2), isTrue);

      // Đọc trọn A lần nữa cũng không dựng lại lời mời cho A — đây là
      // hệ quả CÓ CHỦ Ý của chính sách một-lời-mời (DR-2026-0023 mục
      // 8), không phải lỗi.
      await controller.markSurahCompleted(1);
      expect(container.read(boundaryCompletionProvider), 2);
    });

    test('dấu vĩnh viễn của Surah này không bị lời mời của Surah kia ghi đè',
        () async {
      final container = await _container();
      addTearDown(container.dispose);
      final controller = container.read(boundaryCompletionProvider.notifier);

      await controller.markSurahCompleted(1);
      final markedAtA = container
          .read(sharedPreferencesProvider)
          .getInt(BoundaryCompletionController.surahKey(1));

      await controller.markSurahCompleted(2);
      await controller.markSurahCompleted(1);

      expect(
        container
            .read(sharedPreferencesProvider)
            .getInt(BoundaryCompletionController.surahKey(1)),
        markedAtA,
        reason: 'Dấu của A phải giữ nguyên thời điểm ghi lần đầu',
      );
    });
  });

  group('surahRevisionTargetProvider — thu hẹp theo Surah', () {
    // Al-Fatihah = ordinal 1..7; Al-Baqarah = 8..293.
    List<Override> eligible(List<int> ayahIds) => [
          revisionEligibleAyahsProvider.overrideWith(
            (ref) => Stream.value([
              for (final id in ayahIds) (ayahId: id, savedAt: 0),
            ]),
          ),
        ];

    test('chỉ giữ Ayah thuộc Surah đã xong', () async {
      final container = await _container(
        extra: eligible([1, 3, 7, 8, 100, 294]),
      );
      addTearDown(container.dispose);

      final target =
          await container.read(surahRevisionTargetProvider(1).future);

      expect(target, [1, 3, 7]);
    });

    test('Ayah của Surah khác bị loại', () async {
      final container = await _container(extra: eligible([1, 7, 8, 9]));
      addTearDown(container.dispose);

      final target =
          await container.read(surahRevisionTargetProvider(2).future);

      // 8 và 9 là Al-Baqarah 1 và 2; 1 và 7 thuộc Al-Fatihah.
      expect(target, [8, 9]);
    });

    test('luật đủ-điều-kiện vẫn là của Sprint 7.3 — rỗng thì rỗng', () async {
      final container = await _container(extra: eligible([]));
      addTearDown(container.dispose);

      expect(
        await container.read(surahRevisionTargetProvider(1).future),
        isEmpty,
      );
    });

    test(
        'Ayah đủ điều kiện nhưng Surah chưa xong vẫn không tự vào phạm vi '
        'Surah khác', () async {
      final container = await _container(extra: eligible([100, 200]));
      addTearDown(container.dispose);

      expect(
        await container.read(surahRevisionTargetProvider(1).future),
        isEmpty,
      );
    });

    test('Surah ngoài miền -> rỗng, không ném', () async {
      final container = await _container(extra: eligible([1, 2, 3]));
      addTearDown(container.dispose);

      expect(
        await container.read(surahRevisionTargetProvider(0).future),
        isEmpty,
      );
      expect(
        await container.read(surahRevisionTargetProvider(115).future),
        isEmpty,
      );
    });
  });
}
