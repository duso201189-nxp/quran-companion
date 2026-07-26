# Giấy phép của mọi nội dung phát hành kèm app

Lập ở Sprint 33.0 Phase 1. Mỗi dòng dưới đây được **đọc từ trang điều
khoản của chính nguồn** hoặc **trích từ metadata nhúng trong file**,
ngày 2026-07-26. Chỗ nào không tìm được điều khoản chính thức thì ghi
thẳng là KHÔNG XÁC MINH ĐƯỢC — không suy đoán.

Màn hình Ghi nguồn trong app (Hồ sơ → Nguồn dữ liệu) đọc thẳng từ
database, nên nó không thể lệch với dữ liệu đang phát hành. Tài liệu
này là phần điều khoản mà database KHÔNG chứa: nguyên văn điều kiện,
và đánh giá rủi ro.

## 1. Nội dung trong `assets/database/quran.sqlite`

| # | Nội dung | Nguồn | Giấy phép | Thương mại | Phân phối lại | Bắt buộc kèm |
|---|---|---|---|---|---|---|
| 1 | Văn bản Ả Rập Uthmani | Tanzil Project | Tanzil Terms of Use | **Không nêu** | Cho phép, **cấm sửa** | Ghi "Tanzil Project" + **link tanzil.net** |
| 2 | Phiên âm Latin | Quran.com / QUL (Tarteel AI) | **KHÔNG XÁC MINH ĐƯỢC** | không rõ | không rõ | ghi nguồn (theo thông lệ QUL) |
| 3 | Bản dịch Việt (Rowwad) | QuranEnc.com | QuranEnc Terms (7 điều) | không nêu rõ | Cho phép có điều kiện | Ghi nhà phát hành + **QuranEnc.com** + **số phiên bản** |
| 4 | Bản dịch Anh (Saheeh International) | Tanzil Project | Tanzil translations terms | **CẤM** — "for non-commercial purposes only" | Cho phép phi thương mại | Ghi nguồn; link nếu dùng >3 bản dịch |
| 5 | Tafsir Al-Muyassar (ar) | Quran.com / QUL | **KHÔNG XÁC MINH ĐƯỢC** | không rõ | không rõ | ghi nguồn |
| 6 | Tafsir Ibn Kathir (en, rút gọn) | Quran.com / QUL | **KHÔNG XÁC MINH ĐƯỢC** | không rõ | không rõ | ghi nguồn |

### Nguyên văn điều kiện

**Tanzil — văn bản Qur'an** (https://tanzil.net/download/):
> "Permission is granted to copy and distribute verbatim copies of the
> Quran text provided here" — "changing the text is not allowed" —
> "The text can be used in any website or application, provided that
> its source (Tanzil Project) is clearly indicated" — "a link is made
> to tanzil.net to enable users to keep track of changes".

Trang này KHÔNG nói gì về mục đích thương mại.

