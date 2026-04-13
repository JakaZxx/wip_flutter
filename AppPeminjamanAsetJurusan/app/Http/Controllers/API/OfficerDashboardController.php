<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Commodity;
use App\Models\Borrowing;
use App\Models\Student;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class OfficerDashboardController extends Controller
{
    public function dashboardStats(Request $request)
    {
        \Log::info('OfficerDashboardController::dashboardStats started');
        try {
            $user = Auth::user();
            $jurusan = $user->jurusan ? strtolower(trim($user->jurusan)) : null;

            // Basic statistics filtered by jurusan
            $activeBorrowingsCount = Borrowing::where('status', 'approved')
                ->whereHas('items.commodity', fn($q) => $q->where('jurusan', $jurusan))
                ->count();

            $overdueBorrowingsCount = Borrowing::where('status', 'approved')
                ->where('return_date', '<', now())
                ->whereHas('items.commodity', fn($q) => $q->where('jurusan', $jurusan))
                ->count();

            $totalAssetsCount = Commodity::where('jurusan', $jurusan)->count();

            $pendingRequestsCount = Borrowing::where('status', 'pending')
                ->whereHas('items.commodity', fn($q) => $q->where('jurusan', $jurusan))
                ->count();

            // Approved today
            $approvedToday = Borrowing::where('status', 'approved')
                ->whereDate('updated_at', Carbon::today())
                ->whereHas('items.commodity', fn($q) => $q->where('jurusan', $jurusan))
                ->count();

            // Total borrowings for jurusan
            $totalBorrowings = Borrowing::whereHas('items.commodity', fn($q) => $q->where('jurusan', $jurusan))
                ->count();

            // Asset status summary filtered by jurusan
            $assetStatusCounts = Commodity::select('condition', DB::raw('COUNT(*) as count'))
                ->where('jurusan', $jurusan)
                ->groupBy('condition')
                ->get()
                ->keyBy('condition');

            $assetStatus = [
                'available' => $assetStatusCounts->has('available') ? $assetStatusCounts['available']->count : 0,
                'borrowed' => $assetStatusCounts->has('borrowed') ? $assetStatusCounts['borrowed']->count : 0,
                'maintenance' => $assetStatusCounts->has('maintenance') ? $assetStatusCounts['maintenance']->count : 0,
                'damaged' => $assetStatusCounts->has('damaged') ? $assetStatusCounts['damaged']->count : 0,
            ];

            // Recent activities
            $recentActivities = Borrowing::with(['student.user', 'items.commodity'])
                ->whereHas('items.commodity', fn($q) => $q->where('jurusan', $jurusan))
                ->latest()
                ->take(5)
                ->get();

            // New requests
            $newRequests = Borrowing::with(['student.user', 'items.commodity'])
                ->where('status', 'pending')
                ->whereHas('items.commodity', fn($q) => $q->where('jurusan', $jurusan))
                ->latest()
                ->take(5)
                ->get();

            // Due soon (within 3 days)
            $dueSoonBorrowings = Borrowing::with('student.user')
                ->where('status', 'approved')
                ->where('return_date', '>', now())
                ->where('return_date', '<=', now()->addDays(3))
                ->whereHas('items.commodity', fn($q) => $q->where('jurusan', $jurusan))
                ->get();

            \Log::info('OfficerDashboardController::dashboardStats ended');
            return response()->json([
                'success' => true,
                'message' => 'Officer dashboard statistics retrieved successfully',
                'data' => [
                    'active_borrowings_count' => $activeBorrowingsCount,
                    'overdue_borrowings_count' => $overdueBorrowingsCount,
                    'total_assets' => $totalAssetsCount,
                    'pending_requests_count' => $pendingRequestsCount,
                    'approved_today' => $approvedToday,
                    'total_borrowings' => $totalBorrowings,
                    'asset_status' => $assetStatus,
                    'recent_activities' => $recentActivities,
                    'new_requests' => $newRequests->map(function($b) {
                        return [
                            'student_name' => $b->student->user->name ?? 'Student',
                            'items_summary' => $b->items->map(fn($i) => ($i->commodity->name ?? 'Item') . ' (x' . $i->quantity . ')')->implode(', '),
                        ];
                    }),
                    'rejected_borrowings_count' => Borrowing::where('status', 'rejected')
                        ->whereHas('items.commodity', fn($q) => $q->where('jurusan', $jurusan))
                        ->count(),
                    'returned_borrowings_count' => Borrowing::where('status', 'returned')
                        ->whereHas('items.commodity', fn($q) => $q->where('jurusan', $jurusan))
                        ->count(),
                    'due_soon' => $due_soon_borrowings,
                ]
            ]);
        } catch (\Exception $e) {
            \Log::error('OfficerDashboardController::dashboardStats error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            \Log::error('OfficerDashboardController::dashboardStats ended with error');
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while fetching officer dashboard stats'
            ], 500);
        }
    }
}
