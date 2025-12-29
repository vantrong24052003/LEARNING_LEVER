# Setup Cron Backup PostgreSQL

## Mục lục

- [1. Mục đích](#1-muc-dich)
- [2. Điều kiện](#2-dieu-kien)
- [3. Cấu trúc thư mục](#3-cau-truc-thu-muc)
- [4. Script backup](#4-script-backup)
- [5. Test chạy tay](#5-test-chay-tay)
- [6. Setup cron](#6-setup-cron)
- [7. Cơ chế dọn backup cũ](#7-co-che-don-backup-cu)
- [8. Kiểm tra cron đang chạy](#8-kiem-tra-cron-dang-chay)

---

## 1. Mục đích

- Tự động backup PostgreSQL
- Không phụ thuộc deploy
- Không ảnh hưởng production đang chạy
- Có dọn backup cũ để tránh đầy disk

---

## 2. Điều kiện

- Server có PostgreSQL
- User chạy cron: `deploy`
- Đã có script backup

Script dùng:
```
/home/deploy/scripts/backup_postgres.sh
```

---

## 3. Cấu trúc thư mục

```
/home/deploy/
├── scripts/
│   └── backup_postgres.sh
└── backups/
    └── postgres/
        └── learning_lerver1_YYYY-MM-DD_HH-MM.pgsql.gz
```

---

## 4. Script backup

File: `/home/deploy/scripts/backup_postgres.sh`

```bash
#!/bin/bash
set -e

APP_NAME="learning_lerver1"
DB_NAME="rails_lv1_production"
DB_USER="deploy"

BACKUP_DIR="/home/deploy/backups/postgres"
KEEP_DAYS=7
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
BACKUP_FILE="${BACKUP_DIR}/${APP_NAME}_${TIMESTAMP}.pgsql.gz"

setup() {
  mkdir -p "$BACKUP_DIR"
}

check_postgres() {
  pg_isready -U "$DB_USER" >/dev/null 2>&1
}

backup_db() {
  pg_dump -U "$DB_USER" "$DB_NAME" | gzip > "$BACKUP_FILE"
}

verify_backup() {
  [ -s "$BACKUP_FILE" ]
}

cleanup_old() {
  find "$BACKUP_DIR" -type f -name "*.pgsql.gz" -mtime +$KEEP_DAYS -delete
}

main() {
  setup
  check_postgres || exit 1
  backup_db
  verify_backup || { rm -f "$BACKUP_FILE"; exit 1; }
  cleanup_old
  echo "Backup OK: $BACKUP_FILE"
}

main
```

### Giải thích script

| Hàm | Công dụng |
|-----|----------|
| `setup()` | Tạo thư mục backup nếu chưa có |
| `check_postgres()` | Kiểm tra PostgreSQL có sẵn sàng |
| `backup_db()` | Dump DB và nén bằng gzip |
| `verify_backup()` | Kiểm tra file backup có dữ liệu |
| `cleanup_old()` | Xóa backup cũ hơn `KEEP_DAYS` ngày |

---

## 5. Test chạy tay (bắt buộc)

Chạy:
```bash
/home/deploy/scripts/backup_postgres.sh
```

Kiểm tra:
```bash
ls -lh /home/deploy/backups/postgres/
```

Phải thấy file mới và size > 0.

---

## 6. Setup cron

Mở crontab của user deploy:
```bash
crontab -e
```

### Test (chạy mỗi 2 phút)
```cron
*/2 * * * * /home/deploy/scripts/backup_postgres.sh
```

Sau 5–10 phút, kiểm tra:
```bash
ls -lh /home/deploy/backups/postgres/
```

### Production (khuyến nghị)

Đổi cron thành chạy mỗi ngày lúc 02:00:
```cron
0 2 * * * /home/deploy/scripts/backup_postgres.sh
```

---

## 7. Cơ chế dọn backup cũ

Trong script có:
```ini
KEEP_DAYS=7
```

Nghĩa là:
- Mỗi lần cron chạy → backup cũ hơn 7 ngày trong thư mục backup sẽ bị xoá
- Chỉ xoá file `.pgsql.gz` trong folder backup

---

## 8. Kiểm tra cron đang chạy

Xem cron hiện tại:
```bash
crontab -l
```

Xem log cron (nếu cần debug):
```bash
# Xem log cron
sudo tail -f /var/log/syslog | grep CRON

# Hoặc
grep CRON /var/log/syslog | tail -20
```
