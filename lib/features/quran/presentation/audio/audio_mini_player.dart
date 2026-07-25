import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../../app/router.dart';
import 'audio_controller.dart';

/// Chiều cao phần điều khiển của thanh phát thu gọn (chưa tính vùng
/// an toàn dưới đáy). Đủ cho vùng chạm 48px chuẩn Material.
const double kMiniPlayerHeight = 56;

/// Bọc TOÀN BỘ ứng dụng và gắn [AudioMiniPlayer] xuống đáy khi đang
/// phát audio (Sprint 29.0).
///
/// VÌ SAO Ở ĐÂY (`MaterialApp.builder`) chứ không phải trong
/// `AppScaffold`: `AppScaffold` chỉ là vỏ của 5 tab. Mọi màn hình
/// khác (Thư viện, Tìm kiếm, Flashcards, các phiên học/quiz — 15
/// route top-level) được `push` ĐÈ LÊN vỏ đó, nên một thanh phát đặt
/// trong `AppScaffold` sẽ bị chính chúng che mất. `MaterialApp.builder`
/// nằm TRÊN Navigator nên là điểm gắn duy nhất phủ được mọi route —
/// đúng yêu cầu "điều khiển được xuyên suốt ứng dụng".
///
/// KHÔNG chồng lên nội dung: dùng [Column] nên thanh phát chiếm chỗ
/// thật, đẩy nội dung (kể cả `NavigationBar` của vỏ tab) lên trên —
/// không che thanh điều hướng, không cần Stack/overlay.
///
/// Khi không phát: trả về ĐÚNG [child], không thêm một widget nào vào
/// cây. Ứng dụng ở trạng thái bình thường hoàn toàn không đổi.
class AudioMiniPlayerHost extends ConsumerWidget {
  const AudioMiniPlayerHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // select(): vỏ ứng dụng CHỈ dựng lại khi bắt đầu/kết thúc phát,
    // không theo từng tick vị trí (~3 lần/giây). Đây là lý do host và
    // thanh phát là hai widget tách rời.
    final active = ref.watch(audioControllerProvider.select((s) => s.active));
    if (!active) return child;

    return Column(
      children: [
        // removeBottom: khu vực dưới cùng nay do [_MiniPlayerSlot] giữ,
        // nên nội dung bên trên không tự chèn vùng an toàn nữa — nếu
        // không gỡ sẽ đệm hai lần.
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: child,
          ),
        ),
        _MiniPlayerSlot(router: ref.watch(routerProvider)),
      ],
    );
  }
}

/// Chỗ đứng dưới cùng của ứng dụng: thanh thu gọn, HOẶC khoảng trống
/// đúng bằng vùng an toàn khi đang ở trang đọc.
///
/// PHẢI là widget ANH EM của nội dung ứng dụng, tuyệt đối không phải
/// tổ tiên. `GoRouterDelegate` phát thông báo NGAY TRONG lúc Router
/// dựng lại vì điều hướng; nếu thứ nghe nó bọc quanh cả Router thì
/// chính tổ tiên bị đánh dấu "dirty" giữa lúc con đang dựng và
/// Flutter ném `'!_dirty': is not true`. Đứng sau Router trong cùng
/// một [Column] thì phần tử này chưa dựng ở khung hình đó nên nhận
/// thông báo hoàn toàn an toàn (đã tái hiện cả hai chiều bằng
/// `audio_mini_player_test.dart`).
///
/// Đọc `router.state.uri`, KHÔNG phải
/// `routerDelegate.currentConfiguration.uri`: với route mở bằng
/// `push` (trang đọc chính là vậy), `currentConfiguration.uri` vẫn
/// đứng ở vị trí NỀN ('/quran') còn route được push nằm trong một
/// `ImperativeRouteMatch` lồng bên trong. `state` đi tới match sâu
/// nhất nên trả về đúng vị trí đang hiển thị.
class _MiniPlayerSlot extends StatelessWidget {
  const _MiniPlayerSlot({required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: router.routerDelegate,
      builder: (context, _) {
        if (AppRoutes.isReadingLocation(router.state.uri.path)) {
          // Trang đọc đã có AudioBar đầy đủ -> không hiện thanh thu
          // gọn. Nhưng phải TRẢ LẠI đúng vùng an toàn vừa gỡ khỏi nội
          // dung, nếu không AudioBar sẽ nằm đè lên thanh home.
          return SizedBox(height: MediaQuery.paddingOf(context).bottom);
        }
        return const AudioMiniPlayer();
      },
    );
  }
}

