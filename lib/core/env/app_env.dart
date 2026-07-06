/// Cấu hình môi trường: Development / Staging / Production.
///
/// Giá trị được truyền lúc build bằng --dart-define-from-file:
///
///   flutter run   --dart-define-from-file=env/dev.json
///   flutter build --dart-define-from-file=env/prod.json
///
/// QUY TẮC BẢO MẬT:
/// - File env/*.json KHÔNG được commit (đã chặn trong env/.gitignore).
/// - Chỉ commit file *.example.json làm mẫu.
/// - Trên CI, nội dung file env nằm trong GitHub Secrets.
/// - Không bao giờ hard-code API key trong source.
enum AppEnvironment { dev, staging, prod }

abstract final class AppEnv {
  static const String _name = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  static AppEnvironment get current => switch (_name) {
        'prod' => AppEnvironment.prod,
        'staging' => AppEnvironment.staging,
        _ => AppEnvironment.dev,
      };

  static bool get isProduction => current == AppEnvironment.prod;

  /// Crashlytics & Analytics (tích hợp ở Bước 11):
  /// bật ở Production, tắt ở Development — điều khiển bằng env,
  /// không sửa code.
  static const bool crashReportingEnabled = bool.fromEnvironment(
    'CRASH_REPORTING',
  );

  // Bước 10-11 sẽ thêm (đọc từ env, không hard-code):
  // static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  // static const String supabaseAnonKey =
  //     String.fromEnvironment('SUPABASE_ANON_KEY');
}
