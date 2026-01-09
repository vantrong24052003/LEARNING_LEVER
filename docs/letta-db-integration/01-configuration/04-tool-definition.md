# Phase 1: Register Tool (Tránh lỗi Server)

Việc đăng ký tool đôi khi có thể gây lỗi `NameError: DynamicModel` trên Server Letta nếu định dạng JSON Schema không chuẩn. 

---

## 1. Cách đăng ký "An Toàn" (Khuyên dùng)

Để tránh lỗi, Letta khuyên bạn hãy để nó **tự động suy luận** (Auto-infer) cấu trúc tool từ Python Docstring. 

- **Body (JSON)**: Không cần truyền `jsonSchema`.

```json
{
  "sourceCode": "def query_local_db(query, category=None):\n    \"\"\"\n    Tìm kiếm sản phẩm trong database local của khách hàng.\n\n    Args:\n        query (str): Từ khóa tìm kiếm.\n        category (str): Danh mục (tùy chọn).\n    \"\"\"\n    # Code python này SẼ KHÔNG CHẠY nếu bạn bật requires_approval\n    return \"WAITING_FOR_CLIENT_EXECUTION\"",
  "description": "Tool dùng để truy vấn database local của Client App.",
  "defaultRequiresApproval": true
}
```

### Tại sao cách này an toàn hơn?
- Letta Server tự dùng thư viện Python để parse docstring thành JSON Schema chuẩn của nó.
- Bạn không cần lo lắng về việc viết JSON Schema sai định dạng gây crash server.

---

## 2. Lưu ý về Execution (Thực thi)

Nếu boss thấy Server tự động trả về kết quả `"WAITING_FOR_CLIENT_EXECUTION"` mà không dừng lại hỏi:
1. Đảm bảo `defaultRequiresApproval` luôn là `true`.
2. Trong Project 2 (Rails/Go), code của bạn phải **không được tiếp tục chat** nếu nhận thấy message có `tool_calls`. Bạn phải ngắt flow, chạy DB, rồi mới gửi kết quả ngược lại.

---

## 3. Khắc phục lỗi Crash (422/500)

Nếu boss gặp lỗi `NameError: DynamicModel`:
- **Nguyên nhân**: Do trường `jsonSchema` bạn gửi lên có cấu trúc mà Pydantic (phía Server) không hiểu được.
- **Giải pháp**: Xóa trường `jsonSchema` trong request Postman và sử dụng định dạng docstring `Args:` như ví dụ ở Mục 1.

Tiếp theo: [Agent Setup](./05-agent-setup.md)
