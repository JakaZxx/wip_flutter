# ASPAJ Project Learnings & Knowledge Base

This file tracks persistent learnings, common errors, and their fixes to maintain consistency across development sessions.

## Authentication & Authorization

### Email Verification
- **Issue**: Mandatory email verification was blocking student logins because no mail server was active.
- **Fix**: 
  - Backend: Set `MAIL_MAILER=log` in `.env`.
  - Frontend: Bypassed `email_verified_at` check in `AuthProvider.dart`.
- **Learning**: For local development, always use the `log` driver for mail to prevent connection timeouts/refusals.

### Student Login Identifiers
- **Issue**: Students could only log in via email, but they prefer using their NIS (Student ID).
- **Fix**: 
  - Backend: Updated `AuthController.php` to accept both `email` and `identitas` (NIS).
  - Frontend: Relaxed `EmailValidator` in `LoginScreen`.

## UI & Assets

### FontAwesome Integration
- **Issue**: Updating to `font_awesome_flutter` 11.0.0 caused type mismatches in components expecting `IconData` but receiving `FaIconData`.
- **Fix**: Refactored components (like `_StatCard` in `DashboardScreen`) to accept `dynamic` icons and handle `FaIcon` internally.

### Image Cropping (Web)
- **Issue**: `image_cropper` library throws "cropper is not initialized" on Flutter Web.
- **Fix**: Added `cropper.js` and `cropper.css` CDN links to `web/index.html`.
- **Learning**: Flutter packages with native JS dependencies often require manual asset injection in the host HTML for the web platform.

## Data Synchronization

### Cart Sync
- **Issue**: Cart changes in Flutter were not reflected in the Laravel Web UI.
- **Fix**: (In progress) verified that both API and Web use the `Cart` database model. Added logging to `PeminjamanController` to verify request flow.

## Database & Models

### Role Consistency
- **Issue**: Some backend logic used "students" while others used "student".
- **Fix**: Standardized on singular/plural based on context but ensure the UI handles plural string roles from the API.

## Business Logic & Workflows

### Partial Return Visibility
- **Issue**: The "Kembalikan" (Return) button was disappearing after the first item was returned because the borrowing status changed to `partially_returned`.
- **Fix**: Updated UI logic to base button visibility on the presence of ANY items with `approved` status, rather than the parent record's status alone.
- **Learning**: Avoid basing actionable UI states on high-level statuses while internal item states are still pending/in-progress.

### Role-Based Action Buttons
- **Issue**: Administrative roles (Admin/Officer) were unable to initiate returns in the Flutter app because action buttons were only enabled for students.
- **Fix**: Harmonized `_buildActionButtons` in `BorrowingCard` to support all management roles.

## Image & File Management

### Image Storage Paths
- **Issue**: Mismatch between controller storage paths (`public/uploads`) and model accessor expectations (`public/storage`).
- **Fix**: Standardized on Laravel `public` disk (`storage/app/public`). Updated accessors to check multiple paths for backward compatibility.
- **Learning**: Always use the `Storage` facade instead of `move()` to `public_path()` to ensure symlink compatibility and easier cloud migration.

### Flutter-Backend Upload Sync
- **Issue**: "Cropper is not initialized" errors in Flutter were fixed by script injection, but photos were still not appearing because the Backend `returnItem` API expected a file, while Flutter sent a path string (result of a separate pre-upload step).
- **Fix**: Updated the API to handle both `UploadedFile` objects and string paths.
- **Learning**: When using mobile-to-backend flows, decide early if uploads are bundled with the action or handled separately, and ensure the backend supports the chosen strategy.

---
*Updated on: 2026-04-12*
