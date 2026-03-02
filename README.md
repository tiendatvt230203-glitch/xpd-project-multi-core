# XDP Forwarder (multi-WAN, per-packet crypto)

Daemon nhận config từ PostgreSQL (NOTIFY), ghim 1 core CPU, forward gói qua LOCAL/WAN với mã hóa L2/L3/L4 (AES-CTR/GCM), hỗ trợ fragment L3/L4.

## 1. Yêu cầu hệ thống

- Linux (kernel có XDP, libbpf)
- **Build**: `gcc`, `clang`, kernel headers (`linux-headers-$(uname -r)`), `libbpf`, `libxdp`, `libpq` (PostgreSQL client)
- **Chạy**: PostgreSQL đang chạy, DB đã tạo và có bảng config; quyền root để attach XDP

### Cài đặt dependency (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install -y build-essential clang libbpf-dev libxdp-dev libpq-dev postgresql-client linux-headers-$(uname -r)
```

Nếu dùng libbpf/libxdp từ source hoặc distro khác, đảm bảo `pkg-config` tìm được và include path của PostgreSQL (Makefile dùng `pg_config --includedir`).

## 2. Build

```bash
cd /home/tiendat/CODE/xdp-project-no-core
make
```

Binary: `bin/xdp_forwarder`.

## 3. Database PostgreSQL

- Tạo database (ví dụ `xdpdb`) và dùng file `schema.sql` để tạo bảng:

```bash
psql -U postgres -d xdpdb -f schema.sql
```

- Điền config (ít nhất 1 bản ghi trong `xdp_configs`, ít nhất 1 LOCAL trong `xdp_local_configs`, ít nhất 1 WAN trong `xdp_wan_configs`) rồi ghi nhớ `id` trong `xdp_configs` để truyền qua NOTIFY.

## 4. Chạy daemon

```bash
sudo ./bin/xdp_forwarder --db-url "host=localhost user=postgres password=secret dbname=xdpdb"
```

Hoặc dùng connection string dạng URI:

```bash
sudo ./bin/xdp_forwarder --db-url "postgresql://postgres:secret@localhost/xdpdb"
```

Ghim sang core khác (mặc định là core 0):

```bash
sudo ./bin/xdp_forwarder --db-url "postgresql://postgres:secret@localhost/xdpdb" --cpu-core 2
```

Daemon sẽ:
1. Ghim process lên core chỉ định (mặc định 0)
2. LISTEN kênh `xdp_start`
3. In ra hướng dẫn gửi NOTIFY

## 5. Khởi động forwarder với config_id

Từ client PostgreSQL (psql, VSCode SQL, …) kết nối vào cùng DB:

```sql
LISTEN xdp_start;
SELECT pg_notify('xdp_start', '1');
```

Thay `1` bằng `config_id` tương ứng trong bảng `xdp_configs`. Daemon nhận NOTIFY → load config từ DB → attach XDP và bắt đầu forward.

## 6. Tắt

Ctrl+C để dừng daemon. XDP sẽ được detach khi process thoát.
