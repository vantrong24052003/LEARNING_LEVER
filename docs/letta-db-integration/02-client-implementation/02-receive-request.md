# Phase 3: Receive Request tại Client App (Project 2)

## Mục tiêu
Backend của bạn cần parse được JSON response từ Letta Server để phát hiện khi nào AI muốn gọi tool.

**Thực hiện tại:** Project 2 (Client Application Logic).

## Logic Parse Response

Dựa theo [API Contract](../01-configuration/06-api-contract.md), bạn cần kiểm tra field `message_type`.

### Pseudo Code (Logic chung)

```text
response = HTTP_POST(LETTA_API_URL, payload)

IF response.message_type == "tool_call_message":
    // AI yêu cầu gọi tool
    tool_name = response.tool_calls[0].function.name
    tool_args = JSON_PARSE(response.tool_calls[0].function.arguments)
    RETURN { type: "TOOL_REQUEST", name: tool_name, args: tool_args }

ELSE:
    // AI trả lời bình thường
    RETURN { type: "TEXT", content: response.content }
```

### Implementation Example (Node.js)

```typescript
const toolCalls = incomingMessages.filter(msg => 
  msg.message_type === 'tool_call_message'
);

if (toolCalls.length > 0) {
  // Logic: Bắt được tín hiệu gọi tool
  const call = toolCalls[0];
  const funcName = call.tool_calls[0].function.name;
  const args = JSON.parse(call.tool_calls[0].function.arguments);
  
  executeMyTool(funcName, args);
}
```

### Implementation Example (Rails)

```ruby
# controller/chat_controller.rb
body = JSON.parse(response.body)
messages = body['messages']

tool_msg = messages.find { |m| m['message_type'] == 'tool_call_message' }

if tool_msg
  call = tool_msg['tool_calls'].first
  func_name = call['function']['name']
  args = JSON.parse(call['function']['arguments'])
  
  # Gọi service tương ứng
  result = MyToolService.call(func_name, args)
end
```
