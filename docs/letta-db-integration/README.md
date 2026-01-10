# Letta-DB Integration Suite

Bộ tài liệu hướng dẫn tích hợp **Letta Server** (The Brain) và **Client Application** (The Body/Database).

---

## 📖 Hướng dẫn nhanh

Bỏ qua các tài liệu rườm rà, bạn chỉ cần làm theo đúng 2 bước sau để hệ thống chạy thông suốt:

1.  **[BƯỚC 1: SERVER SETUP (The Brain)](./SERVER_SETUP.md)**: Cách khai báo tool và khởi tạo Agent trên Letta Server.
2.  **[BƯỚC 2: CLIENT IMPLEMENTATION (The Body)](./CLIENT_IMPLEMENTATION.md)**: Cách code logic xử lý flow 3-Payload theo chuẩn **Deterministic**.

---

## 💡 Stuck Points & Rules
- Toàn bộ giao tiếp dựa trên mô hình **1 Endpoint - 3 Payloads**.
- Client App đóng vai trò thực thi local, tuyệt đối không share DB cho AI.
- Sử dụng **Deterministic Paths** để extract dữ liệu, không dùng fallback.
