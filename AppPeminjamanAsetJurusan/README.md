# 🖥️ 4LLASET Backend (Sistem Peminjaman Aset Jurusan)
**Central Management API & Admin Dashboard**

4LLASET Backend adalah inti dari ekosistem 4LLASET, menyediakan API robust untuk aplikasi mobile dan dashboard berbasis web untuk manajemen aset sekolah secara terpusat.

---

## ✨ Fitur Utama
*   **API Resource Ready**: Mendukung integrasi mulus dengan frontend mobile Flutter.
*   **Role-Based Access Control (RBAC)**: Pemisahan akses ketat antara Admin, Officer, dan Siswa.
*   **Manajemen Inventaris**: Dashboard untuk menambah, mengubah, dan memantau stok aset per jurusan.
*   **Sistem Verifikasi**: Alur persetujuan peminjaman yang dapat dikelola per departemen/jurusan.
*   **Email Integration**: Mendukung verifikasi email untuk keamanan akun.

---

## 🛠️ Persiapan Pengembangan
1.  **Clone Repository**:
    ```bash
    git clone [url-repository]
    ```
2.  **Environment Setup**:
    Salin `.env.example` menjadi `.env` dan konfigurasikan database Anda.
3.  **Install Dependencies**:
    ```bash
    composer install
    npm install && npm run build
    ```
4.  **Database Migration & Seeding**:
    ```bash
    php artisan migrate:fresh --seed
    ```
5.  **Run Server**:
    ```bash
    php artisan serve
    ```

---

## 📖 Dokumentasi Lengkap
*   [Buku Manual Lengkap (Indonesian)](./Manual_Book_4LLASET_Lengkap.md)
*   [Laporan Teknis & Debugging](./System_Documentation_and_Debugging_Report.md)

---
*Dibuat oleh Tim 4LLASET untuk efisiensi sekolah Indonesia.*
