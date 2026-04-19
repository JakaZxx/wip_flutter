# 4LLASET System Credentials List

This document contains authentication information for various roles in the 4LLASET (Aplikasi Peminjaman Aset Jurusan) system.

## 🔑 Admin (Full Access)
These accounts have access to the administrative dashboard, user management, and global asset tracking.

| Name | Email | Default Password |
| :--- | :--- | :--- |
| Admin Aset | `admin@aset.com` | `admin123` |
| Admin Kedua | `ilham@aset.com` | `ilham123` |

---

## 🛡️ Officers (Department Staff)
These accounts are responsible for managing assets within their specific departments.

| Name | Email | Department | Default Password |
| :--- | :--- | :--- | :--- |
| Petugas TKJ | `officer@aset.com` | TKJ | `officer123` |
| Petugas DKV | `dkv@aset.com` | DKV | `dkv123` |
| officerrpl | `RPL@aset.com` | RPL | `password` |
| officerTOI | `officerTOI@aset.com` | TOI | `password` |

---

## 🎓 Students (Borrowers)
Sample accounts for testing the student borrowing flow.

| Name | Email / NIS | Default Password |
| :--- | :--- | :--- |
| Siswa Test | `siswa@aset.com` | `siswa123` |
| Siswa Dummy 1 | `siswa1_rpl3@example.com` | `password` |
| Siswa Dummy 2 | `siswa2_rpl3@example.com` | `password` |
| ... | (Siswa 3 to 33) | `password` |

---

## ⚡ Technical Support Notes
- **API Base URL**: `http://172.16.101.36:8000/api`
- **Asset Storage**: `http://172.16.101.36:8000`
- **Troubleshooting**:
    - If login fails with "Network Error", ensure the physical device is on the same Wi-Fi as the host machine (`172.16.101.36`).
    - Verify that `android:usesCleartextTraffic="true"` is set in `AndroidManifest.xml` (already implemented).
    - Ensure `php artisan serve --host=0.0.0.0` is running on the host machine.
