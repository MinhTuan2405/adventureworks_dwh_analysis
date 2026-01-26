
FROM python:3.10-slim

# Cài đặt git
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# --- SETUP UV ---
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Cấu hình UV
ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy

# Thiết lập thư mục làm việc
WORKDIR /opt/dagster/app

# uv sync sẽ tạo .venv, ta thêm nó vào PATH để gọi lệnh trực tiếp
ENV PATH="/opt/dagster/app/.venv/bin:$PATH"

# --- INSTALL DEPENDENCIES ---
COPY etl_pipeline/pyproject.toml etl_pipeline/uv.lock ./

# Cài đặt thư viện (nhưng chưa cài code project)
RUN uv sync --frozen --no-install-project

# --- INSTALL PROJECT & DBT ---
COPY etl_pipeline/ ./etl_pipeline/
COPY dbt_project/ ./dbt_project/

# Cài đặt project hiện tại
RUN uv sync --frozen

# Thiết lập biến môi trường
ENV PYTHONPATH=/opt/dagster/app/etl_pipeline/src:$PYTHONPATH

# Tạo thư mục target và cấp quyền
RUN mkdir -p /opt/dagster/app/dbt_project/target && \
    chmod -R 777 /opt/dagster/app/dbt_project/target

# Chạy dbt deps (Lúc này nó sẽ tìm thấy dbt nhờ dòng ENV PATH ở trên)
RUN cd /opt/dagster/app/dbt_project && \
    dbt deps && \
    dbt parse

EXPOSE 4000

# Health check
HEALTHCHECK --interval=10s --timeout=3s --start-period=30s --retries=5 \
    CMD dagster api grpc-health-check -p 4000

# Start
CMD ["dagster", "code-server", "start", "-h", "0.0.0.0", "-p", "4000", "-m", "etl_pipeline.definitions"]