# API Contract Specification

**Base URL**: `http://localhost:4000/api`

---

## 1. Register Tool
Gửi request đăng ký capability.

- **Endpoint**: `POST /agents/tools`
- **Payload (Safe Mode)**:
```json
{
  "sourceCode": "def my_tool(query):\n    \"\"\"\n    Mô tả tool.\n    Args:\n        query (str): Tham số\n    \"\"\"\n    return \"PENDING\"",
  "defaultRequiresApproval": true
}
```
*Lưu ý: Hạn chế dùng `jsonSchema` trực tiếp nếu gặp lỗi `DynamicModel`.*

---

## 2. Chat & Tool Intersection

Khi `POST /agents/{agent_id}/messages`, nếu nhận response có `message_type: "tool_call_message"`:

1. **DỪNG** việc hiển thị tin nhắn cho user.
2. **LẤY** `tool_calls`.
3. **CHẠY** logic local (Rails/Go).
4. **SEND** kết quả về Server qua API `/messages` với `role: tool`.

---

## 3. Submit Tool Result

```json
{
  "messages": [
    {
      "role": "tool",
      "tool_call_id": "id_của_call",
      "content": "Kết quả cuối cùng từ Rails"
    }
  ]
}
```
