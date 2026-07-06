# Dart AOT snapshot không đi qua R8 — chỉ lớp embedding Java/Kotlin và
# plugin native (just_audio, sqlite3_flutter_libs, path_provider,
# shared_preferences, package_info_plus) mới bị R8 xử lý. Các plugin này
# đã tự đóng gói consumer-rules.pro trong AAR của chúng, nên hiện chưa
# cần rule tùy chỉnh nào ở đây. Thêm rule mới vào file này nếu R8 xóa
# nhầm 1 class/method cần giữ lại (lỗi runtime "ClassNotFoundException"
# hoặc tương tự chỉ xảy ra ở bản release, không xảy ra ở debug).
