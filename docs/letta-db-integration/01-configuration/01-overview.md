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

1. **User**: Chat trên App của bạn (Project 2).
2. **Project 2**: Forward tin nhắn đó sang Project 1 (API Call).
3. **Project 1**: Trả về hướng dẫn: "Hãy chạy hàm `query_product` với tham số `name='iphone'`".
4. **Project 2**: Thực thi hàm đó bằng code của chính mình (Ruby/Go code).
5. **Project 2**: Gửi kết quả JSON về Project 1.
6. **Project 1**: Trả về câu trả lời văn bản hoàn chỉnh.

Xem chi tiết: [Sequence Diagrams](./03-sequence-diagrams.md)
