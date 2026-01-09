# Troubleshooting Guide

## Issues theo Component

### Project 1: Letta Server (The Brain)

#### 💣 Agent không gọi tool
**Hiện tượng**: Client gửi chat "Tìm laptop", Server trả về text "Tôi không biết" thay vì Tool Call.
**Nguyên nhân**:
- System prompt chưa đủ mạnh ("You MUST use tool").
- Agent chưa được attach tool `query_local_db`.
- Tool description trên Server sai lệch với mục đích user.
**Khắc phục**:
- Vào Dashboard Server check prompt & models.
- Dùng `api/agents/{id}/tools` để verify tool đã attach.

#### 💣 Register Tool thất bại
**Hiện tượng**: Client chạy script register bị lỗi 400/500.
**Nguyên nhân**: JSON Schema sai format.
**Khắc phục**: Properties phải có `type`, `description`. Check log server.

---

### Project 2: Client Application (The Body)

#### 💣 Không nhận được Tool Request
**Hiện tượng**: Server có vẻ đã xử lý xong nhưng Client không nhận được gì đặc biệt.
**Nguyên nhân**:
- Code Client chưa check kỹ `message_type == 'tool_call'`.
- Client dùng version SDK cũ không parse được format mới của Server.
**Khắc phục**:
- `console.log` toàn bộ response raw từ Server để inspect.
- Nếu dùng REST API, check array `tool_calls`.

#### 💣 JSON Parse Error
**Hiện tượng**: Client crash khi đọc `args`.
**Nguyên nhân**: Server (LLM) sinh ra JSON invalid (thiếu ngoặc, dư phẩy).
**Khắc phục**:
- Wrap `JSON.parse` trong `try-catch`.
- Nếu lỗi thường xuyên, chỉnh lại Prompt trên Server: "Output valid JSON only".

#### 💣 DB Connection Failed
**Hiện tượng**: Client nhận request ok nhưng không query được Data.
**Nguyên nhân**: Lỗi cấu hình DB local ở Project 2.
**Khắc phục**: Chạy lại script test local (Phase 0) để debug.

#### 💣 Context Window Exceeded
**Hiện tượng**: Request gửi tool output lên Server bị lỗi 400.
**Nguyên nhân**: Client trả về quá nhiều dữ liệu (query SELECT * 1000 dòng).
**Khắc phục**: Luôn `LIMIT 5-10` trong câu SQL ở Client.

## Debugging Checklist

Khi flow bị gãy, hãy check lần lượt:

1. [ ] **Project 2 -> Project 1**: Chat message có lên tới Server không? (Check log Server)
2. [ ] **Project 1 Thought**: Server có quyết định gọi tool không? (Check log Server/Dashboard)
3. [ ] **Project 1 -> Project 2**: Client có nhận được tool call không? (Check log Client)
4. **Project 2 Execution**:
   - [ ] Arguments parse có đúng không?
   - [ ] Query DB có ra data không?
5. [ ] **Project 2 -> Project 1**: Submit output có thành công không?

## Useful Commands (Client Side)

```bash
# Test connection tới Server (Project 1)
curl http://letta-server.com/v1/health

# Test DB Local (Project 2)
npm run test:db-local
```
