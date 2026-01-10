# API Contract Specification

**Base URL**: `http://localhost:4000/api`

---

## 1. Register Tool
Gửi request đăng ký capability.

- **Endpoint**: `POST {LETTA_SERVER_URL}/api/agents/tools`
  *(Hiện tại: `http://localhost:4000/api/agents/tools`)*
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

Khi `POST {LETTA_SERVER_URL}/api/agents/{agent_id}/messages`, nếu nhận response có `message_type: "tool_call_message"`:
*(Hiện tại: `http://localhost:4000/api/agents/...`)*

1. **DỪNG** việc hiển thị tin nhắn cho user.
2. **LẤY** `tool_calls`.
3. **CHẠY** logic local (Rails/Go).
4. **SEND** kết quả về Server qua API `POST {LETTA_SERVER_URL}/api/agents/{agent_id}/messages` với `role: tool`.

---

## 3. Submit Tool Result

```json
{
  "messages": [
    {
      "role": "system",
      "content": "Tool 'query_local_db' output: {\"id\": 1, \"title\": \"...\"}"
    }
  ]
}
```
