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

> ### ⚠ Đính chính 2026-08-28 (Session 146) — kiến trúc màn hình Ghi nguồn
>
> Câu trước đây đứng ở chỗ này — *"Màn hình Ghi nguồn trong app (Hồ sơ →
> Nguồn dữ liệu) đọc thẳng từ database, nên nó không thể lệch với dữ
> liệu đang phát hành"* — **KHÔNG đúng với `main` `155845a`**. Kiến trúc
> đã kiểm chứng trực tiếp trong mã nguồn:
>
> - Phần ghi nguồn hiển thị ở Hồ sơ là một **chuỗi ARB đã bản địa hoá**,
>   viết cứng riêng cho từng ngôn ngữ: `aboutSourcesDetail` ở
>   `lib/l10n/app_vi.arb:222`, `app_en.arb:222`, `app_ar.arb:222`; được
>   dựng ra màn hình ở
>   `lib/features/profile/presentation/profile_screen.dart:133-134`.
> - **`getEnabledSources()` KHÔNG phải nguồn của màn hình này.** Hàm này
>   khai báo ở `lib/features/quran/domain/repositories/quran_repository.dart:16`
>   và hiện thực ở `lib/features/quran/data/quran_repository_impl.dart:56`,
>   nhưng trên `main` nó **không có nơi gọi nào trong `lib/`** — chỉ các
>   test gọi tới.
> - **Hệ quả:** phần ghi nguồn hiển thị **CÓ THỂ lệch** khỏi siêu dữ liệu
>   nguồn nằm trong database (`translation_sources`, `meta`). Không có cơ
>   chế nào trong mã ràng buộc hai bên với nhau.
>
> Đính chính này chỉ nêu sự thật kiến trúc; nó **không** kết luận rằng
> chuỗi ARB hiện tại đủ hay không đủ để thỏa bất kỳ điều kiện ghi nguồn
> nào của bên cấp phép.

Tài liệu này là phần điều khoản mà database KHÔNG chứa: nguyên văn điều
kiện, và đánh giá rủi ro.

## 1. Nội dung trong `assets/database/quran.sqlite`

| # | Nội dung | Nguồn | Giấy phép | Thương mại | Phân phối lại | Bắt buộc kèm |
|---|---|---|---|---|---|---|
| 1 | Văn bản Ả Rập Uthmani | Tanzil Project | Tanzil Terms of Use | **Không nêu** | Cho phép, **cấm sửa** | Ghi "Tanzil Project" + **link tanzil.net** |
| 2 | Phiên âm Latin | **Quran.com QDC** (`api.qurancdn.com`) — xem đính chính Session 147 bên dưới | **CHƯA XÁC ĐỊNH** — kho mã không xác lập được giấy phép/sự cho phép phân phối lại từ thượng nguồn | không rõ | không rõ | ghi nguồn |
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

