import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/audio/ayah_audio_item.dart';
import 'package:quran_companion/core/audio/ayah_audio_player.dart';
import 'package:quran_companion/core/audio/quran_audio_handler.dart';
import 'package:quran_companion/core/quran/quran_address.dart';

import 'fixtures/fake_audio_player.dart';

/// Sprint B1 — phần QUYẾT ĐỊNH ĐƯỢC của tích hợp phát nền.
///
/// Việc "audio có tiếp tục phát khi khoá màn hình không" chỉ trả lời
/// được trên thiết bị thật (roadmap B4). Nhưng gần như mọi thứ KHÁC thì
/// kiểm được ngay ở đây: nội dung hiện trên màn hình khoá, nút nào
/// sáng, và nút bấm có nối đúng xuống trình phát hay không.
///
/// Ranh giới thật hoá ra hẹp hơn dự đoán ban đầu: `BaseAudioHandler`
/// dựng được trong test thường vì nó chỉ tạo vài `BehaviorSubject`.
/// Chỉ `AudioService.init()` mới cần nền tảng thật — và nó thuộc
/// Phase 2.
void main() {
  final item = AyahAudioItem(
    address: QuranAddress.ayah(2, 255),
    source: Uri.parse('https://a.test/002255.mp3'),
    surahName: 'Al-Baqarah',
    reciterName: 'Alafasy',
  );

  group('B1 — mô tả cho thông báo hệ điều hành', () {
    test('màn hình khoá hiện số Ayah, tên Surah, tên Qari', () {
      final media = mediaItemFor(item);

      expect(media.title, 'Ayah 255');
      expect(media.album, 'Al-Baqarah');
      expect(media.artist, 'Alafasy');
    });

    test('danh tính là ĐỊA CHỈ, không phải URL', () {
      // URL đổi khi người dùng đổi Qari; địa chỉ thì không. Dùng URL
      // làm id nghĩa là cùng một Ayah có hai danh tính khác nhau tuỳ
      // Qari — sai ngay khi ai đó đổi giọng đọc giữa chừng.
      expect(mediaItemFor(item).id, '2:255');

      final otherReciter = AyahAudioItem(
        address: QuranAddress.ayah(2, 255),
        source: Uri.parse('https://h.test/002255.mp3'),
        surahName: 'Al-Baqarah',
        reciterName: 'Husary',
      );
      expect(mediaItemFor(otherReciter).id, mediaItemFor(item).id);
    });

    test('số Ayah là số 1-based người đọc thấy, không phải chỉ số', () {
      // Ayah 1 phải hiện "Ayah 1", không phải "Ayah 0".
      final first = AyahAudioItem(
        address: QuranAddress.ayah(2, 1),
        source: Uri.parse('https://a.test/002001.mp3'),
        surahName: 'Al-Baqarah',
        reciterName: 'Alafasy',
      );
      expect(mediaItemFor(first).title, 'Ayah 1');
    });
  });

  /// Phần nối dây — hoá ra KHÔNG cần thiết bị: `BaseAudioHandler` chỉ
  /// dựng vài `BehaviorSubject`, không đụng kênh nền tảng. Chỉ
  /// `AudioService.init()` mới cần, và nó thuộc Phase 2.
  ///
  /// Đây là phần dễ sai nhất của B1: nếu nút trên thông báo không nối
  /// đúng xuống trình phát, người dùng bấm mà không có gì xảy ra — và
  /// không có gì trong `flutter analyze` bắt được điều đó.
  group('B1 — nút trên thông báo nối xuống trình phát', () {
    late FakeAyahAudioPlayer player;
    late QuranAudioHandler handler;

    Future<void> settle() => Future<void>.delayed(Duration.zero);

    setUp(() {
      player = FakeAyahAudioPlayer();
      handler = QuranAudioHandler(player);
    });

    tearDown(() async {
      await handler.close();
      await player.dispose();
    });

    test('Phát / Tạm dừng / Dừng gọi đúng lệnh trên trình phát', () async {
      await handler.play();
      expect(player.playing, isTrue);

      await handler.pause();
      expect(player.playing, isFalse);

      await handler.stop();
      expect(player.stopped, isTrue);
    });

    test('Ayah kế / Ayah trước nhảy đúng chỉ số', () async {
      player.indexController.add(2);
      await settle();

      await handler.skipToNext();
      expect(player.seekedTo, 3);

      await handler.skipToPrevious();
      expect(player.seekedTo, 1);
    });

    test('Ayah trước ở đầu playlist KHÔNG lùi về số âm', () async {
      player.indexController.add(0);
      await settle();

      await handler.skipToPrevious();

      // Hệ điều hành vẫn vẽ nút và người dùng vẫn bấm được; -1 sẽ là
      // một lệnh seek hỏng.
      expect(player.seekedTo, 0);
    });

    test('Ayah mới -> thông báo đổi nội dung theo', () async {
      player.itemController.add(item);
      await settle();

      expect(handler.mediaItem.value?.title, 'Ayah 255');
      expect(handler.mediaItem.value?.album, 'Al-Baqarah');
    });

    test('hết playlist -> thông báo trống, không giữ Ayah cũ', () async {
      player.itemController.add(item);
      await settle();
      player.itemController.add(null);
      await settle();

      expect(handler.mediaItem.value, isNull);
    });

    test('đang phát/dừng phản ánh vào trạng thái thông báo', () async {
      player.playingController.add(true);
      await settle();
      expect(handler.playbackState.value.playing, isTrue);
      expect(
        handler.playbackState.value.controls,
        contains(MediaControl.pause),
      );

      player.playingController.add(false);
      await settle();
      expect(handler.playbackState.value.playing, isFalse);
      expect(handler.playbackState.value.controls, contains(MediaControl.play));
    });

    test('nhạc đã chạy TRƯỚC khi adapter dựng -> vẫn bắt được Ayah hiện tại',
        () async {
      // Stream broadcast không phát lại giá trị cũ, nên nếu chỉ nghe
      // stream thì thông báo sẽ trống cho tới Ayah kế tiếp. Đây là lý
      // do `AyahAudioPlayer` có getter đồng bộ `currentItem`.
      final late_ = FakeAyahAudioPlayer();
      await late_.setPlaylist([item]);
      final lateHandler = QuranAudioHandler(late_);
      addTearDown(() async {
        await lateHandler.close();
        await late_.dispose();
      });

      expect(lateHandler.mediaItem.value?.title, 'Ayah 255');
    });
  });

  group('B1 — trạng thái phát cho thông báo', () {
    PlaybackState stateWith({
      required bool playing,
      AyahPlayerProcessing processing = AyahPlayerProcessing.ready,
      Duration position = Duration.zero,
      int index = 0,
    }) =>
        playbackStateFor(
          playing: playing,
          processing: processing,
          position: position,
          index: index,
        );

    test('đang phát -> nút Tạm dừng; đang dừng -> nút Phát', () {
      expect(
        stateWith(playing: true).controls,
        contains(MediaControl.pause),
      );
      expect(
        stateWith(playing: true).controls,
        isNot(contains(MediaControl.play)),
      );
      expect(
        stateWith(playing: false).controls,
        contains(MediaControl.play),
      );
    });

    test('luôn có nút Ayah trước / Ayah kế', () {
      for (final playing in [true, false]) {
        final controls = stateWith(playing: playing).controls;
        expect(controls, contains(MediaControl.skipToPrevious));
        expect(controls, contains(MediaControl.skipToNext));
      }
    });

    test('bốn trạng thái xử lý ánh xạ đúng, không nhập nhằng', () {
      expect(
        stateWith(playing: false, processing: AyahPlayerProcessing.idle)
            .processingState,
        AudioProcessingState.idle,
      );
      expect(
        stateWith(playing: true, processing: AyahPlayerProcessing.loading)
            .processingState,
        AudioProcessingState.loading,
      );
      expect(
        stateWith(playing: true, processing: AyahPlayerProcessing.ready)
            .processingState,
        AudioProcessingState.ready,
      );
      expect(
        stateWith(playing: false, processing: AyahPlayerProcessing.completed)
            .processingState,
        AudioProcessingState.completed,
      );
    });

    test('vị trí và chỉ số hàng đợi được chuyển tiếp nguyên vẹn', () {
      final state = stateWith(
        playing: true,
        position: const Duration(seconds: 12),
        index: 4,
      );

      expect(state.updatePosition, const Duration(seconds: 12));
      expect(state.queueIndex, 4);
      expect(state.playing, isTrue);
    });
  });
}
