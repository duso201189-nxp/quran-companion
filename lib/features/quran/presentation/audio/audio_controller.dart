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

  /// Số thứ tự các Ayah của playlist đang phát — ĐẦU VÀO để dựng
  /// nguồn, không phải nguồn đã dựng.
  ///
  /// Sprint 28.1 — trước đây lưu `List<Uri> _sources` (kết quả đã
  /// dựng SẴN từ Qari lúc bắt đầu phát). Vì URL đã "đóng băng" Qari,
  /// đổi Qari giữa chừng không thể có tác dụng, và [retry] cũng nạp
  /// lại đúng giọng cũ. Lưu đầu vào thay vì kết quả dẫn xuất là điều
  /// kiện cần để [_sourcesFor] luôn sinh URL theo Qari HIỆN TẠI.
  ///
  /// Cũng chính là độ dài playlist (mỗi Ayah một nguồn) — Sprint 28.0
  /// đã bỏ biến `_playlistLength` song song.
  ///
  /// Để riêng (không đưa vào [AudioState]): không widget nào cần đọc
  /// danh sách này, và `List` so sánh theo tham chiếu nên đưa vào
  /// state sẽ phá vỡ `select()` của thanh phát.
  List<int> _ayahNumbers = const [];

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

  /// NƠI DUY NHẤT dựng URL nguồn — mọi lần nạp đều đi qua đây, nên
  /// không thể tồn tại một playlist "dựng theo Qari cũ".
  List<Uri> _sourcesFor(Reciter reciter, int surahId) {
    return [
      for (final ayahNumber in _ayahNumbers)
        Uri.parse(
          buildAyahAudioUrl(
            template: reciter.audioUrlTemplate,
            surahId: surahId,
            ayahNumber: ayahNumber,
          ),
        ),
    ];
  }

  /// NƠI DUY NHẤT nạp nguồn xuống engine — dùng chung bởi [playSurah],
  /// [retry] và [selectReciter] (Sprint 28.1). Trước đây [playSurah]
  /// và [retry] mỗi bên tự lặp lại đúng bốn lệnh này; thêm đường nạp
  /// thứ ba cho việc đổi Qari sẽ thành ba bản sao.
  ///
  /// [play] = false: nạp xong vẫn giữ trạng thái tạm dừng — dùng khi
  /// người dùng đổi Qari trong lúc đang tạm dừng.
  Future<void> _load({
    required Reciter reciter,
    required int surahId,
    required int index,
    Duration position = Duration.zero,
    required bool play,
  }) async {
    await _player.setPlaylist(
      _sourcesFor(reciter, surahId),
      initialIndex: index,
      initialPosition: position,
    );
    await _player.setSpeed(state.speed);
    await _player.setRepeatMode(state.repeat);
    if (play) await _player.play();
  }

  /// Phát một Surah từ Ayah [startIndex].
  Future<void> playSurah({
    required int surahId,
    required List<Ayah> ayahs,
    int startIndex = 0,
  }) async {
    final reciter = await _resolveReciter();
    if (reciter == null || ayahs.isEmpty) return;

    _ayahNumbers = [for (final a in ayahs) a.ayahNumber];

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

    await _load(
      reciter: reciter,
      surahId: surahId,
      index: startIndex,
      play: true,
    );
  }

  /// Thử lại sau lỗi (mạng chập chờn...): nạp lại playlist tại
  /// đúng Ayah đang dở rồi phát tiếp.
  ///
  /// Sprint 28.1 — dựng lại nguồn theo Qari HIỆN TẠI trong state. Bản
  /// cũ phát lại `_sources` đã đóng băng, nên sau khi đổi Qari thì
  /// "Thử lại" vẫn nạp giọng cũ.
  Future<void> retry() async {
    final reciter = state.reciter;
    final surahId = state.surahId;
    if (reciter == null || surahId == null || _ayahNumbers.isEmpty) return;
    state = state.copyWith(clearError: true, loading: true, playing: true);
    await _load(
      reciter: reciter,
      surahId: surahId,
      index: state.currentIndex,
      play: true,
    );
  }

  /// Phát / tạm dừng.
  ///
  /// Sprint 28.0 — chốt ý định TRƯỚC `await`, đúng khuôn mọi phương
  /// thức khác của lớp này ([nextAyah], [cycleSpeed], [playSurah]:
  /// đặt state rồi mới gọi engine).
  ///
  /// Bản cũ tính `!state.playing` SAU `await _player.pause()`. Trong
  /// khoảng chờ đó `playingStream` đã kịp đặt `playing = false`, nên
  /// phép phủ định lật NGƯỢC lại thành `true`: engine dừng nhưng
  /// thanh phát vẫn báo "đang phát", và mọi lần bấm sau đó lặp lại
  /// đúng vòng đó -> không bao giờ phát tiếp được. Xem test
  /// `audio_controller_test.dart` ("togglePlayPause ...").
  Future<void> togglePlayPause() async {
    if (!state.active) return;
    final wasPlaying = state.playing;
    // Cập nhật lạc quan: UI đổi icon ngay. Stream sau đó chỉ xác nhận
    // (listener có guard `!=` nên không sinh state thừa).
    state = state.copyWith(playing: !wasPlaying);
    if (wasPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> nextAyah() async {
    if (!state.active) return;
    final next = state.currentIndex + 1;
    if (next >= _ayahNumbers.length) return; // đã ở Ayah cuối
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
  ///
  /// Sprint 28.1 — phần "nạp lại nguồn" của hợp đồng này trước đây
  /// KHÔNG được thực hiện: hàm chỉ lưu prefs và đổi nhãn, còn engine
  /// vẫn chạy playlist dựng theo Qari cũ, nên người dùng đổi giọng mà
  /// tiếng không đổi. Nay nạp lại thật qua [_load] dùng chung.
  ///
  /// Giữ nguyên: Surah, chỉ số Ayah, vị trí trong Ayah (nhờ
  /// `initialPosition`), tốc độ, chế độ lặp, và trạng thái phát/tạm
  /// dừng — đổi giọng KHÔNG được tự ý phát khi đang tạm dừng.
  Future<void> selectReciter(Reciter reciter) async {
    // Luôn lưu bền, kể cả khi chọn lại đúng Qari đang dùng: lần đầu
    // Qari đến từ mặc định (`_resolveReciter`) chứ chưa có trong prefs.
    await ref
        .read(sharedPreferencesProvider)
        .setString(kReciterPrefsKey, reciter.code);

    // Chọn lại chính Qari đang nghe -> không nạp lại. `RadioListTile`
    // vẫn gọi onChanged khi chạm mục đã chọn; nạp lại ở đây sẽ cắt
    // ngang tiếng đọc mà người dùng không hề yêu cầu đổi gì.
    if (reciter.code == state.reciter?.code) return;

    final surahId = state.surahId;
    if (surahId == null || _ayahNumbers.isEmpty) {
      // Chưa phát gì: chỉ ghi nhớ lựa chọn, lần phát sau sẽ dùng.
      state = state.copyWith(reciter: reciter);
      return;
    }

    final wasPlaying = state.playing;
    final position = state.position;
    state = state.copyWith(reciter: reciter, loading: true, clearError: true);
    await _load(
      reciter: reciter,
      surahId: surahId,
      index: state.currentIndex,
      position: position,
      play: wasPlaying,
    );
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
