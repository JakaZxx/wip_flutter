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

// Upload endpoint used by mobile/web clients to upload images/files.
// Returns JSON { "success": true, "path": "public/<relative_path>" }
Route::post('/upload', [UploadController::class, 'upload']);

Route::middleware('auth:sanctum')->get('/user', [UserController::class, 'profile']);
Route::middleware('auth:sanctum')->post('/user', [UserController::class, 'updateProfile']);

// Asset routes
Route::get('/assets', [AsetController::class, 'index']);
Route::post('/assets', [AsetController::class, 'store']);
Route::get('/assets/{id}', [AsetController::class, 'show']);
Route::put('/assets/{id}', [AsetController::class, 'update']);
Route::delete('/assets/{id}', [AsetController::class, 'destroy']);

// User routes
Route::get('/users', [UserController::class, 'index']);
Route::post('/users', [UserController::class, 'store']);
Route::put('/users/{id}', [UserController::class, 'update']);
Route::delete('/users/{id}', [UserController::class, 'destroy']);
Route::patch('/users/{id}/approve', [UserController::class, 'approve']);
Route::patch('/users/{id}/reject', [UserController::class, 'reject']);

// Auth routes
Route::post('/login', [AuthController::class, 'login']);

// School class routes
Route::get('/school-classes', [KelasController::class, 'index']);
Route::post('/school-classes', [KelasController::class, 'store']);
Route::put('/school-classes/{id}', [KelasController::class, 'update']);
Route::delete('/school-classes/{id}', [KelasController::class, 'destroy']);

Route::middleware('auth:sanctum')->group(function () {
    // Borrowing routes
    Route::get('/borrowings', [PeminjamanController::class, 'index']);
    Route::get('/borrowings/pending', [PeminjamanController::class, 'getPending']);
    Route::patch('/borrowings/{id}/status', [PeminjamanController::class, 'updateStatus']);
    Route::post('/borrowings/update-status', [PeminjamanController::class, 'updateStatus']);

    // Student routes
    Route::get('/student/dashboard-stats', [StudentController::class, 'dashboardStats']);
    Route::get('/student/active-borrowings', [StudentController::class, 'activeBorrowings']);
    Route::get('/student/recent-requests', [StudentController::class, 'recentRequests']);
    Route::get('/student/borrowing-history', [StudentController::class, 'borrowingHistory']);
    Route::get('/student/borrowings/{id}', [StudentController::class, 'showBorrowing']);

    // Commodities for borrowing
    Route::get('/commodities', [AsetController::class, 'commodities']);

    // Cart routes
    Route::get('/cart', [PeminjamanController::class, 'getCart']);
    Route::post('/cart', [PeminjamanController::class, 'saveCart']);
    Route::post('/cart/update', [PeminjamanController::class, 'updateCartItem']);
    Route::delete('/cart', [PeminjamanController::class, 'clearCart']);

    // Borrowing creation for students
    Route::post('/borrowings', [PeminjamanController::class, 'store']);

    // Borrowing detail and return for students
    Route::get('/borrowings/{id}', [PeminjamanController::class, 'show']);
    Route::post('/borrowings/{id}/return', [PeminjamanController::class, 'returnBorrowing']);
    Route::post('/borrowings/{borrowingId}/items/{itemId}/return', [PeminjamanController::class, 'returnItem']);
    Route::post('/borrowings/{id}/approve', [PeminjamanController::class, 'approve']);
    Route::post('/borrowings/{id}/reject', [PeminjamanController::class, 'reject']);
    Route::post('/borrowings/{id}/admin-return', [PeminjamanController::class, 'adminReturn']);

    // Dashboard routes
    Route::get('/admin/dashboard-stats', [AdminDashboardController::class, 'dashboardStats']);
    Route::get('/officer/dashboard-stats', [OfficerDashboardController::class, 'dashboardStats']);
});
