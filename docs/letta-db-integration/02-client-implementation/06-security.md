# Phase 7: Security tại Client App (Project 2)

## Tại sao cần bảo mật?
Client App đang mở một cánh cửa cho Server (Project 1) điều khiển. Nếu Server bị hack hoặc Agent bị prompt injection, nó có thể yêu cầu query nguy hiểm.

**Client App phải tự bảo vệ mình.**

## Các biện pháp bảo vệ (Client Side)

### 1. Hard Limit
Agent có thể yêu cầu lấy 1 triệu bản ghi. Client phải luôn override limit.

```typescript
// Luôn luôn limit 20 dòng dù agent có đòi bao nhiêu
const LIMIT = 20;
sql += ` LIMIT ${LIMIT}`;
```

### 2. Read-Only DB User
DB Connection mà Client App dùng để chạy tool queries nên là **Read-Only**.

```sql
GRANT SELECT ON products TO agent_viewer;
-- Cấm INSERT/DROP/DELETE
```

### 3. Input Validation
Kiểm tra kỹ arguments Server gửi về trước khi chạy.

```typescript
if (typeof args.max_price !== 'number') {
  throw new Error("Invalid price format");
}
```

### 4. PII Scrubbing (Loại bỏ dữ liệu nhạy cảm)

Trước khi gửi JSON về Server, boss **BẮT BUỘC** phải xóa toàn bộ các cột nhạy cảm. AI không cần biết danh tính thực của User để làm việc.

> [!CAUTION]
> Tuyệt đối KHÔNG trả về các thông tin sau:
> - `password`, `password_digest`
> - `email`
> - `phone_number`, `address` (Địa chỉ nhà)
> - `token`, `secret_key`

**Ví dụ implementation (Rails):**
```ruby
# Loại bỏ các cột cấm trước khi gửi kết quả
result = posts.as_json(except: [:author_email, :password_digest])
```

**Ví dụ implementation (Go):**
```go
// Chỉ select những field an toàn
rows, err := db.Query("SELECT title, content, status FROM posts ...")
```

## Checkpoint
Thử giả lập Server gửi request query 1000 dòng. Client vẫn chỉ trả về 20 dòng -> **PASS**.
