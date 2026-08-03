import 'dart:async';

import 'package:audio_service/audio_service.dart';

import 'ayah_audio_item.dart';
import 'ayah_audio_player.dart';

/// Cầu nối giữa trình phát của ứng dụng và thông báo media của hệ điều
/// hành (Sprint B1 — xem `docs/AUDIO.md`).
///
/// ## Nó KHÔNG phải một trình phát
///
/// `audio_service` thường được dựng theo lối "handler LÀ trình phát".
/// Ở đây thì không, và đó là lựa chọn có chủ ý: [AyahAudioPlayer] vẫn
/// là trừu tượng duy nhất, còn lớp này chỉ *quan sát* nó rồi *chuyển
/// tiếp* các nút bấm ngược lại.
///
/// Đổi lại được hai điều:
///
/// 1. **Windows và Linux không phải biết gì.** `audio_service` chỉ hỗ
///    trợ Android/iOS/macOS/web; hai nền tảng kia dùng
///    `JustAudioAyahPlayer` y như cũ, không nhánh, không lớp con.
/// 2. **`AudioController` không phải đổi.** Nút trên thông báo gọi
///    thẳng xuống trình phát, và controller vốn đã lắng nghe các stream
///    của trình phát, nên trạng thái tự khớp. Không có đường ghi thứ
///    hai vào state — tức không có vòng lặp như chỗ audio/cuộn mà
///    `DR-2026-0019` E3 phải đi gỡ.
///
/// ## Chưa được nối
///
/// Sprint B1 CỐ Ý dừng trước phần cấu hình nền tảng: `AudioService.init`
/// chưa được gọi ở `main.dart`, AndroidManifest chưa khai báo service,
/// Info.plist chưa có `UIBackgroundModes`. Gọi `init()` khi manifest
/// chưa khai báo service là lỗi lúc CHẠY, nên nối sớm sẽ làm hỏng app
/// trên Android. Phần đó là Phase 2 và cần quyết định về bộ quyền —
/// một cam kết với cửa hàng ứng dụng, không phải một thay đổi mã.
class QuranAudioHandler extends BaseAudioHandler with SeekHandler {
  QuranAudioHandler(this._player) {
    _subs.addAll([
      _player.currentItemStream.listen((item) {
        _item = item;
        mediaItem.add(item == null ? null : mediaItemFor(item));
        _publish();
      }),
      _player.currentIndexStream.listen((index) {
        _index = index ?? 0;
        _publish();
      }),
      _player.playingStream.listen((value) {
        _playing = value;
        _publish();
      }),
      _player.processingStream.listen((value) {
        _processing = value;
        _publish();
      }),
      _player.positionStream.listen((value) {
        _position = value;
        _publish();
      }),
    ]);

    // Trình phát có thể đã chạy trước khi lớp này được dựng; stream
    // broadcast không phát lại giá trị cũ nên phải hỏi thẳng một lần.
    _item = _player.currentItem;
    if (_item != null) mediaItem.add(mediaItemFor(_item!));
    _publish();
  }

  final AyahAudioPlayer _player;
  final List<StreamSubscription<Object?>> _subs = [];

  AyahAudioItem? _item;
  int _index = 0;
  bool _playing = false;
  Duration _position = Duration.zero;
  AyahPlayerProcessing _processing = AyahPlayerProcessing.idle;

  void _publish() => playbackState.add(
        playbackStateFor(
          playing: _playing,
          processing: _processing,
          position: _position,
          index: _index,
        ),
      );

  // ---------- nút bấm trên thông báo / màn hình khoá ----------

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> skipToNext() => _player.seekToIndex(_index + 1);

  @override
  Future<void> skipToPrevious() => _player.seekToIndex(
        // Không lùi quá đầu playlist. Hệ điều hành vẫn vẽ nút, người
        // dùng vẫn bấm được — chặn ở đây rẻ hơn là tin vào nó.
        _index > 0 ? _index - 1 : 0,
      );

  @override
  Future<void> skipToQueueItem(int index) => _player.seekToIndex(index);

  Future<void> close() async {
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
  }
}

/// Mô tả một Ayah cho thông báo của hệ điều hành.
///
/// Hàm THUẦN, tách riêng để test được mà không cần thiết bị: đây là
/// phần duy nhất của B1 quyết định người dùng ĐỌC thấy gì trên màn
/// hình khoá.
///
/// - `id` dùng địa chỉ chứ không dùng URL: URL đổi theo Qari, còn địa
///   chỉ thì không, nên nó là danh tính ổn định của mục phát.
/// - `title` là "Ayah N" — con số 1-based người đọc thấy, lấy qua
///   `QuranAddress` chứ không phải chỉ số playlist.
MediaItem mediaItemFor(AyahAudioItem item) => MediaItem(
      id: '${item.address}',
      title: 'Ayah ${item.address.ayah}',
      album: item.surahName,
      artist: item.reciterName,
    );

/// Trạng thái phát cho thông báo của hệ điều hành.
///
/// Hàm THUẦN, cùng lý do như [mediaItemFor]. Nó quyết định nút nào sáng
/// và thanh tiến độ chạy tới đâu khi màn hình đã khoá.
PlaybackState playbackStateFor({
  required bool playing,
  required AyahPlayerProcessing processing,
  required Duration position,
  required int index,
}) =>
    PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {MediaAction.seek},
      androidCompactActionIndices: const [0, 1, 2],
      processingState: switch (processing) {
        AyahPlayerProcessing.idle => AudioProcessingState.idle,
        AyahPlayerProcessing.loading => AudioProcessingState.loading,
        AyahPlayerProcessing.ready => AudioProcessingState.ready,
        AyahPlayerProcessing.completed => AudioProcessingState.completed,
      },
      playing: playing,
      updatePosition: position,
      queueIndex: index,
    );
