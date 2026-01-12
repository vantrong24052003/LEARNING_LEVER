# frozen_string_literal: true

def data_comparator_definition
  {
    name: "data_comparator",
    description: "Compare two records from the database.",
    sourceCode: <<~PYTHON
      def data_comparator(table_name: str, id1: int, id2: int):
          """
          Thực hiện so sánh chi tiết giữa hai bản ghi dữ liệu (Records) để tìm ra các điểm khác biệt.
          Tool này cực kỳ hữu ích khi bạn cần đối chiếu nội dung (body/content) hoặc các trường thông tin dài mà 'post_finder' không hiển thị hết.

          Quy trình sử dụng:
          1. Bạn tìm dữ liệu bằng 'post_finder' để lấy ID của các bản ghi.
          2. Dùng ID đó làm tham số 'id1' và 'id2' cho tool này để xem sự khác biệt.
          3. Tổng hợp kết quả cho người dùng, tuyệt đối KHÔNG hiển thị ID trong câu trả lời cuối cùng.

          Args:
              table_name (str): 'posts' (bài viết) hoặc 'users' (người dùng).
              id1 (int): ID của bản ghi thứ nhất.
              id2 (int): ID của bản ghi thứ hai để so sánh.

          Returns:
              dict: Danh sách các trường có dữ liệu khác nhau.
          """
          pass
    PYTHON
  }
end
