# Phase 5: Gửi kết quả về Server

## Mục tiêu
Sau khi có kết quả query (JSON String), gửi nó trở lại Letta Server để hoàn tất chu trình reasoning của Agent.

**Thực hiện tại:** Project 2.

## API Specification
Tuân thủ mục 3 trong [API Contract](../01-configuration/06-api-contract.md).

### Payload Construction

Bạn cần lắp ghép payload gửi đi chính xác như sau:

```json
{
  "messages": [
    {
      "role": "tool",
      "tool_call_id": "<ID_NHẬN_ĐƯỢC_TỪ_PHASE_3>",
      "content": "<KẾT_QUẢ_QUERY_STRING>"
    }
  ]
}
```

### Example Mapping

| Field | Nguồn dữ liệu |
|-------|---------------|
| `role` | "tool" (Cố định) |
| `tool_call_id` | Lấy từ response của Phase 3 (`msg.tool_calls[0].id`) |
| `content` | Kết quả của Phase 4 (`JSON.stringify(db_rows)`) |

## Xử lý Final Response

Sau khi gửi request này, Server sẽ trả về một response mới.
- Thường là text (AI đã tổng hợp xong dữ liệu và trả lời user).
- Đôi khi lại là một Tool Call khác (nếu Agent muốn query thêm - xem Phase 6).

Client App cần hiển thị text cuối cùng này ra UI cho User.
