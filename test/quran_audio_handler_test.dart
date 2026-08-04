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

  /// Playlist [count] Ayah đầu của Al-Baqarah.
  List<AyahAudioItem> playlistOf(int count) => [
        for (var n = 1; n <= count; n++)
          AyahAudioItem(
            address: QuranAddress.ayah(2, n),
            source: Uri.parse('https://a.test/002-$n.mp3'),
            surahName: 'Al-Baqarah',
            reciterName: 'Alafasy',
          ),
      ];

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

    /// Sprint BM4 — lỗi tìm thấy khi chạy trên máy Android thật.
    ///
    /// Tái hiện: mở Al-Kahf, bấm nút phát của HÀNG MỞ ĐẦU, đọc
    /// `adb shell dumpsys media_session` trong lúc Basmalah còn đang
    /// phát. Trước bản sửa:
    ///
    ///     active item id=0
    ///     metadata: description=Ayah null, Mishary Rashid Alafasy, Al-Kahf
    ///
    /// Tức màn hình khoá hiện đúng chữ "Ayah null". Lỗi sinh ra ở BM1
    /// (mục mở đầu mang địa chỉ mức Surah) nhưng nằm trong hàm của B1,
    /// vốn viết khi mọi mục phát đều là Ayah nên `.ayah` không bao giờ
    /// null.
    group('BM4 — mục mở đầu có tên riêng trên thông báo', () {
      test('địa chỉ mức Surah -> "Bismillah", KHÔNG phải "Ayah null"', () {
        final opening = AyahAudioItem(
          address: QuranAddress.surah(18),
          source: Uri.parse('https://a.test/001001.mp3'),
          surahName: 'Al-Kahf',
          reciterName: 'Alafasy',
        );

        final media = mediaItemFor(opening);

        expect(media.title, 'Bismillah');
        expect(media.title, isNot(contains('null')));
        // Surah và Qari vẫn hiện như mọi mục khác.
        expect(media.album, 'Al-Kahf');
        expect(media.artist, 'Alafasy');
        // Danh tính là địa chỉ mức Surah.
        expect(media.id, '18');
      });

      test('địa chỉ mức Ayah vẫn hiện số Ayah như cũ', () {
        expect(mediaItemFor(item).title, 'Ayah 255');
      });
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
      // Sprint B2: phải nạp playlist trước. Trước B2, `skipToNext` cộng
      // 1 vô điều kiện nên test này chạy được với hàng đợi rỗng — đó
      // chính là lỗi B2 đi sửa, không phải một tiện lợi của test.
      await player.setPlaylist(playlistOf(5));
      player.indexController.add(2);
      await settle();

      await handler.skipToNext();
      expect(player.seekedTo, 3);

      await handler.skipToPrevious();
      expect(player.seekedTo, 1);
    });

    test('Ayah kế ở CUỐI playlist KHÔNG nhảy ra ngoài', () async {
      await player.setPlaylist(playlistOf(3));
      player.indexController.add(2); // mục cuối
      await settle();

      await handler.skipToNext();

      // Không seek gì cả. Kẹp về chính mục cuối cũng sai: nó phát lại
      // từ đầu đúng Ayah người dùng đang nghe. Im lặng là đúng, và là
      // cách mọi trình phát nhạc hành xử ở cuối danh sách.
      expect(player.seekedTo, isNull);
    });

    test('chưa nạp playlist -> Ayah kế không làm gì', () async {
      player.indexController.add(0);
      await settle();

      await handler.skipToNext();

      expect(player.seekedTo, isNull);
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

  /// Sprint B2 — hàng đợi. Nó phục vụ hai việc, và việc thứ hai mới là
  /// lý do nó tồn tại ở sprint này: hàng đợi là NGUỒN DUY NHẤT biết
  /// playlist dài bao nhiêu, nên `skipToNext` chặn biên dựa vào nó.
  group('B2 — hàng đợi cho thông báo', () {
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

    test('nạp playlist -> hàng đợi đủ mục, đúng thứ tự đọc', () async {
      await player.setPlaylist(playlistOf(3));
      await settle();

      expect(
        handler.queue.value.map((m) => m.id).toList(),
        ['2:1', '2:2', '2:3'],
      );
    });

    test('nạp playlist mới -> hàng đợi THAY hẳn, không cộng dồn', () async {
      await player.setPlaylist(playlistOf(3));
      await settle();
      await player.setPlaylist(playlistOf(2));
      await settle();

      expect(handler.queue.value, hasLength(2));
    });

    test('playlist nạp TRƯỚC khi adapter dựng -> hàng đợi vẫn đầy', () async {
      // Cùng lý do như currentItem: stream broadcast không phát lại giá
      // trị cũ, nên phải hỏi thẳng trình phát một lần lúc dựng.
      final started = FakeAyahAudioPlayer();
      await started.setPlaylist(playlistOf(4));
      final lateHandler = QuranAudioHandler(started);
      addTearDown(() async {
        await lateHandler.close();
        await started.dispose();
      });

      expect(lateHandler.queue.value, hasLength(4));
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

    /// Sprint B3 — lỗi tìm thấy khi chạy trên máy Android thật (emulator
    /// API 37), không phải giả định.
    ///
    /// Tái hiện: phát hết một Surah rồi để yên. Trước bản sửa, thông báo
    /// còn lại nút "Tạm dừng" cho thứ đã im, KHÔNG vuốt bỏ được, và
    /// foreground service bị giữ vô thời hạn — xác nhận bằng
    /// `dumpsys notification` (`flags=ONGOING_EVENT|NO_CLEAR|NO_DISMISS`,
    /// action `[1] "Pause"`) và `dumpsys activity services`
    /// (`isForeground=true`).
    ///
    /// Nguyên nhân: `playing` của just_audio nghĩa là "đã được lệnh
    /// phát", không phải "đang ra tiếng", nên nó vẫn `true` sau khi hết
    /// playlist. `AudioController` đã tự chữa từ lâu; adapter thông báo
    /// thì chưa — hai bên nói khác nhau về cùng một trình phát.
    group('B3 — hết playlist thì KHÔNG còn là đang phát', () {
      test('completed + playing=true -> thông báo hiện nút PHÁT', () {
        final state = playbackStateFor(
          playing: true, // just_audio vẫn báo true sau khi hết
          processing: AyahPlayerProcessing.completed,
          position: const Duration(seconds: 13),
          index: 6,
        );

        expect(state.playing, isFalse);
        expect(state.controls, contains(MediaControl.play));
        expect(state.controls, isNot(contains(MediaControl.pause)));
      });

      test('completed vẫn được báo đúng là completed', () {
        // Sửa cờ `playing` KHÔNG được nuốt mất trạng thái xử lý: hệ
        // điều hành cần biết đây là "hết bài", không phải "tạm dừng".
        expect(
          playbackStateFor(
            playing: true,
            processing: AyahPlayerProcessing.completed,
            position: Duration.zero,
            index: 6,
          ).processingState,
          AudioProcessingState.completed,
        );
      });

      test('đang phát bình thường KHÔNG bị ảnh hưởng', () {
        final state = playbackStateFor(
          playing: true,
          processing: AyahPlayerProcessing.ready,
          position: Duration.zero,
          index: 0,
        );

        expect(state.playing, isTrue);
        expect(state.controls, contains(MediaControl.pause));
      });
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
