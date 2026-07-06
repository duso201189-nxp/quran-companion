import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/audio/audio_url.dart';
import '../../../../core/audio/ayah_audio_player.dart';
import '../../../../core/storage/prefs_provider.dart';
import '../../data/quran_providers.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/entities/reciter.dart';

/// Danh sách Qari (từ database nội dung).
final recitersProvider = FutureProvider<List<Reciter>>(
  (ref) => ref.watch(quranRepositoryProvider).getEnabledReciters(),
);

/// Các mức tốc độ phát, xoay vòng.
const List<double> kPlaybackSpeeds = [0.75, 1.0, 1.25, 1.5, 2.0];

/// Trạng thái trình phát Ayah.
class AudioState {
  const AudioState({
    this.surahId,
    this.currentIndex = 0,
    this.playing = false,
    this.speed = 1.0,
    this.repeat = RepeatMode.off,
    this.reciter,
    this.position = Duration.zero,
    this.duration,
    this.loading = false,
    this.errorMessage,
  });

  /// Surah đang phát; null = trình phát chưa hoạt động.
  final int? surahId;

  /// Chỉ số Ayah (0-based) trong Surah đang phát.
  final int currentIndex;
  final bool playing;
  final double speed;
  final RepeatMode repeat;
  final Reciter? reciter;

  /// Vị trí phát trong Ayah hiện tại.
  final Duration position;

  /// Thời lượng Ayah hiện tại (null khi chưa biết).
  final Duration? duration;

  /// Đang tải/buffer nguồn audio.
  final bool loading;

  /// Lỗi phát gần nhất (null = không lỗi).
  final String? errorMessage;

  bool get active => surahId != null;

  double? get progress {
    final d = duration;
    if (d == null || d.inMilliseconds == 0) return null;
    return (position.inMilliseconds / d.inMilliseconds).clamp(0.0, 1.0);
  }

