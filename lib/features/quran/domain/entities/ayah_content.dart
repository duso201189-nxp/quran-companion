import 'ayah.dart';

/// Một Ayah kèm toàn bộ lớp văn bản đang bật (dịch, phiên âm...).
class AyahContent {
  const AyahContent({required this.ayah, required this.texts});

  final Ayah ayah;

  /// key = code của TranslationSource ('vi_main', 'en_sahih'...),
  /// value = văn bản của Ayah theo nguồn đó.
  final Map<String, String> texts;
}
