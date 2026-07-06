import 'dart:async';

import 'package:just_audio/just_audio.dart';

import 'ayah_audio_player.dart';

/// Triển khai [AyahAudioPlayer] trên package just_audio.
///
/// Ghi chú nền tảng: phát khi tắt màn hình / thông báo media cần
/// cấu hình bổ sung theo docs/AUDIO.md (AndroidManifest + Info.plist
/// + package audio_service) — thực hiện ở giai đoạn phát hành.
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
  StreamSubscription<PlaybackEvent>? _eventSub;

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

  @override
  Future<void> setPlaylist(List<Uri> sources, {int initialIndex = 0}) async {
    try {
      await _player.setAudioSource(
        ConcatenatingAudioSource(
          children: [for (final uri in sources) AudioSource.uri(uri)],
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
    await _player.dispose();
  }
}
