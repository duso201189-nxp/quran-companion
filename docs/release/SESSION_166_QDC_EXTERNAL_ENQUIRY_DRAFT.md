# Session 166 — QDC Transliteration: External Enquiry Draft

**Baseline:** `main` at `8eed01c36d2638699dae9ea37c2f4a1169d874fc` — **Prepared:** 2026-08-29 — **Scope:** the
Latin transliteration shipped in `assets/database/quran.sqlite` (`translation_sources.code = 'translit_latin'`).

**`P2-2` = OPEN. Licence = UNKNOWN — COUNSEL REQUIRED. NOT SENT.** A draft held for owner decision **D-A**
(Session 165 §1). It adds no evidence and reaches no legal conclusion. It does not state that any upstream
terms govern this dataset, and it does not state that they do not.

## 1. Purpose

Session 164 §10 **O-2** recorded that a direct answer from the operator of `api.qurancdn.com` would resolve
more of the open evidence matrix than further repository analysis; Session 165 §1 made sending such an enquiry
owner decision **D-A**, with no text drafted to decide against. This file supplies that text. Drafting is not
sending, and does not pre-empt **D-A**. The enquiry seeks clarification only: it asks what applies, and
asserts nothing about what applies.

## 2. Recipient

| Field | Value |
|---|---|
| To | `developers@quran.com` |
| Basis | developer contact published in the Quran Foundation Developer Terms of Service — Session 164 §10 **O-2**, sources **S-3**/**S-4** |
| Check before sending | re-confirm the address is still the published contact; **S-3** was retrieved 2026-08-29 |
| From | the owner, in the owner's own name. `[owner name]` and `[reply-to address]` are placeholders; no owner contact detail is recorded in this file |

The draft does not assume this recipient holds rights in the dataset; where the operator of the endpoint is unconfirmed, it says so and asks to be redirected.

## 3. Subject

`Terms applying to word-by-word transliteration from api.qurancdn.com`

## 4. English email draft — primary artifact

```text
Dear Quran Foundation team,

I maintain Qur'an Companion, a Qur'an study application for mobile devices; its source is publicly
viewable at https://github.com/duso201189-nxp/quran-companion. I am writing to ask which terms apply
to one dataset the project uses.

On 6 July 2026 the project made a single retrieval of the word-by-word Latin transliteration for all
114 chapters from

  https://api.qurancdn.com/api/qdc/verses/by_chapter/{chapter}?words=true&word_fields=transliteration,text_uthmani

iterating chapters 1 to 114 and paginating each to the end. No API key, OAuth credential or developer
registration was used, and there has been no further retrieval since.

The project then normalised the transliteration's spelling — consistent capitalisation of the divine
name, consistent hamza and ayn characters, and a pass aligning minority spellings with the majority
form — and stored the result in a SQLite database file. That file is bundled inside the application
so the feature works offline, and it is also present in the public source repository above. The
application has not been released; no version has been published to any application store. The intention
is to submit it to Google Play and the Apple App Store. It carries no charge, no advertising and no
in-app purchases, and I would like to understand the position before submitting.

I located two published documents that may bear on this — the Quran.com Terms and Conditions, and the Quran
Foundation Developer Terms of Service — and I am using this address because it is the developer contact given
in the latter. I have not been able to confirm from any published document which entity operates
api.qurancdn.com, and I am not assuming that Quran Foundation holds rights in this transliteration; that is
among the things I am asking. If this enquiry belongs elsewhere, please do point me to the right place.

My questions:

 1. Do either of those two documents apply to content returned by api.qurancdn.com/api/qdc/? Neither
    of them names that host.
 2. If either applies, does it extend to the word-by-word Latin transliteration that endpoint returns?
    Neither document mentions transliteration or word-by-word data.
 3. May a project retrieve the complete transliteration for all 114 chapters and bundle it inside a
    mobile application for offline use?
 4. The Developer Terms list, among things a developer must not do, "Cache or store QF Content longer
    than 1 week unless expressly permitted." How should that be read for a copy shipped inside an
    installed application, rather than one held in a cache?
 5. The same list includes "Attempt to extract, scrape, or index QF Content ... outside the API
    responses." How should that be read for a single one-time paginated retrieval of 114 chapters
    through the documented endpoint?
 6. Which licence or terms govern onward redistribution of this transliteration inside a distributed application?
 7. Is attribution required? If so, what exact wording and what link should appear, and where?
 8. May an application containing this dataset be distributed through application stores, given that a
    store is a commercial channel even where the application itself carries no charge?
 9. Are the spelling normalisation and the database conversion described above within contemplation,
    or would written consent be needed first?
10. Is there a separate Quran.com or QDC data licence for this dataset that supplements or replaces
    the two documents above?
11. Who authored this transliteration, and is it held under a third-party licence carrying its own
    conditions?
12. For data retrieved on 6 July 2026 and redistributed thereafter, which version of any applicable terms
    would you regard as operative — that in force on the date, or the current one? Both were amended since.

If any of this is more easily answered by pointing me to a document I have missed, that would help
just as much. I am ready to make whatever changes your answer indicates, including removing the
dataset. Thank you for your time, and for the work behind Quran.com.

Kind regards,
[owner name]
[reply-to address]
```

## 5. Vietnamese translation — owner review only; §4 stays the version that would be sent

```text
Kính gửi nhóm Quran Foundation,

Tôi phụ trách Qur'an Companion, một ứng dụng học Kinh Qur'an trên thiết bị di động; mã nguồn xem công
khai tại https://github.com/duso201189-nxp/quran-companion. Tôi viết thư này để hỏi những điều khoản
nào áp dụng cho một bộ dữ liệu mà dự án đang dùng.

Ngày 6 tháng 7 năm 2026, dự án thực hiện một lần lấy duy nhất phần phiên âm Latin theo từng từ cho
toàn bộ 114 chương từ

  https://api.qurancdn.com/api/qdc/verses/by_chapter/{chapter}?words=true&word_fields=transliteration,text_uthmani

duyệt các chương từ 1 đến 114 và phân trang đến hết. Không dùng khóa API, thông tin xác thực OAuth hay
đăng ký nhà phát triển nào, và từ đó đến nay không lấy thêm lần nào.

Sau đó dự án chuẩn hóa chính tả của phần phiên âm — viết hoa thống nhất danh xưng của Thượng Đế, thống
nhất ký tự hamza và ayn, và một lượt đưa các cách viết thiểu số về dạng phổ biến — rồi lưu kết quả vào
một tệp cơ sở dữ liệu SQLite. Tệp đó được đóng gói bên trong ứng dụng để tính năng hoạt động ngoại tuyến,
và cũng có trong kho mã nguồn công khai nêu trên. Ứng dụng chưa phát hành; chưa có phiên bản nào được đưa
lên bất kỳ chợ ứng dụng nào. Dự định là nộp lên Google Play và Apple App Store. Ứng dụng không thu phí,
không quảng cáo, không mua trong ứng dụng, và tôi muốn hiểu rõ tình hình trước khi nộp.

Tôi tìm thấy hai văn bản đã công bố có thể liên quan — Quran.com Terms and Conditions, và Quran Foundation
Developer Terms of Service — và tôi dùng địa chỉ này vì đây là đầu mối nhà phát triển nêu trong văn bản thứ
hai. Tôi chưa thể xác nhận từ bất kỳ văn bản công bố nào rằng đơn vị nào vận hành api.qurancdn.com, và tôi
không mặc định rằng Quran Foundation nắm quyền đối với phần phiên âm này; đó chính là một trong những điều
tôi đang hỏi. Nếu thư này nên gửi tới nơi khác, xin quý vị chỉ giúp nơi phù hợp.

Các câu hỏi của tôi:

 1. Hai văn bản đó có áp dụng cho nội dung trả về từ api.qurancdn.com/api/qdc/ không? Không văn bản
    nào nêu tên máy chủ đó.
 2. Nếu có áp dụng, phạm vi đó có bao gồm phần phiên âm Latin theo từng từ mà endpoint đó trả về
    không? Không văn bản nào nhắc tới phiên âm hay dữ liệu theo từng từ.
 3. Một dự án có thể lấy toàn bộ phần phiên âm cho cả 114 chương rồi đóng gói bên trong ứng dụng di
    động để dùng ngoại tuyến không?
 4. Developer Terms liệt kê, trong những điều nhà phát triển không được làm, "Cache or store QF
    Content longer than 1 week unless expressly permitted." Điều đó nên hiểu thế nào với một bản sao
    nằm sẵn trong ứng dụng đã cài, thay vì một bản nằm trong bộ nhớ đệm?
 5. Cùng danh sách đó có "Attempt to extract, scrape, or index QF Content ... outside the API
    responses." Điều đó nên hiểu thế nào với một lần lấy dữ liệu duy nhất, có phân trang, cho 114
    chương qua đúng endpoint đã công bố?
 6. Giấy phép hay điều khoản nào điều chỉnh việc phân phối lại phần phiên âm này trong một ứng dụng phát hành?
 7. Có bắt buộc ghi nguồn không? Nếu có thì cần đúng câu chữ nào, đúng liên kết nào, và đặt ở đâu?
 8. Ứng dụng chứa bộ dữ liệu này có thể phát hành qua các chợ ứng dụng không, xét rằng chợ ứng dụng là
    kênh thương mại kể cả khi bản thân ứng dụng không thu phí?
 9. Việc chuẩn hóa chính tả và việc chuyển thành cơ sở dữ liệu nêu trên có nằm trong dự liệu không,
    hay cần có văn bản chấp thuận trước?
10. Có tồn tại một giấy phép dữ liệu riêng của Quran.com hoặc QDC cho bộ dữ liệu này, bổ sung hoặc
    thay thế hai văn bản trên, hay không?
11. Ai là tác giả của phần phiên âm này, và nó có thuộc một giấy phép của bên thứ ba kèm điều kiện
    riêng hay không?
12. Với dữ liệu lấy ngày 6 tháng 7 năm 2026 rồi phân phối lại sau đó, quý vị xem phiên bản điều khoản nào là
    phiên bản có hiệu lực — phiên bản tại ngày đó, hay phiên bản hiện hành? Cả hai đều đã sửa đổi sau đó.

Nếu phần nào dễ trả lời hơn bằng cách chỉ cho tôi một văn bản tôi đã bỏ sót thì cũng hữu ích không
kém. Tôi sẵn sàng thực hiện mọi thay đổi mà câu trả lời của quý vị cho thấy là cần, kể cả gỡ bỏ bộ dữ
liệu. Xin cảm ơn quý vị đã dành thời gian, và cảm ơn công việc phía sau Quran.com.

Trân trọng,
[tên chủ dự án]
[địa chỉ thư trả lời]
```

## 6. Questions checklist

Each point the set must establish, mapped to the question carrying it. Wording is optimised for an external
reader; substance is unchanged from Session 165 §6 **Q1**–**Q12**, and nothing was dropped or merged.

| Q | Must establish | Q | Must establish | Q | Must establish |
|---|---|---|---|---|---|
| 1 | terms reach the endpoint | 5 | scraping clause vs the one-time crawl | 9 | normalisation, DB conversion |
| 2 | terms reach this transliteration | 6 | which licence governs redistribution | 10 | separate QDC data licence? |
| 3 | complete offline bundling | 7 | attribution: owed, wording, link, place | 11 | authorship, third-party rights |
| 4 | 1-week caching vs a shipped copy | 8 | commercial app-store distribution | 12 | terms version for 2026-07-06 |

## 7. Evidence references

Every factual sentence in §4 traces to one of these; no new fact is introduced.
`docs/release/SESSION_164_QDC_LICENSING_EVIDENCE_PACKET.md` — §2 dataset and editorial rewriting, §3 retrieval
path and unauthenticated access, §5 sources **S-1**–**S-9** and verbatim clauses, §10 **O-2** recipient, §12
retrieval and amendment dates. `docs/release/SESSION_165_QDC_OWNER_DECISION_BRIEF.md` — §1 **D-A**, §6
**Q1**–**Q12**. `docs/release/V1_STORE_LEGAL_READINESS.md` — "Status: NOT RELEASED", **P2-2**.
`docs/LICENSING.md` §1 row 2 — licence recorded as CHƯA XÁC ĐỊNH / UNKNOWN. `pubspec.yaml` — version
`0.8.1+7`, no advertising or in-app-purchase dependency. `github.com/duso201189-nxp/quran-companion` —
repository visibility PUBLIC, checked 2026-08-29.

**One wording change from the Session 165 §6 context sentence, made for accuracy.** It opens "An open-source
Qur'an study application"; the repository is publicly visible but carries **no licence file**, so
"open-source" is not established by repository evidence. §4 states the verifiable fact instead — the source is
publicly viewable at the named URL — and drops the label.

## 8. Safety review

Every sentence of §4 and §5 was read against the constraints. The draft admits no infringement, no breach and
no unauthorised redistribution; asserts neither that permission exists nor that it does not; asserts no
ownership; and asserts neither that the site Terms and Conditions govern the endpoint nor that the Developer
Terms of Service govern the dataset. It reaches no legal conclusion in either direction. *Prohibited*,
*violation*, *breach*, *infringement*, *compliant*, *authorised* and *ownership* appear nowhere in §4 or §5,
in any form. The flagged words that do appear are each quoted or interrogative: **"permitted"** only inside
the Q4 quotation of the Developer Terms, marked and attributed as a quotation; **"required"** only in Q7 —
"Is attribution required?" asks, and states nothing either way; **"licence"** in Q6, Q10 and Q11, naming what
is being asked about, never claiming one was granted; **"rights"** once, disclaiming an assumption — "I am
not assuming that Quran Foundation holds rights". Two facts could be mistaken for admissions — the database
file sits in a public repository, and the dataset is bundled offline — and both are stated deliberately and
neutrally, because withholding either would make any answer less reliable; neither attaches a legal
characterisation to the conduct it describes. The tone carries no apology, urgency, appeal or accusation, and
the closing offer of changes states willingness, not an acknowledgement that changes are owed.

## 9. NOT SENT

**This enquiry has not been sent, submitted, or communicated to any third party, in any form, through any
channel.** No contact with Quran.com, Quran Foundation, Inc., or any other external party was made in
preparing it. The address in §2 is transcribed from repository evidence, not written to. Sending requires
owner decision **D-A** (Session 165 §1), and is an act the owner takes personally. `P2-2` remains **OPEN**.
The licence of the shipped transliteration remains **UNKNOWN — COUNSEL REQUIRED**. **D-A** remains undecided
— this file is what it now decides on. Application code, the database, and all ADR/DR records are unchanged
by this file. No clearance of any kind is asserted or implied; this file does not clear, and does not block,
any release.
