# Phase 0: Chuẩn bị thực thi tại Client App (Project 2)

## Mục tiêu
Project 2 của bạn (Rails/Go...) phải đóng vai trò là "Cơ bắp" - nơi thực hiện các công việc nặng nhọc như truy vấn Database.

---

## 1. Logic vận hành

Dù bạn dùng công nghệ gì, logic phải tuân thủ:
1. Nhận **Tên Tool** và **Tham số** từ Project 1.
2. Tự xử lý bằng code backend của bạn.
3. Trả về kết quả thô (Dạng String/JSON).

---

## 2. Ví dụ logic thực thi (Agnostic)

### Concept (Mọi ngôn ngữ)
```text
Hàm thực thi(arguments):
   kết_quả = DB.Execute("SELECT * FROM ... WHERE ...", arguments.query)
   trả_về JSON_STRINGIFY(kết_quả)
```

### Ruby on Rails (Example)
```ruby
def execute_query_db(args)
  # Logic lấy từ Database thật của App Rails
  results = Product.where("name LIKE ?", "%#{args['query']}%").limit(5)
  results.to_json
end
```

### Golang (Example)
```go
func ExecuteQuery(args map[string]interface{}) string {
    // Logic dùng GORM hoặc SQL driver
    products := []Product{}
    db.Where("name LIKE ?", args["query"]).Find(&products)
    b, _ := json.Marshal(products)
    return string(b)
}
```

---

## Checkpoint
Bạn hãy viết hoàn thiện các hàm truy vấn này trước. Đảm bảo chúng có thể chạy độc lập và trả về dữ liệu đúng trước khi gắn vào flow AI.

Sau khi xong, hãy sang [Bước 1: Đăng ký Tool](../01-configuration/04-tool-definition.md) để khai báo khung của hàm này lên Server.
