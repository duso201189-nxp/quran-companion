import 'dart:async';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:just_audio/just_audio.dart';

import 'ayah_audio_item.dart';
import 'ayah_audio_player.dart';

/// Nạp trước (không phát) nguồn của MỘT Ayah — tách ra để test không cần
/// dựng engine just_audio thật lần thứ hai. Xem doc comment của
/// [JustAudioAyahPlayer] mục "Nạp trước Ayah kế".
typedef AyahPrefetcher = Future<void> Function(Uri source);

/// Triển khai [AyahAudioPlayer] trên package just_audio.
///
/// Đây là trình phát DUY NHẤT trên mọi nền tảng. `audio_service` không
/// thay thế lớp này — `QuranAudioHandler` bọc quanh nó để nói chuyện
/// với thông báo của hệ điều hành (xem docs/AUDIO.md). Nhờ vậy Windows
/// và Linux, nơi audio_service không hỗ trợ, dùng đúng lớp này không
/// sửa gì.
///
/// ## Nạp trước Ayah kế
///
/// `ConcatenatingAudioSource` không có lookahead thật trên Web:
/// `useLazyPreparation` bị chính just_audio_web bỏ qua ("Currently
/// ignored" — đọc thẳng từ mã nguồn gói, không phải suy đoán), và chỉ
/// có DUY NHẤT một `<audio>` dùng chung cho mọi mục playlist. Kết quả:
/// khi Ayah N kết thúc TỰ NHIÊN, byte đầu tiên của Ayah N+1 mới bắt đầu
/// được tải — khác hẳn bấm "kế tiếp" thủ công, nơi mạng thường đã có
/// sẵn dữ liệu từ lần nghe trước hoặc người dùng đã đợi.
///
/// Vá bằng MỘT trình phát just_audio thứ hai, dựng lười, KHÔNG BAO GIỜ
/// gọi `play()` — chỉ `setAudioSource(..., preload: true)` để ép engine
/// (và trình duyệt, trên Web) tải sẵn tệp. Vì `AudioSession.setActive`
/// (xin quyền phát âm thanh) chỉ được gọi bên trong `play()` của chính
/// just_audio (đọc thẳng mã nguồn gói: "This method activates the audio
/// session before playback"), một trình phát chưa từng `play()` không
/// bao giờ xin audio focus, không đụng tới `QuranAudioHandler` (nó chỉ
/// quan sát CHÍNH trình phát này qua [AyahAudioPlayer], không biết gì
/// về trình phát nạp-trước riêng), và không phát ra âm thanh nào cả.
class JustAudioAyahPlayer implements AyahAudioPlayer {
  JustAudioAyahPlayer({AudioPlayer? player, AyahPrefetcher? prefetch})
      : _player = player ?? AudioPlayer(),
        _injectedPrefetch = prefetch {
    // Lỗi bất đồng bộ của engine (mất mạng giữa chừng, nguồn 404...)
    // -> chuyển hết vào errorStream, không để nổ ra ngoài.
    _eventSub = _player.playbackEventStream.listen(
      (_) {},
      onError: (Object e, StackTrace _) => _errors.add(_describe(e)),
    );
    // Mỗi khi mục ĐANG PHÁT đổi (dù do just_audio tự chuyển tiếp hay do
    // seekToIndex), nạp trước đúng MỘT mục kế — không hơn.
    _indexSub = _player.currentIndexStream.listen(_onCurrentIndexChanged);
  }

  final AudioPlayer _player;
  final AyahPrefetcher? _injectedPrefetch;
  final StreamController<String> _errors = StreamController.broadcast();
  final StreamController<List<AyahAudioItem>> _playlists =
      StreamController.broadcast();
  StreamSubscription<PlaybackEvent>? _eventSub;
  StreamSubscription<int?>? _indexSub;

  /// Trình phát nạp-trước dựng lười, chỉ khi không có [_injectedPrefetch]
  /// (test) — TÁI SỬ DỤNG cho mọi lần nạp trước, không dựng mới mỗi Ayah.
  AudioPlayer? _prefetchPlayer;

