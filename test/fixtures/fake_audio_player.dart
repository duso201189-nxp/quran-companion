import 'dart:async';

import 'package:quran_companion/core/audio/ayah_audio_player.dart';

/// Trình phát giả cho test: ghi lại mọi lệnh, phát stream điều
/// khiển được — không cần thiết bị audio thật.
class FakeAyahAudioPlayer implements AyahAudioPlayer {
  final indexController = StreamController<int?>.broadcast();
  final playingController = StreamController<bool>.broadcast();
  final positionController = StreamController<Duration>.broadcast();
  final durationController = StreamController<Duration?>.broadcast();
  final processingController =
      StreamController<AyahPlayerProcessing>.broadcast();
  final errorController = StreamController<String>.broadcast();

  List<Uri> playlist = const [];
  int initialIndex = 0;
  bool playing = false;
  double speed = 1.0;
  RepeatMode repeatMode = RepeatMode.off;
  int? seekedTo;
  bool stopped = false;

  @override
  Stream<int?> get currentIndexStream => indexController.stream;

  @override
  Stream<bool> get playingStream => playingController.stream;

  @override
  Stream<Duration> get positionStream => positionController.stream;

  @override
  Stream<Duration?> get durationStream => durationController.stream;

  @override
  Stream<AyahPlayerProcessing> get processingStream =>
      processingController.stream;

  @override
  Stream<String> get errorStream => errorController.stream;

  @override
  Future<void> setPlaylist(List<Uri> sources, {int initialIndex = 0}) async {
    playlist = sources;
    this.initialIndex = initialIndex;
    processingController.add(AyahPlayerProcessing.loading);
  }

  @override
  Future<void> play() async {
    playing = true;
    // Mô phỏng engine thật: nạp xong -> ready (UI tắt vòng xoay).
    processingController.add(AyahPlayerProcessing.ready);
    playingController.add(true);
  }

  @override
  Future<void> pause() async {
    playing = false;
    playingController.add(false);
  }

  @override
  Future<void> seekToIndex(int index) async => seekedTo = index;

  @override
  Future<void> setSpeed(double value) async => speed = value;

  @override
  Future<void> setRepeatMode(RepeatMode mode) async => repeatMode = mode;

  @override
  Future<void> stop() async {
    stopped = true;
    playing = false;
  }

  @override
  Future<void> dispose() async {
    await indexController.close();
    await playingController.close();
    await positionController.close();
    await durationController.close();
    await processingController.close();
    await errorController.close();
  }
}
