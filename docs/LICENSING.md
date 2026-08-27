> **Ghi chú áp dụng cho nhánh `main`.** Tài liệu này được soạn trên
> `sprint1-my-library` (Sprint 33.0) và mô tả sáu nguồn nội dung. Database
> `assets/database/quran.sqlite` trên `main` (~19,9 MB) có TRƯỚC lần
> nhập tafsir — nó chỉ chứa các nguồn 1–4 (văn bản Ả Rập, phiên âm
> Latin, bản dịch Việt, bản dịch Anh). Nguồn 5–6 (Tafsir Al-Muyassar,
> Tafsir Ibn Kathir) và các rủi ro nêu cho chúng ở mục 4 CHƯA áp dụng
> cho những gì `main` đang phát hành — chúng mô tả nội dung được thêm
> sau (xem `RELEASE_INVENTORY.md`, nhóm G10). Giữ nguyên toàn văn bên
> dưới, không cắt bớt, để tài liệu này vẫn đúng ngay khi nội dung đó
> được hợp nhất vào `main`, không cần soạn lại từ đầu vào lúc đó.
>
> Tài liệu được đưa vào `main` ở bước này vì cổng CI ranh giới kho mã
> (`test/repository_boundary_test.dart`) trỏ người đọc tới đây khi nó
> chặn một tệp — xem `CI_GATE_SPLIT_PLAN.md` Phần 5.

---

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
| 2 | Phiên âm Latin | Quran.com / QUL (Tarteel AI) | QUL không bảo đảm; chưa có tuyên bố của chủ dữ liệu | không rõ | không rõ | ghi nguồn |
| 3 | Bản dịch Việt (Rowwad) | QuranEnc.com | QuranEnc Terms (7 điều) | không nêu rõ | Cho phép có điều kiện | Ghi nhà phát hành + **QuranEnc.com** + **số phiên bản** |
| 4 | Bản dịch Anh (Saheeh International) | Tanzil Project | Tanzil translations terms | **CẤM** — "for non-commercial purposes only" | Cho phép phi thương mại | Ghi nguồn; link nếu dùng >3 bản dịch |
| 5 | Tafsir Al-Muyassar (ar) — ⚠ **KHÔNG có trên `main`** | نخبة من العلماء · **مجمع الملك فهد** (qua QUL) | chưa có phép | không rõ | **cần phép** | ghi نخبة من العلماء + KFGQPC |
| 6 | Tafsir Ibn Kathir (en, rút gọn) — ⚠ **KHÔNG có trên `main`** | **Maktaba Dar-us-Salam 2003** (qua QUL) | **CÒN BẢN QUYỀN HIỆU LỰC** | **cần phép** | **cần phép bằng văn bản** | ghi Darussalam + nhóm dịch |

> ⚠ **Dòng 5–6 mô tả bộ dữ liệu tafsir, KHÔNG mô tả `main`.** Xem ghi
> chú áp dụng ở đầu tài liệu. `main` chỉ phát hành nguồn 1–4.

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

