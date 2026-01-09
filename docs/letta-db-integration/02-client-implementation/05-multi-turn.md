# Phase 6: Multi-turn Refinement

## Context nằm ở đâu?

- **Context và Memory** nằm hoàn toàn ở **Project 1 (Letta Server)**.
- **Client App (Project 2)** là stateless (về mặt AI). Nó chỉ việc execute những gì Server bảo.

## Luồng đi Refinement

### Turn 1
1. **User**: "Có iphone không?"
2. **Server**: Bảo Client "Query iphone".
3. **Client**: Trả về list 5 iphone.
4. **Server**: "Có 5 chiếc..."

### Turn 2
5. **User**: "Cái nào màu đen?"
6. **Server**: (Tự nhớ 5 chiếc cũ, tự nhớ context iphone) -> Bảo Client "Query iphone màu đen".
7. **Client**: Query DB với filter màu đen.
8. **Client**: Trả về 2 chiếc.
9. **Server**: "Có 2 chiếc màu đen..."

## Lưu ý cho Client App
Client App không cần logic để "nhớ" user đang hỏi về iphone. Client App chỉ cần logic: **Nhận request -> Query -> Trả về**. Việc nhớ là việc của Server.

## Checkpoint
Test 2 câu liên tiếp như trên. Nếu câu 2 Agent vẫn gọi tool đúng parameters (`category: iphone`, `color: black`) -> **PASS**.
