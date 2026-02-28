# Finance Dashboard — Câu hỏi kinh doanh (Tiếng Việt)

> **Ngày**: 2026-03-01  
> **Dataset**: Enterprise DWH (DuckDB + dbt + S3/Parquet)

---

## FINANCE FUNNEL — 7 DASHBOARDS × 3 CÂU HỎI = 21 CÂU HỎI KINH DOANH

---

### 1️⃣ Tổng quan tài chính

> Bức tranh P&L tổng quan cho lãnh đạo — Doanh thu, Giá vốn, Lợi nhuận gộp, các chi phí vận hành chính, so sánh với kỳ trước.

| # | Câu hỏi kinh doanh | Tính khả thi |
|---|---|---|
| Q1 | Hiệu quả tài chính tổng thể (Doanh thu, Giá vốn, Lợi nhuận gộp, và các chi phí vận hành chính gồm chi phí sản xuất, vận chuyển, thuế) so với các kỳ trước như thế nào? | ⚠️ Điều chỉnh — không có SGA/bảng ngân sách; dùng so sánh kỳ trước |
| Q2 | Các KPI tài chính trọng yếu (Biên lợi nhuận gộp %, Giá trị đơn hàng trung bình, Doanh thu/đơn vị, Tỷ lệ chi phí/doanh thu) đang biến động ra sao theo thời gian, và có điểm ngoặt đáng lo ngại nào không? | ✅ Khả thi hoàn toàn |
| Q3 | Hiệu quả tài chính phân bổ giữa kênh Internet và Reseller ở mức tổng quan như thế nào? | ✅ Khả thi hoàn toàn |

---

### 2️⃣ Phân tích doanh thu & Tăng trưởng

> Phân tích xu hướng doanh thu — tốc độ tăng trưởng, tỷ trọng kênh bán, tác động chiết khấu, tính mùa vụ.

| # | Câu hỏi kinh doanh | Tính khả thi |
|---|---|---|
| Q1 | Xu hướng doanh thu theo thời gian (MoM, QoQ, YoY) ra sao, và giai đoạn nào tăng trưởng mạnh/yếu nhất? | ✅ Khả thi hoàn toàn |
| Q2 | Tỷ trọng doanh thu giữa kênh Internet và Reseller đang dịch chuyển thế nào, và chiết khấu tác động ra sao đến doanh thu thuần của mỗi kênh? | ✅ Khả thi hoàn toàn |
| Q3 | Doanh thu có tính mùa vụ không, và tháng/quý nào thường xuyên vượt hoặc thấp hơn kỳ vọng? | ✅ Khả thi hoàn toàn |

---

### 3️⃣ Cơ cấu chi phí & Kiểm soát

> Phân tích chi phí toàn doanh nghiệp — Giá vốn, sản xuất, vận chuyển, thuế, phế liệu. Phát hiện chênh lệch chi phí và xu hướng chi phí leo thang.

| # | Câu hỏi kinh doanh | Tính khả thi |
|---|---|---|
| Q1 | Tổng chi phí phân bổ theo các thành phần chính (Giá vốn, sản xuất, vận chuyển, thuế, phế liệu) như thế nào, và mỗi thành phần biến động ra sao theo thời gian? | ✅ Khả thi hoàn toàn |
| Q2 | Chênh lệch chi phí lớn nhất xảy ra ở đâu — sản phẩm, phân xưởng, hay nhà cung cấp nào đang đẩy chi phí vượt mức dự kiến? | ✅ Khả thi hoàn toàn |
| Q3 | Tỷ lệ chi phí/doanh thu đang biến động thế nào, và các chi phí liên quan sản xuất (Giá vốn, sản xuất, vận chuyển) có đang tăng nhanh hơn doanh thu không? | ⚠️ Điều chỉnh — chỉ có chi phí liên quan sản xuất, không có toàn bộ chi phí hoạt động |

---

### 4️⃣ Phân tích lợi nhuận & Biên lợi nhuận

> Phân tích biên lợi nhuận gộp — xu hướng biên, xếp hạng danh mục, mối quan hệ chiết khấu-biên lợi nhuận, phát hiện xói mòn biên.

| # | Câu hỏi kinh doanh | Tính khả thi |
|---|---|---|
| Q1 | Xu hướng biên lợi nhuận gộp qua các kỳ như thế nào, và quý nào cho thấy biên lợi nhuận bị nén hoặc mở rộng? | ✅ Khả thi hoàn toàn |
| Q2 | Nhóm sản phẩm và danh mục phụ nào dẫn đầu biên lợi nhuận, nhóm nào tụt hậu, và thứ hạng này thay đổi ra sao theo thời gian? | ✅ Khả thi hoàn toàn |
| Q3 | Chiết khấu và chiến lược giá ảnh hưởng thế nào đến biên lợi nhuận theo kênh bán, và có dấu hiệu xói mòn biên lợi nhuận do chiết khấu quá mức không? | ✅ Khả thi hoàn toàn |