**Quran.com / QUL (Tarteel AI)** — FAQ chính thức
(https://qul.tarteel.ai/faq) nói rõ, nguyên văn:

> "The resources available on QUL vary in their copyright status. Some
> are in the public domain, while others may be subject to specific
> licenses. We recommend reviewing the licensing information provided
> by each resource's author before use."

> "Yes, you can use QUL data in commercial projects. However, please
> review the licensing terms for each resource. Some data may have
> restrictions or require attribution, while others are freely
> available for commercial use."

Nói cách khác: **QUL KHÔNG bảo đảm giấy phép cho bất kỳ bộ dữ liệu
nào.** Nghĩa vụ rơi về đúng chủ sở hữu của từng bộ. Trước Sprint này
dự án ghi "không xác minh được"; thực ra điều khoản CÓ và nó chuyển
trách nhiệm sang chúng ta. Truy ngược từng bộ:

### Tafsir Ibn Kathir (Abridged, tiếng Anh) — RỦI RO CAO NHẤT

> ⚠ **Không có trong `assets/database/quran.sqlite` trên `main`** (đã
> kiểm chứng ở `5360f49`: database không có bảng tafsir nào). Mục này
> mô tả bộ dữ liệu tafsir, không mô tả bản `main` đang phát hành — xem
> "PHẠM VI ÁP DỤNG CỦA MỤC 4" ở mục 4.

Bản gốc tiếng Ả Rập của Ibn Kathir (mất 1373) thuộc phạm vi công
cộng. Nhưng thứ app đang phát hành KHÔNG phải bản gốc: đó là bản
**rút gọn + dịch sang tiếng Anh hiện đại**, do một nhóm học giả thực
hiện dưới sự giám sát của Shaykh Safiur-Rahman al-Mubarakpuri, do
**Darussalam** đặt hàng và xuất bản.

| Sự kiện | Nguồn |
|---|---|
| Xuất bản lần đầu 2000, bản 2 tháng 7/2003 | Darussalam |
| ISBN bộ 10 tập: 9960-892-71-9 | Darussalam |
| **Bản quyền: Maktaba Dar-us-Salam, 2003** | trang bản quyền của chính sách |

Hai hệ quả:

1. **Đây là tác phẩm còn bản quyền hiệu lực của một nhà xuất bản
   thương mại.** Phân phối lại toàn văn trong một ứng dụng cần phép
   bằng văn bản. "Nguồn mở trên QUL" không thay thế được điều đó.
2. **Ghi công đang SAI.** Database ghi `author = 'Hafiz Ibn Kathir'` —
   đó là tác giả thế kỷ 14, không phải người giữ quyền đối với bản
   dịch rút gọn. Ghi công đúng phải nêu Darussalam và nhóm dịch.

### Tafsir Al-Muyassar (tiếng Ả Rập)

> ⚠ **Không có trong `assets/database/quran.sqlite` trên `main`** — xem
> "PHẠM VI ÁP DỤNG CỦA MỤC 4" ở mục 4.

Soạn bởi **نخبة من العلماء** (một nhóm học giả), xuất bản bởi **مجمع
الملك فهد لطباعة المصحف الشريف** (King Fahd Glorious Qur'an Printing
Complex, Madinah) — cùng cơ quan đã cấp EULA miễn phí cho phông chữ
UthmanicHafs mà app đang dùng.

Chưa tìm thấy tuyên bố giấy phép cho phần VĂN BẢN tafsir. Nhưng chủ
sở hữu nay đã xác định chính xác, và KFGQPC là cơ quan nhà nước có
tiền lệ cấp phép rộng rãi cho mục đích da'wah — nên đây là hồ sơ đáng
hỏi và có khả năng được chấp thuận.

**Ghi công đang thiếu.** Database ghi `author = 'المیسر'` — đó là TÊN
TÁC PHẨM (và còn sai chính tả: dùng ی U+06CC của tiếng Ba Tư thay vì
ي), không phải tác giả. Phải là نخبة من العلماء / مجمع الملك فهد.

### Phiên âm Latin (Quran.com word-by-word)

Dữ liệu do chính cộng đồng Quran.com/Tarteel tạo ra, không truy ngược
về một nhà xuất bản bên thứ ba. Rủi ro thấp nhất trong ba bộ QUL,
nhưng vẫn chưa có tuyên bố giấy phép rõ ràng.

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
| 1a | **Ibn Kathir (Abridged) là tác phẩm còn bản quyền của Darussalam** | **NGHIÊM TRỌNG** | CÒN TREO — cần phép bằng văn bản, HOẶC gỡ khỏi bản phát hành |
| 1b | Ghi công Ibn Kathir sai (ghi tác giả thế kỷ 14 thay vì nhà xuất bản bản dịch) | **Cao** | CÒN TREO — sửa được ngay ở lần build dữ liệu kế tiếp |
| 1c | Al-Muyassar: chủ sở hữu đã xác định (KFGQPC) nhưng chưa có phép | **Cao** | CÒN TREO — cần liên hệ KFGQPC |
| 1d | Phiên âm Quran.com: chưa có tuyên bố giấy phép | Trung bình | CÒN TREO — rủi ro thấp nhất nhóm QUL |
| 2 | Giấy phép bản thu everyayah.com không xác minh được | **Cao** | CÒN TREO — đã có kênh liên hệ: quran.zendesk.com |
| 3 | Saheeh International phi thương mại (`PROJ-P-005`) | Cao nếu thu phí | Đã ghi nhận, chặn mọi mô hình có phí |
| 4 | QuranEnc điều 7 cấm quảng cáo không phù hợp | Trung bình | Đã ghi nhận, chặn mô hình quảng cáo |
| 5 | OFL thiếu thông báo giấy phép | Trung bình | **ĐÃ SỬA** Sprint 33.0 |
| 6 | Thiếu màn hình ghi nguồn | Trung bình | **ĐÃ SỬA** Sprint 33.0 |
| 7 | KFGQPC mơ hồ với app có phí | Thấp (miễn phí) | Ghi nhận, chỉ quan trọng khi thu phí |

Không rủi ro nào ở nhóm 1-2 **đóng được bằng cách viết mã**. Chúng cần
câu trả lời từ người giữ quyền.

**Rủi ro 1a khác hẳn phần còn lại.** Ba mục kia là "chưa biết"; mục này
là "đã biết, và câu trả lời bất lợi": bản dịch rút gọn tiếng Anh của
Ibn Kathir là tài sản có bản quyền hiệu lực của một nhà xuất bản
thương mại, và app đang phân phối lại toàn văn 8,9 triệu ký tự của nó.
Không có tư thế phòng vệ nào cho việc đó ngoài (a) giấy phép bằng văn
bản, hoặc (b) gỡ bộ này khỏi bản phát hành.

Cho tới khi 1a được giải quyết theo một trong hai hướng ấy, **không có
bản phát hành công khai nào**, kể cả miễn phí. Miễn phí không phải là
phòng vệ trước vi phạm bản quyền.

> ### ⚠ PHẠM VI ÁP DỤNG CỦA MỤC 4 — đọc trước khi coi đây là chặn phát hành
>
> **Thêm 2026-08-27 (Session 137). Không sửa kết luận nào ở trên; chỉ
> nêu rõ mục 4 đang nói về BẢN NÀO.**
>
> Rủi ro **1a, 1b, 1c** (và dòng 5–6 ở mục 1) mô tả **bộ dữ liệu tafsir**
> — thứ được nhập trên `sprint1-my-library`, nơi tài liệu này được soạn.
> Chúng **KHÔNG mô tả những gì `main` đang phát hành**, đúng như ghi chú
> áp dụng ở đầu tài liệu đã nói.
>
> Session 137 đã kiểm chứng trực tiếp trên `origin/main` `5360f49`:
> `assets/database/quran.sqlite` **không có bảng tafsir nào cả** — không
> phải bảng rỗng, mà là không tồn tại. Toàn bộ bảng trong database đó là
> `surahs`, `ayahs`, `translations` (3 nguồn: Tanzil/Saheeh
> International, QuranEnc/Rowwad, Quran.com/QUL), `reciters`, các bảng
> `search_index*`, `meta`, và nhóm bảng Lexicon (`lemmas`, `roots`,
> `lexemes`, `word_instances`, …) hiện **rỗng (0 dòng)**. Cổng CI
> `test/repository_boundary_test.dart` cũng chặn `tool/data/tafsir_*.json`
> theo mẫu và **không** miễn trừ hai tệp tafsir nào.
>
> Nói thẳng, để không ai phải suy luận: **câu "app đang phân phối lại
> toàn văn 8,9 triệu ký tự" ở ngay trên KHÔNG đúng với `main`. Trên
> `main` câu đó mô tả một tình huống chưa xảy ra.** Vì vậy **1a không
> phải là điều đang chặn bản phát hành hiện tại của `main`**.
>
> Toàn văn mục 4 được giữ nguyên, không cắt bớt, vì nó vẫn đúng — và sẽ
> lập tức có hiệu lực trở lại — với **bất kỳ** bản build nào thực sự
> đóng gói bộ tafsir đó. Nếu bộ tafsir được hợp nhất vào `main`, mọi kết
> luận ở trên áp dụng nguyên vẹn, không cần soạn lại.
>
> Ghi chú này **không** đưa ra kết luận pháp lý mới, **không** giải toả
> rủi ro 1a cho bộ dữ liệu tafsir, và **không** đụng tới các rủi ro
> 2–7 (everyayah, Saheeh International phi thương mại, QuranEnc điều 7,
> KFGQPC) — những mục đó vẫn áp dụng cho `main` như cũ.

## 5. Lexicon / dữ liệu hình thái học (F1) — chưa phát sinh nghĩa vụ giấy phép

**Thêm 2026-08-23 (Session 89), theo yêu cầu "follow-up" nêu tại
`DR-2026-0029` mục "Licensing registry follow-up" và `DR-2026-0030`.**
Khác với mục 1–4 ở trên (mô tả nội dung **đang phát hành**): 8 bảng
Lexicon (`roots`, `lemmas`, `lexemes`, `word_instances`,
`grammar_features`, `phrases`, `phrase_word_instances`,
`lexicon_relations`) tồn tại trong schema và trong
`assets/database/quran.sqlite`, nhưng **cả 8 bảng đều 0 dòng**. Không
có bộ dữ liệu QAC nào và không có bộ dữ liệu MASAQ nào được phát hành
kèm app. Mục này chỉ ghi lại vị thế quản trị hiện tại của nguồn dữ liệu
Lexicon; nó không phải, và không thay thế, một Decision Record.

**MASAQ bị từ chối** (`docs/adr/DR-2026-0029-qac-lexicon-licensing-decision.md`,
accepted, đang áp dụng trên `main`, 2026-08-22). `DR-2026-0016` từng đề
xuất MASAQ (Mendeley `10.17632/9yvrzxktmr`) làm nguồn thay thế QAC.
`DR-2026-0029` từ chối bộ MASAQ hiện đang công bố (v5/v6, dữ liệu
byte-giống-nhau) trên **hai căn cứ độc lập**:

- **Cấu trúc**: file thật (19 cột, không phải 20 như mô tả công bố ban
  đầu) không có cột Root và không có cột Lemma — không thỏa hợp đồng dữ
  liệu bắt buộc của `tool/lexicon/normalizer.py`
  (`docs/release/MASAQ_ACCEPTANCE_REPORT.md`).
- **Giấy phép**: phiên bản v6 hiện đang công bố trên Mendeley là **CC
  BY-NC 3.0** (phi thương mại), không phải CC BY 4.0 mà `DR-2026-0016`
  đã giả định. (v5 — không còn là phiên bản công bố hiện tại — mang CC
  BY 4.0.)

Hai căn cứ này độc lập với nhau: dù pin lại về v5, căn cứ cấu trúc vẫn
không đổi (vì v5 và v6 giống hệt nhau ở dữ liệu). Chi tiết đầy đủ:
`docs/release/MASAQ_ACCEPTANCE_REPORT.md`,
`docs/release/LEXICON_DATASET_VALIDATION.md`.

**QAC vẫn chưa xác định được giấy phép/quyền sử dụng.** Không có bằng
chứng nào trong kho mã cho thấy một yêu cầu xin phép QAC
(corpus.quran.com) từng được gửi đi, và không có bằng chứng nào cho
thấy đã nhận được phản hồi. Tài liệu này **không khẳng định** yêu cầu
đã được gửi, **không khẳng định** yêu cầu chưa từng được gửi, và
**không khẳng định** QAC đã từ chối hay đã chấp thuận bất cứ điều gì —
chỉ ghi nhận rằng kho mã không chứa bằng chứng theo bất kỳ hướng nào.
(`DR-2026-0029` Fact 4/5.)

**Lexicon (F1) và Flashcards (F2) đã được hoãn chính thức khỏi v1.0**
(`docs/adr/DR-2026-0030-formal-deferral-lexicon-flashcards-v1.md`,
accepted, đang áp dụng trên `main`, 2026-08-22) — một quyết định phạm
vi phát hành (release-scope), độc lập với câu hỏi nguồn dữ liệu ở
trên. Quyết định này không phê duyệt, không xếp hạng và không loại trừ
bất kỳ nguồn thay thế nào cho Lexicon.

**Chưa quyết định ở đây** (để ngỏ cho chủ dự án — chủ sở hữu, không
phải kỹ thuật):

- Có nên thay thế nguồn Tanzil (văn bản Ả Rập hoặc bản dịch) hay không.
- Có cần chọn một nguồn bản dịch/dữ liệu khác hay không.
- Có nên gửi yêu cầu xin phép QAC hay không, khi nào, và nội dung ra
  sao.
