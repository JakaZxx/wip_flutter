# 🚀 PANDUAN MENJALANKAN SISTEM 4LLASET
**Khusus untuk Teman/Tim Pengembang**

Dokumen ini menjelaskan cara cepat agar sistem 4LLASET dapat berjalan di laptop Anda dan bisa diakses melalui Handphone (HP) dalam satu jaringan.

---

## 📋 Langkah 1: Persiapan Backend (Laravel)
1. Buka terminal di folder `AppPeminjamanAsetJurusan`.
2. Pastikan file `.env` sudah sesuai dengan database lokal Anda.
3. Jalankan perintah:
   ```bash
   composer install
   php artisan migrate:fresh --seed  # Hapus & isi data dummy baru
   php artisan storage:link          # Agar gambar aset muncul
   php artisan serve --host=0.0.0.0  # WAJIB host 0.0.0.0 agar bisa diakses HP
   ```

---

## 📋 Langkah 2: Persiapan Frontend (Flutter)
1. Buka terminal di folder `ASPAJFlutter`.
2. Cek IP Laptop Anda (jalankan `ipconfig` di Windows).
3. Buka file `lib/services/api_service.dart`.
4. Update variabel `_defaultIP` dengan IP Laptop Anda:
   ```dart
   static const String _defaultIP = '192.168.x.x'; // Ganti dengan IP Anda
   ```
5. Jalankan aplikasi:
   ```bash
   flutter pub get
   flutter run -d chrome  # Untuk running di Web/Laptop
   ```

---

## 📱 Langkah 3: Menjalankan di Handphone (HP)
Agar HP bisa terhubung ke server di laptop:
1. **Satu Jaringan**: Pastikan HP dan Laptop terhubung ke Wi-Fi yang sama (atau HP Tethering ke Laptop).
2. **Update IP**: Pastikan IP di `api_service.dart` sudah benar sesuai IP Laptop.
3. **Running**:
   ```bash
   flutter run           # Pilih device HP Anda (Android/iOS)
   ```
4. **Firewall**: Jika HP tidak bisa konek, matikan sementara Windows Firewall atau izinkan port 8000.

---

## 🔑 Kredensial Login (Testing)
Gunakan akun berikut untuk mencoba:
*   **Admin**: `admin@aset.com` / `admin123`
*   **Petugas**: `officer.rpl@smkn4bdg.sch.id` / `password`
*   **Siswa**: `student.rpl001@smkn4bdg.sch.id` / `password`

---
*Dibuat untuk memudahkan kolaborasi tim 4LLASET.*
