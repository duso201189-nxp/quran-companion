/// Hằng số của lớp dữ liệu nội dung Qur'an.
abstract final class DatabaseConstants {
  /// Đường dẫn file SQLite đóng gói (build bởi tool/build_quran_db.py).
  static const String contentAssetPath = 'assets/database/quran.sqlite';

  /// Phiên bản dữ liệu nội dung mong đợi. Tăng số này khi phát hành
  /// file data mới -> app tự chép đè bản cũ ở lần mở kế tiếp.
  /// PHẢI khớp meta.data_version trong file do tool sinh ra.
  static const String expectedDataVersion = '4';

  /// Tên file nội dung trong bộ nhớ app (tách hẳn database người dùng
  /// để cập nhật nội dung không đụng dữ liệu học — xem DATABASE.md).
  static const String contentFileName = 'quran_content.sqlite';
}
