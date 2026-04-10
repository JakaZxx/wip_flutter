<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AdminAssetController;
use App\Http\Controllers\OfficerAssetController;
use App\Http\Controllers\ApprovalController;
use App\Http\Controllers\BorrowingRequestController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\SchoolClassControllerAdmin;
use App\Http\Controllers\SchoolClassControllerOfficers;
use App\Http\Controllers\AdminDashboardController;
use App\Http\Controllers\OfficerDashboardController;
use App\Http\Controllers\StudentDashboardController;
use App\Http\Controllers\ExportController;
use App\Http\Controllers\RegisterController;
use App\Http\Controllers\PasswordController;
use App\Http\Controllers\ImportController;
use App\Http\Controllers\BugReportController;
use App\Http\Controllers\StudentAssetController;
use App\Http\Controllers\CartController;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
*/

// Route untuk mengakses file storage secara langsung
Route::get('/storage/{path}', function($path) {
    $path = storage_path('app/public/' . $path);
    if (!File::exists($path)) {
        abort(404);
    }
    return response()->file($path, [
        'Cache-Control' => 'public, max-age=3600',
        'Access-Control-Allow-Origin' => '*'
    ]);
})->where('path', '.*');

// Halaman Utama
Route::get('/', function () {
    return view('welcome');
});

// Login & Logout (Berlaku untuk semua role)
Route::get('/login', [AuthController::class, 'showLoginForm'])->name('login');
Route::post('/login', [AuthController::class, 'login'])->name('login.submit');
Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

// Register for Officers
Route::get('/register', [RegisterController::class, 'showRegistrationForm'])->name('register');
Route::post('/register', [RegisterController::class, 'register'])->name('register.submit');

// Password Change
Route::get('/password/change', [PasswordController::class, 'showChangeForm'])->name('password.change.form')->middleware('auth');
Route::post('/password/change', [PasswordController::class, 'change'])->name('password.change')->middleware('auth');

// Forgot Password
Route::get('/forgot-password', [PasswordController::class, 'showForgotForm'])->name('password.forgot.form');
Route::post('/forgot-password', [PasswordController::class, 'sendResetLink'])->name('password.forgot');

// Reset Password
Route::get('/reset-password/{token}', [PasswordController::class, 'showResetForm'])->name('password.reset.form');
Route::post('/reset-password', [PasswordController::class, 'reset'])->name('password.reset');

// Email Verification
Route::get('/email/verify', [AuthController::class, 'showEmailVerificationForm'])->name('verification.notice');
use App\Http\Controllers\CustomVerificationController;

Route::get('/email/verify/{id}/{hash}', [CustomVerificationController::class, 'verify'])
    ->middleware(['signed'])
    ->name('verification.verify');
Route::post('/email/verification-notification', [AuthController::class, 'resendVerification'])->name('verification.send');

// Profile Routes (accessible to all authenticated users)
Route::get('/profile', [UserController::class, 'profile'])->name('profile')->middleware('auth');
Route::post('/profile', [UserController::class, 'updateProfile'])->name('profile.update')->middleware('auth');
Route::delete('/profile/picture', [UserController::class, 'deleteProfilePicture'])->name('profile.picture.delete')->middleware('auth');

// Profile Photo Routes
use App\Http\Controllers\ProfilePhotoController;
Route::post('/profile/photo/upload', [ProfilePhotoController::class, 'uploadNewPhoto'])->name('profile.photo.upload')->middleware('auth');
Route::delete('/profile/photo', [ProfilePhotoController::class, 'deletePhoto'])->name('profile.photo.delete')->middleware('auth');

// Bug Report Routes (accessible to all authenticated users)
Route::get('/bug-report', [BugReportController::class, 'showForm'])->name('bugreport.form')->middleware('auth');
Route::post('/bug-report', [BugReportController::class, 'submitForm'])->name('bugreport.submit')->middleware('auth');

// Notification Routes (accessible to all authenticated users)
Route::middleware(['auth'])->group(function () {
    Route::get('/notifications', [NotificationController::class, 'index'])->name('notifications.index');
    Route::post('/notifications/{id}/mark-as-read', [NotificationController::class, 'markAsRead'])->name('notifications.markAsRead');
});