---

### 5️⃣ Hiệu quả tài chính theo Vùng & Kênh bán

> P&L theo vùng lãnh thổ — doanh thu, lợi nhuận, biên theo địa lý và kênh bán. Phân tích đà tăng trưởng.

| # | Câu hỏi kinh doanh | Tính khả thi |
|---|---|---|
| Q1 | Vùng lãnh thổ và nhóm vùng nào tạo ra doanh thu, lợi nhuận, biên lợi nhuận cao nhất — và xếp hạng giữa chúng ra sao? | ✅ Khả thi hoàn toàn |
| Q2 | Tỷ trọng kênh Internet vs Reseller khác nhau thế nào giữa các vùng, và kênh nào sinh lời hơn ở mỗi khu vực? | ✅ Khả thi hoàn toàn |
| Q3 | Vùng nào có đà tăng trưởng doanh thu mạnh nhất, vùng nào đang suy giảm — gợi ý cơ hội mở rộng hoặc thu hẹp? | ✅ Khả thi hoàn toàn |

---

### 6️⃣ Phân tích tài chính Mua hàng

> Phân tích chi tiêu mua hàng — xu hướng chi tiêu, mức độ tập trung nhà cung cấp, tương quan giá-khối lượng, tác động chi phí hàng bị từ chối.

| # | Câu hỏi kinh doanh | Tính khả thi |
|---|---|---|
| Q1 | Xu hướng tổng chi tiêu mua hàng ra sao, và nó tương quan thế nào với tăng trưởng doanh thu — chúng ta đang chi tiêu tương xứng với tăng trưởng chưa? | ✅ Khả thi hoàn toàn |
| Q2 | Chi tiêu mua hàng tập trung ở các nhà cung cấp như thế nào, và chúng ta có đạt được giá tốt hơn từ nhà cung cấp khối lượng lớn không? | ✅ Khả thi hoàn toàn |
| Q3 | Tác động tài chính của nguyên vật liệu bị từ chối là bao nhiêu — bao nhiêu chi tiêu bị lãng phí cho hàng lỗi, và nhà cung cấp nào chịu trách nhiệm? | ✅ Khả thi hoàn toàn |

---

### 7️⃣ Phân tích tài chính Danh mục sản phẩm

> Hiệu quả tài chính theo sản phẩm — đóng góp doanh thu/lợi nhuận, phân tích khoảng cách giá, xác định sản phẩm cần điều chỉnh biên.

| # | Câu hỏi kinh doanh | Tính khả thi |
|---|---|---|
| Q1 | Đóng góp doanh thu và lợi nhuận của mỗi danh mục sản phẩm ra sao — danh mục nào là "bò sữa" (cash cow), danh mục nào là "dấu hỏi"? | ✅ Khả thi hoàn toàn |
| Q2 | Giá sản phẩm (giá niêm yết vs giá bán thực tế) khác nhau thế nào giữa các danh mục, và khoảng cách giá lớn nhất ở đâu? | ✅ Khả thi hoàn toàn |
| Q3 | Sản phẩm nào có biên lợi nhuận và doanh thu cao nhất, và sản phẩm doanh thu cao nào có biên lợi nhuận thấp nguy hiểm cần điều chỉnh giá? | ✅ Khả thi hoàn toàn |

---

## TÓM TẮT

| Dashboard | Trạng thái | Ghi chú |
|---|---|---|
| 1️⃣ Tổng quan tài chính | ⚠️ Gần đạt | Không có đầy đủ OpEx (SGA, nhân sự); không có ngân sách — dùng so sánh kỳ trước |
| 2️⃣ Doanh thu & Tăng trưởng | ✅ Hoàn hảo | — |
| 3️⃣ Cơ cấu chi phí & Kiểm soát | ⚠️ Lỗ hổng nhỏ | Chỉ có chi phí liên quan sản xuất, không có toàn bộ OpEx |
| 4️⃣ Lợi nhuận & Biên | ✅ Hoàn hảo | — |
| 5️⃣ Vùng & Kênh bán | ✅ Hoàn hảo | — |
| 6️⃣ Tài chính Mua hàng | ✅ Hoàn hảo | — |
| 7️⃣ Danh mục sản phẩm | ✅ Hoàn hảo | — |

**Kết quả: 5/7 khả thi hoàn toàn, 2/7 cần điều chỉnh câu chữ nhỏ (không cần thay đổi cấu trúc dashboard).**
