/// Chọn cách mở database theo nền tảng lúc compile:
/// - io (Android/iOS/desktop): copy asset ra file, mở NativeDatabase
/// - web: drift WASM + nạp asset vào OPFS/IndexedDB
library;

export 'unsupported.dart'
    if (dart.library.io) 'native.dart'
    if (dart.library.html) 'web.dart';
