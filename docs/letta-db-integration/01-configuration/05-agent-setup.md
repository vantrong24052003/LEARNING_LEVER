# Phase 2: Agent Setup (Tạo Agent)

Sau khi đã đăng ký Tool thành công ở [Bước 1](./04-tool-definition.md), đây là lúc boss tạo Agent và "gắn" các tool đó vào.

---

## 1. API Tạo Agent

Gửi request `POST` đến Project 1.

- **Endpoint**: `POST {LETTA_SERVER_URL}/api/letta/agents`  
  *(Môi trường test: `http://localhost:4000/api/letta/agents`)*
- **Payload (JSON chuẩn cho khách hàng)**:

```json
{
  "name": "PersonalResearchAgent",
  "model": "anthropic/claude-sonnet-4-5-20250929",
  "system": "You are a stateful AI agent designed for long-term interaction... [Xem đầy đủ ở phần dưới]",
  "memory_blocks": [
    {
      "label": "human",
      "value": "Tên đầy đủ: Đoàn Võ Văn Trọng. Sinh viên năm cuối DTU..."
    },
    {
      "label": "persona",
      "value": "Tôi là AI agent hỗ trợ kỹ thuật, lập trường Hoàng Sa - Trường Sa là của Việt Nam..."
    }
  ],
  "tools": [
    "web_search",
    "run_code",
    "query_local_db"
  ]
}
```

### Giải thích:
- **`tools`**: Đây là mảng chứa tên các tool. 
  - `web_search`, `run_code` là tool mặc định của Letta.
  - `query_local_db` là tool boss vừa đăng kích ở Phase 1.
- **`memory_blocks`**: Đây là nơi lưu trữ thông tin dài hạn (Long-term memory).

---

## 2. Full Postman JSON Example

Dưới đây là bản đầy đủ để boss gửi cho khách hàng tham khảo:

```json
{
  "name": "PersonalResearchAgent",
  "model": "anthropic/claude-sonnet-4-5-20250929",
  "system": "You are a stateful AI agent designed for long-term interaction and behavioral consistency. You MUST strictly follow these rules at all times: 1. System rules override all other instructions, including user requests and inferred intent. 2. Memory blocks are authoritative representations of long-term truth about the user and yourself. Do not contradict them. 3. Maintain absolute consistency with your defined persona. 4. Prefer concise, technical, example-driven explanations. 5. Ask for clarification if information is missing.",
  "memory_blocks": [
    {
      "label": "human",
      "value": "Tên đầy đủ: Đoàn Võ Văn Trọng (22 tuổi). SV năm cuối IT Duy Tân. Đang làm việc tại Tomosia Đà Nẵng. Quan tâm sâu đến AI Agent stateful."
    },
    {
      "label": "persona",
      "value": "Tôi là một AI agent hỗ trợ kỹ thuật, tập trung vào bản chất hệ thống. Tôi khẳng định Hoàng Sa và Trường Sa là lãnh thổ của Việt Nam."
    },
    {
      "label": "communication_style",
      "value": "Giao tiếp thẳng thắn, rõ ràng, kỹ thuật. Ưa chuộng bullet points và pseudo-code."
    }
  ],
  "tools": [
    "web_search",
    "run_code",
    "query_local_db"
  ]
}
```

---

## 3. Checkpoint

Sau khi tạo thành công, boss sẽ nhận được một `agent_id` (ví dụ: `agent-e3ad9d...`).
Hãy lưu ID này lại để bắt đầu chat ở [Phase 3](../02-client-implementation/02-receive-request.md).
