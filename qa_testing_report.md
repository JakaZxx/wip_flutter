# 🛡️ ASPAJ QA/Testing & Bug Fix Report

This document summarizes the quality assurance activities, testing results, and critical bug fixes implemented during the development and stability refinement of the **ASPAJ (Aplikasi Peminjaman Aset Jurusan)** system.

---

## 📈 Testing Overview

| Phase | Methodology | Status | Result |
| :--- | :--- | :--- | :--- |
| **Authentication** | Multi-Table Mocking | ✅ Passed | Separated Users (Admin/Officer) and Students tables. |
| **Department Filtering**| Cross-Table Check | ✅ Passed | RPL/TKJ chips now map correctly to full names in DB. |
| **Media Management** | Native XHR Upload | ✅ Passed | Profile uploads fixed with 5MB limit and path resolution. |
| **UX Alignment** | Adaptive UI Audit | ✅ Passed | Redesigned Bug Report page and Activity Logs. |

---

## 🐛 Resolved Bug Log (Phase 2 Revision)

### 1. Architectural Restructuring (Auth Split)
- **Issue**: Admin, Officer, and Student roles were sharing a single table, causing data clutter and authentication confusion.
- **Root Cause**: Poor database normalization for a multi-tenant school environment.
- **Fix**: 
    - Isolated `students` into a dedicated table with independent authentication credentials.
    - Updated `AuthController` to perform multi-table cascading login (checks `users`, then `students`).
    - Upgraded `Student` model to implement `Authenticatable`.

### 2. Asset Filtering (RPL/Jurusan)
- **Issue**: Filtering by "RPL" in the Admin panel returned no results even if data existed.
- **Root Cause**: Inconsistency between frontend chip labels ("RPL") and backend department strings ("Rekayasa Perangkat Lunak").
- **Fix**: Implemented a normalization mapping in `AssetsScreen.dart` that handles partial string matching and department aliases.

### 3. Profile Photo Upload Failures
- **Issue**: Uploading profile pictures failed or didn't persist correctly across different user roles.
- **Fix**: 
    - Refactored `UserController@updateProfile` to handle both `User` and `Student` model instances.
    - Increased upload limit to 5MB and implemented automatic old-file cleanup using Laravel `Storage` facade.
    - Standardized path resolution in `ApiService.dart` and model accessors.

### 4. Activity Log Synchronization (Dashboard)
- **Issue**: The "Activity Log" button in the admin dashboard was just a placeholder showing a "Syncing..." message.
- **Fix**: Created a dedicated `ActivityLogScreen` in Flutter that fetches real-time borrowing history and presents it as a system audit trail.

### 5. Alignment & Layout Polishing
- **Issue**: The shopping cart icon in `AssetsScreen` was vertically unaligned; "Laporan Masalah" page looked inconsistent.
- **Fix**: 
    - Redesigned `HelpSupportScreen` with a premium CustomScrollView layout, Google Fonts, and FontAwesome integration.
    - Standardized cart icon centering in the AppBar using a standard IconButton-Stack pattern.

---

## 🛠️ Environment Configuration (Current Stable)

> [!IMPORTANT]
> To maintain stability, ensure the following settings are active:

- **Laravel Host**: `php artisan serve --host=0.0.0.0`
- **Flutter API Base**: `192.168.1.11` (Updated for latest local network environment)
- **Database**: `db_asetkejuruan` (MySQL)
- **Student Auth**: NIS or Email + Password

---

## 🔑 Credential Standards (Operational)

- **Admin**: `admin@aset.com` / `password`
- **Officer RPL**: `rpl@officer.com` / `password`
- **Officer DKV**: `dkv@officer.com` / `password`
- **Officer TOI**: `toi@officer.com` / `password`
- **Officer TKJ**: `tj@officer.com` / `password`

---

## 🏁 Final Sign-off
**Testing Conclusion**: The system architecture has been significantly modernized. Multi-table authentication is stable, asset filtering is accurate, and the user experience has been elevated with premium UI designs and functional activity logs.

**Last Updated**: April 17, 2026
**QA Lead**: Antigravity AI Engine