**QUL (Tarteel AI)** — FAQ chính thức (https://qul.tarteel.ai/faq) nói
rõ, nguyên văn. *(Nhãn sửa 2026-08-28, Session 147: trước đây ghi
"Quran.com / QUL"; đây là FAQ của QUL, không phải điều khoản do
Quran.com phát hành.)*

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

> **Phạm vi của phần trích QUL ở trên (đánh dấu 2026-08-28, Session
> 147).** Hai đoạn trích nguyên văn ngay trên là điều khoản **của QUL**,
> dẫn từ FAQ **của QUL**, và chỉ áp dụng cho những bộ dữ liệu thực sự
> lấy qua QUL. Trong ba bộ được truy ngược bên dưới, **bộ phiên âm Latin
> KHÔNG lấy qua QUL** — nó được tải qua điểm cuối QDC của Quran.com
> (`api.qurancdn.com`). Xem đính chính Session 147 ở tiểu mục "Phiên âm
> Latin". Không được đọc điều khoản QUL như điều khoản chi phối bộ phiên
> âm đó.

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

> ### ⚠ Đính chính 2026-08-28 (Session 147) — nguồn thật của bộ phiên âm đang phát hành
>
> Đoạn trước đây đứng ở chỗ này — *"Dữ liệu do chính cộng đồng
> Quran.com/Tarteel tạo ra, không truy ngược về một nhà xuất bản bên thứ
> ba. Rủi ro thấp nhất trong ba bộ QUL, nhưng vẫn chưa có tuyên bố giấy
> phép rõ ràng"* — quy bộ dữ liệu này về **QUL**. Cách quy đó KHÔNG khớp
> với bằng chứng trong kho mã.
>
> **SỰ THẬT.** Bộ phiên âm đang phát hành được tải qua **điểm cuối QDC
> của Quran.com** (`api.qurancdn.com`), không qua QUL:
>
> - `tool/fetch_transliteration.py:30`–`:34` gọi
>   `https://api.qurancdn.com/api/qdc/verses/by_chapter/{chapter}` với
>   `word_fields=transliteration,text_uthmani`. Đây là đường lấy dữ liệu
>   duy nhất của bộ phiên âm.
> - Siêu dữ liệu trong chính database đang phát hành
>   (`assets/database/quran.sqlite`, bảng `translation_sources`, dòng
>   `code = 'translit_latin'`) ghi `name = 'Phiên âm Latin (Quran.com)'`,
>   `author = 'Quran.com word-by-word transliteration'`,
>   `source_url = 'https://quran.com'`, `version = '2026-07-06'` (ngày
>   tải). Tại thời điểm Session 147, `updated_at` cũng là `'2026-07-06'`;
>   sau lần dựng lại CSDL của Session 162 nó là `'2026-08-29'` — đó là
>   dấu thời gian dựng bản, **không** phải ngày tải dữ liệu, vốn không
>   đổi.
>
> **Hệ quả:** **FAQ của QUL KHÔNG phải văn bản điều khoản chi phối** bộ
> phiên âm đang phát hành. Phần trích FAQ của QUL ở mục "Nguyên văn điều
> kiện" phía trên được **giữ nguyên** vì nó được dẫn nguồn chính xác và
> vẫn áp dụng cho các bộ dữ liệu khác lấy qua QUL — nhưng nó không được
> đọc như điều khoản của bộ phiên âm này.
>
> **SỰ THẬT.** Kho mã **không xác lập được** một giấy phép hoặc sự cho
> phép phân phối lại dứt khoát từ thượng nguồn cho bộ dữ liệu này.
> Trường `license` trong database ghi, **tại thời điểm Session 147**,
> *"Quran.com/QUL community data — ghi nguồn khi phân phối"* (trích lại
> làm dấu vết lịch sử; giá trị đó đã được sửa ở nguồn trong Session 161
> và đồng bộ vào CSDL phát hành trong Session 162 — xem khối ngay dưới,
> nay là *"UNKNOWN — COUNSEL REQUIRED"*). Dù là giá trị cũ hay mới,
> chuỗi đó do **chính dự án tự đặt** (sao từ
> `tool/data/transliteration.json`, do `tool/fetch_transliteration.py`
> sinh ra) — **không** phải tuyên bố của Quran.com hay của bất kỳ chủ sở
> hữu nào, và không được coi là căn cứ.
>
> **CHƯA XÁC ĐỊNH — CẦN Ý KIẾN CHUYÊN MÔN.** Giấy phép/sự cho phép nào
> thực sự chi phối bộ dữ liệu này, và điều khoản nào có hiệu lực tại
> **ngày tải 2026-07-06** ghi trong siêu dữ liệu, đều chưa được giải
> quyết.
>
> Đính chính này **không** kết luận rằng Quran.com đã cho phép phân phối
> lại, **không** kết luận rằng Quran.com cấm điều đó, và **không** khẳng
> định có bất kỳ vi phạm nào. Nó chỉ sửa lại việc quy nguồn trong kho mã.
>
> **Không gọi đây là dữ liệu "AI".** "Tarteel AI" trong tài liệu cũ là
> tên tổ chức vận hành QUL, không mô tả cách bộ phiên âm được tạo ra.
> Kho mã không chứa bằng chứng nào cho thấy bộ dữ liệu này do mô hình
> sinh ra, nên tài liệu này không gọi nó là dữ liệu "AI".
>
> Phân tích chi tiết (đường dẫn API đã dùng, biến đổi biên tập đã áp
> dụng, khoảng trống bằng chứng, điểm lệch quản trị với `PROJ-P-005`):
> `docs/release/SESSION_146_COPY_SHARE_LICENSING_PACKET.md` — đã có trên
> `main` từ `953382b` (PR #48).
>
> Lưu ý: các nhãn "Quran.com/QUL" còn sót ở chỗ khác trong tài liệu này
> (ví dụ trong khối kiểm chứng đề ngày của Session 137 ở mục 4) có TRƯỚC
> đính chính này và được giữ nguyên như bản ghi lịch sử; chúng không phủ
> nhận sự thật nêu ở đây.

> ### ⚠ Đồng bộ 2026-08-29 (Session 162) — CSDL phát hành đã khớp nguồn
>
> Session 161 sửa siêu dữ liệu ở **nguồn** (`tool/fetch_transliteration.py`,
> `tool/data/transliteration.json`) nhưng chưa dựng lại
> `assets/database/quran.sqlite`, nên tệp phát hành vẫn mang chuỗi cũ.
> Session 162 dựng lại CSDL bằng đúng pipeline tài liệu hóa
> (`tool/build_quran_db.py`) và thay tệp phát hành. Đây là **đồng bộ hiện
> vật với nguồn — KHÔNG phải kết luận pháp lý, KHÔNG phải thay đổi trạng
> thái giấy phép.**
>
> **SỰ THẬT — nguồn.** Đường tải bộ phiên âm vẫn là **QDC của Quran.com**
> (`api.qurancdn.com`). **QUL KHÔNG phải nguồn** của bộ dữ liệu này.
> Điều đó không đổi so với đính chính Session 147 ở trên.
>
> **SỰ THẬT — trường `license` trong CSDL.** Giá trị hiện hành là
> *"UNKNOWN — COUNSEL REQUIRED"*. Nó vẫn là **siêu dữ liệu do chính dự án
> tự đặt**, **không** phải tuyên bố của Quran.com hay của bất kỳ chủ sở
> hữu quyền nào, và **không** được coi là căn cứ cho bất cứ điều gì. Việc
> chuỗi này đổi từ một câu nghe như nghĩa vụ ghi nguồn sang "UNKNOWN"
> **không** làm thay đổi bất kỳ quyền hay nghĩa vụ nào; nó chỉ khiến siêu
> dữ liệu thôi khẳng định điều mà kho mã không chứng minh được.
>
> **Đã kiểm chứng.** Trong CSDL phát hành không còn chuỗi
> `"Quran.com/QUL community data"` hay `"ghi nguồn khi phân phối"` nào.
> Đối chiếu CSDL cũ ↔ mới: lược đồ giống hệt, số dòng mọi bảng bằng nhau,
> nội dung trùng khớp từng dòng (`ayahs` 6.236, `translations` 18.708,
> `surahs` 114, `reciters` 5, `search_index` 43.652). Khác biệt duy nhất
> là 5 ô siêu dữ liệu: chuỗi `license` nói trên và bốn dấu thời gian dựng
> bản. Văn bản Ả Rập, phiên âm, bản dịch Anh/Việt **không đổi**.
>
> **VẪN CHƯA XÁC ĐỊNH.** Giấy phép hay sự cho phép thượng nguồn thực sự
> chi phối bộ phiên âm QDC — và điều khoản nào có hiệu lực tại ngày tải
> `2026-07-06` — vẫn **CHƯA XÁC ĐỊNH / UNKNOWN — CẦN Ý KIẾN CHUYÊN MÔN**.
> Khối này **không** kết luận rằng có sự cho phép, **không** kết luận
> rằng sự cho phép bị từ chối, **không** khẳng định việc phân phối lại
> được cho phép và **không** khẳng định nó bị cấm. **P2-2 vẫn ĐANG MỞ.**
>
> **Bản ghi lịch sử được giữ nguyên.** Khối đính chính Session 147 ở
> trên, khối kiểm chứng đề ngày Session 137 ở mục 4, và mọi chỗ khác
> trích lại chuỗi cũ đều **không bị viết lại** — chúng là bản ghi những
> gì tài liệu và CSDL từng ghi.

Ở mức sự thật kho mã: bộ phiên âm đến từ Quran.com QDC, và **vẫn chưa
có tuyên bố giấy phép rõ ràng từ thượng nguồn.**

> **Session 146 — chỉ dẫn tham chiếu, không phải kết luận mới.** Nguồn
> gốc và điều kiện phân phối lại của bộ phiên âm này cần phân tích rộng
> hơn phạm vi một đính chính tài liệu, và **không** được quyết ở đây. Hồ
> sơ dẫn chứng đầy đủ (đường dẫn API đã dùng, biến đổi biên tập đã áp
> dụng, khoảng trống bằng chứng, và điểm lệch quản trị với `PROJ-P-005`)
> nằm ở `docs/release/SESSION_146_COPY_SHARE_LICENSING_PACKET.md`.

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
id 13 = mô tả giấy phép).

> ### ⚠ Đính chính 2026-08-28 (Session 146) — nơi chứa văn bản giấy phép
>
> Câu trước đây đứng ở chỗ này — *"Văn bản đầy đủ nằm trong
> `assets/licenses/` và hiển thị qua `showLicensePage` (Hồ sơ → Nguồn dữ
> liệu → Giấy phép phần mềm & phông chữ)"* — **KHÔNG đúng với `main`
> `155845a`**. Sự thật kho mã, đã kiểm chứng trực tiếp:
>
> - **Thư mục `assets/licenses/` KHÔNG tồn tại trên `main`.** `assets/`
>   chỉ có `assets/database/` và `assets/fonts/`. `pubspec.yaml:56-57`
>   khai báo đúng **một** asset duy nhất: `assets/database/quran.sqlite`.
> - **KHÔNG có hiện thực `showLicensePage` / `LicenseRegistry` nào trên
>   `main`** — không tệp nào trong `lib/` nhắc tới hai định danh này.
> - Chuỗi `assets/licenses/Amiri-OFL.txt` xuất hiện **đúng một lần** trong
>   toàn kho mã, tại `test/repository_boundary_test.dart:313`. Đó là một
>   **đường dẫn GIẢ ĐỊNH trong danh sách `shouldPass` của cổng CI** — nó
>   chứng minh cổng ranh giới không chặn nhầm dạng đường dẫn ấy; nó
>   **không** chứng minh tệp tồn tại.
> - Thứ **thực sự** có trên `main` là **siêu dữ liệu trong bảng `name` của
>   chính các tệp `.ttf`** — tức đúng những gì bảng ngay dưới đây trích ra,
>   và không có gì khác.
>
> **Tài liệu này KHÔNG khẳng định** rằng siêu dữ liệu `name` nhúng trong
> font là đủ về mặt pháp lý để thỏa điều kiện thông báo giấy phép của
> OFL 1.1 hay của EULA KFGQPC. Đó là câu hỏi CHƯA XÁC ĐỊNH — xem đính
> chính ở cuối mục này và rủi ro 5 ở mục 4.
>
> Đính chính này **không đề xuất UI thay thế**: chọn cơ chế hiển thị giấy
> phép là quyết định kỹ thuật/chủ dự án, không phải một sửa lỗi tài liệu.

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
Software typefaces."

> ### ⚠ Đính chính 2026-08-28 (Session 146) — "đã sửa Sprint 33.0" không đúng với `main`
>
> Câu trước đây đứng ở chỗ này — *"Trước Sprint 33.0 app KHÔNG kèm thông
> báo nào — đây là vi phạm giấy phép đã tồn tại suốt và nay đã sửa"* — mô
> tả một biện pháp khắc phục **không có mặt trên `main`**. Tách rõ ba
> việc khác nhau:
>
> 1. **Biện pháp khắc phục CÓ TỒN TẠI trong lịch sử.** Commit `bb445ef`
>    ("Sprint 35.0: Release Candidate engineering and distribution
>    readiness", 2026-07-26) thêm 4 tệp `assets/licenses/*.txt`
>    (Amiri-OFL, Inter-OFL, NotoNaskhArabic-OFL, UthmanicHafs-KFGQPC-EULA),
>    `lib/core/licenses/bundled_font_licenses.dart` — hàm
>    `registerBundledFontLicenses()` gọi `LicenseRegistry.addLicense()` —
>    và `test/font_licenses_test.dart`.
> 2. **`bb445ef` KHÔNG phải tổ tiên của `main`.** Đã kiểm chứng:
>    `git merge-base --is-ancestor bb445ef origin/main` trả về SAI. Commit
>    này chỉ nằm trên `sprint1-my-library` và
>    `ci/dataset-verification-workflow`.
> 3. **Do đó phần "nay đã sửa" KHÔNG đúng với `main`.** Trên `main` không
>    có tệp văn bản giấy phép nào và không có cơ chế đăng ký giấy phép nào.
>
> Thứ còn lại trên `main` là siêu dữ liệu bảng `name` nhúng trong chính
> các tệp `.ttf`. **Tài liệu này KHÔNG kết luận** siêu dữ liệu ấy có tự nó
> thỏa điều kiện thông báo của OFL 1.1 hay không. Đó là **câu hỏi pháp lý
> CHƯA XÁC ĐỊNH (cần ý kiến chuyên môn)** — không giải được bằng suy luận
> trong kho mã, và đính chính này không giải nó.

## 4. Kết luận rủi ro

| # | Rủi ro | Mức | Trạng thái |
|---|---|---|---|
| 1a | **Ibn Kathir (Abridged) là tác phẩm còn bản quyền của Darussalam** | **NGHIÊM TRỌNG** | CÒN TREO — cần phép bằng văn bản, HOẶC gỡ khỏi bản phát hành |
| 1b | Ghi công Ibn Kathir sai (ghi tác giả thế kỷ 14 thay vì nhà xuất bản bản dịch) | **Cao** | CÒN TREO — sửa được ngay ở lần build dữ liệu kế tiếp |
| 1c | Al-Muyassar: chủ sở hữu đã xác định (KFGQPC) nhưng chưa có phép | **Cao** | CÒN TREO — cần liên hệ KFGQPC |
| 1d | Phiên âm Quran.com: chưa có tuyên bố giấy phép | Trung bình | CÒN TREO — bộ dữ liệu lấy qua QDC `api.qurancdn.com`, KHÔNG qua QUL; xem đính chính Session 147 ở mục 1 |
| 2 | Giấy phép bản thu everyayah.com không xác minh được | **Cao** | CÒN TREO — đã có kênh liên hệ: quran.zendesk.com |
| 3 | Saheeh International phi thương mại (`PROJ-P-005`) | Cao nếu thu phí | Đã ghi nhận, chặn mọi mô hình có phí |
| 4 | QuranEnc điều 7 cấm quảng cáo không phù hợp | Trung bình | Đã ghi nhận, chặn mô hình quảng cáo |
| 5 | OFL thiếu thông báo giấy phép | Trung bình | **CÒN TREO trên `main`** — biện pháp khắc phục nằm ở `bb445ef`, không phải tổ tiên của `main`; xem đính chính Session 146 ở mục 3 |
| 6 | Thiếu màn hình ghi nguồn | Trung bình | **ĐÃ SỬA** Sprint 33.0 |
| 7 | KFGQPC mơ hồ với app có phí | Thấp (miễn phí) | Ghi nhận, chỉ quan trọng khi thu phí |

> **Session 146 — bảng rủi ro trên KHÔNG bao gồm hành vi Sao chép/Chia
> sẻ.** Bảng này chỉ đánh giá nội dung **đóng gói kèm app**. Việc app
> phát nội dung ra NGOÀI qua chức năng Sao chép/Chia sẻ là một diện phân
> phối lại riêng, chưa từng được đánh giá ở tài liệu này, và **không**
> được kết luận ở đây. Hồ sơ leo thang dành cho chủ dự án/luật sư:
> `docs/release/SESSION_146_COPY_SHARE_LICENSING_PACKET.md`.

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
