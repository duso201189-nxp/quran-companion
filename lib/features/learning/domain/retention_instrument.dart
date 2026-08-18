import 'entities/retention_observation.dart';
import 'entities/srs_card.dart';
import 'repositories/retention_event_source_repository.dart';
import 'scheduling_algorithm.dart';

/// Suy dẫn quan sát ghi nhớ từ danh sách sự kiện đã đọc sẵn —
/// Sprint D7.8 (DR-2026-0027, đã `accepted`).
///
/// THUẦN DART: không Flutter, không Riverpod, không Drift, không
/// `dart:io`. KHÔNG tự truy vấn. KHÔNG BAO GIỜ đọc đồng hồ hệ thống —
/// không `DateTime.now()`, không nguồn thời gian ngầm, không giá trị
/// mặc định giấu kín, không tham số `asOfMs` tuỳ chọn có đường lùi về
/// đồng hồ. [asOfMs] là tham số `required` epoch ms UTC do nơi gọi
/// cung cấp — cùng kỷ luật `computeHifzReviewHistory`/
/// `computeHifzPlanProgress`/`SchedulingAlgorithm` đã lập. Một hàm
/// tính toán có đọc đồng hồ thì không kiểm thử tất định được và không
/// suy luận được qua các múi giờ hay mốc đổi giờ.
///
/// [asOfMs] là `int` chứ không phải `DateTime` vì công cụ này KHÔNG hề
/// làm số học lịch: nó không tạo ra ngày, tuần, tháng hay `DateTime`
/// nào, chỉ so sánh và trừ epoch ms. Do đó không có hành vi múi giờ
/// nào phải đặc tả, không có trường hợp biên đổi giờ nào phải kiểm, và
/// không phụ thuộc locale — KHÁC HẲN D6.11, vốn chia mốc theo ngày
/// lịch ĐỊA PHƯƠNG. Mọi diễn giải theo lịch thuộc về nơi gọi tương lai.
///
/// [events] là các sự kiện thuộc MỘT phạm vi đã đọc sẵn (nơi gọi đã
/// lọc theo `item_type` và tập `item_id`). Hàm này KHÔNG giả định đầu
/// vào đã sắp xếp: nó tự sắp lại ỔN ĐỊNH nên vẫn đúng khi đứng một
/// mình, không âm thầm phụ thuộc nơi gọi.
///
/// KHÔNG BAO GIỜ ném lỗi vì NỘI DUNG dữ liệu: một dòng có `grade` hay
/// trạng thái lạ sẽ bị đếm là không hợp lệ và loại ra, chứ không phá
/// huỷ việc suy dẫn của mọi mục khác (DR-2026-0027 Quyết định mở #2,
/// giải theo hướng "loại kèm bộ đếm" thay vì "ném lỗi"). Lỗi ĐỐI SỐ
/// (vd. đầu vào null-safety sai) là chuyện khác và không bị bắt ở đây.
RetentionDerivation deriveRetentionObservations({
  required List<RetentionSourceEvent> events,
  required int asOfMs,
}) {
  final eligible = <RetentionSourceEvent>[];
  var excludedAsFuture = 0;
  var excludedAsIneligible = 0;

  for (final event in events) {
    // BƯỚC 1 — hợp lệ. Chuỗi lạ KHÔNG BAO GIỜ được ép về mặc định:
    // trong đường đọc-và-đo, một fallback im lặng sẽ BỊA RA bằng chứng
    // (xem doc `RetentionSourceEvent.beforeStateRaw`).
    if (_gradeFromRaw(event.gradeRaw) == null ||
        _stateFromRaw(event.beforeStateRaw) == null ||
        _stateFromRaw(event.afterStateRaw) == null) {
      excludedAsIneligible++;
      continue;
    }

    // BƯỚC 2 — loại sự kiện TƯƠNG LAI, TRƯỚC khi sắp xếp, ghép cặp hay
    // kiểm liên tục. Một quan sát không bao giờ được hình thành nhờ
    // bằng chứng chưa tồn tại tại thời điểm quan sát đã nêu; nếu không
    // thì công cụ không dùng để suy luận về bất kỳ mốc quá khứ nào
    // được, và test trên fixture cố định sẽ không tái lập được.
    //
    // Biên: `reviewedAtMs == asOfMs` được TÍNH VÀO — `asOfMs` bao gồm
    // chính khoảnh khắc của nó, cùng quy ước nửa khoảng [đầu, cuối) mà
    // `computeHifzReviewHistory` đã dùng cho mốc dưới.
    if (event.reviewedAtMs > asOfMs) {
      excludedAsFuture++;
      continue;
    }

    eligible.add(event);
  }

  // BƯỚC 3 — gom nhóm theo `(itemType, itemId)`. KHÔNG gom theo
  // `card_id`: ordinal Ayah cố định vĩnh viễn theo Mushaf, còn tính
  // liên tục của `card_id` phụ thuộc cách `syncItemsForType` hồi sinh
  // thẻ. `card_id` là ĐIỀU KIỆN liên tục (số hạng 3), không phải khoá
  // gom nhóm.
  //
  // `ayah` và `hifz` của CÙNG một ordinal rơi vào HAI nhóm khác nhau:
  // `UNIQUE(item_type, item_id)` của `srs_cards` khiến mỗi cặp là một
  // thẻ riêng, nên ôn tập thường và học thuộc có hai lịch trình độc
  // lập theo đúng thiết kế.
  final groups = <(RetentionItemScope, int), List<RetentionSourceEvent>>{};
  for (final event in eligible) {
    groups.putIfAbsent((event.itemType, event.itemId), () => []).add(event);
  }

  // Thứ tự nhóm TẤT ĐỊNH: theo chỉ số `itemType` rồi tới `itemId` tăng
  // dần. Cố ý sắp theo ĐỊNH DANH chứ không theo bất kỳ phẩm chất ghi
  // nhớ nào, để kết quả không bao giờ đọc được như một bảng xếp hạng.
  final groupKeys = groups.keys.toList()
    ..sort((a, b) {
      final byType = a.$1.index.compareTo(b.$1.index);
      return byType != 0 ? byType : a.$2.compareTo(b.$2);
    });

  final observations = <RetentionObservation>[];
  final discontinuities = <RetentionDiscontinuity>[];

  for (final key in groupKeys) {
    // BƯỚC 4 — sắp ỔN ĐỊNH theo `reviewedAtMs`. `List.sort` của Dart
    // KHÔNG bảo đảm ổn định, nên dùng thứ tự đầu vào làm khoá phá hoà:
    // hai sự kiện trùng mili giây giữ NGUYÊN thứ tự đầu vào, tức giữ
    // đúng thứ tự `ORDER BY reviewed_at ASC, id ASC` mà repository đã
    // trả về. Cùng nhau, hai lớp này cho một thứ tự TOÀN PHẦN, tái lập
    // được từ đầu tới cuối mà không cần lộ thêm trường thứ mười lăm.
    final group = groups[key]!;
    final ordered = [
      for (var i = 0; i < group.length; i++) (index: i, event: group[i]),
    ]..sort((a, b) {
        final byTime = a.event.reviewedAtMs.compareTo(b.event.reviewedAtMs);
        return byTime != 0 ? byTime : a.index.compareTo(b.index);
      });

    // BƯỚC 5 — duyệt từng cặp kề nhau.
    for (var i = 1; i < ordered.length; i++) {
      final p = ordered[i - 1].event;
      final s = ordered[i].event;

      if (!_isContinuous(p, s)) {
        // Điểm gãy: KHÔNG phát quan sát nào vắt qua nó — khoảng thời
        // gian ngang qua một điểm gãy không đo sự ghi nhớ của bất cứ
        // thứ gì, nó bao trùm quãng mà định danh lập lịch của thẻ đã
        // bị thay thế. Ghi nhận điểm gãy, rồi TIẾP TỤC: `s` trở thành
        // ứng viên tiền nhiệm của cặp kế tiếp, nên một đoạn liên tục
        // về sau vẫn được quan sát. Một điểm gãy cắt ngắn chuỗi, nó
        // không loại bỏ cả mục.
        discontinuities.add(
          RetentionDiscontinuity(
            itemType: p.itemType,
            itemId: p.itemId,
            predecessorCardId: p.cardId,
            successorCardId: s.cardId,
            predecessorReviewedAtMs: p.reviewedAtMs,
            successorReviewedAtMs: s.reviewedAtMs,
          ),
        );
        continue;
      }

      observations.add(
        RetentionObservation(
          itemType: s.itemType,
          itemId: s.itemId,
          cardId: s.cardId,
          predecessorReviewedAtMs: p.reviewedAtMs,
          successorReviewedAtMs: s.reviewedAtMs,
          // Hiệu hai mốc ôn THẬT, và không bằng cách nào khác. Một cặp
          // trùng mili giây mà vẫn liên tục sẽ cho `elapsedMs == 0` và
          // ĐƯỢC PHÁT RA: 0 là phép đo trung thực của một khoảng dài
          // bằng 0, còn lọc nó đi chính là dựng lên một ngưỡng tự bịa.
          elapsedMs: s.reviewedAtMs - p.reviewedAtMs,
          outcomeGrade: _gradeFromRaw(s.gradeRaw)!,
          beforeState: _stateFromRaw(s.beforeStateRaw)!,
          afterState: _stateFromRaw(s.afterStateRaw)!,
          // Xuất xứ lịch đã hẹn lấy từ TIỀN NHIỆM — đó là điều bộ lập
          // lịch đã yêu cầu cho chính khoảng thời gian này.
          scheduledIntervalDays: p.afterIntervalDays,
          scheduledDueDateMs: p.afterDueDateMs,
          predecessorAlgorithmId: p.algorithmId,
          successorAlgorithmId: s.algorithmId,
        ),
      );
    }
  }

  return RetentionDerivation(
    observations: observations,
    discontinuities: discontinuities,
    eventsConsidered: events.length,
    eventsExcludedAsFuture: excludedAsFuture,
    eventsExcludedAsIneligible: excludedAsIneligible,
  );
}

