# Architecture: Letta Server & Client App

## System Overview

```
    PROJECT 1 (SERVER)                     PROJECT 2 (CLIENT)
  ┌────────────────────┐                 ┌────────────────────┐
  │                    │     API         │                    │
  │   Letta Cloud /    │ <─────────────> │   Client Backend   │
  │   Self-Hosted      │   Protocol      │                    │
  │                    │                 │ ┌────────────────┐ │
  │  [Agent Memory]    │                 │ │    Local DB    │ │
  │  [Planner]         │                 │ └────────────────┘ │
  └────────────────────┘                 └────────────────────┘
         BRAIN                                  BODY
```

## Component Roles

### Project 1: Letta Server
- **Host**: Có thể là Cloud của Letta AI hoặc Server Docker tự host.
- **Data**: Chỉ lưu conversation history và memory ảo.
- **Access**: KHÔNG access trực tiếp vào DB của Project 2.

### Project 2: Client Application
- **Host**: Server của khách hàng / Local machine.
- **Logic**: Chứa code query DB, business rules.
- **Mechanism**:
  - **Giai đoạn Thiết lập (Setup)**: Client định nghĩa sẵn logic các hàm (ví dụ: `query_local_db`) và chủ động **Đăng ký (Register)** danh sách Tool này lên Project 1.
  - **Giai đoạn Vận hành (Runtime)**:
    1. User gửi tin nhắn -> Project 2.
    2. Project 2 forward tin nhắn -> Project 1.
    3. Project 1 yêu cầu gọi Tool (dựa trên danh sách đã đăng ký) -> Project 2.
    4. Project 2 thực thi logic thực tế (SQL/Business rules) -> Trả kết quả về Project 1.

## Security Boundary

Ranh giới bảo mật nằm giữa P1 và P2.
- **P2 tin tưởng P1** về mặt logic hội thoại.
- **P2 KHÔNG tin tưởng P1** về mặt data access (luôn validate và execute local).
