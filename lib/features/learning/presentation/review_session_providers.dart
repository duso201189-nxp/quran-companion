import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../quran/data/quran_providers.dart';
import '../../quran/domain/entities/ayah_search_result.dart';
import '../data/scheduler_providers.dart';
import '../domain/entities/srs_card.dart';

/// Một mục ôn tập hiển thị trên màn hình: thẻ SRS + nội dung Ayah đã
/// giải quyết (Arabic/bản dịch). Kết hợp dữ liệu từ 2 repository độc
/// lập (Scheduler + Quran nội dung) — đúng vai trò tầng Provider
/// (DR-2026-0005).
typedef ReviewSessionItem = ({SrsCard card, AyahSearchResult ayah});

/// Mục ôn tập hiện tại — luôn là thẻ đầu tiên của dueReviewCardsProvider
/// (đã sắp theo hạn gần nhất, ổn định, không trùng lặp — Phase 2), với
/// nội dung Ayah đã giải quyết để hiển thị. null = đã ôn hết (hoặc
/// chưa từng có thẻ nào đến hạn) -> màn hình hoàn tất.
///
/// Không chứa logic scheduling — chỉ chọn phần tử đầu tiên và giải
/// quyết nội dung hiển thị (tầng Provider, không phải Repository).
final currentReviewItemProvider =
    FutureProvider.autoDispose<ReviewSessionItem?>((ref) async {
  final dueCards = await ref.watch(dueReviewCardsProvider.future);
  if (dueCards.isEmpty) return null;

  final card = dueCards.first;
  final results =
      await ref.watch(quranRepositoryProvider).getAyahsByIds([card.itemId]);
  if (results.isEmpty) return null;

  return (card: card, ayah: results.first);
});
