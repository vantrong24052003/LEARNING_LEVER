# Production Request Flow & Config Guide

## Mục lục

- [1. Kiến trúc tổng quan](#1-kiến-trúc-tổng-quan)
- [2. Luồng Request chi tiết](#2-luồng-request-chi-tiết)
- [3. Cấu hình Nginx](#3-cấu-hình-nginx)
- [4. Cấu hình Puma](#4-cấu-hình-puma)
- [5. Debug - Vị trí file Log](#5-debug---vị-trí-file-log)
- [6. Các lỗi thường gặp](#6-các-lỗi-thường-gặp)

---

## 1. Kiến trúc tổng quan

```
┌─────────┐      ┌─────────┐      ┌─────────┐      ┌─────────┐      ┌──────────┐
│  User   │ ───► │  Nginx  │ ───► │  Puma   │ ───► │  Rails  │ ───► │PostgreSQL│
└─────────┘      └─────────┘      └─────────┘      └─────────┘      └──────────┘
                      │                                  │
                      ▼                                  ▼
                 ┌─────────┐                      ┌─────────┐
                 │  Port   │                      │   DB    │
                 │   :80   │                      │:5432    │
                 └─────────┘                      └─────────┘
```

| Tầng | Port | Vai trò |
|------|------|---------|
| **Nginx** | 80 | Reverse proxy, serve static files |
| **Puma** | 3000 | App server, quản lý Rails threads |
| **Rails** | - | Application logic |
| **PostgreSQL** | 5432 | Database |

---

## 2. Luồng Request chi tiết

### Ví dụ: GET /posts

```
1. Client gửi GET http://16.171.55.15/posts
                    ↓
2. Nginx nhận request (port 80)
   - Kiểm tra static file trong public/ → không có
   - Forward sang Puma (127.0.0.1:3000)
                    ↓
3. Puma nhận request
   - Chọn thread trong pool
   - Gọi Rails application
                    ↓
4. Rails xử lý
   - Router: GET /posts → PostsController#index
   - Middleware stack
   - Controller action
   - Model query DB
   - Render JSON
                    ↓
5. PostgreSQL trả data
   - SELECT * FROM posts
   - Trả về kết quả
                    ↓
6. Response path: DB → Rails → Puma → Nginx → User
```

---

## 3. Cấu hình Nginx

### File config: `/etc/nginx/sites-enabled/learning_lerver1`

```nginx
# Upstream: định nghĩa Puma server
upstream app {
  server 127.0.0.1:3000 fail_timeout=0;
}

server {
  listen 80 default_server;
  listen [::]:80 default_server;

  server_name _;

  # Đường dẫn tới Rails app
  root /home/deploy/Learning_lerver1/current/public;
  index index.html;

  # Thử serve static file trước, nếu không có thì forward sang Rails
  try_files $uri/index.html $uri @app;

  # Forward request sang Puma
  location @app {
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header Host $host;
    proxy_redirect off;
    proxy_set_header Connection '';
    proxy_pass http://app;
    proxy_read_timeout 150;
  }

  # Cache cho assets (CSS, JS, images...)
  location ~* ^/assets/ {
    expires 1y;
    add_header Cache-Control public;
    add_header Last-Modified "";
    add_header ETag "";
    break;
  }

  # Error pages
  error_page 500 502 503 504 /50x.html;
  location = /50x.html {
    root /usr/share/nginx/html;
  }
}
```

### Các lệnh Nginx

```bash
# Kiểm tra config có đúng không
sudo nginx -t

# Reload config (không làm mất connection)
sudo nginx -s reload

# Restart hoàn toàn
sudo systemctl restart nginx

# Check status
sudo systemctl status nginx
```

---

## 4. Cấu hình Puma

### File config: `config/puma.rb`

```ruby
# Số threads cho mỗi worker
threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

# Port Puma sẽ lắng nghe
port ENV.fetch("PORT", 3000)

# Plugin restart
plugin :tmp_restart

# Solid queue (nếu dùng background jobs)
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

# PID file (để restart/stop)
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
```

### Các lệnh Puma

```bash
# Đi vào thư mục app
cd /home/deploy/Learning_lerver1/current

# START - Khởi động Puma
bundle exec puma -d -e production -p 3000

# RESTART - Khởi động lại (giữ PID file)
bundle exec pumactl -P tmp/pids/puma.pid restart

# STOP - Dừng Puma
bundle exec pumactl -P tmp/pids/puma.pid stop

# Check Puma đang chạy
ps aux | grep puma

# Check port 3000 có đang lắng nghe không
sudo netstat -tlnp | grep 3000
```

### Puma + Systemd (Tạo service)

Để Puma tự động khởi động cùng server, tạo systemd service:

**File:** `/etc/systemd/system/learning_lerver1.service`

```ini
[Unit]
Description=Puma Rails App learning_lerver1
After=network.target

[Service]
Type=simple
User=deploy
WorkingDirectory=/home/deploy/Learning_lerver1/current

Environment=RAILS_ENV=production

ExecStart=/bin/bash -lc 'source /home/deploy/.rvm/scripts/rvm && bundle exec puma -C config/puma.rb'

Restart=always
RestartSec=5

StandardOutput=append:/home/deploy/Learning_lerver1/shared/log/puma.stdout.log
StandardError=append:/home/deploy/Learning_lerver1/shared/log/puma.stderr.log

[Install]
WantedBy=multi-user.target
```

**Giải thích log:**
| Log | Nội dung |
|-----|----------|
| `puma.stdout.log` | Log bình thường: app khởi động, worker chạy, restart xong |
| `puma.stderr.log` | Log lỗi: crash, không kết nối DB, lỗi system |

```bash
# Reload systemd sau khi tạo/sửa service
sudo systemctl daemon-reload

# Enable service (tự động chạy khi boot)
sudo systemctl enable learning_lerver1

# Start/Stop/Restart
sudo systemctl start learning_lerver1
sudo systemctl stop learning_lerver1
sudo systemctl restart learning_lerver1

# Check status
sudo systemctl status learning_lerver1

# Xem log Puma
tail -f /home/deploy/Learning_lerver1/shared/log/puma.stdout.log
tail -f /home/deploy/Learning_lerver1/shared/log/puma.stderr.log
```

---

## 5. Debug - Vị trí file Log

| Service | Log Path | Xem lệnh |
|---------|----------|----------|
| Nginx Access | `/var/log/nginx/access.log` | `sudo tail -f /var/log/nginx/access.log` |
| Nginx Error | `/var/log/nginx/error.log` | `sudo tail -f /var/log/nginx/error.log` |
| Puma Stdout | `shared/log/puma.stdout.log` | `tail -f shared/log/puma.stdout.log` |
| Puma Stderr | `shared/log/puma.stderr.log` | `tail -f shared/log/puma.stderr.log` |
| Rails | `current/log/production.log` | `tail -f log/production.log` |
| PostgreSQL | `/var/log/postgresql/` | `sudo tail -f /var/log/postgresql/*.log` |

---

## 6. Các lỗi thường gặp

| Lỗi | Nguyên nhân | Cách fix |
|-----|-------------|----------|
| **502 Bad Gateway** | Puma không chạy | `ps aux \| grep puma` → start puma |
| **504 Gateway Timeout** | Request quá lâu | Tăng `proxy_read_timeout` trong nginx |
| **Connection refused** | Nginx không connect được Puma | Check port 3000: `netstat -tlnp \| grep 3000` |
| **404 Not Found** | Route không tồn tại | `rails routes` để check |
| **500 Internal Error** | Lỗi Rails app | Xem `log/production.log` |
| **Database timeout** | PostgreSQL không chạy | `sudo systemctl status postgresql` |
