
# Giải thích chi tiết Dockerfile cho Dagster User Code

Tài liệu này giải thích từng bước (step-by-step) cách xây dựng Docker Image cho service **User Code** trong dự án Enterprise Data Platform.

Image này chịu trách nhiệm chứa code Python (Dagster) và code SQL (dbt), đồng thời chạy gRPC server để Dagster Webserver/Daemon có thể giao tiếp.

---

## 1. Môi trường cơ sở (Base Image)

```dockerfile
FROM python:3.10-slim

```
* **Ý nghĩa:** Sử dụng ảnh nền (base image) là Python phiên bản 3.10.


## 2. Cài đặt Dependencies hệ thống

```dockerfile
# 1. Install system dependencies (git needed for dbt deps)
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

```

* **`apt-get update`**: Cập nhật danh sách các gói phần mềm mới nhất.
* **`install -y git`**: Cài đặt Git.
* *Tại sao cần Git?* Vì dbt thường cần tải các gói thư viện (packages) từ GitHub/GitLab thông qua lệnh `dbt deps`. Nếu thiếu Git, bước chạy dbt sẽ bị lỗi.


* **`rm -rf /var/lib/apt/lists/*`**: Xóa bộ nhớ đệm (cache) của apt sau khi cài xong để giảm dung lượng image.

---

## 3. Cài đặt thư viện Python (Dependencies)

```dockerfile
# 2. Copy and install Python requirements
COPY docker/requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

```

* **`COPY ...`**: Copy file `requirements.txt` từ máy thật (nằm trong thư mục `docker/`) vào thư mục tạm `/tmp/` trong container.
* **`pip install ...`**: Cài đặt các thư viện (Dagster, dbt, Pandas...) được liệt kê trong file đó.
* **Tại sao làm bước này trước khi Copy Code?**: Đây là kỹ thuật **Docker Layer Caching**. Nếu bạn chỉ sửa code mà không sửa file requirements, Docker sẽ bỏ qua bước này (dùng cache cũ), giúp quá trình build lại chỉ mất vài giây thay vì vài phút.

---

## 4. Thiết lập thư mục làm việc

```dockerfile
# Set working directory
WORKDIR /opt/dagster/app

```

* Tạo và di chuyển con trỏ làm việc vào thư mục `/opt/dagster/app`. Mọi lệnh `COPY`, `RUN` phía sau sẽ mặc định thao tác tại đây nếu dùng đường dẫn tương đối.

---

## 5. Copy mã nguồn (Source Code)

Đây là bước quan trọng để đưa code từ máy tính vào trong Docker.

```dockerfile
# 3. Copy dbt project
COPY dbt_project/ /opt/dagster/app/dbt_project/

# 4. Copy Python Code
COPY etl_pipeline/ /opt/dagster/app/etl_pipeline/

```

* **`dbt_project/`**: Chứa toàn bộ Models, Seeds, Snapshots của dbt.
* **`etl_pipeline/`**: Chứa code Python (Assets, Definitions) và file cấu hình `pyproject.toml`.
* *Lưu ý:* Docker sẽ copy **toàn bộ nội dung** bên trong folder nguồn vào folder đích tương ứng trong container.

---

## 6. Cài đặt Project Python

```dockerfile
# 5. Install the project
RUN pip install --no-deps -e /opt/dagster/app/etl_pipeline

```

* **`pip install -e <path>`**: Cài đặt project Python ở chế độ "Editable" (có thể chỉnh sửa). Dagster yêu cầu code phải được đóng gói thành package để có thể import được (ví dụ: `from etl_pipeline import ...`).
* **`--no-deps`**: Không cài lại các thư viện phụ thuộc nữa (vì đã cài ở bước 3 rồi). Điều này giúp tránh xung đột phiên bản và tiết kiệm thời gian.

---

## 7. Cấu hình biến môi trường (Environment Variables)

```dockerfile
# 6. Set Python path
ENV PYTHONPATH=/opt/dagster/app/etl_pipeline/src:$PYTHONPATH

# Set DBT profiles directory
ENV DBT_PROFILES_DIR=/opt/dagster/app/dbt_project

```

* **`PYTHONPATH`**: Chỉ cho Python biết nơi tìm kiếm module. Ta trỏ vào thư mục `src` để câu lệnh `import etl_pipeline` hoạt động đúng.
* **`DBT_PROFILES_DIR`**: Chỉ cho dbt biết file `profiles.yml` (cấu hình kết nối database) nằm ở đâu. Nếu không có dòng này, dbt sẽ tìm ở `~/.dbt/` và sẽ báo lỗi không tìm thấy.

---

## 8. Chuẩn bị cho dbt (Pre-compile)

```dockerfile
# Create directory for dbt artifacts
RUN mkdir -p /opt/dagster/app/dbt_project/target

# 7. Run dbt deps and parse
RUN cd /opt/dagster/app/dbt_project && \
    dbt deps && \
    dbt parse

```

* **`mkdir ... target`**: Tạo thư mục chứa kết quả biên dịch.
* **`dbt deps`**: Tải các gói dbt (như `dbt-utils`...) nếu có khai báo trong `packages.yml`.
* **`dbt parse`**: Đây là bước tối ưu hóa. Nó đọc toàn bộ project dbt và tạo ra file `manifest.json`. Dagster cần file này để hiển thị Asset Graph. Việc chạy trước ở đây giúp container khởi động nhanh hơn.

---

## 9. Cấu hình Server & Healthcheck

```dockerfile
# Expose port for gRPC server
EXPOSE 4000

```

* Mở cổng 4000 để các container khác (Webserver/Daemon) có thể kết nối vào.

```dockerfile
# Health check
HEALTHCHECK --interval=10s --timeout=3s --start-period=30s --retries=5 \
    CMD dagster api grpc-health-check -p 4000

```

* **Tác dụng:** Docker sẽ định kỳ kiểm tra xem server có còn sống không.
* **`dagster api grpc-health-check`**: Lệnh chuyên dụng của Dagster để ping thử vào cổng 4000.
* **`start-period=30s`**: Cho phép container có 30 giây để khởi động (load thư viện, đọc dbt project...) trước khi bắt đầu kiểm tra. Điều này ngăn chặn việc container bị kill oan khi đang khởi động nặng.

---

## 10. Lệnh khởi động (Entrypoint)

```dockerfile
# Start the gRPC server
CMD ["dagster", "code-server", "start", "-h", "0.0.0.0", "-p", "4000", "-m", "etl_pipeline.definitions"]

```

* Đây là lệnh chính sẽ chạy khi container bắt đầu.
* **`dagster code-server start`**: Khởi chạy server chứa code người dùng.
* **`-h 0.0.0.0`**: Lắng nghe mọi địa chỉ IP (bắt buộc trong Docker).
* **`-p 4000`**: Chạy trên cổng 4000.
* **`-m etl_pipeline.definitions`**: Chỉ định file Python chứa đối tượng `Definitions` (điểm bắt đầu của Dagster).
