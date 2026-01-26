

# 🛠️ Hướng dẫn Dev Local 

Cách này giúp terminal của bạn "chui" hẳn vào trong môi trường ảo. Mọi lệnh `python`, `dagster`, `dbt` bạn gõ sẽ tự động dùng thư viện của dự án.

**Prequisite**: uv, nếu chưa tải thì tải uv về, dự án chạy trên môi trường ảo uv.

## 1. Chuẩn bị (Chỉ làm 1 lần khi mở máy)

Đầu tiên, hãy đi vào thư mục chứa code Python (nơi có file `pyproject.toml`).

```bash
cd ~/workspace/enterprise-data-platform/AdventureWork/etl_pipeline

uv sync

```

*(Nếu chưa có môi trường hoặc muốn chắc ăn, chạy `uv sync` để nó tạo folder `.venv` mới nhất).*

## 2. Kích hoạt môi trường (Activate)

Chạy lệnh này để bật chế độ môi trường ảo:

```bash
source .venv/bin/activate

```

> **Dấu hiệu thành công:**
> Bạn sẽ thấy tên dự án (thường là `(etl-pipeline)` hoặc `(.venv)`) xuất hiện ở đầu dòng lệnh terminal.
> Ví dụ: `(etl-pipeline) nghiavo@halo:~/...$`

---

## 3. Chạy Dagster

Bây giờ bạn đã ở trong môi trường, bạn có thể gọi trực tiếp `dagster` (hoặc `dg`).

```bash
dagster dev

```

*Lệnh này sẽ tự động load code từ file `pyproject.toml` hoặc `dagster.yaml` hiện tại.*

---

## 4. Chạy dbt (Thủ công / Debug)

Đây là phần bạn cần lưu ý. Vì chúng ta đang đứng ở folder `etl_pipeline`, nhưng code dbt lại nằm ở folder `dbt_project` (ngang hàng bên ngoài), nên khi chạy lệnh `dbt` bạn phải **chỉ đường** cho nó.

**Lệnh chạy dbt build (Chạy cả Model + Test):**

```bash
dbt build --project-dir ../dbt_project --profiles-dir ../dbt_project

```

**Giải thích:**

* `--project-dir ../dbt_project`: Bảo dbt là "Ê, code SQL nằm ở thư mục cha, bên cạnh ấy".
* `--profiles-dir ../dbt_project`: Bảo dbt tìm file `profiles.yml` kết nối DB cũng ở đó luôn.

*(Mẹo: Nếu bạn thấy lệnh dài quá, bạn có thể `cd ../dbt_project` để chui vào folder dbt, chạy lệnh `dbt build` cho ngắn, rồi lại `cd ../etl_pipeline` để về chạy Dagster).*

---

## 5. Thoát môi trường (Khi nghỉ làm)

Khi nào code xong, muốn thoát ra để terminal trở lại bình thường:

```bash
deactivate

```

---

### Tóm tắt quy trình hàng ngày (Cheat Sheet)

1. `cd AdventureWork/etl_pipeline`
2. `source .venv/bin/activate` (Thấy hiện chữ `(etl-pipeline)` là ngon)
3. Làm việc:
* Chạy server: `dagster dev`
* Debug dbt: `dbt build --project-dir ../dbt_project ...`


4. Xong việc: `deactivate`