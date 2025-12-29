# GraphQL Guide - Rails Lv1

## Table of Contents
1. [Luồng chạy GraphQL](#luồng-chạy-graphql)
2. [Cấu trúc Project](#cấu-trúc-project)
3. [Giải thích các khái niệm](#giải-thích-các-khái-n niệm)

---

## Luồng chạy GraphQL

### Query Flow (Đọc dữ liệu)

```
Client Query
   │
   ▼
RailsLv1Schema
   │
   ▼
QueryType (entries/query_type.rb)
   │
   ▼
Queries::Post::IndexQuery
   │
   ▼
Post.all → ObjectTypes::PostType → JSON Response
```

### Mutation Flow (Thay đổi dữ liệu)

```
Client Mutation
   │
   ▼
RailsLv1Schema
   │
   ▼
MutationType (entries/mutation_type.rb)
   │
   ▼
Mutations::Post::CreateMutation
   │
   ▼
Post.create → render_success/render_error → JSON Response
```

---

## Cấu trúc Project

```
app/graphql/
├── rails_lv1_schema.rb         # Schema chính - entry point cho mọi request
│
├── entries/                    # Entry points (routing)
│   ├── query_type.rb           # Routing queries → queries
│   └── mutation_type.rb        # Routing mutations → mutations
│
├── base/                       # Base classes (shared logic)
│   ├── base_object.rb          # Base cho ObjectTypes
│   ├── base_field.rb           # Base cho fields
│   └── base_input_object.rb    # Base cho input types
│
├── object_types/               # Domain Objects (Post, Comment, User...)
│   └── post_type.rb            # Định nghĩa shape của Post object
│
├── queries/                    # Query logic (đọc dữ liệu)
│   ├── base_query.rb           # Base class với helper methods
│   └── post/
│       ├── index_query.rb      # List all posts
│       └── show_query.rb       # Find post by ID
│
└── mutations/                  # Mutation logic (thay đổi dữ liệu)
    ├── base_mutation.rb        # Base class với render_success/render_error
    └── post/
        ├── create_mutation.rb  # Create post
        ├── update_mutation.rb  # Update post
        └── destroy_mutation.rb # Delete post
```

---

## Giải thích các khái niệm

### 1. `type` - Định nghĩa kiểu trả về

```ruby
type ObjectTypes::PostType, null: true
```

| Phần | Giải thích |
|------|------------|
| `type` | Keyword định nghĩa kiểu trả về của query/mutation |
| `ObjectTypes::PostType` | Trả về object PostType (có id, title, status) |
| `null: true` | Có thể trả về `null` nếu không tìm thấy |
| `null: false` | Bắt buộc phải trả về dữ liệu, không được null |

**Ví dụ:**

```ruby
# Query có thể null
type ObjectTypes::PostType, null: true
# → Nếu không tìm thấy post: { post: null } ✅

# Query bắt buộc có dữ liệu
type [ObjectTypes::PostType], null: false
# → Luôn trả về mảng: { posts: [...] } (mảng rỗng cũng được)
```

---

### 2. `argument` - Định nghĩa tham số đầu vào

```ruby
argument :id, ID, required: true
```

| Phần | Giải thích |
|------|------------|
| `argument` | Keyword định nghĩa input parameter |
| `:id` | Tên argument (client gọi với tên này) |
| `ID` | Kiểu GraphQL đặc biệt (có thể String hoặc Int) |
| `required: true` | Client bắt buộc phải truyền |

**Các kiểu dữ liệu GraphQL:**

```ruby
argument :id, ID, required: true              # ID (string hoặc int)
argument :title, String, required: true        # String
argument :age, Integer, required: false        # Integer
argument :active, Boolean, required: false     # Boolean
argument :limit, Integer, required: false      # Optional argument

# Array type
argument :ids, [ID], required: true            # Mảng IDs

# Enum type (nếu có định nghĩa)
argument :status, PostStatusEnum, required: true
```

**Client gọi:**

```graphql
# Required argument
query {
  post(id: "123") {        # id: bắt buộc
    id
    title
  }
}

# Optional argument
query {
  posts(limit: 10) {       # limit: optional
    id
    title
  }
}

# Không truyền required → Lỗi
query {
  post {                   # ❌ Lỗi: Field 'post' is missing required argument 'id'
    id
  }
}
```

---

### 3. `field` - Định nghĩa field trong Object Type

```ruby
field :id, ID, null: false
field :title, String, null: false
field :errors, [String], null: false
```

| Phần | Giải thích |
|------|------------|
| `field` | Keyword định nghĩa field |
| `:id` | Tên field |
| `ID` | Kiểu dữ liệu của field |
| `null: false` | Field này không được null |

**Ví dụ trong PostType:**

```ruby
class PostType < Base::BaseObject
  field :id, ID, null: false           # Bắt buộc có id
  field :title, String, null: false    # Bắt buộc có title
  field :status, String, null: true    # Status có thể null
end
```

---

### 4. `resolve` - Method xử lý logic

```ruby
def resolve(id:)
  ::Post.find_by(id: id)
end
```

| Phần | Giải thích |
|------|------------|
| `resolve` | Entry point - GraphQL gọi method này |
| `id:` | Nhận argument `id` từ client (keyword argument) |
| `::Post` | Dùng `::` để trỏ root namespace (tránh nhầm module Post) |
| `find_by` | Tìm record, trả về object hoặc nil |

**Ví dụ với multiple arguments:**

```ruby
def resolve(title:, status:, limit: 10)
  # title, status: required arguments
  # limit: optional argument (default 10)
  ::Post.where(status: status).where("title LIKE ?", "%#{title}%").limit(limit)
end
```

---

### 5. `render_success` / `render_error` - Helper methods

```ruby
# Trong BaseMutation
def render_success(resource)
  { data: resource, errors: [] }
end

def render_error(messages)
  errors = Array(messages)
  { data: nil, errors: }
end
```

| Phần | Giải thích |
|------|------------|
| `data:` | Chứa resource (post, comment, user...) |
| `errors:` | Mảng error messages |

**Sử dụng trong mutation:**

```ruby
def resolve(title:, status:)
  post = ::Post.new(title: title, status: status)

  if post.save
    render_success(post)
    # → { data: post, errors: [] }
  else
    render_error(post.errors.full_messages)
    # → { data: nil, errors: ["Title can't be blank"] }
  end
end
```

---

### 6. `resolver` - Routing query đến resolver class

```ruby
# Trong QueryType
field :posts, resolver: Queries::Post::IndexQuery
field :post, resolver: Queries::Post::ShowQuery
```

| Phần | Giải thích |
|------|------------|
| `field :posts` | Tên field trong GraphQL schema |
| `resolver:` | Chỉ định resolver class xử lý logic |
| `Queries::Post::IndexQuery` | Class này có `resolve` method trả về data |

**Inline resolver (không cần class riêng):**

```ruby
# Cách 1: Dùng resolver class (clean hơn)
field :posts, resolver: Queries::Post::IndexQuery

# Cách 2: Inline resolver (đơn giản)
field :posts, [ObjectTypes::PostType], null: false do
  def resolve
    ::Post.all
  end
end
```

---

### 7. `mutation` - Routing mutation đến mutation class

```ruby
# Trong MutationType
field :create_post, mutation: Mutations::Post::CreateMutation
```

| Phần | Giải thích |
|------|------------|
| `field :create_post` | Tên field trong GraphQL (camelCase) |
| `mutation:` | Chỉ định mutation class xử lý logic |
| `Mutations::Post::CreateMutation` | Class này có `resolve` method execute logic |

---

### 8. `::` (Double colon) - Root namespace

```ruby
::Post.find_by(id: id)
```

| Phần | Giải thích |
|------|------------|
| `::Post` | Trỏ đến class `Post` ở root level |
| `Post.find_by` | ❌ Có thể nhầm với `module Post` |

**Ví dụ:**

```ruby
module Post
  class ShowQuery < BaseQuery
    def resolve(id:)
      ::Post.find_by(id: id)  # ✅ Rails model Post
      # Post.find_by(id: id)   # ❌ Sẽ nhầm module Post
    end
  end
end
```

---

## So sánh REST vs GraphQL

| REST | GraphQL | Điểm tương đồng |
|------|---------|-----------------|
| `GET /posts` | `query { posts { id title } }` | Index |
| `GET /posts/:id` | `query { post(id: "...") { ... } }` | Show |
| `POST /posts` | `mutation { createPost(...) { ... } }` | Create |
| `PUT /posts/:id` | `mutation { updatePost(...) { ... } }` | Update |
| `DELETE /posts/:id` | `mutation { deletePost(...) { ... } }` | Delete |
| `PostsController` | `Queries::Post::*`, `Mutations::Post::*` | Controller |
| `render json:` | `type`, `field`, `render_*` | Render response |
| `params[:id]` | `argument`, `resolve(id:)` | Parameters |

---

## Backend kiểm soát, Client chọn field

**GraphQL = Client chọn field CẦN LẤY, nhưng BACKEND định nghĩa schema**

```
Backend (Schema):
  - Queries được phép: posts, post
  - Fields được expose: id, title, status
  - Arguments: page, limit
  - Logic: Post.page(page).per(limit)

Client chỉ dùng những gì được expose:

  Cho phép:
    posts(page: 1, limit: 10) { id title }
    posts(page: 1, limit: 10) { id title status }

  Không cho phép:
    posts(page: 1, limit: 10) { created_at }  <- Chưa expose
    comments { ... }                           <- Chưa định nghĩa
```

**Backend định nghĩa:**
```ruby
class PostType < Base::BaseObject
  field :id, ID, null: false
  field :title, String, null: false
  field :status, String, null: true
  # created_at -> không expose
end
```

**Client chỉ có thể:**
```graphql
# Cho phép
posts { id title status }

# Không cho phép
posts { created_at }  # Lỗi: Field không tồn tại
```

**Tóm lại:**

| Client có thể | Client không thể |
|---------------|------------------|
| Chọn field cần lấy | Query field không expose |
| Chỉ định page, limit | Tự do query SQL |
| Nhận data theo format | Thay đổi logic backend |

**Backend vẫn phải:**
- Validate arguments
- Authorization (user có quyền không?)
- Xử lý logic (pagination, filter, sort...)
- Limit data exposure (chỉ expose field cần thiết)

---

## Quick Reference

### Query Structure

```ruby
module Queries
  module Post
    class IndexQuery < BaseQuery
      type ObjectTypes::PostType, null: false

      def resolve
        ::Post.all
      end
    end
  end
end
```

### Mutation Structure

```ruby
module Mutations
  module Post
    class CreateMutation < BaseMutation
      argument :title, String, required: true
      argument :status, String, required: true

      field :data, ObjectTypes::PostType, null: true
      field :errors, [String], null: false

      def resolve(title:, status:)
        post = ::Post.new(title: title, status: status)
        return render_success(post) if post.save
        render_error(post.errors.full_messages)
      end
    end
  end
end
```

### Object Type Structure

```ruby
module ObjectTypes
  class PostType < Base::BaseObject
    graphql_name "Post"

    field :id, ID, null: false
    field :title, String, null: false
    field :status, String, null: true
  end
end
```

---

Generated for Rails Lv1 Project