/// Điều kiện liên tục — BẢY số hạng, tất cả đều phải đúng
/// (DR-2026-0027 §"Continuity and reset semantics", nhận nguyên văn).
///
/// Kề nhau về thời gian KHÔNG phải là liên tục, và chung `card_id`
/// cũng KHÔNG phải là liên tục: `syncItemsForType` HỒI SINH đúng
/// `srs_cards.id` cũ và reset nó về `initialState()` khi một mục quay
/// lại tập thành viên. Xoá một kế hoạch Hifz rồi tạo lại đúng đoạn đó
/// sẽ trả về ĐÚNG card id cũ với tiến độ đã bị xoá sạch — hành vi mà
/// chính sản phẩm nói rõ với người dùng trong hộp thoại xoá. Ghép hai
/// sự kiện nằm hai bên lần reset ấy sẽ báo cáo, như bằng chứng ghi nhớ
/// hàng tháng trời, một khoảng thời gian chẳng đo điều gì như thế cả.
/// Đó là BỊA ĐẶT.
///
/// Bốn số hạng trạng thái so sánh CHÍNH XÁC trên hai chuỗi nền-enum,
/// ba số nguyên và một mốc epoch ms — tất cả đều so sánh khớp tuyệt
/// đối được. Đây là thêm một lý do hai ease factor (`double`) bị loại
/// hoàn toàn khỏi cổng đọc: chúng sẽ kéo phép so sánh dấu phẩy động
/// vào một điều kiện then chốt về tính đúng đắn.
bool _isContinuous(RetentionSourceEvent p, RetentionSourceEvent s) {
  return p.itemType == s.itemType &&
      p.itemId == s.itemId &&
      p.cardId == s.cardId &&
      p.afterStateRaw == s.beforeStateRaw &&
      p.afterRepetitions == s.beforeRepetitions &&
      p.afterIntervalDays == s.beforeIntervalDays &&
      p.afterDueDateMs == s.beforeDueDateMs;
}

