<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Commodity;
use App\Models\Borrowing;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

class AdminDashboardController extends Controller
{
    public function dashboardStats(Request $request)
    {
        \Log::info('AdminDashboardController::dashboardStats started');
        try {
            // Basic statistics
            $totalUsers = User::count();
            $totalAssets = Commodity::count();
            $pendingUsersCount = User::where('approval_status', 'pending')->count();
            $totalBorrowings = Borrowing::count();

            // Active borrowings (approved)
            $activeBorrowings = Borrowing::where('status', 'approved')->count();

            // Pending approvals
            $pendingApprovals = Borrowing::where('status', 'pending')->count();

            // Recent users needing approval
            $recentUsers = User::where('approval_status', 'pending')
                ->latest()
                ->take(5)
                ->get(['id', 'name', 'email', 'role', 'created_at']);

            // Asset status summary
            $assetStatusCounts = Commodity::select('condition', DB::raw('COUNT(*) as count'))
                ->groupBy('condition')
                ->get()
                ->keyBy('condition');

            $assetStatus = [
                'available' => $assetStatusCounts->has('available') ? $assetStatusCounts['available']->count : 0,
                'borrowed' => $assetStatusCounts->has('borrowed') ? $assetStatusCounts['borrowed']->count : 0,
                'maintenance' => $assetStatusCounts->has('maintenance') ? $assetStatusCounts['maintenance']->count : 0,
                'damaged' => $assetStatusCounts->has('damaged') ? $assetStatusCounts['damaged']->count : 0,
            ];

            // Recent borrowings
            $recentBorrowings = Borrowing::with('student.user', 'items.commodity')
                ->latest()
                ->take(5)
                ->get();

            \Log::info('AdminDashboardController::dashboardStats ended');
            return response()->json([
                'success' => true,
                'message' => 'Admin dashboard statistics retrieved successfully',
                'data' => [
                    'total_users' => $totalUsers,
                    'total_assets' => $totalAssets,
                    'pending_users_count' => $pendingUsersCount,
                    'total_borrowings' => $totalBorrowings,
                    'active_borrowings_count' => $activeBorrowings,
                    'pending_approvals_count' => $pendingApprovals,
                    'asset_status' => $assetStatus,
                    'recent_users' => $recentUsers,
                    'recent_borrowings' => $recentBorrowings,
                    // Placeholders for chart data if not yet implemented
                    'user_growth' => [
                        'labels' => [],
                        'data' => [],
                    ],
                    'rejected_borrowings_count' => \App\Models\Borrowing::where('status', 'rejected')->count(),
                    'returned_borrowings_count' => \App\Models\Borrowing::where('status', 'returned')->count(),
                ]
            ]);
        } catch (\Exception $e) {
            \Log::error('AdminDashboardController::dashboardStats error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            \Log::error('AdminDashboardController::dashboardStats ended with error');
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while fetching admin dashboard stats'
            ], 500);
        }
    }
}
