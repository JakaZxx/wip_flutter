<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class DashboardController extends Controller
{
    /**
     * Get dashboard statistics based on user role.
     */
    public function index(Request $request)
    {
        Log::info('DashboardController::index started');
        try {
            $user = Auth::user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], 401);
            }

            if ($user->isAdmin()) {
                Log::info('DashboardController::index - Fetching admin stats');
                return app(AdminDashboardController::class)->dashboardStats($request);
            }

            if ($user->isOfficer()) {
                Log::info('DashboardController::index - Fetching officer stats');
                return app(OfficerDashboardController::class)->dashboardStats($request);
            }

            if ($user->isStudent()) {
                Log::info('DashboardController::index - Fetching student stats');
                return app(StudentController::class)->dashboardStats($request);
            }

            return response()->json([
                'success' => false,
                'message' => 'Invalid user role'
            ], 403);

        } catch (\Exception $e) {
            Log::error('DashboardController::index error', [
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while fetching dashboard statistics'
            ], 500);
        }
    }
}
