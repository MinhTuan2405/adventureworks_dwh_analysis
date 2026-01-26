
# Giải thích chi tiết Docker Compose (`docker-compose.yaml`)

Tài liệu này giải thích cấu hình của 4 services chính tạo nên **Enterprise Data Platform**. Hệ thống được thiết kế để đảm bảo tính nhất quán (consistency), khả năng cập nhật code nóng (hot-reload) và thứ tự khởi động an toàn.

## 1. Service: `postgres` (Cơ sở dữ liệu)

Đây là nơi lưu trữ trạng thái của Dagster (Lịch sử chạy Run history, Event logs, trạng thái Schedules).

```yaml
postgres:
  image: postgres:14
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U ${DAGSTER_PG_USERNAME}"]
    interval: 10s
    retries: 5

```

* **Lưu trữ bền vững (Persistence):**
* Volume `postgres_data` được mount vào `/var/lib/postgresql/data`. Điều này đảm bảo khi bạn tắt container (`docker compose down`), dữ liệu lịch sử chạy job **không bị mất**.


* **Healthcheck (Kiểm tra sức khỏe):**
* Sử dụng lệnh `pg_isready` để kiểm tra DB đã sẵn sàng nhận kết nối chưa.
* **Tại sao quan trọng?** Các service khác (`webserver`, `daemon`) sẽ bị crash nếu khởi động trước khi DB sẵn sàng. Healthcheck này giúp điều phối thứ tự khởi động.



---

## 2. Service: `user-code` (Trái tim của hệ thống)

Đây là container chứa toàn bộ logic nghiệp vụ (Python Code + dbt Project). Nó đóng vai trò là một **gRPC Server** để Dagster Webserver giao tiếp.

```yaml
user-code:
  build:
    context: .              # Build từ thư mục gốc
    dockerfile: docker/Dockerfile
  image: my_dagster_image:latest

```

### Các cấu hình quan trọng:

#### a. Biến môi trường (Environment Variables)

* **`DAGSTER_DBT_PARSE_PROJECT_ON_LOAD: "1"`**:
* **Tác dụng:** Buộc thư viện `dagster-dbt` chạy lệnh `dbt parse` để tạo lại file `manifest.json` mỗi khi container khởi động hoặc reload.
* **Ý nghĩa:** Giúp Dagster nhận diện được các thay đổi trong file SQL/dbt models mà không cần build lại image.


* **`DBT_PROFILES_DIR`**: Chỉ định nơi chứa file `profiles.yml` (đã được copy vào `/opt/dagster/app/dbt_project` trong Dockerfile).

#### b. Mount Volumes (Cơ chế Hot-reload)

* **Code Python:** `- ./etl_pipeline/src:/opt/dagster/app/etl_pipeline/src`
* Map code từ máy thật vào container. Sửa file `.py` xong -> Dagster tự reload.


* **Code dbt:** `- ./dbt_project:/opt/dagster/app/dbt_project`
* Map code từ máy thật vào container. Sửa file `.sql` xong -> Dagster (nhờ biến môi trường ở trên) sẽ parse lại và cập nhật.


* **dbt Artifacts (Quan trọng):**
* `- dbt_target:/opt/dagster/app/dbt_project/target`
* `- dbt_logs:/opt/dagster/app/dbt_project/logs`
* **Tác dụng:** Sử dụng volume riêng biệt cho thư mục `target` và `logs`. Điều này giúp giữ lại kết quả compile (tăng tốc độ chạy dbt) và tránh xung đột file giữa máy chủ (Linux) và máy local (Windows/Mac).



#### c. Healthcheck

* Chạy lệnh `dagster api grpc-health-check` để đảm bảo code server đã nạp xong (load xong thư viện, parse xong dbt) trước khi cho phép Webserver kết nối.

---

## 3. Service: `dagster-webserver` (Giao diện UI)

Service này cung cấp giao diện web tại cổng 3000.

```yaml
dagster-webserver:
  image: my_dagster_image:latest  # Tái sử dụng image của user-code
  entrypoint:
    - dagster-webserver
    - -w
    - "/opt/dagster/dagster_home/workspace.yaml"
  depends_on:
    user-code:
      condition: service_healthy

```

* **Tái sử dụng Image:**
* Chúng ta dùng chung image `my_dagster_image:latest` với service `user-code`.
* **Lợi ích:** Đảm bảo phiên bản Python và các thư viện (`dagster`, `dbt-core`, `pandas`...) giữa Webserver và Code Server là **giống hệt nhau**. Tránh lỗi "Version Mismatch".


* **Thứ tự khởi động (`depends_on`):**
* Chỉ khởi động khi `postgres` và `user-code` đều đã ở trạng thái **Healthy**. Điều này khắc phục triệt để lỗi `Connection Refused` hoặc `Workspace Not Found`.


* **Workspace:** Tham số `-w` chỉ định file cấu hình để Webserver biết cần kết nối tới gRPC server nào (ở đây là `user-code:4000`).

---

## 4. Service: `dagster-daemon` (Bộ điều phối ngầm)

Service này chạy ngầm, chịu trách nhiệm kích hoạt:

1. **Schedules:** Lịch chạy định kỳ.
2. **Sensors:** Cảm biến sự kiện.
3. **Run Queue:** Quản lý hàng đợi job.

```yaml
dagster-daemon:
  image: my_dagster_image:latest
  entrypoint:
    - dagster-daemon
    - run
    - -w
    - "/opt/dagster/dagster_home/workspace.yaml"

```

* **Cấu hình tương tự Webserver:** Nó cũng tái sử dụng image và cần đọc `workspace.yaml` để biết các lịch trình (Schedules) đang nằm ở đâu trong `user-code`.
* **Logs:** Volume `dagster_compute_logs` được chia sẻ giữa Webserver và Daemon để bạn có thể xem log chạy job trực tiếp trên UI.

---

## 5. Network & Volumes

### Networks

* `dagster_network`: Một mạng cầu nối (bridge network) riêng biệt giúp các container nhìn thấy nhau bằng tên service (ví dụ: code kết nối DB qua host `postgres`, webserver kết nối code qua host `user-code`).

### Volumes

* `postgres_data`: Lưu dữ liệu DB bền vững.
* `dagster_compute_logs`: Lưu file log (stdout/stderr) của từng job run.
* `dagster_local_artifact_storage`: Nơi lưu các file tạm hệ thống của Dagster.
* `dbt_target`: Cache kết quả biên dịch dbt (giúp chạy nhanh hơn).
* `dbt_logs`: Lưu log chi tiết của dbt.