/// Mốc thời gian UTC (mili-giây) dùng chung cho mọi repository impl —
/// trích ra sau khi phát hiện `_epochNow()` bị viết tay lại y hệt ở 7
/// file (flashcard/khatm/scheduler/bookmark_collection/quiz/
/// user_content/study_session repository impl — Sprint 24 Repository
/// Health Audit). Mỗi repository vẫn tự nhận `nowMs` qua constructor
/// (mặc định gọi hàm này) để test tiêm được giá trị xác định — hàm
/// này chỉ là GIÁ TRỊ MẶC ĐỊNH dùng chung, không đổi cách tiêm.
int epochNowMs() => DateTime.now().toUtc().millisecondsSinceEpoch;
