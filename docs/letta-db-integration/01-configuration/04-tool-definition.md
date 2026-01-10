# Phase 1: Tool Definition (Định nghĩa Tool)

Tài liệu này đặc tả cấu hình chuẩn để đăng ký Capability (Tool) từ Client App lên Letta Server.

---

## 1. API Đăng ký Tool

Client Application (Project 2) cần khai báo các hàm local để Letta Server (Project 1) có thể lập kế hoạch gọi tool.

- **Endpoint**: `POST {LETTA_SERVER_URL}/api/letta/agents/tools`
  *(Mặc định: `http://localhost:4000/api/letta/agents/tools`)*

- **Payload Cấu hình chuẩn**:
```json
{
  "name": "query_local_db",
  "description": "Truy vấn database local của Client App để tìm thông tin bài viết.",
  "sourceCode": "def query_local_db(query: str, category: str = None):\n    \"\"\"\n    Mô tả: Tìm kiếm bài viết trong DB local.\n\n    Args:\n        query (str): Từ khóa tìm kiếm.\n        category (str): Danh mục bài viết (tùy chọn).\n    \"\"\"\n    return \"WAITING_FOR_CLIENT_EXECUTION\"",
  "defaultRequiresApproval": true
}
```

---

## 2. Quy trình Vận hành (Workflow)

Hệ thống vận hành theo cơ chế ủy thác thực thi:

1. **Đăng ký (Setup)**: Client gửi định nghĩa hàm lên Project 1. Project 1 lưu trữ "khuôn mẫu" của hàm.
2. **Yêu cầu (Trigger)**: Khi User gửi yêu cầu cần dữ liệu, Project 1 trả về tín hiệu `tool_call_message` chứa tên hàm và tham số đã parse.
3. **Thực thi (Local)**: Project 2 (Client) nhận tín hiệu, thực thi code SQL/Logic thực tế trên máy local.
4. **Báo cáo (Result)**: Project 2 gửi kết quả JSON ngược lại cho Project 1 để hoàn tất câu trả lời.

---

## 3. Quy ước Kỹ thuật (Specification)

Để đảm bảo AI nhận diện chính xác tham số (Parameters), Source Code đăng ký **PHẢI** tuân thủ:

- **Type Hinting**: Khai báo kiểu dữ liệu rõ ràng (ví dụ: `query: str`, `limit: int`).
- **Docstring**: Sử dụng định dạng `Args:` trong cặp `"""..."""` để mô tả ý nghĩa từng tham số.
- **Return Value**: Giá trị trả về trong `sourceCode` không quan trọng vì logic thực tế chạy ở Client, nhưng nên để chuỗi thông báo (ví dụ: `WAITING...`).

> [!IMPORTANT]
> Toàn bộ logic nghiệp vụ (SQL Query, Business Rules) nằm tại **Project 2**. Project 1 chỉ đóng vai trò là "Bộ não" điều hướng.

Tiếp theo: [Agent Setup](./05-agent-setup.md)
