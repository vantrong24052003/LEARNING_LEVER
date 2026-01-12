# frozen_string_literal: true

def post_finder_definition
  {
    name: "post_finder",
    description: "Tìm kiếm bài viết theo tác giả, từ khóa hoặc trạng thái.",
    sourceCode: <<~PYTHON
      def post_finder(author_name: str = None, keyword: str = None, limit: int = 10, status: str = None):
          """
          Tìm kiếm bài viết trên toàn hệ thống dựa trên tác giả, từ khóa tiêu đề hoặc trạng thái.
          Đây là tool 'khởi đầu' quan trọng. Kết quả trả về chứa ID của các bài viết.

          QUY TẮC QUAN TRỌNG:
          1. Chaining: Sử dụng ID từ kết quả tool này để gọi 'data_comparator' nếu người dùng muốn so sánh chi tiết, hoặc 'statistics_aggregator' để thống kê.
          2. Privacy: ID chỉ dùng cho việc gọi tool nội bộ. KHÔNG được hiển thị ID này trong câu trả lời cho khách hàng.

          Args:
              author_name (str): Tên tác giả (Ví dụ: 'Samara Corwin').
              keyword (str): Từ khóa trong tiêu đề (Ví dụ: 'Letta').
              status (str): Trạng thái bài viết: 'published' hoặc 'draft'.
              limit (int): Tối đa 50 (Mặc định: 10).

          Returns:
              list: Danh sách bài viết kèm ID nội bộ.
          """
          pass
    PYTHON
  }
end
