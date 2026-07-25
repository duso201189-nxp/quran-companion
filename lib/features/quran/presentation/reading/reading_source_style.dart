import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/translation_source.dart';

/// Cách trình bày MỘT lớp văn bản đi kèm Ayah, suy ra từ metadata của
/// nguồn — không từ tên tính năng (Sprint 30.1).
///
/// Đầu vào CHỈ gồm hai thứ, đúng hợp đồng `DR-2026-0006` D3:
///   - [SourceType]  : phiên âm / bản dịch / tafsir
///   - ngôn ngữ      : của nguồn, so với ngôn ngữ giao diện
///
/// Nhờ vậy một nguồn Tafsir hay một bản dịch mới nhập vào database sẽ
/// tự có kiểu chữ và hướng chữ hợp lý mà KHÔNG phải sửa `AyahCard`.
///
/// Vì sao "cùng ngôn ngữ với giao diện" là trục thứ hai chứ không phải
/// mã nguồn hay `display_order`: bản dịch theo đúng tiếng người dùng
/// đang dùng app là bản họ ĐỌC, các bản còn lại là để đối chiếu. Đó
/// cũng chính là điều mã cũ diễn đạt bằng cách ép cứng `vi_main` cỡ
/// 18/onSurface và `en_sahih` cỡ 16/onSurfaceVariant — cùng kết quả,
/// nhưng nay là một quy tắc thay vì một danh sách.
class ReadingLayerStyle {
  const ReadingLayerStyle({
    required this.textStyle,
    required this.textDirection,
    required this.textAlign,
  });

  final TextStyle textStyle;
  final TextDirection textDirection;
  final TextAlign textAlign;
}

/// Dựng cách trình bày cho [source] trong bảng màu [scheme].
///
/// [appLanguage] là mã ngôn ngữ giao diện hiện tại (vd 'vi').
ReadingLayerStyle readingLayerStyle({
  required TranslationSource source,
  required ColorScheme scheme,
  required String appLanguage,
}) {
  // Hướng chữ suy ra từ NGÔN NGỮ của nguồn (`TranslationSource.isRtl`),
  // không mặc định LTR. Trước Sprint 30.1 mọi lớp dịch đều bị ép
  // `TextDirection.ltr`, nên một nguồn tiếng Ả Rập/Ba Tư/Urdu — khả
  // năng cao là nguồn Tafsir đầu tiên — sẽ hiển thị sai hướng.
  final direction = source.isRtl ? TextDirection.rtl : TextDirection.ltr;
  final align = source.isRtl ? TextAlign.right : TextAlign.left;

  final style = switch (source.type) {
    // Phiên âm: chữ phụ, nghiêng, mờ hơn — chỉ để dò cách đọc.
    SourceType.transliteration => TextStyle(
        fontFamily: AppTheme.latinFont,
        fontStyle: FontStyle.italic,
        fontSize: 15,
        height: 1.55,
        letterSpacing: 0.2,
        color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
      ),

    // Bản dịch theo đúng ngôn ngữ giao diện: bản chính, dễ đọc nhất.
    SourceType.translation when source.language == appLanguage => TextStyle(
        fontFamily: AppTheme.latinFont,
        fontSize: 18,
        height: 1.7,
        color: scheme.onSurface,
      ),

    // Bản dịch ngôn ngữ khác: bản đối chiếu, nhẹ hơn một bậc.
    SourceType.translation => TextStyle(
        fontFamily: AppTheme.latinFont,
        fontSize: 16,
        height: 1.6,
        color: scheme.onSurfaceVariant,
      ),

    // Tafsir: khối chú giải dài -> cỡ nhỏ hơn bản dịch chính và giãn
    // dòng rộng để đọc đoạn dài đỡ mỏi.
    SourceType.tafsir => TextStyle(
        fontFamily: AppTheme.latinFont,
        fontSize: 15,
        height: 1.75,
        color: scheme.onSurfaceVariant,
      ),
  };

  return ReadingLayerStyle(
    textStyle: style,
    textDirection: direction,
    textAlign: align,
  );
}
