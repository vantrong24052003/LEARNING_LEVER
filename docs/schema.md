# Database Schema Documentation

## Schema Diagram

```
+------------------+           +------------------+           +------------------+
|     users        |           |     posts        |           |    comments      |
+------------------+           +------------------+           +------------------+
| id (PK)          |<---+      | id (PK)          |<---+      | id (PK)          |
| email            |    |      | user_id (FK)     |    |      | post_id (FK)     |
| name             |    |      | title            |    |      | content          |
| created_at       |    |      | status           |    |      | created_at       |
| updated_at       |    |      | created_at       |    |      | updated_at       |
+------------------+    |      | updated_at       |    |      +------------------+
         |              |      +------------------+    |              ^
         |              |               ^               |              |
         |              |               |               |              |
         |              |               +---------------+              |
         |              |                                               |
         |              +-------------------+---------------------------+
         |                                  |
         v                                  v
+------------------+              +------------------+
|     wallets      |              |                  |
+------------------+              |                  |
| id (PK)          |              |                  |
| user_id (FK)*    |              |                  |
| balance          |              |                  |
| lock_version     |              |                  |
| created_at       |              |                  |
| updated_at       |              |                  |
+------------------+              +------------------+

## Relationships

### User
- has_many :posts
- has_one :wallet

### Post
- belongs_to :user
- has_many :comments

### Comment
- belongs_to :post

### Wallet
- belongs_to :user (unique)
- balance: integer (default: 0)
- lock_version: integer (default: 0) - optimistic locking for race condition testing
