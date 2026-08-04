package com.duso.qurancompanion

import com.ryanheise.audioservice.AudioServiceActivity

/**
 * Sprint B2: kế thừa AudioServiceActivity thay cho FlutterActivity.
 *
 * audio_service cần điều này để khi người dùng chạm vào thông báo media
 * (hoặc mở lại app từ màn hình khoá), activity được gắn vào đúng
 * FlutterEngine đang giữ phiên phát — thay vì dựng một engine mới, làm
 * mất trạng thái và bỏ rơi service đang chạy.
 *
 * AudioServiceActivity chỉ là FlutterActivity kèm phần nối engine đó;
 * mọi hành vi khác giữ nguyên.
 */
class MainActivity : AudioServiceActivity()
