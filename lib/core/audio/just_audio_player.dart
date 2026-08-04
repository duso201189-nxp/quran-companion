import 'dart:async';

import 'package:just_audio/just_audio.dart';

import 'ayah_audio_item.dart';
import 'ayah_audio_player.dart';

/// Triển khai [AyahAudioPlayer] trên package just_audio.
///
/// Đây là trình phát DUY NHẤT trên mọi nền tảng. `audio_service` không
/// thay thế lớp này — `QuranAudioHandler` bọc quanh nó để nói chuyện
/// với thông báo của hệ điều hành (xem docs/AUDIO.md). Nhờ vậy Windows
/// và Linux, nơi audio_service không hỗ trợ, dùng đúng lớp này không
/// sửa gì.
class JustAudioAyahPlayer implements AyahAudioPlayer {
  JustAudioAyahPlayer({AudioPlayer? player})
      : _player = player ?? AudioPlayer() {
    // Lỗi bất đồng bộ của engine (mất mạng giữa chừng, nguồn 404...)
    // -> chuyển hết vào errorStream, không để nổ ra ngoài.
    _eventSub = _player.playbackEventStream.listen(
      (_) {},
      onError: (Object e, StackTrace _) => _errors.add(_describe(e)),
    );
  }

  final AudioPlayer _player;
  final StreamController<String> _errors = StreamController.broadcast();
  final StreamController<List<AyahAudioItem>> _playlists =
      StreamController.broadcast();
  StreamSubscription<PlaybackEvent>? _eventSub;

  /// Playlist đang nạp — nguồn của [currentItem]/[currentItemStream].
  /// just_audio chỉ trả về chỉ số, phần mô tả là của ứng dụng.
  List<AyahAudioItem> _items = const [];

  static String _describe(Object e) => switch (e) {
        PlayerException(:final message) => message ?? 'PlayerException',
        _ => e.toString(),
      };

  @override
  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  @override
  Stream<bool> get playingStream => _player.playingStream;

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Stream<AyahPlayerProcessing> get processingStream =>
      _player.processingStateStream.map(
        (s) => switch (s) {
          ProcessingState.idle => AyahPlayerProcessing.idle,
          ProcessingState.loading ||
          ProcessingState.buffering =>
            AyahPlayerProcessing.loading,
          ProcessingState.ready => AyahPlayerProcessing.ready,
          ProcessingState.completed => AyahPlayerProcessing.completed,
        },
      );

  @override
  Stream<String> get errorStream => _errors.stream;

  /// Chỉ số nằm ngoài playlist -> `null`, KHÔNG ném. just_audio có thể
  /// phát ra chỉ số của playlist cũ trong khoảnh khắc đang đổi nguồn;
  /// một ngoại lệ ở đây sẽ giết stream và làm thông báo hệ điều hành
  /// đứng hình vĩnh viễn.
  AyahAudioItem? _itemAt(int? index) =>
      index != null && index >= 0 && index < _items.length
          ? _items[index]
          : null;

  @override
  AyahAudioItem? get currentItem => _itemAt(_player.currentIndex);

  @override
  Stream<AyahAudioItem?> get currentItemStream =>
      _player.currentIndexStream.map(_itemAt);

  @override
  List<AyahAudioItem> get playlist => _items;

  @override
  Stream<List<AyahAudioItem>> get playlistStream => _playlists.stream;

  @override
  Future<void> setPlaylist(
    List<AyahAudioItem> items, {
    int initialIndex = 0,
  }) async {
    _items = List.unmodifiable(items);
    // Phát TRƯỚC khi nạp nguồn: nếu setAudioSource lỗi, hàng đợi vẫn
    // đúng với thứ người dùng vừa yêu cầu, và Thử lại dùng lại chính
    // danh sách này.
    _playlists.add(_items);
    try {
      await _player.setAudioSource(
        ConcatenatingAudioSource(
          children: [for (final item in items) AudioSource.uri(item.source)],
        ),
        initialIndex: initialIndex,
      );
    } catch (e) {
      _errors.add(_describe(e));
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seekToIndex(int index) =>
      _player.seek(Duration.zero, index: index);

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> setRepeatMode(RepeatMode mode) => _player.setLoopMode(
        switch (mode) {
          RepeatMode.off => LoopMode.off,
          RepeatMode.one => LoopMode.one,
          RepeatMode.all => LoopMode.all,
        },
      );

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() async {
    await _eventSub?.cancel();
    await _errors.close();
    await _playlists.close();
    await _player.dispose();
  }
}