/// Thanh phát thu gọn: cho biết đang nghe gì và cho tạm dừng / dừng
/// hẳn / quay lại trang đọc — ở bất kỳ đâu trong ứng dụng.
///
/// KHÔNG có bộ máy phát riêng: mọi thao tác đi thẳng vào
/// [AudioController] đã có, cùng một provider mà `AudioBar` dùng. Rời
/// trang đọc không dừng nhạc vì controller là `NotifierProvider` toàn
/// cục (không `autoDispose`).
///
/// Cố ý KHÔNG lặp lại đủ bộ nút của `AudioBar` (Qari, tua Ayah, tốc
/// độ, lặp): thanh này là lối tắt, không phải bản sao thứ hai của
/// trình phát. Cần đủ nút thì chạm để quay về trang đọc.
///
/// VÌ SAO DÙNG `Icon(semanticLabel:)` CHỨ KHÔNG PHẢI `Tooltip` như
/// `AudioBar`: `Tooltip` bắt buộc phải có `Overlay` tổ tiên, mà
/// `Overlay` do `Navigator` cung cấp — nằm BÊN DƯỚI
/// `MaterialApp.builder`. Đặt tooltip ở đây làm app ném
/// "No Overlay widget found" ngay khi thanh hiện ra (đã tái hiện
/// bằng `audio_mini_player_test.dart`). Nhãn cho trình đọc màn hình
/// vẫn đầy đủ — chỉ mất gợi ý khi rê chuột, đúng như
/// `CircularProgressIndicator(semanticsLabel:)` đang làm.
class AudioMiniPlayer extends ConsumerWidget {
  const AudioMiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerHigh,
      elevation: 3,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _MiniProgressBar(),
            // Không ép chiều cao cứng: cỡ chữ lớn -> hàng tự cao thêm
            // thay vì cắt chữ.
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: kMiniPlayerHeight),
              child: Row(
                children: [
                  Expanded(child: _MiniTitle(l10n: l10n)),
                  const _MiniPlayPauseButton(),
                  IconButton(
                    icon: Icon(Icons.close, semanticLabel: l10n.stopAudio),
                    onPressed: ref.read(audioControllerProvider.notifier).stop,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dải tiến độ mảnh — cùng ngôn ngữ hình ảnh với `AudioBar` trên trang
/// đọc, để hai thanh trông như một hệ.
class _MiniProgressBar extends ConsumerWidget {
  const _MiniProgressBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (loading, progress) = ref.watch(
      audioControllerProvider.select((s) => (s.loading, s.progress)),
    );

    return LinearProgressIndicator(
      minHeight: 2,
      value: loading ? null : progress ?? 0,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }
}

/// Nhãn "đang phát" + chạm để quay lại trang đọc đúng Surah/Ayah.
class _MiniTitle extends ConsumerWidget {
  const _MiniTitle({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (surahId, currentIndex, reciterName) = ref.watch(
      audioControllerProvider.select(
        (s) => (s.surahId, s.currentIndex, s.reciter?.name ?? ''),
      ),
    );
    if (surahId == null) return const SizedBox.shrink();

    final reference = '$surahId:${currentIndex + 1}';

    // MỘT node duy nhất cho trình đọc màn hình: "Đang phát, Alafasy,
    // 2:5, Mở trang đọc" — thay vì đọc rời từng dòng chữ.
    return Semantics(
      button: true,
      label: [l10n.nowPlaying, reciterName, reference]
          .where((s) => s.isNotEmpty)
          .join(', '),
      hint: l10n.openReadingScreen,
      excludeSemantics: true,
      child: InkWell(
        onTap: () => _openReading(ref, surahId),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reciterName.isEmpty ? l10n.nowPlaying : reciterName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelMedium,
              ),
              Text(
                reference,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Dùng LẠI route đọc top-level đã có — cùng route mà Thư viện của
  /// tôi và Tìm kiếm dùng (xem `reading_navigation.dart`). KHÔNG ghi
  /// đè vị trí đọc đã lưu: người dùng chỉ muốn xem cái đang nghe, và
  /// trang đọc tự cuộn theo audio sẵn rồi.
  ///
  /// Điều hướng qua ĐỐI TƯỢNG router chứ không phải `context.push`:
  /// `MaterialApp.builder` dựng widget này TRÊN Router, nên
  /// `InheritedGoRouter` (thứ mà `context.push` tra cứu) không tồn tại
  /// ở đây. `routerProvider` là cùng một GoRouter mà app đang chạy —
  /// không phải đường điều hướng thứ hai.
  void _openReading(WidgetRef ref, int surahId) {
    ref.read(routerProvider).push(AppRoutes.read(surahId));
  }
}

/// Nút phát/tạm dừng — trạng thái tải hiển thị vòng xoay, đúng như
/// `AudioBar`.
class _MiniPlayPauseButton extends ConsumerWidget {
  const _MiniPlayPauseButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final (playing, loading) = ref.watch(
      audioControllerProvider.select((s) => (s.playing, s.loading)),
    );

    if (loading) {
      return Container(
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(12),
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: scheme.primary,
          semanticsLabel: l10n.audioLoading,
        ),
      );
    }

    return IconButton(
      icon: Icon(
        playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
        size: 34,
        color: scheme.primary,
        semanticLabel: playing ? l10n.pause : l10n.play,
      ),
      onPressed: ref.read(audioControllerProvider.notifier).togglePlayPause,
    );
  }
}
