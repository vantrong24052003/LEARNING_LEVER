# Overview: Client-Server Integration Model

## Kiến trúc hệ thống

Mô hình này tách biệt hoàn toàn **Trí tuệ (AI)** và **Dữ liệu (DB)** thành 2 project riêng biệt.

### Project 1: Letta Server (The Brain)
- Là server chạy Letta (Node.js).
- **Tuyệt đối không** chứa logic nghiệp vụ.
- Chỉ giao tiếp qua JSON API chuẩn.

### Project 2: Client Application (The Body)
- **Công nghệ tự do**: Rails, Go, Python, Java, .NET... (Bất kỳ ngôn ngữ nào gửi được HTTP Request).
- **Dữ liệu**: Chứa Database thật (Postgres, MySQL...).
- **Nhiệm vụ**:
  - Gửi text user chat lên P1.
  - Nhận lệnh (JSON) từ P1.
  - Chạy query SQL local.
  - Gửi data trả về P1.

## Tại sao mô hình này hoạt động với mọi ngôn ngữ?

Project 1 và Project 2 **không share code**. Chúng chỉ share **API Contract**.
Miễn là Project 2 của bạn tuân thủ đúng [API Contract](./06-api-contract.md), nó có thể giao tiếp mượt mà với Project 1.

## Workflow Tổng Quát

Hệ thống vận hành theo 3 luồng chính tùy thuộc vào độ phức tạp của yêu cầu User:

### Luồng A: Chat cơ bản (Text-only)
1. **User**: Hỏi một câu thông thường (ví dụ: "Chào bạn").
2. **Project 2**: Forward tin nhắn sang Project 1 (POST `{LETTA_SERVER_URL}/api/agents/:agentId/messages`).  
   *(Mặc định hiện tại: `http://localhost:4000`)*
3. **Project 1**: Trả về text trả lời ngay lập tức.
4. **Project 2**: Hiển thị cho User.

### Luồng B: Gọi Tool có xác nhận (HITL Flow)
*Dành cho các tác vụ quan trọng như Query/Update Database.*
1. **User**: "Tìm 5 bài viết published".
2. **Project 2**: Forward tin nhắn sang Project 1.
3. **Project 1**: Trả về yêu cầu Tool Call (`requires_approval`).
4. **Project 2**: **Chờ User xác nhận** -> Gửi Approve lên P1 (`approve: true`).
5. **Project 1**: Xác nhận "Approved" (409 Conflict hoặc Message Type).
6. **Project 2**: Thực thi logic local (SQL Query).
7. **Project 2**: Gửi kết quả `role: system` lên Project 1.
8. **Project 1**: Trả về text tổng hợp dữ liệu cuối cùng cho User.

### Luồng C: Gọi Tool tự động (Auto-execution)
*Dành cho các tool mang tính tiện ích (Search web, Tính toán).*
1. **User**: "Fetch thông tin ABC trên mạng".
2. **Project 2**: Forward tin nhắn sang Project 1.
3. **Project 1**: Trả về yêu cầu Tool Call (không yêu cầu approval).
4. **Project 2**: **Tự động thực thi** logic local ngay lập tức.
5. **Project 2**: Gửi kết quả lên Project 1.
6. **Project 1**: Trả về text trả lời cuối cùng.

Xem chi tiết: [Sequence Diagrams](./03-sequence-diagrams.md)
