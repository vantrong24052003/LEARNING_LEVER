# frozen_string_literal: true

def statistics_aggregator_definition
  {
    name: "statistics_aggregator",
    description: "Calculate statistics for a database column.",
    sourceCode: <<~PYTHON
      def statistics_aggregator(table_name: str, column: str, operation: str = "count"):
          """
          Thực hiện các phép toán thống kê (Tổng, Trung bình, Đếm...) trên một cột dữ liệu.
          Sử dụng tool này khi cần báo cáo số liệu hoặc so sánh định lượng.

          Cấu hình chi tiết:
          - table_name: 'posts' (bài viết) hoặc 'users' (người dùng).
          - operation: 
            + 'count': Đếm số lượng bản ghi.
            + 'sum': Tính tổng giá trị (ví dụ: tổng balance).
            + 'avg': Tính giá trị trung bình.
            + 'min'/'max': Tìm giá trị nhỏ nhất/lớn nhất.
          - column: Chỉ cho phép các cột số như 'id', 'author_id', 'balance', 'price', 'amount'.

          Args:
              table_name (str): Bảng dữ liệu.
              column (str): Cột cần thống kê.
              operation (str): Mặc định là 'count'.

          Returns:
              dict: Mô tả và kết quả số liệu.
          """
          pass
    PYTHON
  }
end
