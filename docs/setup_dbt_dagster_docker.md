

# Enterprise Data Platform

Dự án Data Platform chuẩn doanh nghiệp, sử dụng **Dagster** để điều phối (orchestration) và **dbt** (với DuckDB/Postgres) để biến đổi dữ liệu. Toàn bộ hạ tầng được đóng gói bằng **Docker Compose**.

## 📂 Cấu trúc dự án

Dự án được tổ chức theo mô hình **Platform Pattern**, tách biệt mã nguồn và cấu hình hạ tầng:

```text
enterprise-data-platform/
├── dbt_project/           # Source code dbt (Models, Seeds, Macros)
├── etl_pipeline/          # Source code Dagster (Assets, Resources, Definitions)
│   ├── src/               # Code Python chính
│   └── pyproject.toml     # Quản lý dependencies cho Python project
├── docker/                # Cấu hình Docker
│   ├── Dockerfile         # File build image cho User Code
│   └── requirements.txt   # Các thư viện Python cần cài đặt
├── dagster_home/          # Cấu hình Dagster Instance
│   ├── dagster.yaml       # Cấu hình Storage (Postgres)
│   └── workspace.yaml     # Cấu hình gRPC server location
├── docker-compose.yaml    # File điều phối container
└── .env                   # Biến môi trường (Không commit lên Git)

```

## 🚀 Yêu cầu tiên quyết (Prerequisites)

Trước khi bắt đầu, hãy đảm bảo máy tính của bạn đã cài đặt:

* **Git**
* **Docker Engine** (phiên bản 20.10+)
* **Docker Compose** (V2 recommended)

---

## 🛠️ Hướng dẫn cài đặt (Installation)

### 1. Clone dự án

Mở terminal và chạy lệnh sau để tải source code về máy:

```bash
git clone git@gitlab.hiptechvn.com:hiptech/enterprise-data-platform.git
cd enterprise-data-platform

```

### 2. Cấu hình biến môi trường

Tạo file `.env` tại thư mục gốc của dự án (tạo giống file `.env.template`):

```bash
# Copy file mẫu (nếu có) hoặc tạo mới
touch .env

```

Mở file `.env` và dán nội dung cấu hình sau:

```ini
# Database Configuration (Postgres for Dagster Storage)
# PostgreSQL Configuration
DAGSTER_PG_USERNAME=postgres
DAGSTER_PG_PASSWORD=postgres
DAGSTER_PG_HOSTNAME=postgres
DAGSTER_PG_DB=dagster_storage

# Dagster Configuration
DAGSTER_OVERALL_CONCURRENCY_LIMIT=10

# dbt Configuration
DBT_PROFILES_DIR=/opt/dagster/app/dbt_project
DAGSTER_DBT_PARSE_PROJECT_ON_LOAD=1

```

### 3. Build Docker Image

Quá trình này sẽ tải các thư viện cần thiết và đóng gói code dbt/python vào image.

```bash
docker compose build 

```

> **Lưu ý:** Nếu bạn đang chạy trên Server/Linux và gặp warning về "legacy builder", hãy dùng lệnh sau:
> `COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose build`

---

## ▶️ Khởi chạy dự án (Running)

### 1. Khởi động các dịch vụ

Chạy toàn bộ hệ thống (Webserver, Daemon, Postgres, User Code) dưới nền (detached mode):

```bash
docker compose up -d

```

### 2. Kiểm tra trạng thái

Đảm bảo tất cả container đều ở trạng thái `Healthy` hoặc `Running`:

```bash
docker compose ps

```

### 3. Truy cập giao diện (UI)

* **Dagster UI:** Truy cập trình duyệt tại địa chỉ [http://localhost:3000](https://www.google.com/search?q=http://localhost:3000).
* **Reload Code:** Nếu bạn sửa code Python, Dagster sẽ tự động reload (nhờ volume mount). Nếu sửa thư viện (`requirements.txt`), bạn cần build lại image.

---

## 👨‍💻 Quy trình phát triển (Development Workflow)

### Thêm thư viện Python mới

1. Mở file `docker/requirements.txt`.
2. Thêm tên thư viện (ví dụ: `requests==2.31.0`).
3. Chạy lệnh build lại:
```bash
docker compose build
docker compose up -d

```



### Debug lỗi kết nối

Nếu Dagster Webserver báo lỗi không kết nối được code server:

1. Kiểm tra log của container `user-code`:
```bash
docker logs -f dagster_user_code

```


2. Đảm bảo file `dagster_home/workspace.yaml` trỏ đúng host `user-code` và port `4000`.

### Reset dữ liệu (Cẩn thận)

Để xóa sạch database và chạy lại từ đầu:

```bash
docker compose down -v
docker compose up -d

```

---

## 🤝 Đóng góp (Contributing)

1. Tạo branch mới cho tính năng (`git checkout -b feature/amazing-feature`).
2. Commit thay đổi (`git commit -m 'Add some amazing feature'`).
3. Push lên branch (`git push origin feature/amazing-feature`).
4. Tạo Merge Request (MR).

---

## 📄 License

Project này được lưu hành nội bộ (Internal Use Only).