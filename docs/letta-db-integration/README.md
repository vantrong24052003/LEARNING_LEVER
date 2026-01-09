# Letta-DB Integration Guide

Documentation này hướng dẫn cách tích hợp **Letta Server** (Project 1 - Bộ não) với **Client Application** (Project 2 - Thân thể/DB) của bạn.

---

## 🚀 Quy trình Tích hợp (3 Bước nhanh)

Để hệ thống hoạt động, bạn cần thực hiện theo đúng thứ tự sau:

1.  **Bước 1: Register Tool (Khai báo)**
    - Gọi API lên **Project 1** để đăng ký "khung" của công cụ.
    - Mục đích: Để Letta Server biết tool đó tên gì, nhận tham số nào.
    - Xem chi tiết tại: [Tool Registration](./01-configuration/04-tool-definition.md).

2.  **Bước 2: Create Agent (Gắn Tool)**
    - Tạo Agent trên **Project 1** và liệt kê tên tool đã đăng ký ở Bước 1 vào danh sách `tools`.
    - Xem chi tiết tại: [Agent Setup](./01-configuration/05-agent-setup.md).

3.  **Bước 3: Execute Logic (Thực thi)**
    - Khi bạn chat, **Project 1** sẽ gửi yêu cầu gọi tool về **Project 2**.
    - **Project 2** code logic SQL/Database của chính mình để lấy dữ liệu và gửi trả lại P1.
    - Xem chi tiết tại: [Client Implementation](./02-client-implementation/).

---

## 📁 Cấu trúc Tài liệu

### 1. [Configuration & Architecture](./01-configuration/)
Dành cho việc setup "Bộ não" (Project 1).

- **1.1 [Overview](./01-configuration/01-overview.md)**: Hiểu mô hình Brain-Body.
- **1.2 [Architecture](./01-configuration/02-architecture.md)**: Sơ đồ thành phần.
- **1.3 [Sequence Diagrams](./01-configuration/03-sequence-diagrams.md)**: Luồng dữ liệu.
- **1.4 [Tool Registration](./01-configuration/04-tool-definition.md)**: 🛠️ Cách đăng ký tool lên Server.
- **1.5 [Agent Setup](./01-configuration/05-agent-setup.md)**: Cách tạo Agent.
- **1.6 [API Contract](./01-configuration/06-api-contract.md)**: 📄 **QUAN TRỌNG** - Định nghĩa chuẩn JSON.

### 2. [Client Implementation](./02-client-implementation/)
Dành cho việc code "Thân thể" (Project 2 - Rails/Go/Python...).

- **2.1 [DB Preparation](./02-client-implementation/01-db-preparation.md)**: Chuẩn bị query local.
- **2.2 [Receive Request](./02-client-implementation/02-receive-request.md)**: Bắt lệnh gọi tool từ Server.
- **2.3 [Execute DB](./02-client-implementation/03-execute-db.md)**: Mapping & Chạy SQL.
- **2.4 [Send Response](./02-client-implementation/04-send-response.md)**: Gửi data về lại cho não.

---

## 🛠 Support
- **[Troubleshooting](./troubleshooting.md)**: Các lỗi thường gặp (404, Missing tools...).
