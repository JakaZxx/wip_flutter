<?php

namespace App\Http\Controllers;

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
    public function index()
    {
        $user = Auth::user();
        $jurusan = $user->jurusan ? strtolower(trim($user->jurusan)) : null;

        $activeBorrowingsCount = Borrowing::where('status', 'approved')
            ->whereHas('items.commodity', fn($q) => $q->where('jurusan', $jurusan))->count();

        $overdueBorrowingsCount = Borrowing::where('status', 'approved')->where('return_date', '<', now())
            ->whereHas('items.commodity', fn($q) => $q->where('jurusan', $jurusan))->count();

        $totalAssetsCount = Commodity::where('jurusan', $jurusan)->count();

        $pendingRequestsCount = Borrowing::where('status', 'pending')
            ->whereHas('items.commodity', fn($q) => $q->where('jurusan', $jurusan))->count();

        // 3. Data untuk Tabel Peminjaman Aktif (Aktivitas Terbaru)
        $recentActivities = Borrowing::with(['student.user', 'items.commodity'])
            ->whereHas('items.commodity', fn($q) => $q->where('jurusan', $jurusan))
            ->latest()->take(5)->get();

        // 4. Data untuk Permintaan Baru
        $newRequests = Borrowing::with(['student.user', 'items.commodity'])
            ->where('status', 'pending')
            ->whereHas('items.commodity', fn($q) => $q->where('jurusan', $jurusan))
            ->latest()->take(5)->get();

        // 5. Data untuk Reminder (Jatuh Tempo dalam 3 Hari)
        $dueSoonBorrowings = Borrowing::with('student.user')
            ->where('status', 'approved')
            ->where('return_date', '>', now())
            ->where('return_date', '<=', now()->addDays(3))
            ->whereHas('items.commodity', fn($q) => $q->where('jurusan', $jurusan))
            ->get();

        // 1. User Growth - total users in last 6 months filtered by jurusan
        $userGrowth = User::select(
            DB::raw("DATE_FORMAT(created_at, '%Y-%m') as month"),
            DB::raw('COUNT(*) as count')
        )
        ->where('jurusan', $jurusan)
        ->where('created_at', '>=', \Carbon\Carbon::now()->subMonths(6))
        ->groupBy('month')
        ->orderBy('month')
        ->get();

        // Prepare user growth data for chart
        $userGrowthLabels = [];
        $userGrowthData = [];
        $months = collect();
        for ($i = 5; $i >= 0; $i--) {
            $months->push(\Carbon\Carbon::now()->subMonths($i)->format('Y-m'));
        }
        foreach ($months as $month) {
            $userGrowthLabels[] = \Carbon\Carbon::createFromFormat('Y-m', $month)->format('M');
            $found = $userGrowth->firstWhere('month', $month);
            $userGrowthData[] = $found ? $found->count : 0;
        }

        // 2. Asset Distribution - total vs available by category (name) filtered by jurusan
        $assetDistributionTotal = Commodity::select('name', DB::raw('COUNT(*) as total'))
            ->where('jurusan', $jurusan)
            ->groupBy('name')
            ->get();

        $assetDistributionAvailable = Commodity::select('name', DB::raw('COUNT(*) as available'))
            ->where('jurusan', $jurusan)
            ->where('condition', 'available')
            ->groupBy('name')
            ->get();

        // Map available counts by name for easy lookup
        $availableMap = $assetDistributionAvailable->keyBy('name');

        $assetDistributionLabels = [];
        $assetDistributionTotalData = [];
        $assetDistributionAvailableData = [];

        foreach ($assetDistributionTotal as $item) {
            $assetDistributionLabels[] = $item->name;
            $assetDistributionTotalData[] = $item->total;
            $assetDistributionAvailableData[] = $availableMap->has($item->name) ? $availableMap[$item->name]->available : 0;
        }

        // 3. Borrowing Trend - borrowed vs returned in last 6 weeks filtered by jurusan
        $borrowedTrend = Borrowing::select(
            DB::raw("DATE_FORMAT(borrow_date, '%Y-%u') as week"),
            DB::raw('COUNT(*) as count')
        )
        ->where('borrow_date', '>=', \Carbon\Carbon::now()->subWeeks(6))
        ->whereHas('items.commodity', fn($q) => $q->where('jurusan', $jurusan))
        ->groupBy('week')
        ->orderBy('week')
        ->get();

        $returnedTrend = Borrowing::select(
            DB::raw("DATE_FORMAT(return_date, '%Y-%u') as week"),
            DB::raw('COUNT(*) as count')
        )
        ->where('return_date', '>=', \Carbon\Carbon::now()->subWeeks(6))
        ->whereHas('items.commodity', fn($q) => $q->where('jurusan', $jurusan))
        ->groupBy('week')
        ->orderBy('week')
        ->get();

        // Prepare borrowing trend data for chart
        $borrowTrendLabels = [];
        $borrowedData = [];
        $returnedData = [];
        $weeks = collect();
        for ($i = 5; $i >= 0; $i--) {
            $weeks->push(\Carbon\Carbon::now()->subWeeks($i)->format('Y-W'));
        }
        foreach ($weeks as $week) {
            $borrowTrendLabels[] = 'W' . explode('-', $week)[1];
            $foundBorrowed = $borrowedTrend->firstWhere('week', $week);
            $foundReturned = $returnedTrend->firstWhere('week', $week);
            $borrowedData[] = $foundBorrowed ? $foundBorrowed->count : 0;
            $returnedData[] = $foundReturned ? $foundReturned->count : 0;
        }

        // 4. Asset Status - summary of conditions filtered by jurusan
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

        return view('officers.dashboard', compact(
            'activeBorrowingsCount',
            'totalAssetsCount',
            'pendingRequestsCount',
            'overdueBorrowingsCount',
            'recentActivities',
            'newRequests',
            'dueSoonBorrowings',
            'userGrowthLabels',
            'userGrowthData',
            'assetDistributionLabels',
            'assetDistributionTotalData',
            'assetDistributionAvailableData',
            'borrowTrendLabels',
            'borrowedData',
            'returnedData',
            'assetStatus'
        ));
    }
}
