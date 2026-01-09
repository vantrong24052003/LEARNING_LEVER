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
  - Gửi chat text -> P1.
  - Nhận tool call -> P2.
  - Thực thi -> P2.
  - Gửi kết quả -> P1.

## Security Boundary

Ranh giới bảo mật nằm giữa P1 và P2.
- **P2 tin tưởng P1** về mặt logic hội thoại.
- **P2 KHÔNG tin tưởng P1** về mặt data access (luôn validate và execute local).