  /// Chỉ số ĐÃ tính mục kế để nạp trước — chặn nạp trước lặp lại khi
  /// currentIndexStream phát ra cùng một chỉ số nhiều lần (bản thân
  /// just_audio có thể làm vậy), và được ĐẶT LẠI ở [setPlaylist] để một
  /// chỉ số trùng số nhưng thuộc playlist MỚI không bị hiểu nhầm là "đã
  /// nạp trước rồi" từ playlist CŨ.
  int? _lastIndexPrefetchedFrom;

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
    // Đặt lại dấu vết nạp-trước: playlist mới, chỉ số cũ không còn
    // nghĩa gì — xem doc comment của [_lastIndexPrefetchedFrom].
    _lastIndexPrefetchedFrom = null;
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

  /// Nạp trước đúng MỘT mục kế mỗi khi mục đang phát đổi.
  ///
  /// Không tự phát/seek trình phát chính, không đụng `_items`/playlist
  /// chính — chỉ quan sát rồi gọi [_safePrefetch] một lần cho mỗi chỉ
  /// số mới thật sự.
  void _onCurrentIndexChanged(int? index) {
    if (index == null || index == _lastIndexPrefetchedFrom) return;
    _lastIndexPrefetchedFrom = index;
    final next = index + 1;
    if (next < 0 || next >= _items.length) return; // cuối playlist / rỗng
    unawaited(_safePrefetch(_items[next].source));
  }

  /// Chỉ để test: gọi thẳng logic nạp-trước như khi `currentIndexStream`
  /// của trình phát CHÍNH phát ra [index] — không cần dựng một
  /// `AudioPlayer` thật để mô phỏng luồng chỉ số của engine, đúng tinh
  /// thần "fake/injected seam, không phải engine thật thứ hai" đã dùng
  /// cho [AyahPrefetcher].
  @visibleForTesting
  void debugSimulateIndexChange(int? index) => _onCurrentIndexChanged(index);

  /// Chỉ để test: đặt [_items] (và đặt lại dấu vết nạp-trước) giống hệt
  /// phần ĐẦU, đồng bộ của [setPlaylist] — KHÔNG gọi
  /// `_player.setAudioSource`, vốn cần kênh nền tảng thật (mạng/engine)
  /// mà một unit test không có. Logic nạp-trước chỉ phụ thuộc [_items],
  /// không phụ thuộc trình phát chính đã thật sự nạp xong hay chưa.
  @visibleForTesting
  void debugSetItemsForTest(List<AyahAudioItem> items) {
    _items = List.unmodifiable(items);
    _lastIndexPrefetchedFrom = null;
  }

  /// Lỗi nạp trước KHÔNG được lọt ra đường phát chính — Ayah kế vẫn còn
  /// cơ hội tải lại đúng lúc nó thật sự cần phát (playSurah/seekToIndex
  /// đi qua `_player` chính, không phụ thuộc vào lần nạp trước này).
  Future<void> _safePrefetch(Uri source) async {
    try {
      await _prefetch(source);
    } catch (_) {
      // Im lặng: đây là tối ưu, không phải yêu cầu — xem doc comment
      // lớp này mục "Nạp trước Ayah kế".
    }
  }

  Future<void> _prefetch(Uri source) {
    final injected = _injectedPrefetch;
    if (injected != null) return injected(source);
    // Một trình phát DUY NHẤT, tái dùng cho mọi lần nạp trước — không
    // bao giờ play(), nên không bao giờ xin audio focus (xem doc
    // comment lớp này).
    final player = _prefetchPlayer ??= AudioPlayer();
    return player.setAudioSource(AudioSource.uri(source), preload: true);
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
    await _indexSub?.cancel();
    await _errors.close();
    await _playlists.close();
    await _player.dispose();
    await _prefetchPlayer?.dispose();
  }
}
