<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AdminAssetController;
use App\Http\Controllers\OfficerAssetController;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\AsetController;
use App\Http\Controllers\API\UserController;
use App\Http\Controllers\API\PeminjamanController;
use App\Http\Controllers\API\KelasController;
use App\Http\Controllers\API\StudentController;
use App\Http\Controllers\API\AdminDashboardController;
use App\Http\Controllers\API\OfficerDashboardController;
use App\Http\Controllers\API\DashboardController;
use Illuminate\Support\Facades\File;
use App\Http\Controllers\API\UploadController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

// Public storage access route - must be outside auth middleware
Route::get('/public-storage/{path}', function ($path) {
    $filePath = storage_path('app/public/' . $path);
    if (!file_exists($filePath)) {
        abort(404);
    }
    return response()->file($filePath, [
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET, OPTIONS',
        'Access-Control-Allow-Headers' => 'Origin, Content-Type, Accept',
    ]);
})->where('path', '.*');

// Auth routes
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    // Current user profile
    Route::get('/user', [UserController::class, 'profile']);
    Route::post('/user', [UserController::class, 'updateProfile']);

    // Admin & Officer shared routes
    Route::middleware(['admin'])->group(function () {
        // User management (Admin only)
        Route::get('/users', [UserController::class, 'index']);
        Route::post('/users', [UserController::class, 'store']);
        Route::put('/users/{id}', [UserController::class, 'update']);
        Route::delete('/users/{id}', [UserController::class, 'destroy']);
        Route::patch('/users/{id}/approve', [UserController::class, 'approve']);
        Route::patch('/users/{id}/reject', [UserController::class, 'reject']);

        // Dashboard stats for admin
        Route::get('/admin/dashboard-stats', [AdminDashboardController::class, 'dashboardStats']);
    });

    // Shared Management (Admin or Officer)
    // Note: If no staff middleware exists, we apply both separately or check in controllers.
    // Since we only have IsAdmin and IsOfficer, I will use a custom closure for Staff if needed,
    // but for now, I'll protect them with a loose check or rely on the Controller's existing logic.
    // Looking at the controllers, they already have $user->isOfficer() checks.
    // So protecting with auth:sanctum is the primary step.

    // Asset management
    Route::get('/assets', [AsetController::class, 'index']);
    Route::post('/assets', [AsetController::class, 'store']);
    Route::get('/assets/{id}', [AsetController::class, 'show']);
    Route::put('/assets/{id}', [AsetController::class, 'update']);
    Route::delete('/assets/{id}', [AsetController::class, 'destroy']);

    // School class routes
    Route::get('/school-classes', [KelasController::class, 'index']);
    Route::post('/school-classes', [KelasController::class, 'store']);
    Route::put('/school-classes/{id}', [KelasController::class, 'update']);
    Route::delete('/school-classes/{id}', [KelasController::class, 'destroy']);

    // Dashboard statistics (general)
    Route::get('/dashboard', [DashboardController::class, 'index']);
    Route::get('/officer/dashboard-stats', [OfficerDashboardController::class, 'dashboardStats']);

    // Upload endpoint
    Route::post('/upload', [UploadController::class, 'upload']);

    // Borrowing routes
    Route::get('/borrowings', [PeminjamanController::class, 'index']);
    Route::get('/borrowings/pending', [PeminjamanController::class, 'getPending']);
    Route::patch('/borrowings/{id}/status', [PeminjamanController::class, 'updateStatus']);
    Route::post('/borrowings/update-status', [PeminjamanController::class, 'updateStatus']);

    // Student specific routes
    Route::middleware(['students'])->group(function () {
        Route::get('/student/dashboard-stats', [StudentController::class, 'dashboardStats']);
        Route::get('/student/active-borrowings', [StudentController::class, 'activeBorrowings']);
        Route::get('/student/recent-requests', [StudentController::class, 'recentRequests']);
        Route::get('/student/borrowing-history', [StudentController::class, 'borrowingHistory']);
        Route::get('/student/borrowings/{id}', [StudentController::class, 'showBorrowing']);

        // Cart routes
        Route::get('/cart', [PeminjamanController::class, 'getCart']);
        Route::post('/cart', [PeminjamanController::class, 'saveCart']);
        Route::post('/cart/update', [PeminjamanController::class, 'updateCartItem']);
        Route::delete('/cart', [PeminjamanController::class, 'clearCart']);

        // Borrowing creation
        Route::post('/borrowings', [PeminjamanController::class, 'store']);
    });

    // Shared Borrowing Detail/Actions
    Route::get('/commodities', [AsetController::class, 'commodities']);
    Route::get('/borrowings/{id}', [PeminjamanController::class, 'show']);
    Route::post('/borrowings/{id}/return', [PeminjamanController::class, 'returnBorrowing']);
    Route::post('/borrowings/{borrowingId}/items/{itemId}/return', [PeminjamanController::class, 'returnItem']);
    Route::post('/borrowings/{id}/approve', [PeminjamanController::class, 'approve']);
    Route::post('/borrowings/{id}/reject', [PeminjamanController::class, 'reject']);
    Route::post('/borrowings/{id}/admin-return', [PeminjamanController::class, 'adminReturn']);
});