/*
|--------------------------------------------------------------------------
| Admin Routes
|--------------------------------------------------------------------------
*/
Route::prefix('admin')->middleware(['auth', 'admin'])->group(function () {

    // Dashboard
    Route::get('/dashboard', [AdminDashboardController::class, 'index'])->name('admin.dashboard');
    Route::get('/export/excel', [AdminDashboardController::class, 'exportExcel'])->name('admin.export.excel');
    Route::get('/export/pdf', [AdminDashboardController::class, 'exportPDF'])->name('admin.export.pdf');

    // Assets Management
    Route::get('/assets', [AdminAssetController::class, 'index'])->name('admin.assets.index');
    Route::get('/assets/select-jurusan', [AdminAssetController::class, 'selectJurusan'])->name('admin.assets.selectJurusan');
    Route::get('/assets/create', [AdminAssetController::class, 'create'])->name('admin.assets.create');
    Route::post('/assets', [AdminAssetController::class, 'store'])->name('admin.assets.store');
    Route::get('/assets/{id}/edit', [AdminAssetController::class, 'edit'])->name('admin.assets.edit');
    Route::put('/assets/{id}', [AdminAssetController::class, 'update'])->name('admin.assets.update');
    Route::delete('/assets/{id}', [AdminAssetController::class, 'destroy'])->name('admin.assets.destroy');
    Route::get('/assets/{id}/detail', [AdminAssetController::class, 'detail'])->name('admin.assets.detail');

    // Borrowings Approval
    Route::get('/borrowings', [ApprovalController::class, 'index'])->name('admin.borrowings.index');
    Route::get('/borrowings/data', [ApprovalController::class, 'indexData'])->name('admin.borrowings.data');
    Route::post('/borrowings/{id}/approve', [ApprovalController::class, 'approve'])->name('borrowings.approve.admin');
    Route::post('/borrowings/{id}/reject', [ApprovalController::class, 'reject'])->name('borrowings.reject.admin');
    Route::post('/borrowings/{id}/return', [ApprovalController::class, 'return'])->name('borrowings.return.admin');
    Route::get('/borrowings/history', [ApprovalController::class, 'history'])->name('borrowings.history.admin');

    // Commodities
    Route::get('/commodities', [AdminAssetController::class, 'index'])->name('commodities.index');

    // Borrowing Request
    Route::get('/request/borrowings', [BorrowingRequestController::class, 'create'])->name('borrowing.request.create');
    Route::post('/request/borrowings', [BorrowingRequestController::class, 'store'])->name('borrowing.request.store');

    // User Management
    Route::resource('users', UserController::class);
    Route::patch('/users/{user}/approve', [UserController::class, 'approve'])->name('users.approve');
    Route::patch('/users/{user}/reject', [UserController::class, 'reject'])->name('users.reject');

    // Password Reset for Users
    Route::post('/users/{user}/reset-password', [PasswordController::class, 'adminReset'])->name('admin.users.reset-password');

    // Import Data
    Route::post('/import/users', [ImportController::class, 'importUsers'])->name('admin.import.users');
    Route::post('/import/assets', [ImportController::class, 'importAssets'])->name('admin.import.assets');
    Route::post('/import/classes-students', [ImportController::class, 'importClassesStudents'])->name('admin.import.classes-students');

    Route::post('/import/classes', [ImportController::class, 'importClasses'])->name('admin.import.classes');
    Route::post('/import/classes/{schoolClass}/students', [ImportController::class, 'importStudents'])->name('admin.import.students');

    // School Class Management
    Route::get('/classes', [SchoolClassControllerAdmin::class, 'index'])->name('admin.classes.index');
    Route::get('/classes/create', [SchoolClassControllerAdmin::class, 'create'])->name('admin.classes.create');
    Route::post('/classes', [SchoolClassControllerAdmin::class, 'store'])->name('admin.classes.store');
    Route::get('/classes/{schoolClass}/edit', [SchoolClassControllerAdmin::class, 'edit'])->name('admin.classes.edit');
    Route::put('/classes/{schoolClass}', [SchoolClassControllerAdmin::class, 'update'])->name('admin.classes.update');
    Route::delete('/classes/{schoolClass}', [SchoolClassControllerAdmin::class, 'destroy'])->name('admin.classes.destroy');
});

/*
|--------------------------------------------------------------------------
| Student Routes
|--------------------------------------------------------------------------
*/
Route::prefix('students')->middleware(['auth', 'students', 'must.change.password', 'verified.email'])->group(function () {
    Route::get('/dashboard', [StudentDashboardController::class, 'index'])->name('students.dashboard');
    Route::get('/request/borrowings', [BorrowingRequestController::class, 'create'])->name('borrowing.request.create.student');
    Route::post('/request/borrowings', [BorrowingRequestController::class, 'store'])->name('borrowing.request.store.student');
    Route::get('/borrowings/status', [BorrowingRequestController::class, 'studentIndex'])->name('students.borrowings.index');
    Route::get('/borrowings/{id}', [BorrowingRequestController::class, 'studentShow'])->name('students.borrowings.show');

    // Student Assets View
    Route::get('/assets', [StudentAssetController::class, 'index'])->name('students.assets.index');
    Route::get('/assets/data', [StudentAssetController::class, 'getAssetsData'])->name('students.assets.data');
    Route::get('/assets/select-jurusan', [StudentAssetController::class, 'selectJurusan'])->name('students.assets.selectJurusan');

    // Student Return Routes
    Route::get('/students/borrowings/{id}/return', [BorrowingRequestController::class, 'returnForm'])->name('students.borrowings.return.form');
    Route::patch('/students/borrowings/{id}/return', [BorrowingRequestController::class, 'processReturn'])->name('students.borrowings.return.process');
    Route::get('/borrowings/return/{itemId}', [BorrowingRequestController::class, 'returnItemForm'])->name('students.borrowings.return.item');
    Route::patch('/borrowings/return/{itemId}', [BorrowingRequestController::class, 'processReturnItem'])->name('students.borrowings.return.item.process');
});

