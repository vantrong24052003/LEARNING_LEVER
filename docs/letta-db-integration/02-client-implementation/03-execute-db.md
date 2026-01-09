# Phase 4: Execute DB tại Client App (Project 2)

## Mục tiêu
Dựa vào tên tool (`func_name`) và tham số (`args`) nhận được ở Phase 3, Backend của bạn sẽ chạy logic tương ứng.

**Thực hiện tại:** Project 2.

## Mapping Logic (Switch-Case)

Bạn cần một cơ chế map từ "Tên tool AI biết" sang "Hàm code thật chạy".

### Pseudo Code

```text
SWITCH tool_name:
    CASE "query_local_db":
        result = Call_DB_Function(args.category, args.max_price)
        BREAK
    CASE "check_order_status":
        result = Call_Order_Service(args.order_id)
        BREAK
    DEFAULT:
        result = "Error: Tool not found"
```

### Example (Node.js)

```typescript
if (funcName === 'query_local_db') {
  const data = await queryProductLocal(args.category, args.max_price);
  return JSON.stringify(data);
}
```

### Example (Rails)

```ruby
case func_name
when 'query_local_db'
  data = ProductService.query_local_db(args['category'], args['max_price'])
  return data.to_json
when 'another_tool'
  # ...
end
```

## Lưu ý quan trọng
- **Format Output**: Kết quả trả về từ hàm DB phải được convert sang **String** (thường là JSON String) trước khi gửi lại cho AI.
- **Error Handling**: Nếu query lỗi, hãy trả về chuỗi thông báo lỗi (ví dụ: "Error: Database timeout") để AI biết mà xin lỗi user.
