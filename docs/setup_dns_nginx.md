# Hướng dẫn đăng ký & trỏ DNS domain vào VPS (Nginx + Rails + HTTPS)

## Mục lục

- [1. Mục tiêu ví dụ](#1-mục-țiêu-ví-dụ)
- [2. Phần 1 - Cấu hình DNS](#2-phan-1-cau-hinh-dns)
- [3. Phần 2 - Cấu hình Nginx](#3-phan-2-cau-hinh-nginx)
- [4. Phần 3 - Cài HTTPS](#4-phan-3-cai-https)
- [5. Phần 4 - Lưu ý](#5-phan-4-luu-y)

---

Tài liệu này hướng dẫn **từ đầu đến cuối** cách:
- Trỏ domain / subdomain về VPS (EC2)
- Cấu hình Nginx cho Rails app
- Bật HTTPS bằng Let's Encrypt (Certbot)

Áp dụng cho:
- Ubuntu Server
- Nginx
- Rails chạy local (127.0.0.1:3000)

---

## 1. Mục tiêu ví dụ

- Domain gốc: `vantrongdng.id.vn`
- Subdomain cần dùng:
  👉 `railslv1.vantrongdng.id.vn`
- IP VPS (EC2):
  👉 `16.171.55.15`
- Rails app chạy ở:
  👉 `127.0.0.1:3000`

---

## 2. PHẦN 1 - Cấu hình DNS (BẮT BUỘC)

### 1.1. Truy cập trang quan ly DNS cua domain
(Ví du: PA Viet Nam, Cloudflare, Namecheap, v.v.)

### 1.2. Tao ban ghi A (A Record)

| Truong     | Gia tri          |
|------------|------------------|
| Type       | `A`              |
| Name       | `railslv1`       |
| Value      | `16.171.55.15`   |
| TTL        | `300`            |

📌 `railslv1` = `railslv1.vantrongdng.id.vn`
📌 Khong dung `@`, khong dung `www` cho subdomain nay

---

### 1.3. Kiem tra DNS da hoat dong

```bash
ping railslv1.vantrongdng.id.vn
```

Hoặc:

```bash
nslookup railslv1.vantrongdng.id.vn
```

👉 Neu tra ve dung IP VPS → DNS OK

---

## 3. PHẦN 2 - Cấu hình Nginx cho Rails

### 2.1. File cau hinh Nginx

Tao file:

```bash
sudo nano /etc/nginx/sites-available/learning_lerver1
```

### 2.2. Noi dung file (CHUAN - PROD)

```nginx
upstream app {
  server 127.0.0.1:3000 fail_timeout=0;
}

# HTTP -> HTTPS
server {
  listen 80;
  listen [::]:80;
  server_name railslv1.vantrongdng.id.vn;

  location /.well-known/acme-challenge/ {
    root /home/deploy/Learning_lerver1/current/public;
    allow all;
  }

  return 301 https://$host$request_uri;
}

# HTTPS + Rails
server {
  listen 443 ssl http2;
  listen [::]:443 ssl http2;
  server_name railslv1.vantrongdng.id.vn;

  root /home/deploy/Learning_lerver1/current/public;
  index index.html;

  ssl_certificate /etc/letsencrypt/live/railslv1.vantrongdng.id.vn/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/railslv1.vantrongdng.id.vn/privkey.pem;
  include /etc/letsencrypt/options-ssl-nginx.conf;
  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

  try_files $uri/index.html $uri @app;

  location @app {
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto https;
    proxy_pass http://app;
    proxy_read_timeout 150;
  }

  location ~* ^/assets/ {
    expires 1y;
    add_header Cache-Control public;
    add_header ETag "";
  }
}
```

### 2.3. Enable site & reload Nginx

```bash
sudo ln -sf /etc/nginx/sites-available/learning_lerver1 \
           /etc/nginx/sites-enabled/learning_lerver1

sudo rm -f /etc/nginx/sites-enabled/default

sudo nginx -t
sudo systemctl reload nginx
```

---

## 4. PHẦN 3 - Cài HTTPS (Let's Encrypt)

### 3.1. Cai certbot

```bash
sudo apt update
sudo apt install -y certbot python3-certbot-nginx
```

### 3.2. Cap SSL cho subdomain

```bash
sudo certbot --nginx -d railslv1.vantrongdng.id.vn
```

Khi duoc hoi:
- Email → nhap
- Agree → Y
- Redirect HTTP → HTTPS → chon 2

### 3.3. Kiem tra HTTPS

```bash
curl -I https://railslv1.vantrongdng.id.vn
```

Hoac mo trinh duyet:

```
https://railslv1.vantrongdng.id.vn
```

👉 Thay 🔒 la thanh cong

---

## 5. PHẦN 4 - Lưu ý quan trọng

- `server_name` phai khop DNS
- DNS can thoi gian propagate (1-5 phut)
- curl tren VPS co the khong resolve DNS ngay → browser ngoai la chuan
- Moi domain / subdomain nen co 1 file nginx rieng