  AudioState copyWith({
    int? surahId,
    int? currentIndex,
    bool? playing,
    double? speed,
    RepeatMode? repeat,
    Reciter? reciter,
    Duration? position,
    Duration? duration,
    bool? loading,
    String? errorMessage,
    bool clearError = false,
    bool clearDuration = false,
  }) {
    return AudioState(
      surahId: surahId ?? this.surahId,
      currentIndex: currentIndex ?? this.currentIndex,
      playing: playing ?? this.playing,
      speed: speed ?? this.speed,
      repeat: repeat ?? this.repeat,
      reciter: reciter ?? this.reciter,
      position: position ?? this.position,
      duration: clearDuration ? null : duration ?? this.duration,
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  static const AudioState idle = AudioState();
}

class AudioController extends Notifier<AudioState> {
  static const String kReciterPrefsKey = 'audio.reciter';

  final List<StreamSubscription<Object?>> _subs = [];
  int _playlistLength = 0;

  /// Nguồn đang phát — giữ lại để Thử lại sau lỗi mạng.
  List<Uri> _sources = const [];

  AyahAudioPlayer get _player => ref.read(ayahAudioPlayerProvider);

  @override
  AudioState build() {
    ref.onDispose(() {
      for (final s in _subs) {
        unawaited(s.cancel());
      }
      _subs.clear();
    });
    return AudioState.idle;
  }

  void _ensureSubscriptions() {
    if (_subs.isNotEmpty) return;
    _subs.addAll([
      _player.currentIndexStream.listen((index) {
        if (index != null && index != state.currentIndex) {
          // Ayah mới -> reset vị trí/thời lượng của thanh tiến độ.
          state = state.copyWith(
            currentIndex: index,
            position: Duration.zero,
            clearDuration: true,
          );
        }
      }),
      _player.playingStream.listen((playing) {
        if (playing != state.playing) {
          state = state.copyWith(playing: playing);
        }
      }),
      _player.positionStream.listen((position) {
        // Throttle ~300ms: đủ mượt cho thanh tiến độ, không spam
        // rebuild (thẻ Ayah chỉ watch qua select nên không bị ảnh
        // hưởng, đây là để nhẹ cho chính AudioBar).
        if ((position - state.position).abs() >
                const Duration(milliseconds: 300) ||
            position == Duration.zero) {
          state = state.copyWith(position: position);
        }
      }),
      _player.durationStream.listen((duration) {
        if (duration != state.duration) {
          state = state.copyWith(duration: duration);
        }
      }),
      _player.processingStream.listen((processing) {
        final loading = processing == AyahPlayerProcessing.loading;
        if (loading != state.loading) {
          state = state.copyWith(loading: loading);
        }
        // Hết playlist (repeat off) -> hiển thị nút phát lại.
        if (processing == AyahPlayerProcessing.completed && state.playing) {
          state = state.copyWith(playing: false);
        }
      }),
      _player.errorStream.listen((message) {
        state = state.copyWith(errorMessage: message, loading: false);
      }),
    ]);
  }

  /// Phát một Surah từ Ayah [startIndex].
  Future<void> playSurah({
    required int surahId,
    required List<Ayah> ayahs,
    int startIndex = 0,
  }) async {
    final reciter = await _resolveReciter();
    if (reciter == null || ayahs.isEmpty) return;

    _playlistLength = ayahs.length;
    _sources = [
      for (final a in ayahs)
        Uri.parse(
          buildAyahAudioUrl(
            template: reciter.audioUrlTemplate,
            surahId: surahId,
            ayahNumber: a.ayahNumber,
          ),
        ),
    ];

    _ensureSubscriptions();

    state = AudioState(
      surahId: surahId,
      currentIndex: startIndex,
      playing: true,
      speed: state.speed,
      repeat: state.repeat,
      reciter: reciter,
      loading: true,
    );

    await _player.setPlaylist(_sources, initialIndex: startIndex);
    await _player.setSpeed(state.speed);
    await _player.setRepeatMode(state.repeat);
    await _player.play();
  }

  /// Thử lại sau lỗi (mạng chập chờn...): nạp lại playlist tại
  /// đúng Ayah đang dở rồi phát tiếp.
  Future<void> retry() async {
    if (!state.active || _sources.isEmpty) return;
    state = state.copyWith(clearError: true, loading: true);
    await _player.setPlaylist(_sources, initialIndex: state.currentIndex);
    await _player.setSpeed(state.speed);
    await _player.setRepeatMode(state.repeat);
    await _player.play();
  }

  Future<void> togglePlayPause() async {
    if (!state.active) return;
    if (state.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
    state = state.copyWith(playing: !state.playing);
  }

  Future<void> nextAyah() async {
    if (!state.active) return;
    final next = state.currentIndex + 1;
    if (next >= _playlistLength) return; // đã ở Ayah cuối
    state = state.copyWith(currentIndex: next);
    await _player.seekToIndex(next);
  }

  Future<void> previousAyah() async {
    if (!state.active) return;
    final prev = state.currentIndex - 1;
    if (prev < 0) return;
    state = state.copyWith(currentIndex: prev);
    await _player.seekToIndex(prev);
  }

  /// Xoay vòng tốc độ: 0.75 -> 1.0 -> 1.25 -> 1.5 -> 2.0 -> 0.75.
  Future<void> cycleSpeed() async {
    final i = kPlaybackSpeeds.indexOf(state.speed);
    final next = kPlaybackSpeeds[(i + 1) % kPlaybackSpeeds.length];
    state = state.copyWith(speed: next);
    if (state.active) await _player.setSpeed(next);
  }

  /// Xoay vòng lặp: off -> one (lặp Ayah) -> all (lặp Surah) -> off.
  Future<void> cycleRepeat() async {
    final next =
        RepeatMode.values[(state.repeat.index + 1) % RepeatMode.values.length];
    state = state.copyWith(repeat: next);
    if (state.active) await _player.setRepeatMode(next);
  }

  Future<void> stop() async {
    await _player.stop();
    state = AudioState(speed: state.speed, repeat: state.repeat);
  }

  /// Đổi Qari — lưu bền; nếu đang phát thì giữ vị trí, nạp lại nguồn.
  Future<void> selectReciter(Reciter reciter) async {
    await ref
        .read(sharedPreferencesProvider)
        .setString(kReciterPrefsKey, reciter.code);
    state = state.copyWith(reciter: reciter);
  }

  Future<Reciter?> _resolveReciter() async {
    if (state.reciter != null) return state.reciter;
    final reciters = await ref.read(recitersProvider.future);
    if (reciters.isEmpty) return null;
    final saved =
        ref.read(sharedPreferencesProvider).getString(kReciterPrefsKey);
    return reciters.firstWhere(
      (r) => r.code == saved,
      orElse: () => reciters.first,
    );
  }
}

final audioControllerProvider =
    NotifierProvider<AudioController, AudioState>(AudioController.new);