**Tanzil — bản dịch** (https://tanzil.net/trans/), khác hẳn điều khoản
văn bản gốc ở trên:
> "The translations provided at this page are for non-commercial
> purposes only." — "If used otherwise, you need to obtain necessary
> permission from the translator or the publisher." — "If you are using
> more than three of the following translations in a website or
> application, we require you to put a link back to this page."

App dùng ĐÚNG MỘT bản dịch từ Tanzil (Saheeh International), nên điều
kiện "hơn ba bản dịch" chưa áp dụng. Điều kiện phi thương mại thì CÓ.

**QuranEnc** (https://quranenc.com/en/browse/vietnamese_rwwad) — 7 điều:
> 1. "No modification, addition, or deletion of the content."
> 2. "Clearly referring to the publisher and the source (QuranEnc.com)."
> 3. "Mentioning the version number when re-publishing the translation."
> 4. "Keeping the transcript information inside the document."
> 5. "Notifying the source (QuranEnc.com) of any note on the translation."
> 6. "Updating the translation according to the latest version issued
>    from the source (QuranEnc.com)."
> 7. "Inappropriate advertisements must not be included when displaying
>    translations of the meanings of the Noble Quran."

Điều 7 là một ràng buộc THỰC SỰ với bất kỳ mô hình quảng cáo nào sau
này — đứng độc lập với `PROJ-P-005`.

**Quran.com / QUL (Tarteel AI)** — trang tài nguyên (108 bộ tafsir tải
được dạng JSON/SQLite) **không hiển thị trường giấy phép cho từng bộ**.
Trang Terms of Use của Tarteel không truy xuất được nội dung ở thời
điểm rà soát. Vì vậy giấy phép của phiên âm và **cả hai bộ Tafsir đang
phát hành** là KHÔNG XÁC MINH ĐƯỢC. Đây là rủi ro pháp lý còn treo,
không phải một dấu tích đã xong.

## 2. Audio (phát trực tuyến, không đóng gói)

| Nội dung | Nguồn | Giấy phép | Ghi chú |
|---|---|---|---|
| 5 bản thu Qari | everyayah.com | **KHÔNG XÁC MINH ĐƯỢC** | Trang chủ không có mục điều khoản |

File `everyayah.com/data/timings_files/000_disclaimer.txt` nói rõ:
> "(C) VerseByVerseQuran.com You must link back to our site from your
> product and web-site to use these timings."

...nhưng đó là điều khoản của **file canh thời gian**, mà app KHÔNG
dùng. Điều khoản của chính các file MP3 không được nêu ở đâu trên
everyayah.com. Có ý kiến bên thứ ba (thảo luận trong kho quran_android)
cho rằng dữ liệu là CC-BY-NC; **đó không phải tuyên bố của chủ sở hữu**
và không được coi là căn cứ.

Database ghi giấy phép là "Phi thương mại — everyayah.com". Đó là một
GIẢ ĐỊNH THẬN TRỌNG do dự án tự đặt, không phải trích dẫn.

## 3. Phông chữ đóng gói trong APK

Trích thẳng từ bảng `name` của file `.ttf` (id 0 = bản quyền,
id 13 = mô tả giấy phép). Văn bản đầy đủ nằm trong `assets/licenses/`
và hiển thị qua `showLicensePage` (Hồ sơ → Nguồn dữ liệu → Giấy phép
phần mềm & phông chữ).

| Font | Bản quyền | Giấy phép | Thương mại | Sửa đổi |
|---|---|---|---|---|
| UthmanicHafs | KFGQPC 2010 | EULA riêng | **Cấm bán chính font** | **Cấm** |
| Amiri 1.002 | The Amiri Project Authors 2010–2022 | OFL 1.1 | Cho phép | Cho phép |
| Noto Naskh Arabic 2.021 | The Noto Project Authors 2022 | OFL 1.1 | Cho phép | Cho phép |
| Inter 4.001 | The Inter Project Authors 2016 | OFL 1.1 | Cho phép | Cho phép |

**KFGQPC** cho phép rõ ràng việc đóng gói kèm app miễn phí:
> "Permission is hereby granted, Free of Cost, to any person obtaining
> a copy of this Font accompanying this license, the rights to Use,
> Copy, Distribute, subject to the following conditions: 1. The Font
> Software cannot be Sold, Modified, Altered, Translated, Reverse
> Engineered, Decompiled, Disassembled, Reproduced..."

App phân phối font **nguyên trạng**, nên đúng điều kiện. Câu "cannot be
Sold" nói về BẢN THÂN font; nó không nói rõ về một ứng dụng có phí có
chứa font — một điểm mơ hồ cần hỏi KFGQPC trước khi thu phí.

**OFL 1.1** bắt buộc: "The above copyright notice and this license
notice shall be included in all copies of one or more of the Font
Software typefaces." Trước Sprint 33.0 app KHÔNG kèm thông báo nào —
đây là vi phạm giấy phép đã tồn tại suốt và nay đã sửa.

## 4. Kết luận rủi ro

| # | Rủi ro | Mức | Trạng thái |
|---|---|---|---|
| 1 | Giấy phép Tafsir + phiên âm (QUL) không xác minh được | **Cao** | CÒN TREO — cần liên hệ Tarteel/Quran.com |
| 2 | Giấy phép bản thu everyayah.com không xác minh được | **Cao** | CÒN TREO — cần liên hệ everyayah |
| 3 | Saheeh International phi thương mại (`PROJ-P-005`) | Cao nếu thu phí | Đã ghi nhận, chặn mọi mô hình có phí |
| 4 | QuranEnc điều 7 cấm quảng cáo không phù hợp | Trung bình | Đã ghi nhận, chặn mô hình quảng cáo |
| 5 | OFL thiếu thông báo giấy phép | Trung bình | **ĐÃ SỬA** Sprint 33.0 |
| 6 | Thiếu màn hình ghi nguồn | Trung bình | **ĐÃ SỬA** Sprint 33.0 |
| 7 | KFGQPC mơ hồ với app có phí | Thấp (miễn phí) | Ghi nhận, chỉ quan trọng khi thu phí |

Rủi ro 1 và 2 **không thể đóng bằng cách viết mã**. Chúng cần một câu
trả lời từ người giữ quyền. Cho tới lúc đó, bản phát hành phải là miễn
phí, không quảng cáo, và ghi nguồn đầy đủ — đó là tư thế phòng vệ tốt
nhất mà kỹ thuật có thể tạo ra.
