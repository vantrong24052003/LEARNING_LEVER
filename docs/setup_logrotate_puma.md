# Logrotate cho Puma (Rails chạy bằng systemd)

## Mục lục

- [1. Vấn đề](#1-van-de)
- [2. Mục tiêu](#2-muc-tieu)
- [3. Cách hoạt động](#3-cach-hoat-dong)
- [4. Systemd service (Puma)](#4-systemd-service-puma)
- [5. Logrotate config](#5-logrotate-config)
- [6. Kết quả đạt được](#6-ket-qua-dat-duoc)
- [7. Test nhanh](#7-test-nhanh)
- [8. Debug](#8-debug)
- [9. Kết luận](#9-ket-luan)

---

## 1. Vấn đề

Khi Puma chạy production, log (stdout / stderr) sẽ **tăng liên tục** theo thời gian.
Nếu **không xoay log**, file log sẽ:

- phình to không giới hạn
- chiếm hết disk
- khi disk full → **Puma ghi log fail**
- service có thể **crash hoặc treo**

## 2. Mục tiêu

Giải quyết vấn đề log phình to bằng cách:
- giới hạn kích thước log
- tự động xoay log khi quá lớn
- giữ số lượng log cũ có kiểm soát
- không làm gián đoạn service

Giải pháp sử dụng: **logrotate**

---

## 3. Cách hoạt động

Luồng xử lý:

```
Rails → Puma → systemd → file log → logrotate
```

- systemd ghi stdout / stderr ra file
- logrotate theo dõi file đó
- khi log > 50MB → xoay
- log cũ được nén và xóa theo rule

---

## 4. Systemd service (Puma)

File: `/etc/systemd/system/learning_lerver1.service`

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

### File log thực tế

```
/home/deploy/Learning_lerver1/shared/log/puma.stdout.log
/home/deploy/Learning_lerver1/shared/log/puma.stderr.log
```

---

## 5. Logrotate config

File: `/etc/logrotate.d/learning_lerver1`

```conf
/home/deploy/Learning_lerver1/shared/log/*.log {
  size 50M
  rotate 14
  compress
  delaycompress
  missingok
  notifempty
  copytruncate
  su deploy deploy
}
```

### Giải thích các tham số

| Tham số | Ý nghĩa |
|---------|---------|
| `size 50M` | Xoay log khi file đạt 50MB |
| `rotate 14` | Giữ lại 14 bản log cũ |
| `compress` | Nén log cũ bằng gzip |
| `delaycompress` | Hoãn nén bản log tiếp theo |
| `missingok` | Không báo lỗi nếu file log không tồn tại |
| `notifempty` | Không xoay nếu file log rỗng |
| `copytruncate` | Copy nội dung sang file mới sau đó truncate file gốc (quan trọng cho Puma) |
| `su deploy deploy` | Chạy với quyền user `deploy` |

---

## 6. Kết quả đạt được

- Log không phình vô hạn
- Disk không bị full
- Puma không bị sập
- Không cần restart service
- Log cũ vẫn đọc được khi cần

---

## 7. Test nhanh

```bash
# Test logrotate thủ công
sudo logrotate -f /etc/logrotate.conf

# Xem các file log sau khi xoay
ls /home/deploy/Learning_lerver1/shared/log/
```

Kết quả ví dụ:

```
puma.stdout.log
puma.stdout.log.1
puma.stdout.log.2.gz
puma.stderr.log
puma.stderr.log.1
puma.stderr.log.2.gz
```

---

## 8. Debug

Nếu logrotate không hoạt động, kiểm tra:

```bash
# Xem log của logrotate
sudo cat /var/log/logrotate.log

# Test mode (không thực sự xoay)
sudo logrotate -d /etc/logrotate.conf

# Kiểm tra cron logrotate
sudo cat /etc/cron.daily/logrotate
```

---

## 9. Kết luận

Logrotate được dùng để:

- Ngăn log phình to gây sập service
- Đảm bảo Puma chạy ổn định lâu dài trong production
- Tiết kiệm disk space
- Dễ dàng quản lý và debug khi cần
