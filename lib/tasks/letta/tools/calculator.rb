# frozen_string_literal: true

def calculator_definition
  {
    name: "calculator",
    description: "Perform basic arithmetic calculations.",
    sourceCode: <<~PYTHON
      def calculator(expression: str):
          """
          Tính toán giá trị của một biểu thức toán học.
          Sử dụng tool này khi bạn cần tính toán số dư, lợi nhuận, hoặc các phép tính số học phức tạp từ dữ liệu đã lấy được.

          Quy tắc bảo mật & Cú pháp:
          1. Chỉ cho phép các ký tự: số (0-9), khoảng trắng, và các phép toán: +, -, *, /, %, **, (, ).
          2. Hỗ trợ thứ tự thực hiện phép tính (trong ngoặc trước).
          3. KHÔNG sử dụng các hàm toán học phức tạp như sin, cos, sqrt.

          Ví dụ biểu thức hợp lệ: '150000 + (2500 * 0.1) - 5000'

          Args:
              expression (str): Biểu thức toán học cần tính (Ví dụ: '100 * 1.1').

          Returns:
              dict: Kết quả tính toán bao gồm biểu thức gốc và giá trị cuối cùng.
          """
          pass
    PYTHON
  }
end
