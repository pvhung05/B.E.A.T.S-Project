# <p align="center">🌊 B.E.A.T.S. 🌊</p>
<p align="center">
  <strong>Biological Ecosystem Animation and Tracking System</strong><br>
  <i>A real-time marine ecosystem simulation built with Processing</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Version-0.7.0-blue?style=for-the-badge" alt="Version">
  <img src="https://img.shields.io/badge/Built%20with-Processing%204-006699?style=for-the-badge&logo=processing" alt="Processing">
  <img src="https://img.shields.io/badge/Architecture-ECS-green?style=for-the-badge" alt="ECS">
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" alt="License">
</p>

---

### 📖 Giới thiệu
**B.E.A.T.S.** là một môi trường giả lập hệ sinh thái biển thời gian thực. Tại đây, chuỗi thức ăn được tái hiện sinh động: kẻ săn mồi rình rập, con mồi sinh sản và các yếu tố môi trường tác động trực tiếp đến sự cân bằng sinh thái.

> [!TIP]
> **Xem thế giới thở:** Quan sát tảo quang hợp, cá mòi di cư, cá mập săn mồi và cua ăn xác trong một thế giới nước đầy màu sắc.

---

## 🚀 Quick Start

### 🛠 Prerequisites
*   [Processing 4.x](https://processing.org/download) hoặc mới hơn.

### 📥 Installation & Run
1.  **Download** hoặc `git clone` repository này.
2.  Mở file `BEATS/BEATS.pde` trong Processing.
3.  Nhấn **Run** (`Ctrl+R`).
4.  *Simulation sẽ tự động chạy ở chế độ toàn màn hình với kịch bản có sẵn.*

---

## ✨ Key Features

<table width="100%">
  <tr>
    <td width="50%">
      <h4>🌿 Hệ sinh thái sống</h4>
      Tảo, cá mòi, cua và cá mập sinh tồn dựa trên quy luật sinh học thực tế.
    </td>
    <td width="50%">
      <h4>📊 Biểu đồ thời gian thực</h4>
      Theo dõi biến động dân số qua các biểu đồ trực quan ngay trên màn hình.
    </td>
  </tr>
  <tr>
    <td>
      <h4>🌡️ Kiểm soát môi trường</h4>
      Thay đổi nhiệt độ và độ ô nhiễm để thử thách khả năng thích nghi của loài.
    </td>
    <td>
      <h4>🎮 Tương tác trực tiếp</h4>
      Công cụ Spawn (thả quân) và Cull (loại bỏ) cho phép bạn can thiệp vào tự nhiên.
    </td>
  </tr>
</table>

---

## 🏗 System Architecture

Hệ thống được xây dựng trên mô hình **Entity-Component-System (ECS)** mạnh mẽ:

*   **Entities:** Định danh các sinh vật (tảo, cá, cua...).
*   **Components:** Dữ liệu thuộc tính (vị trí, máu, năng lượng, chế độ ăn...).
*   **Systems:** Logic xử lý (di chuyển, săn mồi, sinh sản...).

### 🛠 Major Subsystems
| Subsystem | Purpose |
| :--- | :--- |
| **Core** | Quản lý thực thể, rendering, event routing, âm thanh & camera. |
| **ECS** | Framework lõi điều khiển toàn bộ logic sinh học. |
| **FX** | Hệ thống hạt (particles) cho bong bóng, dòng nước và hiệu ứng thị giác. |
| **UI** | Dashboard tương tác: menu, biểu đồ dân số và bộ công cụ điều khiển. |

---

## 🧬 The Ecosystem: Species & Food Chains



| Loài | Vai trò | Chế độ ăn | Đặc điểm |
| :--- | :--- | :--- | :--- |
| **Algae** | Producer | Quang hợp | Sống tầng mặt, nhạy cảm với ô nhiễm. |
| **Sardine** | Herbivore | Tảo | Di chuyển nhanh, sinh sản mạnh khi no. |
| **Crab** | Scavenger | Chất hữu cơ | Sống tầng đáy, chống chịu ô nhiễm tốt. |
| **Shark** | Apex Predator | Cá mòi | Kẻ săn mồi đỉnh cao, tốc độ cực nhanh. |

---

## ⌨️ Controls & Interaction

### 🖱 Mouse Controls
*   **Cuộn chuột:** Phóng to / Thu nhỏ (Zoom).
*   **Chuột trái:** Sử dụng công cụ (Spawn/Cull).
*   **Kéo chuột phải:** Di chuyển Camera (Pan).

### ⌨️ Keyboard Shortcuts
| Phím | Hành động |
| :--- | :--- |
| `ESC` | Mở / Đóng Menu chính |
| `C` | Xóa sổ toàn bộ sinh vật (Clear All) |

---

## 🛠 Extensibility (Mở rộng)

Bạn muốn thêm sinh vật mới? Chỉ cần tạo file JSON tại `data/organisms/`:

json
{
  "species": "jellyfish",
  "count": 15,
  "initialEnergy": 0.5,
  "region": { "x": 0.0, "y": 0.2, "w": 1.0, "h": 0.6 }
}

## 🔍 Troubleshooting (Xử lý sự cố)

Nếu gặp vấn đề trong quá trình vận hành, hãy kiểm tra các trường hợp sau:

| Vấn đề | Giải pháp |
| :--- | :--- |
| **Giả lập chạy chậm (Lag)** | Giảm số lượng sinh vật bằng công cụ **Cull** hoặc chỉnh lại thông số trong `config.json`. Thu nhỏ tầm nhìn (Zoom out) cũng giúp giảm tải xử lý đồ họa. |
| **Không có âm thanh** | Kiểm tra âm lượng hệ thống và đảm bảo thư mục `data/sound/` có đầy đủ file. Xem Console để biết lỗi thiếu file cụ thể. |
| **Không Spawn được** | Đảm bảo giả lập đang chạy (không nhấn Pause). Kiểm tra xem biểu tượng con trỏ chuột đã thay đổi sang icon sinh vật chưa. |


---

## 🌊 Enjoy the Ecosystem!

Chúc bạn có những giây phút khám phá đại dương đầy thú vị! Hãy thử nghiệm việc:
*   Thả hàng loạt cá mập để xem sự sụp đổ của chuỗi thức ăn.
*   Tăng ô nhiễm lên mức tối đa để tìm ra loài sinh vật "lì lợm" nhất.
*   Tạo ra một kịch bản cân bằng hoàn hảo mà không cần sự can thiệp của con người.

---

<p align="center">
  <b>B.E.A.T.S.</b> - <i>"Exploring the emergent complexity of nature, one pixel at a time."</i>
  <br>
  <img src="https://img.shields.io/badge/Made%20with-Love%20&%20Code-ff69b4?style=flat-square" alt="Made with Love">
</p>