/*
|--------------------------------------------------------------------------
| Officer Routes
|--------------------------------------------------------------------------
*/
Route::prefix('officers')->middleware(['auth', 'officers'])->group(function () {
    Route::get('/dashboard', [OfficerDashboardController::class, 'index'])->name('officers.dashboard');
    Route::get('/request/borrowings', [BorrowingRequestController::class, 'create'])->name('borrowing.request.create.officers');
    Route::post('/request/borrowings', [BorrowingRequestController::class, 'store'])->name('borrowing.request.store.officers');
    Route::get('/assets', [OfficerAssetController::class, 'index'])->name('officers.assets.index');
    // Route::get('/assets/select-jurusan', [OfficerAssetController::class, 'selectJurusan'])->name('officers.assets.selectJurusan');
    Route::get('/assets/create', [OfficerAssetController::class, 'create'])->name('officers.assets.create');
    Route::post('/assets', [OfficerAssetController::class, 'store'])->name('officers.assets.store');
    Route::get('/assets/{id}/edit', [OfficerAssetController::class, 'edit'])->name('officers.assets.edit');
    Route::put('/assets/{id}', [OfficerAssetController::class, 'update'])->name('officers.assets.update');
    Route::delete('/assets/{id}', [OfficerAssetController::class, 'destroy'])->name('officers.assets.destroy');
    Route::get('/assets/{id}/detail', [OfficerAssetController::class, 'detail'])->name('officers.assets.detail');
    // Officer-specific routes bisa ditambah di sini

    // Borrowings Approval for Officers
    Route::get('/borrowings', [ApprovalController::class, 'index'])->name('officers.borrowings.index');
    Route::get('/borrowings/data', [ApprovalController::class, 'indexData'])->name('officers.borrowings.data');
    Route::post('/borrowings/{id}/approve', [ApprovalController::class, 'approve'])->name('borrowings.approve');
    Route::post('/borrowings/{id}/reject', [ApprovalController::class, 'reject'])->name('borrowings.reject');
    Route::post('/borrowings/{id}/return', [ApprovalController::class, 'return'])->name('borrowings.return');
    Route::get('/borrowings/history', [ApprovalController::class, 'history'])->name('borrowings.history');
    Route::get('/my-borrowings', [BorrowingRequestController::class, 'officerIndex'])->name('officers.borrowings.my');
    Route::get('/borrowings/{id}', [BorrowingRequestController::class, 'officerShow'])->name('officers.borrowings.show');
    Route::get('/borrowings/return/{itemId}', [BorrowingRequestController::class, 'returnItemForm'])->name('officers.borrowings.return.item');
    Route::patch('/borrowings/return/{itemId}', [BorrowingRequestController::class, 'processReturnItem'])->name('officers.borrowings.return.item.process');

    // School Class Management
    Route::get('/classes', [SchoolClassControllerOfficers::class, 'index'])->name('officers.classes.index');
    Route::get('/classes/create', [SchoolClassControllerOfficers::class, 'create'])->name('officers.classes.create');
    Route::post('/classes', [SchoolClassControllerOfficers::class, 'store'])->name('officers.classes.store');
    Route::get('/classes/{schoolClass}/edit', [SchoolClassControllerOfficers::class, 'edit'])->name('officers.classes.edit');
    Route::put('/classes/{schoolClass}', [SchoolClassControllerOfficers::class, 'update'])->name('officers.classes.update');
    Route::delete('/classes/{schoolClass}', [SchoolClassControllerOfficers::class, 'destroy'])->name('officers.classes.destroy');

    // Import Data
    Route::post('/import/assets', [ImportController::class, 'importAssets'])->name('officers.import.assets');
    Route::post('/import/classes', [ImportController::class, 'importClasses'])->name('officers.import.classes');
    Route::post('/import/classes/{schoolClass}/students', [ImportController::class, 'importStudents'])->name('officers.import.students');
});

/*
|--------------------------------------------------------------------------
| Cart Routes
|--------------------------------------------------------------------------
*/
Route::middleware(['auth'])->group(function () {
    Route::get('/cart', [CartController::class, 'index'])->name('cart.index');
    Route::get('/cart/checkout', [CartController::class, 'checkout'])->name('cart.checkout');
    Route::post('/cart/add', [CartController::class, 'addItem'])->name('cart.add');
    Route::post('/cart/update', [CartController::class, 'updateItem'])->name('cart.update');
    Route::post('/cart/remove', [CartController::class, 'removeItem'])->name('cart.remove');
    Route::post('/cart/clear', [CartController::class, 'clear'])->name('cart.clear');
    Route::get('/cart/summary', [CartController::class, 'getCartSummary'])->name('cart.summary');
});
