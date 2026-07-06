/// Dựng URL audio một Ayah từ mẫu trong bảng `reciters`.
///
/// Mẫu dùng {sss} = số Surah 3 chữ số, {aaa} = số Ayah 3 chữ số:
///   https://everyayah.com/data/Alafasy_128kbps/{sss}{aaa}.mp3
///   -> Surah 2, Ayah 45: .../002045.mp3
String buildAyahAudioUrl({
  required String template,
  required int surahId,
  required int ayahNumber,
}) {
  return template
      .replaceAll('{sss}', surahId.toString().padLeft(3, '0'))
      .replaceAll('{aaa}', ayahNumber.toString().padLeft(3, '0'));
}

/// Tên file cache cục bộ cho một Ayah (thống nhất mọi nơi).
String ayahCacheFileName(int surahId, int ayahNumber) =>
    '${surahId.toString().padLeft(3, '0')}'
    '${ayahNumber.toString().padLeft(3, '0')}.mp3';