/// `null` khi chuỗi nằm ngoài từ vựng — KHÔNG có nhánh mặc định.
///
/// `ReviewGrade.name` vừa là định danh Dart vừa là chuỗi lưu, nên
/// không cần codec riêng (khác `SrsCardState`).
ReviewGrade? _gradeFromRaw(String raw) => switch (raw) {
      'again' => ReviewGrade.again,
      'hard' => ReviewGrade.hard,
      'good' => ReviewGrade.good,
      'easy' => ReviewGrade.easy,
      _ => null,
    };

/// `null` khi chuỗi nằm ngoài từ vựng — KHÔNG có nhánh mặc định.
///
/// CỐ Ý KHÔNG gọi `srsCardStateFromDbValue`: bộ giải mã đó kết thúc
/// bằng `_ => SrsCardState.newCard`, một fallback IM LẶNG sẽ biến một
/// trạng thái lạ thành `new` và qua đó bịa ra (hoặc che mất) một điểm
/// gãy liên tục. Bảng ánh xạ chuỗi ở đây khớp ĐÚNG
/// `SrsCardStateCodec.toDbValue()`, chỉ khác ở chỗ trả `null` thay vì
/// đoán bừa.
SrsCardState? _stateFromRaw(String raw) => switch (raw) {
      'new' => SrsCardState.newCard,
      'learning' => SrsCardState.learning,
      'review' => SrsCardState.review,
      'lapsed' => SrsCardState.lapsed,
      _ => null,
    };
