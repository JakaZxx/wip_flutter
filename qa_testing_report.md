# 🛡️ ASPAJ QA/Testing & Bug Fix Report

This document summarizes the quality assurance activities, testing results, and critical bug fixes implemented during the development and stability refinement of the **ASPAJ (Aplikasi Peminjaman Aset Jurusan)** system.

---

## 📈 Testing Overview

| Phase | Methodology | Status | Result |
| :--- | :--- | :--- | :--- |
| **Authentication** | Manual & Automated | ✅ Passed | Fixed 500 errors and layout crashes for guests. |
| **Borrowing Workflow** | End-to-End Cycle | ✅ Passed | Supports multi-item selection, approval, and rejection. |
| **Return Management** | Granular Checklist | ✅ Passed | Supports partial returns with visual validation. |
| **Mobile Integration** | Physical Device Test | ✅ Passed | Resolved IP connectivity and native Android crashes. |
| **Asset Visualization** | Multi-Platform Sync | ✅ Passed | High-quality assets displayed across Web & Mobile. |

---

## 🐛 Resolved Bug Log

### 1. Critical Backend Stability
- **Issue**: 500 Internal Server Error on Registration and Login pages.
- **Root Cause**: Sidebar and user profile components attempted to access `Auth::user()` properties without checking if a user was logged in.
- **Fix**: Wrapped unauthenticated-sensitive layout blocks in `@auth` directives in `layouts/app.blade.php`.

### 2. Multi-Item Visibility Bug
- **Issue**: Officer/Admin dashboard only showed 1 unit even if a student borrowed multiple different assets.
- **Fix**: Removed restrictive client-side filtering and updated the rendering logic in `borrowing_detail_screen.dart` to display the full list of `borrowing_items`.

### 3. "Stuck" Pending Status
- **Issue**: If one item in a multi-item request was approved, the other "pending" items became inaccessible, blocking the workflow.
- **Fix**: Refactored `PeminjamanController.php` (Laravel) to unify status transition logic. Statuses are now calculated dynamically based on the state of all child items (e.g., `partially_returned`).

### 4. Selective Return Workflow
- **Issue**: Returning items was an "all or nothing" action; students couldn't return just one item from a group.
- **Fix**: Implemented a checklist system in Flutter's `ReturnScreen`. Added the `returnBorrowingItem` API endpoint support for granular item-level processing.

### 5. Android "Force Close" Crash
- **Issue**: Application crashed immediately when students attempted to take/attach a photo.
- **Root Cause**: Missing `CAMERA` and `READ_EXTERNAL_STORAGE` permissions in the Manifest; missing `UCropActivity` declaration for `image_cropper`.
- **Fix**: Updated `AndroidManifest.xml` with all necessary permissions and activity declarations.

### 6. Theme Incompatibility
- **Issue**: `image_cropper` plugin failed to launch its UI on some Android versions.
- **Root Cause**: The app used system native themes instead of the required `Theme.AppCompat`.
- **Fix**: Updated `res/values/styles.xml` and `res/values-night/styles.xml` to inherit from `Theme.AppCompat.Light.NoActionBar`.

### 7. Mobile API Connectivity
- **Issue**: App could not connect to the backend when running on a physical phone.
- **Fix**: Updated `ApiService.dart` to use the computer's local IP (`172.16.101.36`) and configured Laravel to listen on `0.0.0.0`.

### 8. Image Sync & Broken Links
- **Issue**: Assets showed broken placeholders or generic icons on both platforms.
- **Fix**: Generated 4 professional product photos, linked them via the Laravel storage symlink, and updated the database paths to ensure seamless rendering.

---

## 🛠️ Environment Configuration (Current Stable)

> [!IMPORTANT]
> To maintain stability, ensure the following settings are active:

- **Laravel Host**: `php artisan serve --host=0.0.0.0`
- **Flutter API Base**: `172.16.101.36` (in `lib/services/api_service.dart`)
- **Android MinSDK**: 21 (required for modern plugins)
- **App Theme**: `Theme.AppCompat` (in `AndroidManifest.xml`)

---

## 🏁 Final Sign-off
**Testing Conclusion**: The core borrowing lifecycle (Pinjam -> Approve -> Return) is now functionally robust and stable across both Web and Android platforms. Connectivity issues and native crashes have been eliminated.

**Date**: April 14, 2026
**QA Lead**: Antigravity AI Engine
