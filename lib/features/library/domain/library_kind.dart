/// Các nhóm chú thích người dùng gắn với Ayah, mỗi nhóm ứng với một
/// bảng dữ liệu đã có sẵn. Bốn nhóm đầu render trong "Thư viện của
/// tôi" (`LibraryScreen`, 4 tab cố định — không lặp qua
/// `LibraryKind.values` nên thêm giá trị enum KHÔNG tự thêm tab).
/// [review] là dữ liệu cho Revision Queue (DR-2026-0004 mục 3) —
/// tái dùng cùng mô hình, nhưng hiển thị ở một màn hình riêng, không
/// phải tab thứ 5 của Thư viện.
enum LibraryKind {
  bookmarks,
  favorites,
  notes,
  highlights,
  review,
}
